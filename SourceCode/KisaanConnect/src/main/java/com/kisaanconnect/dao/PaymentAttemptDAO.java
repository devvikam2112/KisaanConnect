package com.kisaanconnect.dao;

import com.kisaanconnect.model.OrderItem;
import com.kisaanconnect.model.PaymentAttempt;
import com.kisaanconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentAttemptDAO {

    /**
     * Persists the durable payment attempt and immutable item snapshot before calling Razorpay API.
     */
    public int createAttemptWithItems(PaymentAttempt attempt, List<OrderItem> items) {
        String sqlAttempt = """
            INSERT INTO payment_attempts (
                user_id, buyer_profile_id, organization_id, gateway_order_id, amount, currency,
                delivery_name, delivery_phone, delivery_address, delivery_pincode, delivery_date,
                status, expires_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'INITIATED', DATE_ADD(NOW(), INTERVAL 30 MINUTE))
            """;

        String sqlItem = """
            INSERT INTO payment_attempt_items (
                attempt_id, product_id, farmer_profile_id, product_name, unit_price, quantity,
                discount_amount, final_unit_price, subtotal, unit
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int attemptId = 0;
            try (PreparedStatement psA = con.prepareStatement(sqlAttempt, Statement.RETURN_GENERATED_KEYS)) {
                psA.setInt(1, attempt.getUserId());
                if (attempt.getBuyerProfileId() != null) psA.setInt(2, attempt.getBuyerProfileId()); else psA.setNull(2, Types.INTEGER);
                if (attempt.getOrganizationId() != null) psA.setInt(3, attempt.getOrganizationId()); else psA.setNull(3, Types.INTEGER);
                psA.setString(4, attempt.getGatewayOrderId());
                psA.setBigDecimal(5, attempt.getAmount());
                psA.setString(6, attempt.getCurrency() != null ? attempt.getCurrency() : "INR");
                psA.setString(7, attempt.getDeliveryName());
                psA.setString(8, attempt.getDeliveryPhone());
                psA.setString(9, attempt.getDeliveryAddress());
                psA.setString(10, attempt.getDeliveryPincode());
                if (attempt.getDeliveryDate() != null) psA.setDate(11, attempt.getDeliveryDate()); else psA.setNull(11, Types.DATE);

                psA.executeUpdate();
                try (ResultSet rs = psA.getGeneratedKeys()) {
                    if (rs.next()) {
                        attemptId = rs.getInt(1);
                    }
                }
            }

            if (attemptId > 0 && items != null) {
                try (PreparedStatement psI = con.prepareStatement(sqlItem)) {
                    for (OrderItem item : items) {
                        psI.setInt(1, attemptId);
                        psI.setInt(2, item.getProductId());
                        psI.setInt(3, item.getFarmerProfileId());
                        psI.setString(4, item.getProductName());
                        psI.setBigDecimal(5, item.getUnitPrice());
                        psI.setDouble(6, item.getQuantity());
                        psI.setBigDecimal(7, item.getDiscountAmount() != null ? item.getDiscountAmount() : BigDecimal.ZERO);
                        psI.setBigDecimal(8, item.getFinalUnitPrice() != null ? item.getFinalUnitPrice() : item.getUnitPrice());
                        psI.setBigDecimal(9, item.getSubtotal());
                        psI.setString(10, item.getUnit());
                        psI.addBatch();
                    }
                    psI.executeBatch();
                }
            }

            con.commit();
            return attemptId;
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
            return 0;
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Updates the attempt with the confirmed Razorpay order ID and marks it 'CREATED'.
     */
    public boolean updateGatewayOrderId(int attemptId, String gatewayOrderId) {
        String sql = "UPDATE payment_attempts SET gateway_order_id = ?, status = 'CREATED' WHERE attempt_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, gatewayOrderId);
            ps.setInt(2, attemptId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Retrieves attempt with its immutable items by Razorpay Order ID.
     */
    public PaymentAttempt getAttemptByGatewayOrderId(String gatewayOrderId) {
        if (gatewayOrderId == null || gatewayOrderId.trim().isEmpty()) return null;

        String sql = "SELECT * FROM payment_attempts WHERE gateway_order_id = ?";
        PaymentAttempt attempt = null;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, gatewayOrderId.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    attempt = new PaymentAttempt();
                    attempt.setAttemptId(rs.getInt("attempt_id"));
                    attempt.setUserId(rs.getInt("user_id"));
                    int bId = rs.getInt("buyer_profile_id");
                    if (!rs.wasNull()) attempt.setBuyerProfileId(bId);
                    int oId = rs.getInt("organization_id");
                    if (!rs.wasNull()) attempt.setOrganizationId(oId);
                    attempt.setGatewayOrderId(rs.getString("gateway_order_id"));
                    attempt.setAmount(rs.getBigDecimal("amount"));
                    attempt.setCurrency(rs.getString("currency"));
                    attempt.setDeliveryName(rs.getString("delivery_name"));
                    attempt.setDeliveryPhone(rs.getString("delivery_phone"));
                    attempt.setDeliveryAddress(rs.getString("delivery_address"));
                    attempt.setDeliveryPincode(rs.getString("delivery_pincode"));
                    attempt.setDeliveryDate(rs.getDate("delivery_date"));
                    attempt.setStatus(rs.getString("status"));
                    int ordId = rs.getInt("order_id");
                    if (!rs.wasNull()) attempt.setOrderId(ordId);
                    attempt.setCreatedAt(rs.getTimestamp("created_at"));
                    attempt.setUpdatedAt(rs.getTimestamp("updated_at"));
                    attempt.setExpiresAt(rs.getTimestamp("expires_at"));
                }
            }

            if (attempt != null) {
                String sqlItems = "SELECT * FROM payment_attempt_items WHERE attempt_id = ?";
                try (PreparedStatement psI = con.prepareStatement(sqlItems)) {
                    psI.setInt(1, attempt.getAttemptId());
                    try (ResultSet rsI = psI.executeQuery()) {
                        List<OrderItem> items = new ArrayList<>();
                        while (rsI.next()) {
                            OrderItem oi = new OrderItem();
                            oi.setProductId(rsI.getInt("product_id"));
                            oi.setFarmerProfileId(rsI.getInt("farmer_profile_id"));
                            oi.setProductName(rsI.getString("product_name"));
                            oi.setUnitPrice(rsI.getBigDecimal("unit_price"));
                            oi.setQuantity(rsI.getDouble("quantity"));
                            oi.setDiscountAmount(rsI.getBigDecimal("discount_amount"));
                            oi.setFinalUnitPrice(rsI.getBigDecimal("final_unit_price"));
                            oi.setSubtotal(rsI.getBigDecimal("subtotal"));
                            oi.setUnit(rsI.getString("unit"));
                            items.add(oi);
                        }
                        attempt.setItems(items);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attempt;
    }

    /**
     * Atomically transitions attempt from 'CREATED' -> 'PROCESSING'.
     */
    public boolean markProcessing(String gatewayOrderId) {
        String sql = "UPDATE payment_attempts SET status = 'PROCESSING' WHERE gateway_order_id = ? AND status IN ('CREATED', 'INITIATED')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, gatewayOrderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Atomically marks attempt 'SUCCESS' and maps created order_id.
     */
    public boolean markSuccess(String gatewayOrderId, int orderId) {
        String sql = "UPDATE payment_attempts SET status = 'SUCCESS', order_id = ? WHERE gateway_order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, gatewayOrderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Logs payment failure into durable recovery table for fail-safe auto-refund.
     */
    public boolean logRecovery(int userId, String gatewayPaymentId, String gatewayOrderId, BigDecimal amount, String failureReason) {
        String sql = """
            INSERT INTO payment_recovery_logs (user_id, gateway_payment_id, gateway_order_id, amount, failure_reason, refund_status)
            VALUES (?, ?, ?, ?, ?, 'REFUND_INITIATED')
            ON DUPLICATE KEY UPDATE failure_reason = VALUES(failure_reason)
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, gatewayPaymentId);
            ps.setString(3, gatewayOrderId);
            ps.setBigDecimal(4, amount);
            ps.setString(5, failureReason);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates recovery log with refund reference upon confirmed completion.
     */
    public boolean updateRecoveryRefund(String gatewayPaymentId, String refundStatus, String refundReference) {
        String sql = "UPDATE payment_recovery_logs SET refund_status = ?, refund_reference = ?, retry_count = retry_count + 1, last_retry_at = CURRENT_TIMESTAMP WHERE gateway_payment_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, refundStatus);
            ps.setString(2, refundReference);
            ps.setString(3, gatewayPaymentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
