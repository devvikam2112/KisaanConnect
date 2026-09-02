package com.kisaanconnect.controller;

import com.kisaanconnect.dao.BuyerDAO;
import com.kisaanconnect.dao.CartDAO;
import com.kisaanconnect.model.BuyerProfile;
import com.kisaanconnect.model.Cart;
import com.kisaanconnect.model.CartItem;
import com.kisaanconnect.model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "CartServlet", urlPatterns = {
    "/cart",
    "/cart/add",
    "/cart/update",
    "/cart/remove",
    "/buyer/cart"
})
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp?error=" + URLEncoder.encode("Please login to view your cart", StandardCharsets.UTF_8));
            return;
        }

        BuyerDAO buyerDAO = new BuyerDAO();
        BuyerProfile buyerProfile = buyerDAO.getOrCreateBuyerProfile(loggedInUser.getUserId());
        int buyerProfileId = buyerProfile.getBuyerProfileId();

        CartDAO cartDAO = new CartDAO();
        Cart cart = cartDAO.getOrCreateCart(buyerProfileId);

        List<CartItem> cartItems = (cart != null) ? cartDAO.getCartItems(cart.getCartId()) : new ArrayList<>();

        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getItemTotal());
        }

        request.setAttribute("cart", cart);
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);

        request.getRequestDispatcher("/buyer/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp?error=" + URLEncoder.encode("Please login to manage your cart", StandardCharsets.UTF_8));
            return;
        }

        BuyerDAO buyerDAO = new BuyerDAO();
        BuyerProfile buyerProfile = buyerDAO.getOrCreateBuyerProfile(loggedInUser.getUserId());
        int buyerProfileId = buyerProfile.getBuyerProfileId();

        CartDAO cartDAO = new CartDAO();
        Cart cart = cartDAO.getOrCreateCart(buyerProfileId);

        String servletPath = request.getServletPath();

        if ("/cart/add".equals(servletPath)) {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");

            if (productIdStr != null && quantityStr != null) {
                try {
                    int productId = Integer.parseInt(productIdStr.trim());
                    double quantity = Double.parseDouble(quantityStr.trim());
                    double availableStock = cartDAO.getAvailableStock(productId);

                    if (quantity <= 0) {
                        String msg = URLEncoder.encode("Invalid quantity specified.", StandardCharsets.UTF_8);
                        response.sendRedirect(request.getContextPath() + "/cart?error=" + msg);
                        return;
                    }

                    if (quantity > availableStock) {
                        String msg = URLEncoder.encode("Insufficient stock. Only " + availableStock + " units are currently available.", StandardCharsets.UTF_8);
                        response.sendRedirect(request.getContextPath() + "/cart?error=" + msg);
                        return;
                    }

                    boolean added = cartDAO.addToCart(cart.getCartId(), productId, quantity);
                    if (added) {
                        String msg = URLEncoder.encode("Item added to cart!", StandardCharsets.UTF_8);
                        response.sendRedirect(request.getContextPath() + "/cart?success=" + msg);
                        return;
                    } else {
                        String msg = URLEncoder.encode("Requested quantity exceeds available stock. Available quantity: " + availableStock + ".", StandardCharsets.UTF_8);
                        response.sendRedirect(request.getContextPath() + "/cart?error=" + msg);
                        return;
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/cart");

        } else if ("/cart/update".equals(servletPath)) {
            String cartItemIdStr = request.getParameter("cartItemId");
            String quantityStr = request.getParameter("quantity");

            if (cartItemIdStr != null && quantityStr != null) {
                try {
                    int cartItemId = Integer.parseInt(cartItemIdStr.trim());
                    double quantity = Double.parseDouble(quantityStr.trim());
                    if (quantity > 0) {
                        boolean updated = cartDAO.updateQuantity(cartItemId, quantity);
                        if (!updated) {
                            String msg = URLEncoder.encode("Requested quantity exceeds available stock.", StandardCharsets.UTF_8);
                            response.sendRedirect(request.getContextPath() + "/cart?error=" + msg);
                            return;
                        }
                    } else {
                        cartDAO.removeItem(cartItemId);
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/cart");

        } else if ("/cart/remove".equals(servletPath)) {
            String cartItemIdStr = request.getParameter("cartItemId");
            if (cartItemIdStr != null) {
                try {
                    int cartItemId = Integer.parseInt(cartItemIdStr.trim());
                    cartDAO.removeItem(cartItemId);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }
}
