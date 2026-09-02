package com.kisaanconnect.dao;

import com.kisaanconnect.model.Order;
import com.kisaanconnect.model.OrderItem;
import com.kisaanconnect.model.SubOrder;
import com.kisaanconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;

public class OrderDAO {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    /**
     * State machine validation for Farmer Sub-Orders.
     * PLACED -> ACCEPTED, CANCELLED, REJECTED
     * ACCEPTED -> READY_FOR_PICKUP, CANCELLED, REJECTED
     * READY_FOR_PICKUP -> DISPATCHED
     * DISPATCHED -> DELIVERED
     * DELIVERED -> COMPLETED (Only by Buyer Confirmation)
     */
    public static boolean isValidStatusTransition(String currentStatus, String targetStatus) {
        if (currentStatus == null || targetStatus == null) return false;
        String cur = currentStatus.toUpperCase().trim();
        String tgt = targetStatus.toUpperCase().trim();
        if (cur.equals(tgt)) return false;

        switch (cur) {
            case "PLACED":
                return "ACCEPTED".equals(tgt) || "CANCELLED".equals(tgt) || "REJECTED".equals(tgt);
            case "ACCEPTED":
                return "READY_FOR_PICKUP".equals(tgt) || "CANCELLED".equals(tgt) || "REJECTED".equals(tgt);
            case "READY_FOR_PICKUP":
                return "DISPATCHED".equals(tgt) || "CANCELLED".equals(tgt);
            case "DISPATCHED":
                return "DELIVERED".equals(tgt);
            case "DELIVERED":
                return "COMPLETED".equals(tgt); // Triggered by buyer confirmation
            case "COMPLETED":
            case "CANCELLED":
            case "REJECTED":
            default:
                return false;
        }
    }

    /**
     * Creates a Master Order and individual Farmer Sub-Orders with atomic inventory deduction and wallet escrow.
     */
    public boolean createOrder(Order order, List<OrderItem> items, int buyerUserId) {
        if (items == null || items.isEmpty()) {
            return false;
        }

        if (order.getOrderNumber() == null || order.getOrderNumber().isEmpty()) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            int randomNum = 1000 + new Random().nextInt(9000);
            order.setOrderNumber("KC-" + sdf.format(new Date()) + "-" + randomNum);
        }

        String rawPm = order.getPaymentMethod();
        String pm = "CASH";
        if (rawPm != null) {
            String pUpper = rawPm.toUpperCase();
            if (pUpper.contains("WALLET")) pm = "WALLET";
            else if (pUpper.contains("UPI") || pUpper.contains("NET")) pm = "UPI";
            else if (pUpper.contains("ONLINE") || pUpper.contains("CARD")) pm = "ONLINE";
            else pm = "CASH";
        }
        order.setPaymentMethod(pm);

        boolean isWallet = "WALLET".equals(pm);
        String paymentStatus = isWallet ? "ESCROW_HELD" : "PENDING";
        order.setPaymentStatus(paymentStatus);
        order.setOrderStatus("PLACED");

