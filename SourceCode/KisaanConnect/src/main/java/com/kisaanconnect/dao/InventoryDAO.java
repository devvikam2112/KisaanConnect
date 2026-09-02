package com.kisaanconnect.dao;

import com.kisaanconnect.model.Inventory;
import com.kisaanconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class InventoryDAO {

    /**
     * Incrementally restocks a product's available quantity with server-side ownership check.
     * Business rule: new_quantity = current_quantity + additionalQty.
     */
    public boolean restockProduct(int productId, double additionalQty, int farmerUserId) {
        if (additionalQty <= 0) {
            return false;
        }

        // 1. Verify that the product belongs to this authenticated farmer
        String authSql = """
            SELECT p.product_id, p.status, i.available_quantity
            FROM products p
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            WHERE p.product_id = ? AND fp.user_id = ?
            FOR UPDATE
            """;

        String updateInvSql = """
            INSERT INTO inventory (product_id, available_quantity, reserved_quantity, minimum_stock)
            VALUES (?, ?, 0, 10.00)
            ON DUPLICATE KEY UPDATE
                available_quantity = available_quantity + VALUES(available_quantity),
                last_updated = CURRENT_TIMESTAMP
            """;

        String updateProdStatusSql = "UPDATE products SET status = 'AVAILABLE', updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            boolean isOwned = false;
            String currentStatus = null;
            try (PreparedStatement psAuth = con.prepareStatement(authSql)) {
                psAuth.setInt(1, productId);
                psAuth.setInt(2, farmerUserId);
                try (ResultSet rs = psAuth.executeQuery()) {
                    if (rs.next()) {
                        isOwned = true;
                        currentStatus = rs.getString("status");
                    }
                }
            }

            if (!isOwned) {
                con.rollback();
                return false; // Unauthorized or product not found
            }

            // 2. Increment available stock atomically
            try (PreparedStatement psInv = con.prepareStatement(updateInvSql)) {
                psInv.setInt(1, productId);
                psInv.setDouble(2, additionalQty);
                psInv.executeUpdate();
            }

            // 3. If product was OUT_OF_STOCK, set to AVAILABLE
            if ("OUT_OF_STOCK".equalsIgnoreCase(currentStatus)) {
                try (PreparedStatement psP = con.prepareStatement(updateProdStatusSql)) {
                    psP.setInt(1, productId);
                    psP.executeUpdate();
                }
            }

            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ignored) {}
            }
        }
        return false;
    }

    public Inventory getInventoryByProductId(int productId) {
        String sql = "SELECT * FROM inventory WHERE product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Inventory inv = new Inventory();
                    inv.setInventoryId(rs.getInt("inventory_id"));
                    inv.setProductId(rs.getInt("product_id"));
                    inv.setAvailableQuantity(rs.getDouble("available_quantity"));
                    inv.setReservedQuantity(rs.getDouble("reserved_quantity"));
                    inv.setMinimumStock(rs.getDouble("minimum_stock"));
                    inv.setLastUpdated(rs.getTimestamp("last_updated"));
                    return inv;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateMinimumStock(int productId, double minStock, int farmerUserId) {
        if (minStock < 0) return false;
        String sql = """
            UPDATE inventory i
            JOIN products p ON i.product_id = p.product_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            SET i.minimum_stock = ?, i.last_updated = CURRENT_TIMESTAMP
            WHERE i.product_id = ? AND fp.user_id = ?
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, minStock);
            ps.setInt(2, productId);
            ps.setInt(3, farmerUserId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
