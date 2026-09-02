package com.kisaanconnect.dao;

import com.kisaanconnect.model.WalletTransaction;
import com.kisaanconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {

    public Map<String, Object> getFarmerSalesReport(int farmerProfileId) {
        Map<String, Object> report = new HashMap<>();

        String summarySql = """
            SELECT COUNT(DISTINCT so.sub_order_id) AS total_orders,
                   COALESCE(SUM(so.subtotal_amount), 0) AS total_revenue,
                   COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
                   COUNT(DISTINCT p.product_id) AS active_products,
                   COALESCE(SUM(CASE WHEN so.payment_method = 'WALLET' THEN so.subtotal_amount ELSE 0 END), 0) AS wallet_revenue,
                   COALESCE(SUM(CASE WHEN so.payment_method = 'CASH' THEN so.subtotal_amount ELSE 0 END), 0) AS cash_revenue,
                   COALESCE(SUM(CASE WHEN so.payment_method = 'UPI' THEN so.subtotal_amount ELSE 0 END), 0) AS upi_revenue
            FROM sub_orders so
            JOIN order_items oi ON so.sub_order_id = oi.sub_order_id
            JOIN products p ON oi.product_id = p.product_id
            WHERE so.farmer_profile_id = ?
            """;

        String topCropsSql = """
            SELECT p.product_name, p.unit,
                   COALESCE(SUM(oi.quantity), 0) AS qty_sold,
                   COALESCE(SUM(oi.subtotal), 0) AS revenue_earned
            FROM sub_orders so
            JOIN order_items oi ON so.sub_order_id = oi.sub_order_id
            JOIN products p ON oi.product_id = p.product_id
            WHERE so.farmer_profile_id = ?
            GROUP BY p.product_id, p.product_name, p.unit
            ORDER BY revenue_earned DESC
            LIMIT 10
            """;

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(summarySql)) {
                ps.setInt(1, farmerProfileId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    report.put("totalOrders", rs.getInt("total_orders"));
                    report.put("totalRevenue", rs.getBigDecimal("total_revenue"));
                    report.put("totalUnitsSold", rs.getDouble("total_units_sold"));
                    report.put("activeProducts", rs.getInt("active_products"));
                    report.put("walletRevenue", rs.getBigDecimal("wallet_revenue"));
                    report.put("cashRevenue", rs.getBigDecimal("cash_revenue"));
                    report.put("upiRevenue", rs.getBigDecimal("upi_revenue"));
                }
            }

            List<Map<String, Object>> topCrops = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(topCropsSql)) {
                ps.setInt(1, farmerProfileId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> crop = new HashMap<>();
                    crop.put("productName", rs.getString("product_name"));
                    crop.put("unit", rs.getString("unit"));
                    crop.put("quantitySold", rs.getDouble("qty_sold"));
                    crop.put("revenue", rs.getBigDecimal("revenue_earned"));
                    topCrops.add(crop);
                }
            }
            report.put("topCrops", topCrops);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }

    public List<Map<String, Object>> getFarmerEarningsDetailed(int farmerProfileId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT so.sub_order_id, so.sub_order_number, so.subtotal_amount, so.payment_method, so.sub_order_status, so.created_at,
                   o.delivery_name, COALESCE(u.full_name, org.org_name, o.delivery_name) AS customer_name,
                   GROUP_CONCAT(CONCAT(oi.product_name, ' (', oi.quantity, ' ', COALESCE(p.unit, 'kg'), ')') SEPARATOR ', ') AS products_summary
            FROM sub_orders so
            JOIN orders o ON so.order_id = o.order_id
            JOIN order_items oi ON so.sub_order_id = oi.sub_order_id
            JOIN products p ON oi.product_id = p.product_id
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            LEFT JOIN users u ON bp.user_id = u.user_id
            LEFT JOIN organizations org ON o.organization_id = org.organization_id
            WHERE so.farmer_profile_id = ?
            GROUP BY so.sub_order_id, so.sub_order_number, so.subtotal_amount, so.payment_method, so.sub_order_status, so.created_at, o.delivery_name, customer_name
            ORDER BY so.created_at DESC
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, farmerProfileId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("subOrderId", rs.getInt("sub_order_id"));
                    map.put("subOrderNumber", rs.getString("sub_order_number"));
                    map.put("amount", rs.getBigDecimal("subtotal_amount"));
                    map.put("paymentMethod", rs.getString("payment_method"));
                    map.put("status", rs.getString("sub_order_status"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("customerName", rs.getString("customer_name"));
                    map.put("productsSummary", rs.getString("products_summary"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getFarmerInventoryReport(int farmerProfileId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT p.product_id, p.product_name, c.category_name, p.price, p.unit,
                   COALESCE(i.available_quantity, 0) AS available_stock,
                   COALESCE(SUM(oi.quantity), 0) AS units_sold,
                   COALESCE(SUM(oi.subtotal), 0) AS total_sales_value
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.category_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            LEFT JOIN order_items oi ON p.product_id = oi.product_id
            WHERE p.farmer_profile_id = ?
            GROUP BY p.product_id, p.product_name, c.category_name, p.price, p.unit, i.available_quantity
            ORDER BY p.product_name ASC
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, farmerProfileId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("productId", rs.getInt("product_id"));
                    item.put("productName", rs.getString("product_name"));
                    item.put("categoryName", rs.getString("category_name"));
                    item.put("price", rs.getBigDecimal("price"));
                    item.put("unit", rs.getString("unit"));
                    item.put("availableStock", rs.getDouble("available_stock"));
                    item.put("unitsSold", rs.getDouble("units_sold"));
                    item.put("totalSalesValue", rs.getBigDecimal("total_sales_value"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Object> getCommercialProcurementReport(int organizationId) {
        Map<String, Object> report = new HashMap<>();

        String summarySql = """
            SELECT COUNT(order_id) AS total_procurements,
                   COALESCE(SUM(total_amount), 0) AS total_spend,
                   COALESCE(SUM(subtotal_amount), 0) AS raw_produce_cost,
                   COALESCE(SUM(delivery_charge), 0) AS logistics_cost,
                   COALESCE(SUM(platform_fee), 0) AS platform_fees
            FROM orders
            WHERE organization_id = ?
            """;

        String topProcuredSql = """
            SELECT oi.product_name,
                   SUM(oi.quantity) AS total_qty,
                   SUM(oi.subtotal) AS total_spent
            FROM orders o
            JOIN order_items oi ON o.order_id = oi.order_id
            WHERE o.organization_id = ?
            GROUP BY oi.product_name
            ORDER BY total_spent DESC
            LIMIT 10
            """;

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(summarySql)) {
                ps.setInt(1, organizationId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    report.put("totalProcurements", rs.getInt("total_procurements"));
                    report.put("totalSpend", rs.getBigDecimal("total_spend"));
                    report.put("rawProduceCost", rs.getBigDecimal("raw_produce_cost"));
                    report.put("logisticsCost", rs.getBigDecimal("logistics_cost"));
                    report.put("platformFees", rs.getBigDecimal("platform_fees"));
                }
            }

            List<Map<String, Object>> topItems = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(topProcuredSql)) {
                ps.setInt(1, organizationId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("productName", rs.getString("product_name"));
                    item.put("totalQty", rs.getDouble("total_qty"));
                    item.put("totalSpent", rs.getBigDecimal("total_spent"));
                    topItems.add(item);
                }
            }
            report.put("topItems", topItems);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }

    public List<Map<String, Object>> getCommercialSupplierSummary(int organizationId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT u.full_name AS farmer_name, fp.farm_name, fp.district, fp.state,
                   COUNT(DISTINCT o.order_id) AS total_orders,
                   SUM(oi.quantity) AS total_units_procured,
                   SUM(oi.subtotal) AS total_volume_value
            FROM orders o
            JOIN order_items oi ON o.order_id = oi.order_id
            JOIN products p ON oi.product_id = p.product_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            WHERE o.organization_id = ?
            GROUP BY u.full_name, fp.farm_name, fp.district, fp.state
            ORDER BY total_volume_value DESC
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, organizationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> sup = new HashMap<>();
                    sup.put("farmerName", rs.getString("farmer_name"));
                    sup.put("farmName", rs.getString("farm_name"));
                    sup.put("district", rs.getString("district"));
                    sup.put("state", rs.getString("state"));
                    sup.put("totalOrders", rs.getInt("total_orders"));
                    sup.put("totalUnits", rs.getDouble("total_units_procured"));
                    sup.put("totalValue", rs.getBigDecimal("total_volume_value"));
                    list.add(sup);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Object> getBuyerSpendingReport(int userId) {
        Map<String, Object> report = new HashMap<>();

        String summarySql = """
            SELECT COUNT(DISTINCT o.order_id) AS total_orders,
                   COALESCE(SUM(o.total_amount), 0) AS total_spent,
                   COALESCE(SUM(oi.quantity), 0) AS total_units_bought
            FROM orders o
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            LEFT JOIN order_items oi ON o.order_id = oi.order_id
            WHERE bp.user_id = ?
            """;

        String topItemsSql = """
            SELECT oi.product_name,
                   SUM(oi.quantity) AS total_qty,
                   SUM(oi.subtotal) AS total_cost
            FROM orders o
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            JOIN order_items oi ON o.order_id = oi.order_id
            WHERE bp.user_id = ?
            GROUP BY oi.product_name
            ORDER BY total_cost DESC
            LIMIT 10
            """;

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(summarySql)) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    report.put("totalOrders", rs.getInt("total_orders"));
                    report.put("totalSpent", rs.getBigDecimal("total_spent"));
                    report.put("totalUnitsBought", rs.getDouble("total_units_bought"));
                }
            }

            List<Map<String, Object>> topItems = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(topItemsSql)) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("productName", rs.getString("product_name"));
                    item.put("totalQty", rs.getDouble("total_qty"));
                    item.put("totalCost", rs.getBigDecimal("total_cost"));
                    topItems.add(item);
                }
            }
            report.put("topItems", topItems);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }

    private String getTimeFilterSql(String timeRange, String dateColumn) {
        if ("7d".equalsIgnoreCase(timeRange)) {
            return " " + dateColumn + " >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
        } else if ("30d".equalsIgnoreCase(timeRange)) {
            return " " + dateColumn + " >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
        } else if ("90d".equalsIgnoreCase(timeRange)) {
            return " " + dateColumn + " >= DATE_SUB(NOW(), INTERVAL 90 DAY)";
        } else if ("1y".equalsIgnoreCase(timeRange)) {
            return " " + dateColumn + " >= DATE_SUB(NOW(), INTERVAL 1 YEAR)";
        }
        return " 1=1";
    }

    public Map<String, Object> getAdminPlatformAnalytics(String timeRange) {
        Map<String, Object> report = new HashMap<>();
        String timeCond = getTimeFilterSql(timeRange, "o.order_date");

        String statsSql = """
            SELECT 
                (SELECT COUNT(*) FROM users WHERE is_deleted = FALSE) AS total_users,
                (SELECT COUNT(*) FROM users WHERE is_deleted = FALSE AND status = 'ACTIVE') AS active_users,
                (SELECT COUNT(*) FROM users WHERE role = 'FARMER' AND is_deleted = FALSE AND status = 'ACTIVE') AS active_farmers,
                (SELECT COUNT(*) FROM users WHERE role = 'BUYER' AND is_deleted = FALSE AND status = 'ACTIVE') AS active_buyers,
                (SELECT COUNT(*) FROM users WHERE role = 'COMMERCIAL' AND is_deleted = FALSE AND status = 'ACTIVE') AS active_commercial,
                (SELECT COUNT(*) FROM users WHERE is_deleted = FALSE AND status = 'PENDING') AS pending_users,
                (SELECT COUNT(*) FROM users WHERE is_deleted = FALSE AND status = 'SUSPENDED') AS suspended_users,
                (SELECT COUNT(*) FROM products WHERE is_available = TRUE) AS total_products,
                (SELECT COUNT(*) FROM organizations) AS total_organizations
            """;

        String orderStatsSql = "SELECT " +
            "COUNT(*) AS total_orders, " +
            "COALESCE(SUM(CASE WHEN order_status NOT IN ('CANCELLED', 'REJECTED') AND payment_status != 'REFUNDED' THEN total_amount ELSE 0 END), 0) AS total_gmv, " +
            "COALESCE(SUM(CASE WHEN order_status = 'COMPLETED' THEN total_amount ELSE 0 END), 0) AS completed_gmv, " +
            "COALESCE(SUM(CASE WHEN order_status = 'COMPLETED' THEN 1 ELSE 0 END), 0) AS completed_orders " +
            "FROM orders o WHERE " + timeCond;

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(statsSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    report.put("totalUsers", rs.getInt("total_users"));
                    report.put("activeUsers", rs.getInt("active_users"));
                    report.put("totalFarmers", rs.getInt("active_farmers"));
                    report.put("activeFarmers", rs.getInt("active_farmers"));
                    report.put("approvedFarmers", rs.getInt("active_farmers"));
                    report.put("activeBuyers", rs.getInt("active_buyers"));
                    report.put("totalCommercial", rs.getInt("active_commercial"));
                    report.put("activeCommercial", rs.getInt("active_commercial"));
                    report.put("approvedCommercial", rs.getInt("active_commercial"));
                    report.put("pendingUsers", rs.getInt("pending_users"));
                    report.put("suspendedUsers", rs.getInt("suspended_users"));
                    report.put("totalProducts", rs.getInt("total_products"));
                    report.put("totalOrganizations", rs.getInt("total_organizations"));
                }
            }

            try (PreparedStatement ps2 = con.prepareStatement(orderStatsSql);
                 ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) {
                    report.put("totalOrders", rs2.getInt("total_orders"));
                    report.put("totalGMV", rs2.getBigDecimal("total_gmv"));
                    report.put("totalRevenue", rs2.getBigDecimal("total_gmv"));
                    report.put("completedGMV", rs2.getBigDecimal("completed_gmv"));
                    report.put("completedOrders", rs2.getInt("completed_orders"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return report;
    }

    public List<Map<String, Object>> getAdminGMVTrend(String timeRange) {
        List<Map<String, Object>> list = new ArrayList<>();
        String timeCond = getTimeFilterSql(timeRange, "order_date");

        String sql = "SELECT DATE(order_date) AS txn_date, " +
                     "COALESCE(SUM(CASE WHEN order_status NOT IN ('CANCELLED', 'REJECTED') AND payment_status != 'REFUNDED' THEN total_amount ELSE 0 END), 0) AS daily_gmv, " +
                     "COUNT(*) AS daily_orders " +
                     "FROM orders WHERE " + timeCond + " " +
                     "GROUP BY DATE(order_date) " +
                     "ORDER BY txn_date ASC LIMIT 30";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> point = new HashMap<>();
                point.put("date", rs.getDate("txn_date") != null ? rs.getDate("txn_date").toString() : "");
                point.put("gmv", rs.getBigDecimal("daily_gmv"));
                point.put("ordersCount", rs.getInt("daily_orders"));
                list.add(point);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Integer> getAdminOrderStatusBreakdown(String timeRange) {
        Map<String, Integer> map = new HashMap<>();
        String timeCond = getTimeFilterSql(timeRange, "order_date");

        String sql = "SELECT order_status, COUNT(*) AS cnt FROM orders WHERE " + timeCond + " GROUP BY order_status";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("order_status"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public List<Map<String, Object>> getAdminTopProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT oi.product_name, p.category, p.unit,
                   COALESCE(SUM(oi.quantity), 0) AS total_qty_sold,
                   COALESCE(SUM(oi.subtotal), 0) AS total_revenue,
                   COUNT(DISTINCT oi.order_id) AS total_orders
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.order_id
            LEFT JOIN products p ON oi.product_id = p.product_id
            WHERE o.order_status NOT IN ('CANCELLED', 'REJECTED')
            GROUP BY oi.product_name, p.category, p.unit
            ORDER BY total_revenue DESC
            LIMIT ?
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 10);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> p = new HashMap<>();
                    p.put("productName", rs.getString("product_name"));
                    p.put("category", rs.getString("category") != null ? rs.getString("category") : "Produce");
                    p.put("unit", rs.getString("unit") != null ? rs.getString("unit") : "kg");
                    p.put("quantitySold", rs.getDouble("total_qty_sold"));
                    p.put("revenue", rs.getBigDecimal("total_revenue"));
                    p.put("orderCount", rs.getInt("total_orders"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getAdminRecentActivity(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
            SELECT o.order_id, o.order_number, o.order_date, o.delivery_name, o.buyer_type,
                   o.payment_method, o.payment_status, o.order_status, o.total_amount,
                   COALESCE(u.full_name, org.org_name, o.delivery_name) AS customer_name
            FROM orders o
            LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id
            LEFT JOIN users u ON bp.user_id = u.user_id
            LEFT JOIN organizations org ON o.organization_id = org.organization_id
            ORDER BY o.order_date DESC
            LIMIT ?
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 15);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> act = new HashMap<>();
                    act.put("orderId", rs.getInt("order_id"));
                    act.put("orderNumber", rs.getString("order_number"));
                    act.put("orderDate", rs.getTimestamp("order_date"));
                    act.put("customerName", rs.getString("customer_name"));
                    act.put("buyerType", rs.getString("buyer_type"));
                    act.put("paymentMethod", rs.getString("payment_method"));
                    act.put("paymentStatus", rs.getString("payment_status"));
                    act.put("orderStatus", rs.getString("order_status"));
                    act.put("totalAmount", rs.getBigDecimal("total_amount"));
                    list.add(act);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Object> getPlatformAdminOverview() {
        return getAdminPlatformAnalytics("all");
    }

    public List<WalletTransaction> getAllPlatformTransactions() {
        List<WalletTransaction> list = new ArrayList<>();
        String sql = "SELECT * FROM user_wallet_transactions ORDER BY transaction_date DESC LIMIT 50";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                WalletTransaction txn = new WalletTransaction();
                txn.setTransactionId(rs.getInt("transaction_id"));
                txn.setWalletId(rs.getInt("wallet_id"));
                int orderId = rs.getInt("order_id");
                if (!rs.wasNull()) {
                    txn.setOrderId(orderId);
                }
                txn.setTransactionType(rs.getString("transaction_type"));
                txn.setTransactionSource(rs.getString("transaction_source"));
                txn.setAmount(rs.getBigDecimal("amount"));
                txn.setBalanceAfter(rs.getBigDecimal("balance_after"));
                txn.setTxnReferenceNo(rs.getString("txn_reference_no"));
                txn.setRemarks(rs.getString("remarks"));
                txn.setStatus(rs.getString("status"));
                txn.setTransactionDate(rs.getTimestamp("transaction_date"));
                list.add(txn);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
