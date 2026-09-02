package com.kisaanconnect.dao;

import com.kisaanconnect.model.Cart;
import com.kisaanconnect.model.CartItem;
import com.kisaanconnect.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    public double getAvailableStock(int productId) {
        String sql = "SELECT available_quantity FROM inventory WHERE product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("available_quantity");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public Cart getOrCreateCart(int buyerProfileId) {
        String selectSql = "SELECT * FROM cart WHERE buyer_profile_id = ?";
        String insertSql = "INSERT INTO cart (buyer_profile_id) VALUES (?)";

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement psSelect = con.prepareStatement(selectSql)) {
                psSelect.setInt(1, buyerProfileId);
                ResultSet rs = psSelect.executeQuery();
                if (rs.next()) {
                    Cart cart = new Cart();
                    cart.setCartId(rs.getInt("cart_id"));
                    cart.setBuyerProfileId(rs.getInt("buyer_profile_id"));
                    cart.setCreatedAt(rs.getTimestamp("created_at"));
                    cart.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return cart;
                }
            }

            try (PreparedStatement psInsert = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                psInsert.setInt(1, buyerProfileId);
                psInsert.executeUpdate();
                ResultSet rs = psInsert.getGeneratedKeys();
                if (rs.next()) {
                    Cart cart = new Cart();
                    cart.setCartId(rs.getInt(1));
                    cart.setBuyerProfileId(buyerProfileId);
                    return cart;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<CartItem> getCartItems(int cartId) {
        List<CartItem> list = new ArrayList<>();
        String sql = """
            SELECT ci.*, p.product_name, p.price AS unit_price, p.unit, p.product_type,
                   i.available_quantity AS available_stock, u.full_name AS farmer_name,
                   (SELECT image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC, display_order ASC LIMIT 1) AS primary_image_url
            FROM cart_items ci
            JOIN products p ON ci.product_id = p.product_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            WHERE ci.cart_id = ?
            ORDER BY ci.added_at DESC
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, cartId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CartItem item = new CartItem();
                item.setCartItemId(rs.getInt("cart_item_id"));
                item.setCartId(rs.getInt("cart_id"));
                item.setProductId(rs.getInt("product_id"));
                item.setQuantity(rs.getDouble("quantity"));
                item.setAddedAt(rs.getTimestamp("added_at"));
                item.setUpdatedAt(rs.getTimestamp("updated_at"));

                item.setProductName(rs.getString("product_name"));
                item.setUnitPrice(rs.getBigDecimal("unit_price"));
                item.setUnit(rs.getString("unit"));
                item.setProductType(rs.getString("product_type"));
                item.setAvailableStock(rs.getDouble("available_stock"));
                item.setFarmerName(rs.getString("farmer_name"));
                item.setPrimaryImageUrl(rs.getString("primary_image_url"));

                list.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addToCart(int cartId, int productId, double quantity) {
        double available = getAvailableStock(productId);
        String checkSql = "SELECT cart_item_id, quantity FROM cart_items WHERE cart_id = ? AND product_id = ?";
        String updateSql = "UPDATE cart_items SET quantity = quantity + ?, updated_at = CURRENT_TIMESTAMP WHERE cart_item_id = ?";
        String insertSql = "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement psCheck = con.prepareStatement(checkSql)) {
                psCheck.setInt(1, cartId);
                psCheck.setInt(2, productId);
                ResultSet rs = psCheck.executeQuery();
                if (rs.next()) {
                    int cartItemId = rs.getInt("cart_item_id");
                    double currentCartQty = rs.getDouble("quantity");
                    if ((currentCartQty + quantity) > available) {
                        return false;
                    }
                    try (PreparedStatement psUpdate = con.prepareStatement(updateSql)) {
                        psUpdate.setDouble(1, quantity);
                        psUpdate.setInt(2, cartItemId);
                        return psUpdate.executeUpdate() > 0;
                    }
                }
            }

            if (quantity > available) {
                return false;
            }

            try (PreparedStatement psInsert = con.prepareStatement(insertSql)) {
                psInsert.setInt(1, cartId);
                psInsert.setInt(2, productId);
                psInsert.setDouble(3, quantity);
                return psInsert.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateQuantity(int cartItemId, double quantity) {
        String prodSql = "SELECT product_id FROM cart_items WHERE cart_item_id = ?";
        String sql = "UPDATE cart_items SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE cart_item_id = ?";

        try (Connection con = DBConnection.getConnection()) {
            int productId = 0;
            try (PreparedStatement psProd = con.prepareStatement(prodSql)) {
                psProd.setInt(1, cartItemId);
                try (ResultSet rs = psProd.executeQuery()) {
                    if (rs.next()) {
                        productId = rs.getInt("product_id");
                    } else {
                        return false;
                    }
                }
            }

            double available = getAvailableStock(productId);
            if (quantity > available) {
                return false;
            }

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setDouble(1, quantity);
                ps.setInt(2, cartItemId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeItem(int cartItemId) {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, cartItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean clearCart(int cartId) {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, cartId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
