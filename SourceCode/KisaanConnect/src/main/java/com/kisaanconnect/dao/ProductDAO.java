package com.kisaanconnect.dao;

import com.kisaanconnect.model.Product;
import com.kisaanconnect.model.ProductImage;
import com.kisaanconnect.model.ProductPriceHistory;
import com.kisaanconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public boolean saveProduct(Product product, List<String> imageUrls, double initialStock) {
        String sqlProduct = """
            INSERT INTO products
            (farmer_profile_id, category_id, product_name, description, price, unit, product_type, status, is_featured)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        String sqlImage = """
            INSERT INTO product_images
            (product_id, image_url, is_primary, display_order)
            VALUES (?, ?, ?, ?)
            """;

        String sqlInventory = """
            INSERT INTO inventory
            (product_id, available_quantity, reserved_quantity, minimum_stock)
            VALUES (?, ?, 0.00, ?)
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int generatedProductId = 0;
            try (PreparedStatement psProduct = con.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS)) {
                psProduct.setInt(1, product.getFarmerProfileId());
                psProduct.setInt(2, product.getCategoryId());
                psProduct.setString(3, product.getProductName());
                psProduct.setString(4, product.getDescription());
                psProduct.setBigDecimal(5, product.getPrice());
                psProduct.setString(6, product.getUnit());
                psProduct.setString(7, product.getProductType());
                psProduct.setString(8, product.getStatus() != null ? product.getStatus() : "AVAILABLE");
                psProduct.setBoolean(9, product.isFeatured());

                int affected = psProduct.executeUpdate();
                if (affected == 0) {
                    con.rollback();
                    return false;
                }

                try (ResultSet rs = psProduct.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedProductId = rs.getInt(1);
                        product.setProductId(generatedProductId);
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            // Save Product Images
            if (imageUrls != null && !imageUrls.isEmpty()) {
                try (PreparedStatement psImg = con.prepareStatement(sqlImage)) {
                    for (int i = 0; i < imageUrls.size(); i++) {
                        psImg.setInt(1, generatedProductId);
                        psImg.setString(2, imageUrls.get(i));
                        psImg.setBoolean(3, i == 0); // first image is primary
                        psImg.setInt(4, i + 1);
                        psImg.addBatch();
                    }
                    psImg.executeBatch();
                }
            }

            // Save Inventory Stock
            try (PreparedStatement psInv = con.prepareStatement(sqlInventory)) {
                psInv.setInt(1, generatedProductId);
                psInv.setDouble(2, initialStock);
                psInv.setDouble(3, product.getMinimumStock() > 0 ? product.getMinimumStock() : 5.0);
                psInv.executeUpdate();
            }

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

    public List<Product> getProductsByFarmer(int farmerProfileId) {
        List<Product> list = new ArrayList<>();
        String sql = """
            SELECT p.*, c.category_name, fp.farm_name, u.full_name AS farmer_name,
                   i.available_quantity, i.minimum_stock,
                   (SELECT image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC, display_order ASC LIMIT 1) AS primary_image_url
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            WHERE p.farmer_profile_id = ?
            ORDER BY p.created_at DESC
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, farmerProfileId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getAllAvailableProducts() {
        List<Product> list = new ArrayList<>();
        String sql = """
            SELECT p.*, c.category_name, fp.farm_name, fp.village, fp.district, fp.state,
                   u.full_name AS farmer_name, i.available_quantity, i.minimum_stock,
                   (SELECT image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC, display_order ASC LIMIT 1) AS primary_image_url
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            WHERE p.status = 'AVAILABLE' AND (i.available_quantity IS NULL OR i.available_quantity > 0)
            ORDER BY p.is_featured DESC, p.created_at DESC
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(mapResultSetToProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> searchProducts(String query, Integer categoryId) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT p.*, c.category_name, fp.farm_name, fp.village, fp.district, fp.state,
                   u.full_name AS farmer_name, i.available_quantity, i.minimum_stock,
                   (SELECT image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC, display_order ASC LIMIT 1) AS primary_image_url
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            WHERE p.status = 'AVAILABLE'
            """);

        List<Object> params = new ArrayList<>();
        if (query != null && !query.trim().isEmpty()) {
            sql.append(" AND (p.product_name LIKE ? OR p.description LIKE ? OR fp.district LIKE ? OR c.category_name LIKE ?)");
            String searchPattern = "%" + query.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }

        sql.append(" ORDER BY p.is_featured DESC, p.created_at DESC");

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql.toString())
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Product getProductById(int productId) {
        String sql = """
            SELECT p.*, c.category_name, fp.farm_name, fp.village, fp.district, fp.state,
                   u.full_name AS farmer_name, i.available_quantity, i.minimum_stock,
                   (SELECT image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC, display_order ASC LIMIT 1) AS primary_image_url
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            JOIN users u ON fp.user_id = u.user_id
            LEFT JOIN inventory i ON p.product_id = i.product_id
            WHERE p.product_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToProduct(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ProductImage> getProductImages(int productId) {
        List<ProductImage> list = new ArrayList<>();
        String sql = "SELECT * FROM product_images WHERE product_id = ? ORDER BY display_order ASC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductImage img = new ProductImage();
                img.setImageId(rs.getInt("image_id"));
                img.setProductId(rs.getInt("product_id"));
                img.setImageUrl(rs.getString("image_url"));
                img.setPrimary(rs.getBoolean("is_primary"));
                img.setDisplayOrder(rs.getInt("display_order"));
                img.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(img);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateProduct(Product product) {
        String sql = """
            UPDATE products
            SET category_id = ?,
                product_name = ?,
                description = ?,
                price = ?,
                unit = ?,
                product_type = ?,
                status = ?,
                is_featured = ?
            WHERE product_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, product.getCategoryId());
            ps.setString(2, product.getProductName());
            ps.setString(3, product.getDescription());
            ps.setBigDecimal(4, product.getPrice());
            ps.setString(5, product.getUnit());
            ps.setString(6, product.getProductType());
            ps.setString(7, product.getStatus());
            ps.setBoolean(8, product.isFeatured());
            ps.setInt(9, product.getProductId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStock(int productId, double newQuantity) {
        if (newQuantity < 0) return false;
        String sql = "UPDATE inventory SET available_quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, newQuantity);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateProductListing(int productId, BigDecimal price, String description, String status) {
        String sql = "UPDATE products SET price = ?, description = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBigDecimal(1, price);
            ps.setString(2, description);
            ps.setString(3, status);
            ps.setInt(4, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Updates product selling price with farmer ownership verification and audit trail.
     * Future purchases will use newPrice. Existing placed orders preserve snapshot price.
     */
    public boolean updateProductPrice(int productId, BigDecimal newPrice, int farmerUserId) {
        if (newPrice == null || newPrice.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        String authSql = """
            SELECT p.product_id, p.price, p.product_name
            FROM products p
            JOIN farmer_profiles fp ON p.farmer_profile_id = fp.farmer_profile_id
            WHERE p.product_id = ? AND fp.user_id = ?
            FOR UPDATE
            """;

        String updatePriceSql = "UPDATE products SET price = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        String insertHistorySql = "INSERT INTO product_price_history (product_id, old_price, new_price, changed_by_user_id) VALUES (?, ?, ?, ?)";

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            BigDecimal oldPrice = null;
            try (PreparedStatement psAuth = con.prepareStatement(authSql)) {
                psAuth.setInt(1, productId);
                psAuth.setInt(2, farmerUserId);
                try (ResultSet rs = psAuth.executeQuery()) {
                    if (rs.next()) {
                        oldPrice = rs.getBigDecimal("price");
                    }
                }
            }

            if (oldPrice == null) {
                con.rollback();
                return false; // Not authorized or product not found
            }

            // 1. Update product price
            try (PreparedStatement psUp = con.prepareStatement(updatePriceSql)) {
                psUp.setBigDecimal(1, newPrice);
                psUp.setInt(2, productId);
                psUp.executeUpdate();
            }

            // 2. Record historical price audit
            try (PreparedStatement psHist = con.prepareStatement(insertHistorySql)) {
                psHist.setInt(1, productId);
                psHist.setBigDecimal(2, oldPrice);
                psHist.setBigDecimal(3, newPrice);
                psHist.setInt(4, farmerUserId);
                psHist.executeUpdate();
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

    public List<ProductPriceHistory> getPriceHistory(int productId) {
        List<ProductPriceHistory> list = new ArrayList<>();
        String sql = """
            SELECT pph.*, p.product_name, u.full_name AS changed_by_name
            FROM product_price_history pph
            JOIN products p ON pph.product_id = p.product_id
            JOIN users u ON pph.changed_by_user_id = u.user_id
            WHERE pph.product_id = ?
            ORDER BY pph.changed_at DESC
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductPriceHistory h = new ProductPriceHistory();
                    h.setPriceHistoryId(rs.getInt("price_history_id"));
                    h.setProductId(rs.getInt("product_id"));
                    h.setProductName(rs.getString("product_name"));
                    h.setOldPrice(rs.getBigDecimal("old_price"));
                    h.setNewPrice(rs.getBigDecimal("new_price"));
                    h.setChangedByUserId(rs.getInt("changed_by_user_id"));
                    h.setChangedByUserName(rs.getString("changed_by_name"));
                    h.setChangedAt(rs.getTimestamp("changed_at"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setFarmerProfileId(rs.getInt("farmer_profile_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setProductName(rs.getString("product_name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setUnit(rs.getString("unit"));
        p.setProductType(rs.getString("product_type"));
        p.setStatus(rs.getString("status"));
        p.setFeatured(rs.getBoolean("is_featured"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            p.setCategoryName(rs.getString("category_name"));
        } catch (SQLException ignored) {}

        try {
            p.setFarmName(rs.getString("farm_name"));
        } catch (SQLException ignored) {}

        try {
            p.setFarmerName(rs.getString("farmer_name"));
        } catch (SQLException ignored) {}

        try {
            String village = rs.getString("village");
            String district = rs.getString("district");
            String state = rs.getString("state");
            if (district != null) {
                p.setFarmerLocation((village != null ? village + ", " : "") + district + ", " + state);
            }
        } catch (SQLException ignored) {}

        try {
            p.setPrimaryImageUrl(rs.getString("primary_image_url"));
        } catch (SQLException ignored) {}

        try {
            p.setAvailableQuantity(rs.getDouble("available_quantity"));
        } catch (SQLException ignored) {}

        try {
            p.setMinimumStock(rs.getDouble("minimum_stock"));
        } catch (SQLException ignored) {}

        return p;
    }
}
