package com.kisaanconnect.controller;

import com.kisaanconnect.dao.CategoryDAO;
import com.kisaanconnect.dao.FarmerProfileDAO;
import com.kisaanconnect.dao.InventoryDAO;
import com.kisaanconnect.dao.ProductDAO;
import com.kisaanconnect.model.Category;
import com.kisaanconnect.model.FarmerProfile;
import com.kisaanconnect.model.Product;
import com.kisaanconnect.model.ProductPriceHistory;
import com.kisaanconnect.model.User;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet(name = "FarmerProductServlet", urlPatterns = {
    "/farmer/products",
    "/farmer/add-product",
    "/farmer/delete-product",
    "/farmer/inventory",
    "/farmer/update-stock",
    "/farmer/update-price",
    "/farmer/price-history",
    "/farmer/update-product"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class FarmerProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        FarmerProfileDAO farmerProfileDAO = new FarmerProfileDAO();
        FarmerProfile profile = farmerProfileDAO.getProfileByUserId(user.getUserId());

        if (profile == null) {
            response.sendRedirect(request.getContextPath() + "/farmer/setup-profile.jsp");
            return;
        }

        String servletPath = request.getServletPath();

        if ("/farmer/add-product".equals(servletPath)) {
            CategoryDAO categoryDAO = new CategoryDAO();
            List<Category> categories = categoryDAO.getActiveCategories();
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/farmer/add-product.jsp").forward(request, response);
        } else if ("/farmer/inventory".equals(servletPath)) {
            ProductDAO productDAO = new ProductDAO();
            List<Product> products = productDAO.getProductsByFarmer(profile.getFarmerProfileId());
            request.setAttribute("products", products);
            request.setAttribute("profile", profile);
            request.getRequestDispatcher("/farmer/inventory.jsp").forward(request, response);
        } else if ("/farmer/price-history".equals(servletPath)) {
            String prodIdStr = request.getParameter("productId");
            if (prodIdStr != null) {
                try {
                    int prodId = Integer.parseInt(prodIdStr.trim());
                    ProductDAO productDAO = new ProductDAO();
                    List<ProductPriceHistory> history = productDAO.getPriceHistory(prodId);
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    StringBuilder json = new StringBuilder("[");
                    for (int i = 0; i < history.size(); i++) {
                        ProductPriceHistory h = history.get(i);
                        json.append(String.format("{\"id\":%d,\"oldPrice\":%s,\"newPrice\":%s,\"changedBy\":\"%s\",\"changedAt\":\"%s\"}",
                            h.getPriceHistoryId(), h.getOldPrice(), h.getNewPrice(), h.getChangedByUserName(), h.getChangedAt()));
                        if (i < history.size() - 1) json.append(",");
                    }
                    json.append("]");
                    response.getWriter().write(json.toString());
                    return;
                } catch (Exception ignored) {}
            }
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        } else {
            // My Products list
            ProductDAO productDAO = new ProductDAO();
            List<Product> products = productDAO.getProductsByFarmer(profile.getFarmerProfileId());
            CategoryDAO categoryDAO = new CategoryDAO();
            List<Category> categories = categoryDAO.getActiveCategories();
            request.setAttribute("products", products);
            request.setAttribute("categories", categories);
            request.setAttribute("profile", profile);
            request.getRequestDispatcher("/farmer/myProducts.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        FarmerProfileDAO farmerProfileDAO = new FarmerProfileDAO();
        FarmerProfile profile = farmerProfileDAO.getProfileByUserId(user.getUserId());

        if (profile == null) {
            response.sendRedirect(request.getContextPath() + "/farmer/setup-profile.jsp");
            return;
        }

        String servletPath = request.getServletPath();

        if ("/farmer/delete-product".equals(servletPath)) {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null && !productIdStr.isEmpty()) {
                ProductDAO productDAO = new ProductDAO();
                productDAO.deleteProduct(Integer.parseInt(productIdStr));
            }
            String msg = URLEncoder.encode("Product deleted successfully.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/farmer/products?success=" + msg);
            return;
        }

        if ("/farmer/update-stock".equals(servletPath)) {
            String productIdStr = request.getParameter("productId");
            String addQtyStr = request.getParameter("additionalQuantity");
            if (addQtyStr == null || addQtyStr.isEmpty()) {
                addQtyStr = request.getParameter("stockQuantity");
            }
            if (productIdStr != null && addQtyStr != null) {
                try {
                    int productId = Integer.parseInt(productIdStr.trim());
                    double addQty = Double.parseDouble(addQtyStr.trim());
                    if (addQty > 0) {
                        InventoryDAO invDAO = new InventoryDAO();
                        boolean ok = invDAO.restockProduct(productId, addQty, user.getUserId());
                        if (ok) {
                            String msg = URLEncoder.encode("Stock successfully restocked (+" + addQty + ")!", StandardCharsets.UTF_8);
                            response.sendRedirect(request.getContextPath() + "/farmer/inventory?success=" + msg);
                            return;
                        } else {
                            String msg = URLEncoder.encode("Restock failed: unauthorized or invalid produce.", StandardCharsets.UTF_8);
                            response.sendRedirect(request.getContextPath() + "/farmer/inventory?error=" + msg);
                            return;
                        }
                    }
                } catch (Exception ignored) {}
            }
            String errorMsg = URLEncoder.encode("Invalid restock quantity provided. Quantity must be greater than 0.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/farmer/inventory?error=" + errorMsg);
            return;
        }

        if ("/farmer/update-price".equals(servletPath)) {
            String productIdStr = request.getParameter("productId");
            String newPriceStr = request.getParameter("newPrice");
            if (productIdStr != null && newPriceStr != null) {
                try {
                    int productId = Integer.parseInt(productIdStr.trim());
                    BigDecimal newPrice = new BigDecimal(newPriceStr.trim());
                    if (newPrice.compareTo(BigDecimal.ZERO) > 0) {
                        ProductDAO productDAO = new ProductDAO();
                        boolean ok = productDAO.updateProductPrice(productId, newPrice, user.getUserId());
                        if (ok) {
                            String msg = URLEncoder.encode("Product price updated to ₹" + newPrice + " and logged in price history.", StandardCharsets.UTF_8);
                            response.sendRedirect(request.getContextPath() + "/farmer/products?success=" + msg);
                            return;
                        } else {
                            String msg = URLEncoder.encode("Failed to update price: unauthorized or invalid product.", StandardCharsets.UTF_8);
                            response.sendRedirect(request.getContextPath() + "/farmer/products?error=" + msg);
                            return;
                        }
                    }
                } catch (Exception ignored) {}
            }
            String errorMsg = URLEncoder.encode("Invalid price provided. Price must be greater than 0.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/farmer/products?error=" + errorMsg);
            return;
        }

        if ("/farmer/update-product".equals(servletPath)) {
            String productIdStr = request.getParameter("productId");
            String priceStr = request.getParameter("price");
            String description = request.getParameter("description");
            String status = request.getParameter("status");
            if (productIdStr != null && priceStr != null) {
                try {
                    int productId = Integer.parseInt(productIdStr.trim());
                    BigDecimal price = new BigDecimal(priceStr.trim());
                    ProductDAO productDAO = new ProductDAO();
                    // Update price with history audit
                    productDAO.updateProductPrice(productId, price, user.getUserId());
                    productDAO.updateProductListing(productId, price, description, status != null ? status : "AVAILABLE");
                    String msg = URLEncoder.encode("Produce listing updated successfully!", StandardCharsets.UTF_8);
                    response.sendRedirect(request.getContextPath() + "/farmer/products?success=" + msg);
                    return;
                } catch (Exception ignored) {}
            }
            String errorMsg = URLEncoder.encode("Failed to update product details.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/farmer/products?error=" + errorMsg);
            return;
        }

        // Add Product Flow
        String productName = request.getParameter("productName");
        String categoryIdStr = request.getParameter("categoryId");
        String priceStr = request.getParameter("price");
        String unit = request.getParameter("unit");
        String productType = request.getParameter("productType");
        String stockStr = request.getParameter("stock");
        String minStockStr = request.getParameter("minimumStock");
        String description = request.getParameter("description");
        String featuredStr = request.getParameter("isFeatured");

        if (productName == null || productName.trim().isEmpty()
                || categoryIdStr == null || categoryIdStr.trim().isEmpty()
                || priceStr == null || priceStr.trim().isEmpty()
                || unit == null || unit.trim().isEmpty()
                || stockStr == null || stockStr.trim().isEmpty()) {

            String errorMsg = URLEncoder.encode("Please fill in all mandatory product fields.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/farmer/add-product?error=" + errorMsg);
            return;
        }

        int categoryId = Integer.parseInt(categoryIdStr);
        BigDecimal price = new BigDecimal(priceStr.trim());
        double stock = Double.parseDouble(stockStr.trim());
        double minStock = (minStockStr != null && !minStockStr.trim().isEmpty())
                ? Double.parseDouble(minStockStr.trim()) : 5.0;
        boolean isFeatured = "true".equalsIgnoreCase(featuredStr) || "1".equals(featuredStr) || "on".equalsIgnoreCase(featuredStr);

        // Handle Image Upload
        Part imagePart = request.getPart("productImage");
        List<String> imageUrls = new ArrayList<>();

        if (imagePart != null && imagePart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "products";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String submittedFileName = imagePart.getSubmittedFileName();
            String extension = "";
            int dot = submittedFileName.lastIndexOf(".");
            if (dot != -1) {
                extension = submittedFileName.substring(dot);
            }

            String newFileName = "crop_" + System.currentTimeMillis() + extension;
            imagePart.write(uploadPath + File.separator + newFileName);
            imageUrls.add("uploads/products/" + newFileName);
        } else {
            // Default placeholder
            imageUrls.add("assets/images/farmer.png");
        }

        Product product = new Product();
        product.setFarmerProfileId(profile.getFarmerProfileId());
        product.setCategoryId(categoryId);
        product.setProductName(productName.trim());
        product.setDescription(description != null ? description.trim() : "");
        product.setPrice(price);
        product.setUnit(unit.trim());
        product.setProductType(productType != null ? productType.trim() : "Organic");
        product.setStatus("AVAILABLE");
        product.setFeatured(isFeatured);
        product.setMinimumStock(minStock);

        ProductDAO productDAO = new ProductDAO();
        boolean saved = productDAO.saveProduct(product, imageUrls, stock);

        if (saved) {
            String successMsg = URLEncoder.encode("Product added successfully to marketplace!", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/farmer/products?success=" + successMsg);
        } else {
            String errorMsg = URLEncoder.encode("Failed to save product. Please try again.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/farmer/add-product?error=" + errorMsg);
        }
    }
}