        String sqlOrder = """
            INSERT INTO orders (
                buyer_profile_id, organization_id, buyer_type, gstin_applied,
                order_number, delivery_name, delivery_phone, delivery_address, delivery_pincode,
                subtotal_amount, discount_amount, delivery_charge, platform_fee, total_amount,
                payment_method, payment_status, order_status, delivery_date, delivery_latitude, delivery_longitude
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        String sqlSubOrder = """
            INSERT INTO sub_orders (
                order_id, farmer_profile_id, sub_order_number, subtotal_amount,
                delivery_charge, total_amount, payment_method, payment_status, sub_order_status,
                delivery_date, pickup_latitude, pickup_longitude, delivery_latitude, delivery_longitude, estimated_distance_km
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        String sqlOrderItem = """
            INSERT INTO order_items (
                order_id, sub_order_id, farmer_profile_id, product_id, product_name, unit_price, quantity,
                discount_amount, final_unit_price, subtotal
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        String sqlDeductStock = "UPDATE inventory SET available_quantity = available_quantity - ? WHERE product_id = ? AND available_quantity >= ?";

        String sqlPayment = """
            INSERT INTO payments (order_id, payment_method, payment_status, transaction_reference, paid_amount)
            VALUES (?, ?, ?, ?, ?)
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Step 1: If paying with KisaanConnect Wallet, verify balance and place in escrow
            if (isWallet) {
                String selectWalletSql = "SELECT wallet_id, current_balance, total_debited FROM wallets WHERE user_id = ? FOR UPDATE";
                int walletId = 0;
                BigDecimal currentBalance = BigDecimal.ZERO;
                BigDecimal totalDebited = BigDecimal.ZERO;

                try (PreparedStatement psW = con.prepareStatement(selectWalletSql)) {
                    psW.setInt(1, buyerUserId);
                    try (ResultSet rsW = psW.executeQuery()) {
                        if (rsW.next()) {
                            walletId = rsW.getInt("wallet_id");
                            currentBalance = rsW.getBigDecimal("current_balance");
                            totalDebited = rsW.getBigDecimal("total_debited");
                        } else {
                            con.rollback();
                            return false;
                        }
                    }
                }

                if (currentBalance.compareTo(order.getTotalAmount()) < 0) {
                    con.rollback();
                    return false;
                }

                // Deduct wallet for escrow
                BigDecimal newBalance = currentBalance.subtract(order.getTotalAmount());
                String updateWalletSql = "UPDATE wallets SET current_balance = ?, total_debited = ?, last_transaction_at = CURRENT_TIMESTAMP WHERE wallet_id = ?";
                try (PreparedStatement psUpW = con.prepareStatement(updateWalletSql)) {
                    psUpW.setBigDecimal(1, newBalance);
                    psUpW.setBigDecimal(2, totalDebited.add(order.getTotalAmount()));
                    psUpW.setInt(3, walletId);
                    psUpW.executeUpdate();
                }

                // Insert wallet transaction record
                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
                String refNo = "TXN-ESCROW-" + sdf.format(new Date()) + "-" + (1000 + new Random().nextInt(9000));
                String insertTxnSql = """
                    INSERT INTO user_wallet_transactions (
                        wallet_id, order_id, transaction_type, transaction_source,
                        amount, balance_after, txn_reference_no, remarks, status
                    ) VALUES (?, NULL, 'DEBIT', 'ORDER_ESCROW', ?, ?, ?, ?, 'SUCCESS')
                    """;
                try (PreparedStatement psTxn = con.prepareStatement(insertTxnSql)) {
                    psTxn.setInt(1, walletId);
                    psTxn.setBigDecimal(2, order.getTotalAmount());
                    psTxn.setBigDecimal(3, newBalance);
                    psTxn.setString(4, refNo);
                    psTxn.setString(5, "Escrow hold for Order #" + order.getOrderNumber());
                    psTxn.executeUpdate();
                }
            }

            // Step 2: Atomic stock deduction for each item
            try (PreparedStatement psStock = con.prepareStatement(sqlDeductStock)) {
                for (OrderItem item : items) {
                    psStock.setDouble(1, item.getQuantity());
                    psStock.setInt(2, item.getProductId());
                    psStock.setDouble(3, item.getQuantity());
                    int affectedRows = psStock.executeUpdate();
                    if (affectedRows == 0) {
                        // Stock is insufficient or changed concurrently
                        con.rollback();
                        return false;
                    }
                }
            }

            // Step 3: Insert Master Order
            int generatedOrderId = 0;
            Double delivLat = order.getDeliveryLatitude();
            Double delivLon = order.getDeliveryLongitude();
            if (delivLat == null && order.getBuyerProfileId() != null && order.getBuyerProfileId() > 0) {
                try (PreparedStatement psBP = con.prepareStatement("SELECT latitude, longitude FROM buyer_profiles WHERE buyer_profile_id = ?")) {
                    psBP.setInt(1, order.getBuyerProfileId());
                    try (ResultSet rsBP = psBP.executeQuery()) {
                        if (rsBP.next()) {
                            java.math.BigDecimal bLat = rsBP.getBigDecimal("latitude");
                            java.math.BigDecimal bLon = rsBP.getBigDecimal("longitude");
                            delivLat = bLat != null ? bLat.doubleValue() : null;
                            delivLon = bLon != null ? bLon.doubleValue() : null;
                        }
                    }
                }
            }
            if (delivLat == null && order.getOrganizationId() != null && order.getOrganizationId() > 0) {
                try (PreparedStatement psOrg = con.prepareStatement("SELECT latitude, longitude FROM organizations WHERE organization_id = ?")) {
                    psOrg.setInt(1, order.getOrganizationId());
                    try (ResultSet rsOrg = psOrg.executeQuery()) {
                        if (rsOrg.next()) {
                            java.math.BigDecimal oLat = rsOrg.getBigDecimal("latitude");
                            java.math.BigDecimal oLon = rsOrg.getBigDecimal("longitude");
                            delivLat = oLat != null ? oLat.doubleValue() : null;
                            delivLon = oLon != null ? oLon.doubleValue() : null;
                        }
                    }
                }
            }
            if (delivLat == null) {
                delivLat = 18.5597200;
                delivLon = 73.7899400;
            }

            if (delivLat != null && (delivLat < -90.0 || delivLat > 90.0)) delivLat = null;
            if (delivLon != null && (delivLon < -180.0 || delivLon > 180.0)) delivLon = null;

            try (PreparedStatement psOrder = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                if (order.getBuyerProfileId() != null && order.getBuyerProfileId() > 0) {
                    psOrder.setInt(1, order.getBuyerProfileId());
                } else {
                    psOrder.setNull(1, Types.INTEGER);
                }

                if (order.getOrganizationId() != null && order.getOrganizationId() > 0) {
                    psOrder.setInt(2, order.getOrganizationId());
                } else {
                    psOrder.setNull(2, Types.INTEGER);
                }

                psOrder.setString(3, order.getBuyerType() != null ? order.getBuyerType() : "INDIVIDUAL");
                psOrder.setString(4, order.getGstinApplied());
                psOrder.setString(5, order.getOrderNumber());
                psOrder.setString(6, order.getDeliveryName());
                psOrder.setString(7, order.getDeliveryPhone());
                psOrder.setString(8, order.getDeliveryAddress());
                psOrder.setString(9, order.getDeliveryPincode());
                psOrder.setBigDecimal(10, order.getSubtotalAmount());
                psOrder.setBigDecimal(11, order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO);
                psOrder.setBigDecimal(12, order.getDeliveryCharge() != null ? order.getDeliveryCharge() : BigDecimal.ZERO);
                psOrder.setBigDecimal(13, order.getPlatformFee() != null ? order.getPlatformFee() : BigDecimal.ZERO);
                psOrder.setBigDecimal(14, order.getTotalAmount());
                psOrder.setString(15, pm);
                psOrder.setString(16, paymentStatus);
                psOrder.setString(17, "PLACED");
                if (order.getDeliveryDate() != null) psOrder.setDate(18, order.getDeliveryDate()); else psOrder.setNull(18, Types.DATE);
                if (delivLat != null) psOrder.setDouble(19, delivLat); else psOrder.setNull(19, Types.DECIMAL);
                if (delivLon != null) psOrder.setDouble(20, delivLon); else psOrder.setNull(20, Types.DECIMAL);

                int affected = psOrder.executeUpdate();
                if (affected == 0) {
                    con.rollback();
                    return false;
                }

                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedOrderId = rs.getInt(1);
                        order.setOrderId(generatedOrderId);
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            // Step 4: Group items by farmer_profile_id and create child Sub-Orders
            Map<Integer, List<OrderItem>> farmerItemsMap = new LinkedHashMap<>();
            String getFarmerSql = "SELECT farmer_profile_id FROM products WHERE product_id = ?";
            try (PreparedStatement psGetF = con.prepareStatement(getFarmerSql)) {
                for (OrderItem item : items) {
                    int farmerProfileId = 0;
                    if (item.getFarmerProfileId() != null && item.getFarmerProfileId() > 0) {
                        farmerProfileId = item.getFarmerProfileId();
                    } else {
                        psGetF.setInt(1, item.getProductId());
                        try (ResultSet rsF = psGetF.executeQuery()) {
                            if (rsF.next()) {
                                farmerProfileId = rsF.getInt("farmer_profile_id");
                                item.setFarmerProfileId(farmerProfileId);
                            }
                        }
                    }
                    farmerItemsMap.computeIfAbsent(farmerProfileId, k -> new ArrayList<>()).add(item);
                }
            }

            // Insert each Sub-Order and its Order Items
            int subOrderIndex = 1;
            List<Object[]> subOrderNotifs = new ArrayList<>(); // [farmerProfId, subOrderId, subOrderNumber, subtotal]
            try (PreparedStatement psSub = con.prepareStatement(sqlSubOrder, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psItem = con.prepareStatement(sqlOrderItem)) {

                for (Map.Entry<Integer, List<OrderItem>> entry : farmerItemsMap.entrySet()) {
                    int farmerProfId = entry.getKey();
                    List<OrderItem> farmerItems = entry.getValue();

                    BigDecimal farmerSubtotal = BigDecimal.ZERO;
                    for (OrderItem fi : farmerItems) {
                        farmerSubtotal = farmerSubtotal.add(fi.getSubtotal());
                    }

                    // Lookup farmer coordinates
                    Double fLat = null;
                    Double fLon = null;
                    try (PreparedStatement psF = con.prepareStatement("SELECT latitude, longitude FROM farmer_profiles WHERE farmer_profile_id = ?")) {
                        psF.setInt(1, farmerProfId);
                        try (ResultSet rsF = psF.executeQuery()) {
                            if (rsF.next()) {
                                java.math.BigDecimal fLatBd = rsF.getBigDecimal("latitude");
                                java.math.BigDecimal fLonBd = rsF.getBigDecimal("longitude");
                                fLat = fLatBd != null ? fLatBd.doubleValue() : null;
                                fLon = fLonBd != null ? fLonBd.doubleValue() : null;
                            }
                        }
                    }
                    if (fLat == null) {
                        fLat = 18.5204303;
                        fLon = 73.8567437;
                    }

                    if (fLat != null && (fLat < -90.0 || fLat > 90.0)) fLat = null;
                    if (fLon != null && (fLon < -180.0 || fLon > 180.0)) fLon = null;

                    Double distKm = null;
                    if (fLat != null && fLon != null && delivLat != null && delivLon != null) {
                        distKm = calculateHaversineDistanceKm(fLat, fLon, delivLat, delivLon);
                    }

                    String subOrderNumber = order.getOrderNumber() + "-F" + farmerProfId;
                    psSub.setInt(1, generatedOrderId);
                    psSub.setInt(2, farmerProfId);
                    psSub.setString(3, subOrderNumber);
                    psSub.setBigDecimal(4, farmerSubtotal);
                    psSub.setBigDecimal(5, BigDecimal.ZERO);
                    psSub.setBigDecimal(6, farmerSubtotal);
                    psSub.setString(7, pm);
                    psSub.setString(8, paymentStatus);
                    psSub.setString(9, "PLACED");
                    if (order.getDeliveryDate() != null) psSub.setDate(10, order.getDeliveryDate()); else psSub.setNull(10, Types.DATE);
                    if (fLat != null) psSub.setDouble(11, fLat); else psSub.setNull(11, Types.DECIMAL);
                    if (fLon != null) psSub.setDouble(12, fLon); else psSub.setNull(12, Types.DECIMAL);
                    if (delivLat != null) psSub.setDouble(13, delivLat); else psSub.setNull(13, Types.DECIMAL);
                    if (delivLon != null) psSub.setDouble(14, delivLon); else psSub.setNull(14, Types.DECIMAL);
                    if (distKm != null) psSub.setDouble(15, distKm); else psSub.setNull(15, Types.DECIMAL);

                    psSub.executeUpdate();
                    int generatedSubOrderId = 0;
                    try (ResultSet rsSub = psSub.getGeneratedKeys()) {
                        if (rsSub.next()) {
                            generatedSubOrderId = rsSub.getInt(1);
                        }
                    }

                    subOrderNotifs.add(new Object[]{farmerProfId, generatedSubOrderId, subOrderNumber, farmerSubtotal});

                    for (OrderItem fi : farmerItems) {
                        fi.setSubOrderId(generatedSubOrderId);
                        psItem.setInt(1, generatedOrderId);
                        psItem.setInt(2, generatedSubOrderId);
                        psItem.setInt(3, farmerProfId);
                        psItem.setInt(4, fi.getProductId());
                        psItem.setString(5, fi.getProductName());
                        psItem.setBigDecimal(6, fi.getUnitPrice());
                        psItem.setDouble(7, fi.getQuantity());
                        psItem.setBigDecimal(8, fi.getDiscountAmount() != null ? fi.getDiscountAmount() : BigDecimal.ZERO);
                        psItem.setBigDecimal(9, fi.getFinalUnitPrice() != null ? fi.getFinalUnitPrice() : fi.getUnitPrice());
                        psItem.setBigDecimal(10, fi.getSubtotal());
                        psItem.addBatch();
                    }
                    subOrderIndex++;
                }
                psItem.executeBatch();
            }

            // Step 5: Insert Payment
            try (PreparedStatement psPay = con.prepareStatement(sqlPayment)) {
                psPay.setInt(1, generatedOrderId);
                psPay.setString(2, "ONLINE".equals(pm) || isWallet || "UPI".equals(pm) ? "ONLINE" : "CASH");
                psPay.setString(3, isWallet ? "SUCCESS" : "PENDING");
                psPay.setString(4, "TXN-" + order.getOrderNumber());
                psPay.setBigDecimal(5, order.getTotalAmount());
                psPay.executeUpdate();
            }

            con.commit();

            // Post-commit Notifications
            for (Object[] row : subOrderNotifs) {
                int fProfId = (Integer) row[0];
                int sOrderId = (Integer) row[1];
                String sOrderNum = (String) row[2];
                BigDecimal sTotal = (BigDecimal) row[3];

                int fUserId = 0;
                String fUserSql = "SELECT user_id FROM farmer_profiles WHERE farmer_profile_id = ?";
                try (PreparedStatement psFU = con.prepareStatement(fUserSql)) {
                    psFU.setInt(1, fProfId);
                    try (ResultSet rsFU = psFU.executeQuery()) {
                        if (rsFU.next()) fUserId = rsFU.getInt("user_id");
                    }
                } catch (SQLException ignored) {}

                if (fUserId > 0) {
                    notificationDAO.createNotification(fUserId, generatedOrderId, sOrderId, null,
                        "New Order Received",
                        "New order received — Sub-Order #" + sOrderNum + " — ₹" + sTotal,
                        "ORDER", "/farmer/orders");
                }
            }

            if (isWallet && buyerUserId > 0) {
                notificationDAO.createNotification(buyerUserId, generatedOrderId, null, null,
                    "Wallet Escrow Reserved",
                    "₹" + order.getTotalAmount() + " has been reserved from your KisaanConnect Wallet for Order #" + order.getOrderNumber(),
                    "WALLET", (order.getOrganizationId() != null && order.getOrganizationId() > 0 ? "/commercial/orders.jsp" : "/buyer/orders.jsp"));
            }

            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    public boolean createOrder(Order order, List<OrderItem> items) {
        return createOrder(order, items, 0);
    }

    /**
     * Creates an online order from an immutable payment attempt snapshot.
     */
    public boolean createOnlineOrderWithSnapshot(Order order, List<OrderItem> items, int buyerUserId,
                                                 String gatewayOrderId, String gatewayPaymentId, String gatewaySignature) {
        if (items == null || items.isEmpty()) {
            return false;
        }

        if (order.getOrderNumber() == null || order.getOrderNumber().isEmpty()) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            int randomNum = 1000 + new Random().nextInt(9000);
            order.setOrderNumber("KC-" + sdf.format(new Date()) + "-" + randomNum);
        }

        order.setPaymentMethod("ONLINE");
        order.setPaymentStatus("PAID");
        order.setOrderStatus("PLACED");

        String sqlOrder = """
            INSERT INTO orders (
                buyer_profile_id, organization_id, buyer_type, gstin_applied,
                order_number, delivery_name, delivery_phone, delivery_address, delivery_pincode,
                subtotal_amount, discount_amount, delivery_charge, platform_fee, total_amount,
                payment_method, payment_status, order_status, delivery_date, delivery_latitude, delivery_longitude
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ONLINE', 'PAID', 'PLACED', ?, ?, ?)
            """;

        String sqlSubOrder = """
            INSERT INTO sub_orders (
                order_id, farmer_profile_id, sub_order_number, subtotal_amount,
                delivery_charge, total_amount, payment_method, payment_status, sub_order_status,
                delivery_date, pickup_latitude, pickup_longitude, delivery_latitude, delivery_longitude, estimated_distance_km
            ) VALUES (?, ?, ?, ?, ?, ?, 'ONLINE', 'ESCROW_HELD', 'PLACED', ?, ?, ?, ?, ?, ?)
            """;

        String sqlOrderItem = """
            INSERT INTO order_items (
                order_id, sub_order_id, farmer_profile_id, product_id, product_name, unit_price, quantity,
                discount_amount, final_unit_price, subtotal
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        String sqlDeductStock = "UPDATE inventory SET available_quantity = available_quantity - ? WHERE product_id = ? AND available_quantity >= ?";

        String sqlPayment = """
            INSERT INTO payments (order_id, payment_method, payment_gateway, transaction_reference, gateway_order_id, gateway_payment_id, gateway_signature, paid_amount, payment_status, payment_date)
            VALUES (?, 'ONLINE', 'RAZORPAY', ?, ?, ?, ?, ?, 'SUCCESS', CURRENT_TIMESTAMP)
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Step 1: Atomic stock deduction for each item in snapshot
            try (PreparedStatement psStock = con.prepareStatement(sqlDeductStock)) {
                for (OrderItem item : items) {
                    psStock.setDouble(1, item.getQuantity());
                    psStock.setInt(2, item.getProductId());
                    psStock.setDouble(3, item.getQuantity());
                    int affectedRows = psStock.executeUpdate();
                    if (affectedRows == 0) {
                        con.rollback();
                        return false;
                    }
                }
            }

            // Step 2: Coordinates
            int generatedOrderId = 0;
            Double delivLat = order.getDeliveryLatitude();
            Double delivLon = order.getDeliveryLongitude();
            if (delivLat == null && order.getBuyerProfileId() != null && order.getBuyerProfileId() > 0) {
                try (PreparedStatement psBP = con.prepareStatement("SELECT latitude, longitude FROM buyer_profiles WHERE buyer_profile_id = ?")) {
                    psBP.setInt(1, order.getBuyerProfileId());
                    try (ResultSet rsBP = psBP.executeQuery()) {
                        if (rsBP.next()) {
                            java.math.BigDecimal bLat = rsBP.getBigDecimal("latitude");
                            java.math.BigDecimal bLon = rsBP.getBigDecimal("longitude");
                            delivLat = bLat != null ? bLat.doubleValue() : null;
                            delivLon = bLon != null ? bLon.doubleValue() : null;
                        }
                    }
                }
            }
            if (delivLat == null && order.getOrganizationId() != null && order.getOrganizationId() > 0) {
                try (PreparedStatement psOrg = con.prepareStatement("SELECT latitude, longitude FROM organizations WHERE organization_id = ?")) {
                    psOrg.setInt(1, order.getOrganizationId());
                    try (ResultSet rsOrg = psOrg.executeQuery()) {
                        if (rsOrg.next()) {
                            java.math.BigDecimal oLat = rsOrg.getBigDecimal("latitude");
                            java.math.BigDecimal oLon = rsOrg.getBigDecimal("longitude");
                            delivLat = oLat != null ? oLat.doubleValue() : null;
                            delivLon = oLon != null ? oLon.doubleValue() : null;
                        }
                    }
                }
            }
            if (delivLat == null) {
                delivLat = 18.5597200;
                delivLon = 73.7899400;
            }

            // Step 3: Insert Master Order
            try (PreparedStatement psOrder = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                if (order.getBuyerProfileId() != null && order.getBuyerProfileId() > 0) {
                    psOrder.setInt(1, order.getBuyerProfileId());
                } else {
                    psOrder.setNull(1, Types.INTEGER);
                }

                if (order.getOrganizationId() != null && order.getOrganizationId() > 0) {
                    psOrder.setInt(2, order.getOrganizationId());
                } else {
                    psOrder.setNull(2, Types.INTEGER);
                }

                psOrder.setString(3, order.getBuyerType() != null ? order.getBuyerType() : "INDIVIDUAL");
                psOrder.setString(4, order.getGstinApplied());
                psOrder.setString(5, order.getOrderNumber());
                psOrder.setString(6, order.getDeliveryName());
                psOrder.setString(7, order.getDeliveryPhone());
                psOrder.setString(8, order.getDeliveryAddress());
                psOrder.setString(9, order.getDeliveryPincode());
                psOrder.setBigDecimal(10, order.getSubtotalAmount());
                psOrder.setBigDecimal(11, order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO);
                psOrder.setBigDecimal(12, order.getDeliveryCharge() != null ? order.getDeliveryCharge() : BigDecimal.ZERO);
                psOrder.setBigDecimal(13, order.getPlatformFee() != null ? order.getPlatformFee() : BigDecimal.ZERO);
                psOrder.setBigDecimal(14, order.getTotalAmount());
                if (order.getDeliveryDate() != null) psOrder.setDate(15, order.getDeliveryDate()); else psOrder.setNull(15, Types.DATE);
                if (delivLat != null) psOrder.setDouble(16, delivLat); else psOrder.setNull(16, Types.DECIMAL);
                if (delivLon != null) psOrder.setDouble(17, delivLon); else psOrder.setNull(17, Types.DECIMAL);

                psOrder.executeUpdate();
                try (ResultSet rsOrder = psOrder.getGeneratedKeys()) {
                    if (rsOrder.next()) {
                        generatedOrderId = rsOrder.getInt(1);
                        order.setOrderId(generatedOrderId);
                    }
                }
            }

            if (generatedOrderId == 0) {
                con.rollback();
                return false;
            }

            // Step 4: Group items by farmer and insert sub-orders
            Map<Integer, List<OrderItem>> farmerGroups = new HashMap<>();
            for (OrderItem item : items) {
                int farmerProfId = item.getFarmerProfileId();
                if (farmerProfId <= 0) {
                    String getFarmerSql = "SELECT farmer_profile_id FROM products WHERE product_id = ?";
                    try (PreparedStatement psP = con.prepareStatement(getFarmerSql)) {
                        psP.setInt(1, item.getProductId());
                        try (ResultSet rsP = psP.executeQuery()) {
                            if (rsP.next()) {
                                farmerProfId = rsP.getInt("farmer_profile_id");
                                item.setFarmerProfileId(farmerProfId);
                            }
                        }
                    }
                }
                farmerGroups.computeIfAbsent(farmerProfId, k -> new ArrayList<>()).add(item);
            }

            List<Object[]> subOrderNotifs = new ArrayList<>();
            try (PreparedStatement psSub = con.prepareStatement(sqlSubOrder, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psItem = con.prepareStatement(sqlOrderItem)) {

                for (Map.Entry<Integer, List<OrderItem>> entry : farmerGroups.entrySet()) {
                    int farmerProfId = entry.getKey();
                    List<OrderItem> farmerItems = entry.getValue();

                    BigDecimal farmerSubtotal = BigDecimal.ZERO;
                    for (OrderItem fi : farmerItems) {
                        farmerSubtotal = farmerSubtotal.add(fi.getSubtotal());
                    }

                    Double fLat = null, fLon = null;
                    String fCoordSql = "SELECT latitude, longitude FROM farmer_profiles WHERE farmer_profile_id = ?";
                    try (PreparedStatement psFC = con.prepareStatement(fCoordSql)) {
                        psFC.setInt(1, farmerProfId);
                        try (ResultSet rsFC = psFC.executeQuery()) {
                            if (rsFC.next()) {
                                java.math.BigDecimal fLatBd = rsFC.getBigDecimal("latitude");
                                java.math.BigDecimal fLonBd = rsFC.getBigDecimal("longitude");
                                fLat = fLatBd != null ? fLatBd.doubleValue() : null;
                                fLon = fLonBd != null ? fLonBd.doubleValue() : null;
                            }
                        }
                    }
                    if (fLat == null) {
                        fLat = 18.5204303;
                        fLon = 73.8567437;
                    }

                    Double distKm = (fLat != null && fLon != null && delivLat != null && delivLon != null)
                            ? calculateHaversineDistanceKm(fLat, fLon, delivLat, delivLon) : null;

                    String subOrderNumber = order.getOrderNumber() + "-F" + farmerProfId;
                    psSub.setInt(1, generatedOrderId);
                    psSub.setInt(2, farmerProfId);
                    psSub.setString(3, subOrderNumber);
                    psSub.setBigDecimal(4, farmerSubtotal);
                    psSub.setBigDecimal(5, BigDecimal.ZERO);
                    psSub.setBigDecimal(6, farmerSubtotal);
                    if (order.getDeliveryDate() != null) psSub.setDate(7, order.getDeliveryDate()); else psSub.setNull(7, Types.DATE);
                    if (fLat != null) psSub.setDouble(8, fLat); else psSub.setNull(8, Types.DECIMAL);
                    if (fLon != null) psSub.setDouble(9, fLon); else psSub.setNull(9, Types.DECIMAL);
                    if (delivLat != null) psSub.setDouble(10, delivLat); else psSub.setNull(10, Types.DECIMAL);
                    if (delivLon != null) psSub.setDouble(11, delivLon); else psSub.setNull(11, Types.DECIMAL);
                    if (distKm != null) psSub.setDouble(12, distKm); else psSub.setNull(12, Types.DECIMAL);

                    psSub.executeUpdate();
                    int generatedSubOrderId = 0;
                    try (ResultSet rsSub = psSub.getGeneratedKeys()) {
                        if (rsSub.next()) {
                            generatedSubOrderId = rsSub.getInt(1);
                        }
                    }

                    subOrderNotifs.add(new Object[]{farmerProfId, generatedSubOrderId, subOrderNumber, farmerSubtotal});

                    for (OrderItem fi : farmerItems) {
                        fi.setSubOrderId(generatedSubOrderId);
                        psItem.setInt(1, generatedOrderId);
                        psItem.setInt(2, generatedSubOrderId);
                        psItem.setInt(3, farmerProfId);
                        psItem.setInt(4, fi.getProductId());
                        psItem.setString(5, fi.getProductName());
                        psItem.setBigDecimal(6, fi.getUnitPrice());
                        psItem.setDouble(7, fi.getQuantity());
                        psItem.setBigDecimal(8, fi.getDiscountAmount() != null ? fi.getDiscountAmount() : BigDecimal.ZERO);
                        psItem.setBigDecimal(9, fi.getFinalUnitPrice() != null ? fi.getFinalUnitPrice() : fi.getUnitPrice());
                        psItem.setBigDecimal(10, fi.getSubtotal());
                        psItem.addBatch();
                    }
                }
                psItem.executeBatch();
            }

            // Step 5: Insert Payment
            try (PreparedStatement psPay = con.prepareStatement(sqlPayment)) {
                psPay.setInt(1, generatedOrderId);
                psPay.setString(2, gatewayPaymentId != null ? gatewayPaymentId : "TXN-" + order.getOrderNumber());
                psPay.setString(3, gatewayOrderId);
                psPay.setString(4, gatewayPaymentId);
                psPay.setString(5, gatewaySignature);
                psPay.setBigDecimal(6, order.getTotalAmount());
                psPay.executeUpdate();
            }

            con.commit();

            // Post-commit Notifications
            for (Object[] row : subOrderNotifs) {
                int fProfId = (Integer) row[0];
                int sOrderId = (Integer) row[1];
                String sOrderNum = (String) row[2];
                BigDecimal sTotal = (BigDecimal) row[3];

                int fUserId = 0;
                String fUserSql = "SELECT user_id FROM farmer_profiles WHERE farmer_profile_id = ?";
                try (PreparedStatement psFU = con.prepareStatement(fUserSql)) {
                    psFU.setInt(1, fProfId);
                    try (ResultSet rsFU = psFU.executeQuery()) {
                        if (rsFU.next()) fUserId = rsFU.getInt("user_id");
                    }
                } catch (SQLException ignored) {}

                if (fUserId > 0) {
                    notificationDAO.createNotification(fUserId, generatedOrderId, sOrderId, null,
                        "New Order Received",
                        "New order received — Sub-Order #" + sOrderNum + " — ₹" + sTotal + " (Paid Online via Razorpay)",
                        "ORDER", "/farmer/orders");
                }
            }

            if (buyerUserId > 0) {
                notificationDAO.createNotification(buyerUserId, generatedOrderId, null, null,
                    "Order Placed Successfully",
                    "Payment of ₹" + order.getTotalAmount() + " received via Razorpay for Order #" + order.getOrderNumber() + ". Producing farms notified.",
                    "ORDER", (order.getOrganizationId() != null && order.getOrganizationId() > 0 ? "/commercial/orders.jsp" : "/buyer/orders.jsp"));
            }

            return true;
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    public Order getOrderByGatewayPaymentId(String gatewayPaymentId) {
        if (gatewayPaymentId == null || gatewayPaymentId.trim().isEmpty()) return null;
        String sql = "SELECT o.* FROM orders o JOIN payments p ON o.order_id = p.order_id WHERE p.gateway_payment_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, gatewayPaymentId.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setOrderNumber(rs.getString("order_number"));
                    order.setOrderStatus(rs.getString("order_status"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    int orgId = rs.getInt("organization_id");
                    if (!rs.wasNull()) order.setOrganizationId(orgId);
                    return order;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Fetches farmer-specific sub-orders with status filter and attaches only the farmer's items.
     */
    public List<SubOrder> getFarmerSubOrders(int farmerProfileId, String statusFilter) {
        List<SubOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT so.*, o.order_number AS master_order_number, o.delivery_name, o.delivery_phone, o.delivery_address, o.delivery_pincode,
                   u.full_name AS buyer_name, org.org_name AS organization_name, fp.farm_name, fu.full_name AS farmer_name, fu.phone AS farmer_phone
            FROM sub_orders so
            JOIN orders o ON so.order_id = o.order_id
            JOIN farmer_profiles fp ON so.farmer_profile_id = fp.farmer_profile_id
            JOIN users fu ON fp.user_id = fu.user_id
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            LEFT JOIN users u ON bp.user_id = u.user_id
            LEFT JOIN organizations org ON o.organization_id = org.organization_id
            WHERE so.farmer_profile_id = ?
            """);

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append(" AND so.sub_order_status = ?");
        }
        sql.append(" ORDER BY so.created_at DESC");

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            ps.setInt(1, farmerProfileId);
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SubOrder so = mapResultSetToSubOrder(rs);
                so.setItems(getOrderItemsBySubOrderId(so.getSubOrderId()));
                list.add(so);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getOrdersForFarmer(int farmerProfileId) {
        List<SubOrder> subOrders = getFarmerSubOrders(farmerProfileId, "ALL");
        List<Order> orders = new ArrayList<>();
        for (SubOrder so : subOrders) {
            Order o = new Order();
            o.setOrderId(so.getOrderId());
            o.setOrderNumber(so.getSubOrderNumber());
            o.setSubtotalAmount(so.getSubtotalAmount());
            o.setDeliveryCharge(so.getDeliveryCharge());
            o.setTotalAmount(so.getTotalAmount());
            o.setPaymentMethod(so.getPaymentMethod());
            o.setPaymentStatus(so.getPaymentStatus());
            o.setOrderStatus(so.getSubOrderStatus());
            o.setDeliveryName(so.getDeliveryName());
            o.setDeliveryPhone(so.getDeliveryPhone());
            o.setDeliveryAddress(so.getDeliveryAddress());
            o.setDeliveryPincode(so.getDeliveryPincode());
            o.setBuyerName(so.getBuyerName());
            o.setOrganizationName(so.getOrganizationName());
            o.setOrderDate(so.getCreatedAt());
            o.setUpdatedAt(so.getUpdatedAt());
            o.setItems(so.getItems());
            orders.add(o);
        }
        return orders;
    }

    /**
     * Executes a Farmer Sub-Order status transition (e.g. ACCEPTED, READY_FOR_PICKUP, DISPATCHED, DELIVERED, REJECTED, CANCELLED).
     */
    public boolean updateFarmerSubOrderStatus(int subOrderId, String targetStatus, int farmerProfileId) {
        if (targetStatus == null) return false;

        String selectSql = "SELECT * FROM sub_orders WHERE sub_order_id = ? AND farmer_profile_id = ? FOR UPDATE";
        String updateSql = "UPDATE sub_orders SET sub_order_status = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = ?";
        String getItemsSql = "SELECT product_id, quantity FROM order_items WHERE sub_order_id = ?";
        String restoreStockSql = "UPDATE inventory SET available_quantity = available_quantity + ? WHERE product_id = ?";

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            SubOrder subOrder = null;
            try (PreparedStatement psSelect = con.prepareStatement(selectSql)) {
                psSelect.setInt(1, subOrderId);
                psSelect.setInt(2, farmerProfileId);
                try (ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        subOrder = mapResultSetToSubOrder(rs);
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            String currentStatus = subOrder.getSubOrderStatus();

            // Farmer cannot directly mark COMPLETED (only Buyer confirmation can)
            if ("COMPLETED".equalsIgnoreCase(targetStatus)) {
                con.rollback();
                return false;
            }

            if (!isValidStatusTransition(currentStatus, targetStatus)) {
                con.rollback();
                return false;
            }

            // If REJECTED or CANCELLED, restore inventory & refund buyer if wallet escrow held
            if ("CANCELLED".equalsIgnoreCase(targetStatus) || "REJECTED".equalsIgnoreCase(targetStatus)) {
                try (PreparedStatement psItems = con.prepareStatement(getItemsSql);
                     PreparedStatement psRestore = con.prepareStatement(restoreStockSql)) {
                    psItems.setInt(1, subOrderId);
                    try (ResultSet rsItems = psItems.executeQuery()) {
                        while (rsItems.next()) {
                            int productId = rsItems.getInt("product_id");
                            double qty = rsItems.getDouble("quantity");
                            psRestore.setDouble(1, qty);
                            psRestore.setInt(2, productId);
                            psRestore.addBatch();
                        }
                    }
                    psRestore.executeBatch();
                }

                // If paid via WALLET and in ESCROW_HELD status, refund the Buyer's wallet for this sub-order portion
                if ("WALLET".equalsIgnoreCase(subOrder.getPaymentMethod()) && "ESCROW_HELD".equalsIgnoreCase(subOrder.getPaymentStatus())) {
                    String getBuyerSql = """
                        SELECT COALESCE(bp.user_id, org.owner_user_id) AS buyer_user_id
                        FROM orders o
                        LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
                        LEFT JOIN organizations org ON o.organization_id = org.organization_id
                        WHERE o.order_id = ?
                        """;
                    int buyerUserId = 0;
                    try (PreparedStatement psBuyer = con.prepareStatement(getBuyerSql)) {
                        psBuyer.setInt(1, subOrder.getOrderId());
                        try (ResultSet rsB = psBuyer.executeQuery()) {
                            if (rsB.next()) {
                                buyerUserId = rsB.getInt("buyer_user_id");
                            }
                        }
                    }

                    if (buyerUserId > 0) {
                        String refundWalletSql = "UPDATE wallets SET current_balance = current_balance + ?, total_credited = total_credited + ?, last_transaction_at = CURRENT_TIMESTAMP WHERE user_id = ?";
                        try (PreparedStatement psRefW = con.prepareStatement(refundWalletSql)) {
                            psRefW.setBigDecimal(1, subOrder.getTotalAmount());
                            psRefW.setBigDecimal(2, subOrder.getTotalAmount());
                            psRefW.setInt(3, buyerUserId);
                            psRefW.executeUpdate();
                        }

                        // Insert refund transaction
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
                        String refNo = "TXN-REFUND-" + sdf.format(new Date()) + "-" + (1000 + new Random().nextInt(9000));
                        String getWalletIdSql = "SELECT wallet_id, current_balance FROM wallets WHERE user_id = ?";
                        int bWalletId = 0;
                        BigDecimal bBalance = BigDecimal.ZERO;
                        try (PreparedStatement psBW = con.prepareStatement(getWalletIdSql)) {
                            psBW.setInt(1, buyerUserId);
                            try (ResultSet rsBW = psBW.executeQuery()) {
                                if (rsBW.next()) {
                                    bWalletId = rsBW.getInt("wallet_id");
                                    bBalance = rsBW.getBigDecimal("current_balance");
                                }
                            }
                        }

                        String insertTxnSql = """
                            INSERT INTO user_wallet_transactions (
                                wallet_id, order_id, transaction_type, transaction_source,
                                amount, balance_after, txn_reference_no, remarks, status
                            ) VALUES (?, ?, 'CREDIT', 'REFUND', ?, ?, ?, ?, 'SUCCESS')
                            """;
                        try (PreparedStatement psTxn = con.prepareStatement(insertTxnSql)) {
                            psTxn.setInt(1, bWalletId);
                            psTxn.setInt(2, subOrder.getOrderId());
                            psTxn.setBigDecimal(3, subOrder.getTotalAmount());
                            psTxn.setBigDecimal(4, bBalance);
                            psTxn.setString(5, refNo);
                            psTxn.setString(6, "Refund for Sub-Order #" + subOrder.getSubOrderNumber());
                            psTxn.executeUpdate();
                        }

                        // Update sub-order payment status to REFUNDED
                        String updateSubPaySql = "UPDATE sub_orders SET payment_status = 'REFUNDED' WHERE sub_order_id = ?";
                        try (PreparedStatement psSubP = con.prepareStatement(updateSubPaySql)) {
                            psSubP.setInt(1, subOrderId);
                            psSubP.executeUpdate();
                        }
                    }
                }
            }

            // Update sub-order status
            try (PreparedStatement psUpdate = con.prepareStatement(updateSql)) {
                psUpdate.setString(1, targetStatus.toUpperCase().trim());
                psUpdate.setInt(2, subOrderId);
                psUpdate.executeUpdate();
            }

            // Recalculate Master Order Status
            recalculateMasterOrderStatus(con, subOrder.getOrderId());

            con.commit();

            // Post-commit Notifications for Buyer
            int bUserId = 0;
            String farmName = "Farmer";
            String bSql = "SELECT COALESCE(bp.user_id, org.owner_user_id) AS buyer_uid, fp.farm_name, u_f.full_name AS farmer_name "
                        + "FROM sub_orders so "
                        + "JOIN orders o ON so.order_id = o.order_id "
                        + "JOIN farmer_profiles fp ON so.farmer_profile_id = fp.farmer_profile_id "
                        + "JOIN users u_f ON fp.user_id = u_f.user_id "
                        + "LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id "
                        + "LEFT JOIN organizations org ON o.organization_id = org.organization_id "
                        + "WHERE so.sub_order_id = ?";
            try (Connection connB = DBConnection.getConnection();
                 PreparedStatement psB = connB.prepareStatement(bSql)) {
                psB.setInt(1, subOrderId);
                try (ResultSet rsB = psB.executeQuery()) {
                    if (rsB.next()) {
                        bUserId = rsB.getInt("buyer_uid");
                        farmName = rsB.getString("farm_name");
                        if (farmName == null || farmName.isEmpty()) farmName = rsB.getString("farmer_name");
                    }
                }
            } catch (SQLException ignored) {}

            if (bUserId > 0) {
                String tgt = targetStatus.toUpperCase().trim();
                if ("ACCEPTED".equals(tgt)) {
                    notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                        "Order Accepted", "Your order portion (#" + subOrder.getSubOrderNumber() + ") from " + farmName + " has been accepted.",
                        "ORDER", "/buyer/orders.jsp");
                } else if ("READY_FOR_PICKUP".equals(tgt)) {
                    notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                        "Order Ready for Pickup", "Your order portion (#" + subOrder.getSubOrderNumber() + ") from " + farmName + " is ready for pickup.",
                        "ORDER", "/buyer/orders.jsp");
                } else if ("DISPATCHED".equals(tgt)) {
                    notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                        "Order Dispatched", "Your order portion (#" + subOrder.getSubOrderNumber() + ") from " + farmName + " has been dispatched.",
                        "DELIVERY", "/buyer/orders.jsp");
                } else if ("DELIVERED".equals(tgt)) {
                    notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                        "Delivery Awaiting Confirmation", "Your order portion (#" + subOrder.getSubOrderNumber() + ") from " + farmName + " has been marked as delivered. Please confirm receipt.",
                        "DELIVERY", "/buyer/orders.jsp");
                } else if ("REJECTED".equals(tgt)) {
                    notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                        "Order Portion Rejected", "Your order portion (#" + subOrder.getSubOrderNumber() + ") from " + farmName + " of ₹" + subOrder.getTotalAmount() + " was rejected.",
                        "ORDER", "/buyer/orders.jsp");
                    if ("WALLET".equalsIgnoreCase(subOrder.getPaymentMethod())) {
                        notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                            "Wallet Refund Received", "₹" + subOrder.getTotalAmount() + " has been refunded to your KisaanConnect Wallet.",
                            "WALLET", "/buyer/wallet.jsp");
                    }
                } else if ("CANCELLED".equals(tgt)) {
                    notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                        "Order Portion Cancelled", "Your order portion (#" + subOrder.getSubOrderNumber() + ") was cancelled.",
                        "ORDER", "/buyer/orders.jsp");
                    if ("WALLET".equalsIgnoreCase(subOrder.getPaymentMethod())) {
                        notificationDAO.createNotification(bUserId, subOrder.getOrderId(), subOrderId, null,
                            "Wallet Refund Received", "₹" + subOrder.getTotalAmount() + " has been refunded to your KisaanConnect Wallet.",
                            "WALLET", "/buyer/wallet.jsp");
                    }
                }
            }

            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    /**
     * Buyer confirms delivery of a Farmer Sub-Order.
     * Transitions sub-order from DELIVERED -> COMPLETED and releases wallet funds to the farmer.
     */
    public boolean confirmBuyerDelivery(int subOrderId, int buyerUserId) {
        String selectSql = """
            SELECT so.*, o.order_number, o.buyer_profile_id, o.organization_id,
                   COALESCE(bp.user_id, org.owner_user_id) AS buyer_user_id,
                   fp.user_id AS farmer_user_id
            FROM sub_orders so
            JOIN orders o ON so.order_id = o.order_id
            JOIN farmer_profiles fp ON so.farmer_profile_id = fp.farmer_profile_id
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            LEFT JOIN organizations org ON o.organization_id = org.organization_id
            WHERE so.sub_order_id = ?
            FOR UPDATE
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int orderId = 0;
            String currentStatus = null;
            String paymentMethod = null;
            String paymentStatus = null;
            BigDecimal subtotalAmount = BigDecimal.ZERO;
            String subOrderNum = null;
            int authorizedBuyerUserId = 0;
            int farmerUserId = 0;
            int orgId = 0;

            try (PreparedStatement ps = con.prepareStatement(selectSql)) {
                ps.setInt(1, subOrderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        orderId = rs.getInt("order_id");
                        currentStatus = rs.getString("sub_order_status");
                        paymentMethod = rs.getString("payment_method");
                        paymentStatus = rs.getString("payment_status");
                        subtotalAmount = rs.getBigDecimal("subtotal_amount");
                        subOrderNum = rs.getString("sub_order_number");
                        authorizedBuyerUserId = rs.getInt("buyer_user_id");
                        farmerUserId = rs.getInt("farmer_user_id");
                        orgId = rs.getInt("organization_id");
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            // Verify that the user confirming is authorized
            boolean isAuthorized = false;
            if (buyerUserId <= 0) {
                isAuthorized = true;
            } else if (buyerUserId == authorizedBuyerUserId) {
                isAuthorized = true;
            } else if (orgId > 0) {
                String checkMemberSql = "SELECT 1 FROM organization_members WHERE organization_id = ? AND user_id = ? AND status = 'ACTIVE'";
                try (PreparedStatement psM = con.prepareStatement(checkMemberSql)) {
                    psM.setInt(1, orgId);
                    psM.setInt(2, buyerUserId);
                    try (ResultSet rsM = psM.executeQuery()) {
                        if (rsM.next()) isAuthorized = true;
                    }
                }
            }

            if (!isAuthorized) {
                con.rollback();
                return false;
            }

            // Must be in DELIVERED state (or ACCEPTED/DISPATCHED) and NOT already COMPLETED
            if ("COMPLETED".equalsIgnoreCase(currentStatus)) {
                // Idempotent: already completed, return true without double payout
                con.rollback();
                return true;
            }

            if (!"DELIVERED".equalsIgnoreCase(currentStatus) && !"DISPATCHED".equalsIgnoreCase(currentStatus) && !"ACCEPTED".equalsIgnoreCase(currentStatus) && !"READY_FOR_PICKUP".equalsIgnoreCase(currentStatus)) {
                con.rollback();
                return false;
            }

            // Update sub-order status to COMPLETED
            String updateSubSql = "UPDATE sub_orders SET sub_order_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = ?";
            try (PreparedStatement psUp = con.prepareStatement(updateSubSql)) {
                psUp.setInt(1, subOrderId);
                psUp.executeUpdate();
            }

            // If paid with WALLET and funds held in ESCROW_HELD, credit the Farmer's wallet
            if ("WALLET".equalsIgnoreCase(paymentMethod) && "ESCROW_HELD".equalsIgnoreCase(paymentStatus)) {
                // Credit Farmer's wallet
                String creditFarmerSql = "UPDATE wallets SET current_balance = current_balance + ?, total_credited = total_credited + ?, last_transaction_at = CURRENT_TIMESTAMP WHERE user_id = ?";
                try (PreparedStatement psCF = con.prepareStatement(creditFarmerSql)) {
                    psCF.setBigDecimal(1, subtotalAmount);
                    psCF.setBigDecimal(2, subtotalAmount);
                    psCF.setInt(3, farmerUserId);
                    psCF.executeUpdate();
                }

                // Insert wallet transaction for farmer
                String getFWalletSql = "SELECT wallet_id, current_balance FROM wallets WHERE user_id = ?";
                int fWalletId = 0;
                BigDecimal fBalance = BigDecimal.ZERO;
                try (PreparedStatement psFW = con.prepareStatement(getFWalletSql)) {
                    psFW.setInt(1, farmerUserId);
                    try (ResultSet rsFW = psFW.executeQuery()) {
                        if (rsFW.next()) {
                            fWalletId = rsFW.getInt("wallet_id");
                            fBalance = rsFW.getBigDecimal("current_balance");
                        }
                    }
                }

                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
                String refNo = "TXN-PAYOUT-" + sdf.format(new Date()) + "-" + (1000 + new Random().nextInt(9000));
                String insertTxnSql = """
                    INSERT INTO user_wallet_transactions (
                        wallet_id, order_id, transaction_type, transaction_source,
                        amount, balance_after, txn_reference_no, remarks, status
                    ) VALUES (?, ?, 'CREDIT', 'ORDER_PAYOUT', ?, ?, ?, ?, 'SUCCESS')
                    """;
                try (PreparedStatement psTxn = con.prepareStatement(insertTxnSql)) {
                    psTxn.setInt(1, fWalletId);
                    psTxn.setInt(2, orderId);
                    psTxn.setBigDecimal(3, subtotalAmount);
                    psTxn.setBigDecimal(4, fBalance);
                    psTxn.setString(5, refNo);
                    psTxn.setString(6, "Payout for Sub-Order #" + subOrderNum);
                    psTxn.executeUpdate();
                }

                // Update sub-order payment status to PAID
                String updateSubPaySql = "UPDATE sub_orders SET payment_status = 'PAID' WHERE sub_order_id = ?";
                try (PreparedStatement psSubP = con.prepareStatement(updateSubPaySql)) {
                    psSubP.setInt(1, subOrderId);
                    psSubP.executeUpdate();
                }
            }

            // Recalculate Master Order Status
            recalculateMasterOrderStatus(con, orderId);

            con.commit();

            // Post-commit Notifications for Farmer
            if (farmerUserId > 0) {
                notificationDAO.createNotification(farmerUserId, orderId, subOrderId, null,
                    "Order Receipt Confirmed",
                    "Buyer confirmed receipt of Sub-Order #" + subOrderNum + ".",
                    "DELIVERY", "/farmer/orders");

                if ("WALLET".equalsIgnoreCase(paymentMethod) && "ESCROW_HELD".equalsIgnoreCase(paymentStatus)) {
                    notificationDAO.createNotification(farmerUserId, orderId, subOrderId, null,
                        "Wallet Payout Received",
                        "₹" + subtotalAmount + " has been released to your KisaanConnect Wallet for Sub-Order #" + subOrderNum + ".",
                        "WALLET", "/farmer/wallet");
                }
            }

            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    /**
     * Recalculates master order status derived dynamically from child sub-orders.
     */
    private void recalculateMasterOrderStatus(Connection con, int orderId) throws SQLException {
        String selectSubsSql = "SELECT sub_order_status FROM sub_orders WHERE order_id = ?";
        List<String> statuses = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(selectSubsSql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    statuses.add(rs.getString("sub_order_status"));
                }
            }
        }

        if (statuses.isEmpty()) return;

        String derivedMasterStatus = deriveMasterStatus(statuses);

        String updateMasterSql = "UPDATE orders SET order_status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_id = ?";
        try (PreparedStatement psUp = con.prepareStatement(updateMasterSql)) {
            psUp.setString(1, derivedMasterStatus);
            psUp.setInt(2, orderId);
            psUp.executeUpdate();
        }
    }

    public static String deriveMasterStatus(List<String> subStatuses) {
        if (subStatuses == null || subStatuses.isEmpty()) return "PLACED";

        boolean allCompleted = true;
        boolean allCancelledOrRejected = true;
        boolean anyDelivered = false;
        boolean anyDispatched = false;
        boolean anyAccepted = false;
        boolean allPlaced = true;

        for (String st : subStatuses) {
            String s = st.toUpperCase().trim();
            if (!"COMPLETED".equals(s)) allCompleted = false;
            if (!"CANCELLED".equals(s) && !"REJECTED".equals(s)) allCancelledOrRejected = false;
            if ("DELIVERED".equals(s)) anyDelivered = true;
            if ("DISPATCHED".equals(s)) anyDispatched = true;
            if ("ACCEPTED".equals(s) || "READY_FOR_PICKUP".equals(s)) anyAccepted = true;
            if (!"PLACED".equals(s)) allPlaced = false;
        }

        if (allCancelledOrRejected) return "CANCELLED";
        if (allCompleted) return "COMPLETED";

        // Check if all non-cancelled/rejected are completed
        int activeCount = 0;
        int completedCount = 0;
        for (String st : subStatuses) {
            String s = st.toUpperCase().trim();
            if (!"CANCELLED".equals(s) && !"REJECTED".equals(s)) {
                activeCount++;
                if ("COMPLETED".equals(s)) completedCount++;
            }
        }
        if (activeCount > 0 && activeCount == completedCount) return "COMPLETED";

        if (anyDelivered) return "PARTIALLY_DELIVERED";
        if (anyDispatched) return "PARTIALLY_DISPATCHED";
        if (anyAccepted) return "PROCESSING";
        if (allPlaced) return "PLACED";

        return "PROCESSING";
    }

    public Order getOrderById(int orderId) {
        String sql = """
            SELECT o.*, u.full_name AS buyer_name, org.org_name AS organization_name
            FROM orders o
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            LEFT JOIN users u ON bp.user_id = u.user_id
            LEFT JOIN organizations org ON o.organization_id = org.organization_id
            WHERE o.order_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                order.setItems(getOrderItems(orderId));
                order.setSubOrders(getSubOrdersByOrderId(orderId));
                return order;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Order> getOrdersByBuyerProfileId(int buyerProfileId) {
        return getOrdersByBuyerProfileId(buyerProfileId, "ALL");
    }

    public List<Order> getOrdersByBuyerProfileId(int buyerProfileId, String statusFilter) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM orders WHERE buyer_profile_id = ?");
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append(" AND order_status = ?");
        }
        sql.append(" ORDER BY order_date DESC");

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            ps.setInt(1, buyerProfileId);
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapResultSetToOrder(rs);
                o.setItems(getOrderItems(o.getOrderId()));
                o.setSubOrders(getSubOrdersByOrderId(o.getOrderId()));
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getOrdersByOrganizationId(int organizationId) {
        return getOrdersByOrganizationId(organizationId, "ALL");
    }

    public List<Order> getOrdersByOrganizationId(int organizationId, String statusFilter) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM orders WHERE organization_id = ?");
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append(" AND order_status = ?");
        }
        sql.append(" ORDER BY order_date DESC");

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            ps.setInt(1, organizationId);
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapResultSetToOrder(rs);
                o.setItems(getOrderItems(o.getOrderId()));
                o.setSubOrders(getSubOrdersByOrderId(o.getOrderId()));
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<SubOrder> getSubOrdersByOrderId(int orderId) {
        List<SubOrder> list = new ArrayList<>();
        String sql = """
            SELECT so.*, fp.farm_name, u.full_name AS farmer_name, u.phone AS farmer_phone
            FROM sub_orders so
            LEFT JOIN farmer_profiles fp ON so.farmer_profile_id = fp.farmer_profile_id
            LEFT JOIN users u ON fp.user_id = u.user_id
            WHERE so.order_id = ?
            ORDER BY so.sub_order_id ASC
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SubOrder so = mapResultSetToSubOrder(rs);
                List<OrderItem> items = getOrderItemsBySubOrderId(so.getSubOrderId());
                so.setItems(items);
                if ((so.getFarmerName() == null || so.getFarmerName().trim().isEmpty() || "Local Farmer".equalsIgnoreCase(so.getFarmerName().trim())) && items != null && !items.isEmpty()) {
                    for (OrderItem itm : items) {
                        if (itm.getFarmerName() != null && !itm.getFarmerName().trim().isEmpty()) {
                            so.setFarmerName(itm.getFarmerName());
                            if (itm.getFarmName() != null) so.setFarmName(itm.getFarmName());
                            break;
                        }
                    }
                }
                list.add(so);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<OrderItem> getOrderItemsBySubOrderId(int subOrderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = """
            SELECT oi.*, p.unit, fp.farm_name, u.full_name AS farmer_name,
                   (SELECT image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC LIMIT 1) AS primary_image_url
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            WHERE oi.sub_order_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, subOrderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem item = mapResultSetToOrderItem(rs);
                list.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = """
            SELECT oi.*, p.unit, fp.farm_name, u.full_name AS farmer_name,
                   (SELECT image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC LIMIT 1) AS primary_image_url
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            WHERE oi.order_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem item = mapResultSetToOrderItem(rs);
                list.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateOrderStatus(int orderId, String targetStatus) {
        String updateSql = "UPDATE orders SET order_status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_id = ?";
        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(updateSql)
        ) {
            ps.setString(1, targetStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePaymentStatus(int orderId, String newPaymentStatus) {
        String sql = "UPDATE orders SET payment_status = ? WHERE order_id = ?";
        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, newPaymentStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean confirmCashPayment(int orderId, int farmerProfileId, String ipAddress, String deviceInfo, String remarks) {
        String sqlCash = """
            INSERT INTO cash_confirmations (order_id, farmer_profile_id, confirmation_status, ip_address, device_info, remarks)
            VALUES (?, ?, 'CONFIRMED', ?, ?, ?)
            """;
        String sqlSub = "UPDATE sub_orders SET payment_status = 'PAID', sub_order_status = 'DELIVERED' WHERE order_id = ? AND farmer_profile_id = ?";

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            try (PreparedStatement psCash = con.prepareStatement(sqlCash)) {
                psCash.setInt(1, orderId);
                psCash.setInt(2, farmerProfileId);
                psCash.setString(3, ipAddress != null ? ipAddress : "127.0.0.1");
                psCash.setString(4, deviceInfo != null ? deviceInfo : "Web Browser");
                psCash.setString(5, remarks);
                psCash.executeUpdate();
            }

            try (PreparedStatement psSub = con.prepareStatement(sqlSub)) {
                psSub.setInt(1, orderId);
                psSub.setInt(2, farmerProfileId);
                psSub.executeUpdate();
            }

            recalculateMasterOrderStatus(con, orderId);

            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));

        int buyerProfileId = rs.getInt("buyer_profile_id");
        if (!rs.wasNull()) {
            o.setBuyerProfileId(buyerProfileId);
        }

        int organizationId = rs.getInt("organization_id");
        if (!rs.wasNull()) {
            o.setOrganizationId(organizationId);
        }

        try {
            o.setBuyerType(rs.getString("buyer_type"));
            o.setGstinApplied(rs.getString("gstin_applied"));
        } catch (SQLException ignored) {}

        o.setOrderNumber(rs.getString("order_number"));
        o.setDeliveryName(rs.getString("delivery_name"));
        o.setDeliveryPhone(rs.getString("delivery_phone"));
        o.setDeliveryAddress(rs.getString("delivery_address"));
        o.setDeliveryPincode(rs.getString("delivery_pincode"));
        o.setSubtotalAmount(rs.getBigDecimal("subtotal_amount"));
        o.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        o.setDeliveryCharge(rs.getBigDecimal("delivery_charge"));
        o.setPlatformFee(rs.getBigDecimal("platform_fee"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setPaymentStatus(rs.getString("payment_status"));
        o.setOrderStatus(rs.getString("order_status"));
        o.setOrderDate(rs.getTimestamp("order_date"));
        o.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            o.setDeliveryDate(rs.getDate("delivery_date"));
        } catch (SQLException ignored) {}

        try {
            o.setBuyerName(rs.getString("buyer_name"));
        } catch (SQLException ignored) {}

        try {
            o.setOrganizationName(rs.getString("organization_name"));
        } catch (SQLException ignored) {}

        return o;
    }

    private SubOrder mapResultSetToSubOrder(ResultSet rs) throws SQLException {
        SubOrder so = new SubOrder();
        so.setSubOrderId(rs.getInt("sub_order_id"));
        so.setOrderId(rs.getInt("order_id"));
        so.setFarmerProfileId(rs.getInt("farmer_profile_id"));
        so.setSubOrderNumber(rs.getString("sub_order_number"));
        so.setSubtotalAmount(rs.getBigDecimal("subtotal_amount"));
        so.setDeliveryCharge(rs.getBigDecimal("delivery_charge"));
        so.setTotalAmount(rs.getBigDecimal("total_amount"));
        so.setPaymentMethod(rs.getString("payment_method"));
        so.setPaymentStatus(rs.getString("payment_status"));
        so.setSubOrderStatus(rs.getString("sub_order_status"));
        so.setCreatedAt(rs.getTimestamp("created_at"));
        so.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            so.setDeliveryDate(rs.getDate("delivery_date"));
        } catch (SQLException ignored) {}

        try { so.setMasterOrderNumber(rs.getString("master_order_number")); } catch (SQLException ignored) {}
        try { so.setDeliveryName(rs.getString("delivery_name")); } catch (SQLException ignored) {}
        try { so.setDeliveryPhone(rs.getString("delivery_phone")); } catch (SQLException ignored) {}
        try { so.setDeliveryAddress(rs.getString("delivery_address")); } catch (SQLException ignored) {}
        try { so.setDeliveryPincode(rs.getString("delivery_pincode")); } catch (SQLException ignored) {}
        try { so.setBuyerName(rs.getString("buyer_name")); } catch (SQLException ignored) {}
        try { so.setOrganizationName(rs.getString("organization_name")); } catch (SQLException ignored) {}
        try { so.setFarmName(rs.getString("farm_name")); } catch (SQLException ignored) {}
        try { so.setFarmerName(rs.getString("farmer_name")); } catch (SQLException ignored) {}
        try { so.setFarmerPhone(rs.getString("farmer_phone")); } catch (SQLException ignored) {}

        try {
            java.math.BigDecimal pLatBd = rs.getBigDecimal("pickup_latitude");
            java.math.BigDecimal pLonBd = rs.getBigDecimal("pickup_longitude");
            java.math.BigDecimal dLatBd = rs.getBigDecimal("delivery_latitude");
            java.math.BigDecimal dLonBd = rs.getBigDecimal("delivery_longitude");
            java.math.BigDecimal distBd = rs.getBigDecimal("estimated_distance_km");
            so.setPickupLatitude(pLatBd != null ? pLatBd.doubleValue() : null);
            so.setPickupLongitude(pLonBd != null ? pLonBd.doubleValue() : null);
            so.setDeliveryLatitude(dLatBd != null ? dLatBd.doubleValue() : null);
            so.setDeliveryLongitude(dLonBd != null ? dLonBd.doubleValue() : null);
            so.setEstimatedDistanceKm(distBd != null ? distBd.doubleValue() : null);
        } catch (SQLException ignored) {}

        return so;
    }

    public Map<String, Object> getSubOrderTrackingDetails(int subOrderId, int userId, String role) {
        String sql = """
            SELECT so.*, o.order_number, o.buyer_profile_id, o.organization_id,
                   o.delivery_name AS master_delivery_name, o.delivery_address AS master_delivery_address,
                   o.delivery_phone AS master_delivery_phone, o.delivery_date AS master_delivery_date,
                   o.delivery_latitude AS master_delivery_lat, o.delivery_longitude AS master_delivery_lon,
                   bp.user_id AS buyer_user_id, bp.latitude AS bp_latitude, bp.longitude AS bp_longitude,
                   fp.user_id AS farmer_user_id, fp.farm_name, fp.farm_address, fp.latitude AS fp_latitude, fp.longitude AS fp_longitude,
                   org.org_name, org.owner_user_id, org.latitude AS org_latitude, org.longitude AS org_longitude,
                   u_f.full_name AS farmer_full_name,
                   COALESCE(u_b.full_name, u_direct_b.full_name) AS buyer_full_name,
                   COALESCE(bp.user_id, u_direct_b.user_id, o.buyer_profile_id) AS resolved_buyer_user_id
            FROM sub_orders so
            JOIN orders o ON so.order_id = o.order_id
            JOIN farmer_profiles fp ON so.farmer_profile_id = fp.farmer_profile_id
            JOIN users u_f ON fp.user_id = u_f.user_id
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            LEFT JOIN users u_b ON bp.user_id = u_b.user_id
            LEFT JOIN users u_direct_b ON o.buyer_profile_id = u_direct_b.user_id
            LEFT JOIN organizations org ON o.organization_id = org.organization_id
            WHERE so.sub_order_id = ?
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int farmerUserId = rs.getInt("farmer_user_id");
                    int buyerUserId = rs.getInt("resolved_buyer_user_id");
                    int orgId = rs.getInt("organization_id");
                    int orgOwnerUserId = rs.getInt("owner_user_id");

                    // Strict server-side role & ownership authorization
                    boolean authorized = false;
                    if ("ADMIN".equalsIgnoreCase(role)) {
                        authorized = true;
                    } else if ("FARMER".equalsIgnoreCase(role) && userId == farmerUserId) {
                        authorized = true;
                    } else if ("BUYER".equalsIgnoreCase(role) && (userId == buyerUserId || userId == rs.getInt("buyer_user_id"))) {
                        authorized = true;
                    } else if ("COMMERCIAL".equalsIgnoreCase(role)) {
                        if (userId == orgOwnerUserId) {
                            authorized = true;
                        } else if (orgId > 0) {
                            String memberCheck = "SELECT 1 FROM organization_members WHERE organization_id = ? AND user_id = ? AND status = 'ACTIVE'";
                            try (PreparedStatement psM = con.prepareStatement(memberCheck)) {
                                psM.setInt(1, orgId);
                                psM.setInt(2, userId);
                                try (ResultSet rsM = psM.executeQuery()) {
                                    if (rsM.next()) authorized = true;
                                }
                            }
                        }
                    }

                    if (!authorized) {
                        return null;
                    }

                    Map<String, Object> map = new HashMap<>();
                    map.put("subOrderId", rs.getInt("sub_order_id"));
                    map.put("subOrderNumber", rs.getString("sub_order_number"));
                    map.put("masterOrderNumber", rs.getString("order_number"));
                    map.put("subOrderStatus", rs.getString("sub_order_status"));

                    String farmName = rs.getString("farm_name");
                    if (farmName == null || farmName.trim().isEmpty()) farmName = rs.getString("farmer_full_name") + " Farm";
                    map.put("pickupName", farmName);
                    map.put("pickupAddress", rs.getString("farm_address"));

                    java.math.BigDecimal pLatBd = rs.getBigDecimal("pickup_latitude");
                    java.math.BigDecimal pLonBd = rs.getBigDecimal("pickup_longitude");
                    if (pLatBd == null) {
                        pLatBd = rs.getBigDecimal("fp_latitude");
                        pLonBd = rs.getBigDecimal("fp_longitude");
                    }

                    java.math.BigDecimal dLatBd = rs.getBigDecimal("delivery_latitude");
                    java.math.BigDecimal dLonBd = rs.getBigDecimal("delivery_longitude");
                    if (dLatBd == null) {
                        dLatBd = rs.getBigDecimal("master_delivery_lat");
                        dLonBd = rs.getBigDecimal("master_delivery_lon");
                    }
                    if (dLatBd == null) {
                        dLatBd = rs.getBigDecimal("bp_latitude");
                        dLonBd = rs.getBigDecimal("bp_longitude");
                    }
                    if (dLatBd == null) {
                        dLatBd = rs.getBigDecimal("org_latitude");
                        dLonBd = rs.getBigDecimal("org_longitude");
                    }

                    java.math.BigDecimal distBd = rs.getBigDecimal("estimated_distance_km");

                    Double pLat = pLatBd != null ? pLatBd.doubleValue() : null;
                    Double pLon = pLonBd != null ? pLonBd.doubleValue() : null;
                    Double dLat = dLatBd != null ? dLatBd.doubleValue() : null;
                    Double dLon = dLonBd != null ? dLonBd.doubleValue() : null;
                    Double distKm = distBd != null ? distBd.doubleValue() : null;

                    boolean hasValidCoords = (pLat != null && pLon != null && dLat != null && dLon != null
                            && pLat >= -90.0 && pLat <= 90.0 && pLon >= -180.0 && pLon <= 180.0
                            && dLat >= -90.0 && dLat <= 90.0 && dLon >= -180.0 && dLon <= 180.0);

                    map.put("pickupLat", pLat);
                    map.put("pickupLon", pLon);
                    map.put("deliveryLat", dLat);
                    map.put("deliveryLon", dLon);
                    map.put("estimatedDistanceKm", distKm);
                    map.put("hasValidCoords", hasValidCoords);

                    String dName = rs.getString("master_delivery_name");
                    if (dName == null || dName.isEmpty()) dName = rs.getString("buyer_full_name");
                    map.put("deliveryName", dName);
                    map.put("deliveryAddress", rs.getString("master_delivery_address"));
                    map.put("deliveryPhone", rs.getString("master_delivery_phone"));

                    java.sql.Date dDate = rs.getDate("delivery_date");
                    if (dDate == null) dDate = rs.getDate("master_delivery_date");
                    map.put("requestedDeliveryDate", dDate != null ? dDate.toString() : null);

                    return map;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static double calculateHaversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth radius in km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return Math.round((R * c) * 10.0) / 10.0;
    }

    private OrderItem mapResultSetToOrderItem(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setOrderItemId(rs.getInt("order_item_id"));
        item.setOrderId(rs.getInt("order_id"));

        int subOrderId = rs.getInt("sub_order_id");
        if (!rs.wasNull()) item.setSubOrderId(subOrderId);

        int farmerProfileId = rs.getInt("farmer_profile_id");
        if (!rs.wasNull()) item.setFarmerProfileId(farmerProfileId);

        item.setProductId(rs.getInt("product_id"));
        item.setProductName(rs.getString("product_name"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        item.setQuantity(rs.getDouble("quantity"));
        item.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        item.setFinalUnitPrice(rs.getBigDecimal("final_unit_price"));
        item.setSubtotal(rs.getBigDecimal("subtotal"));
        item.setCreatedAt(rs.getTimestamp("created_at"));

        try {
            item.setUnit(rs.getString("unit"));
            item.setFarmerName(rs.getString("farmer_name"));
            item.setFarmName(rs.getString("farm_name"));
            item.setPrimaryImageUrl(rs.getString("primary_image_url"));
        } catch (SQLException ignored) {}

        return item;
    }
}
