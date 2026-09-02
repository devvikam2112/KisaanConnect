package com.kisaanconnect.controller;

import com.kisaanconnect.dao.CategoryDAO;
import com.kisaanconnect.dao.ProductDAO;
import com.kisaanconnect.model.Category;
import com.kisaanconnect.model.Product;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "MarketplaceServlet", urlPatterns = {
    "/buyer/products",
    "/marketplace",
    "/products"
})
public class MarketplaceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchQuery = request.getParameter("search");
        String categoryIdStr = request.getParameter("category");

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        ProductDAO productDAO = new ProductDAO();
        CategoryDAO categoryDAO = new CategoryDAO();

        List<Product> products;
        if ((searchQuery != null && !searchQuery.trim().isEmpty()) || categoryId != null) {
            products = productDAO.searchProducts(searchQuery, categoryId);
        } else {
            products = productDAO.getAllAvailableProducts();
        }

        List<Category> categories = categoryDAO.getActiveCategories();

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("searchQuery", searchQuery);

        request.getRequestDispatcher("/buyer/products.jsp").forward(request, response);
    }
}
