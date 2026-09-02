package com.kisaanconnect.dao;

import com.kisaanconnect.model.AdminAuditLog;
import com.kisaanconnect.model.User;
import com.kisaanconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class AdminDAO {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    public Map<String, Object> getPlatformStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = """
            SELECT
                COUNT(*) AS total_users,
                SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending_users,
                SUM(CASE WHEN role = 'FARMER' THEN 1 ELSE 0 END) AS total_farmers,
                SUM(CASE WHEN role = 'FARMER' AND status = 'ACTIVE' THEN 1 ELSE 0 END) AS approved_farmers,
                SUM(CASE WHEN role = 'BUYER' AND status = 'ACTIVE' THEN 1 ELSE 0 END) AS approved_buyers,
                SUM(CASE WHEN role = 'COMMERCIAL' THEN 1 ELSE 0 END) AS total_commercial,
                SUM(CASE WHEN role = 'COMMERCIAL' AND status = 'ACTIVE' THEN 1 ELSE 0 END) AS approved_commercial,
                SUM(CASE WHEN status = 'SUSPENDED' THEN 1 ELSE 0 END) AS suspended_users,
                (SELECT COUNT(*) FROM products) AS total_products,
                (SELECT COUNT(*) FROM orders) AS total_orders,
                (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status NOT IN ('CANCELLED', 'REFUNDED')) AS total_gmv,
                (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status = 'COMPLETED') AS total_revenue
            FROM users
            WHERE is_deleted = 0
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int totUsers = rs.getInt("total_users");
                int pendUsers = rs.getInt("pending_users");
                int totFarmers = rs.getInt("total_farmers");
                int appFarmers = rs.getInt("approved_farmers");
                int appBuyers = rs.getInt("approved_buyers");
                int totComm = rs.getInt("total_commercial");
                int appComm = rs.getInt("approved_commercial");
                int suspUsers = rs.getInt("suspended_users");
                int totProds = rs.getInt("total_products");
                int totOrds = rs.getInt("total_orders");
                BigDecimal totGmv = rs.getBigDecimal("total_gmv");
                BigDecimal totRev = rs.getBigDecimal("total_revenue");

                if (totGmv == null) totGmv = BigDecimal.ZERO;
                if (totRev == null) totRev = BigDecimal.ZERO;

                stats.put("totalUsers", totUsers);
                stats.put("pendingUsers", pendUsers);
                stats.put("totalFarmers", totFarmers);
                stats.put("approvedFarmers", appFarmers);
                stats.put("activeFarmers", appFarmers);
                stats.put("approvedBuyers", appBuyers);
                stats.put("totalCommercial", totComm);
                stats.put("approvedCommercial", appComm);
                stats.put("activeCommercial", appComm);
                stats.put("suspendedUsers", suspUsers);
                stats.put("totalProducts", totProds);
                stats.put("totalOrders", totOrds);
                stats.put("totalGMV", totGmv);
                stats.put("totalRevenue", totRev);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    public List<User> getUsersByFilter(String roleFilter, String statusFilter, String search) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE is_deleted = 0");
        List<Object> params = new ArrayList<>();

        if (roleFilter != null && !roleFilter.isEmpty() && !"ALL".equalsIgnoreCase(roleFilter)) {
            sql.append(" AND role = ?");
            params.add(roleFilter.toUpperCase().trim());
        }

        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND status = ?");
            params.add(statusFilter.toUpperCase().trim());
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?)");
            String term = "%" + search.trim() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append(" ORDER BY created_at DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setFullName(rs.getString("full_name"));
                    u.setEmail(rs.getString("email"));
                    u.setPhone(rs.getString("phone"));
                    u.setRole(rs.getString("role"));
                    u.setStatus(rs.getString("status"));
                    u.setRejectionReason(rs.getString("rejection_reason"));
                    u.setLastLogin(rs.getTimestamp("last_login"));
                    u.setCreatedAt(rs.getTimestamp("created_at"));
                    u.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Object> getUserFullProfile(int userId) {
        Map<String, Object> profile = new HashMap<>();
        String userSql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(userSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    profile.put("userId", rs.getInt("user_id"));
                    profile.put("fullName", rs.getString("full_name"));
                    profile.put("email", rs.getString("email"));
                    profile.put("phone", rs.getString("phone"));
                    profile.put("role", rs.getString("role"));
                    profile.put("status", rs.getString("status"));
                    profile.put("rejectionReason", rs.getString("rejection_reason"));
                    profile.put("createdAt", rs.getTimestamp("created_at"));

                    String role = rs.getString("role");
                    if ("FARMER".equalsIgnoreCase(role)) {
                        String fSql = "SELECT * FROM farmer_profiles WHERE user_id = ?";
                        try (PreparedStatement psF = con.prepareStatement(fSql)) {
                            psF.setInt(1, userId);
                            try (ResultSet rsF = psF.executeQuery()) {
                                if (rsF.next()) {
                                    profile.put("farmName", rsF.getString("farm_name"));
                                    profile.put("farmAddress", rsF.getString("farm_address"));
                                    profile.put("village", rsF.getString("village"));
                                    profile.put("taluka", rsF.getString("taluka"));
                                    profile.put("district", rsF.getString("district"));
                                    profile.put("state", rsF.getString("state"));
                                    profile.put("pincode", rsF.getString("pincode"));
                                    profile.put("latitude", rsF.getObject("latitude"));
                                    profile.put("longitude", rsF.getObject("longitude"));
                                }
                            }
                        }
                    } else if ("BUYER".equalsIgnoreCase(role)) {
                        String bSql = "SELECT * FROM buyer_profiles WHERE user_id = ?";
                        try (PreparedStatement psB = con.prepareStatement(bSql)) {
                            psB.setInt(1, userId);
                            try (ResultSet rsB = psB.executeQuery()) {
                                if (rsB.next()) {
                                    profile.put("address", rsB.getString("address"));
                                    profile.put("city", rsB.getString("city"));
                                    profile.put("district", rsB.getString("district"));
                                    profile.put("state", rsB.getString("state"));
                                    profile.put("pincode", rsB.getString("pincode"));
                                    profile.put("latitude", rsB.getObject("latitude"));
                                    profile.put("longitude", rsB.getObject("longitude"));
                                }
                            }
                        }
                    } else if ("COMMERCIAL".equalsIgnoreCase(role)) {
                        String cSql = """
                            SELECT o.* FROM organizations o
                            LEFT JOIN organization_members om ON o.organization_id = om.organization_id
                            WHERE o.owner_user_id = ? OR om.user_id = ?
                            LIMIT 1
                            """;
                        try (PreparedStatement psC = con.prepareStatement(cSql)) {
                            psC.setInt(1, userId);
                            psC.setInt(2, userId);
                            try (ResultSet rsC = psC.executeQuery()) {
                                if (rsC.next()) {
                                    profile.put("orgName", rsC.getString("org_name"));
                                    profile.put("gstin", rsC.getString("gstin"));
                                    profile.put("panNumber", rsC.getString("pan_number"));
                                    profile.put("businessEmail", rsC.getString("business_email"));
                                    profile.put("businessPhone", rsC.getString("business_phone"));
                                    profile.put("address", rsC.getString("address"));
                                    profile.put("city", rsC.getString("city"));
                                    profile.put("district", rsC.getString("district"));
                                    profile.put("state", rsC.getString("state"));
                                    profile.put("pincode", rsC.getString("pincode"));
                                    profile.put("latitude", rsC.getObject("latitude"));
                                    profile.put("longitude", rsC.getObject("longitude"));
                                }
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return profile;
    }

    public boolean approveUser(int targetUserId, int adminUserId, String ipAddress) {
        String updateSql = "UPDATE users SET status = 'ACTIVE', rejection_reason = NULL, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setInt(1, targetUserId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                logAdminAction(adminUserId, "ADMIN_APPROVED_USER", targetUserId, "USER", targetUserId, "Approved registration verification", ipAddress);
                notificationDAO.createNotification(targetUserId, null, null, null,
                    "Account Verified & Approved",
                    "Your KisaanConnect account has been reviewed and verified by administrator. You now have full platform access.",
                    "SYSTEM", "/index.jsp");
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean rejectUser(int targetUserId, String reason, int adminUserId, String ipAddress) {
        String updateSql = "UPDATE users SET status = 'REJECTED', rejection_reason = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setString(1, reason != null ? reason : "Information provided does not meet verification requirements.");
            ps.setInt(2, targetUserId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                logAdminAction(adminUserId, "ADMIN_REJECTED_USER", targetUserId, "USER", targetUserId, "Rejection reason: " + reason, ipAddress);
                notificationDAO.createNotification(targetUserId, null, null, null,
                    "Account Verification Rejected",
                    "Your verification was not approved. Reason: " + reason,
                    "SYSTEM", "/auth/pending-verification.jsp");
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleUserStatus(int targetUserId, String targetStatus, int adminUserId, String ipAddress) {
        String updateSql = "UPDATE users SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setString(1, targetStatus);
            ps.setInt(2, targetUserId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                String action = "ACTIVE".equalsIgnoreCase(targetStatus) ? "ADMIN_REACTIVATED_USER" : "ADMIN_SUSPENDED_USER";
                logAdminAction(adminUserId, action, targetUserId, "USER", targetUserId, "Changed status to " + targetStatus, ipAddress);
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public void logAdminAction(int adminUserId, String action, Integer targetUserId, String targetEntity, Integer targetEntityId, String details, String ipAddress) {
        String sql = """
            INSERT INTO admin_audit_logs (admin_user_id, action, target_user_id, target_entity, target_entity_id, details, ip_address)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, adminUserId);
            ps.setString(2, action);
            if (targetUserId != null) ps.setInt(3, targetUserId); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, targetEntity);
            if (targetEntityId != null) ps.setInt(5, targetEntityId); else ps.setNull(5, Types.INTEGER);
            ps.setString(6, details);
            ps.setString(7, ipAddress);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<AdminAuditLog> getAuditLogs(int limit) {
        List<AdminAuditLog> list = new ArrayList<>();
        String sql = """
            SELECT aal.*, u_admin.full_name AS admin_name, u_tgt.full_name AS target_user_name
            FROM admin_audit_logs aal
            JOIN users u_admin ON aal.admin_user_id = u_admin.user_id
            LEFT JOIN users u_tgt ON aal.target_user_id = u_tgt.user_id
            ORDER BY aal.created_at DESC
            LIMIT ?
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit > 0 ? limit : 50);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AdminAuditLog log = new AdminAuditLog();
                    log.setLogId(rs.getInt("log_id"));
                    log.setAdminUserId(rs.getInt("admin_user_id"));
                    log.setAdminName(rs.getString("admin_name"));
                    log.setAction(rs.getString("action"));
                    log.setTargetUserId((Integer) rs.getObject("target_user_id"));
                    log.setTargetUserName(rs.getString("target_user_name"));
                    log.setTargetEntity(rs.getString("target_entity"));
                    log.setTargetEntityId((Integer) rs.getObject("target_entity_id"));
                    log.setDetails(rs.getString("details"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
