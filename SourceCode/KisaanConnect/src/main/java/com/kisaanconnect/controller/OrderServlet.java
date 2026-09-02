package com.kisaanconnect.controller;

import com.kisaanconnect.dao.BuyerDAO;
import com.kisaanconnect.dao.CartDAO;
import com.kisaanconnect.dao.FarmerProfileDAO;
import com.kisaanconnect.dao.OrderDAO;
import com.kisaanconnect.dao.OrganizationDAO;
import com.kisaanconnect.dao.ProductDAO;
import com.kisaanconnect.dao.WalletDAO;
import com.kisaanconnect.model.*;

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

@WebServlet(name = "OrderServlet", urlPatterns = {
    "/checkout",
    "/order/place",
    "/buyer/orders",
    "/commercial/orders",
    "/farmer/orders",
    "/farmer/order/update-status",
    "/farmer/order/confirm-cash",
    "/buyer/order/confirm-delivery",
    "/commercial/order/confirm-delivery"
})
public class OrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String servletPath = request.getServletPath();
        OrderDAO orderDAO = new OrderDAO();
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            statusFilter = "ALL";
        }

        if ("/checkout".equals(servletPath)) {
            BuyerDAO buyerDAO = new BuyerDAO();
            BuyerProfile bp = buyerDAO.getOrCreateBuyerProfile(user.getUserId());
            int buyerProfileId = bp.getBuyerProfileId();

            CartDAO cartDAO = new CartDAO();
            Cart cart = cartDAO.getOrCreateCart(buyerProfileId);
            List<CartItem> cartItems = (cart != null) ? cartDAO.getCartItems(cart.getCartId()) : new ArrayList<>();

            if (cartItems.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/buyer/products?error=" + URLEncoder.encode("Your cart is empty. Add items first!", StandardCharsets.UTF_8));
                return;
            }

            // Verify stock availability for all items before checkout
            for (CartItem ci : cartItems) {
                double stock = cartDAO.getAvailableStock(ci.getProductId());
                if (ci.getQuantity() > stock) {
                    String msg = "Insufficient stock for " + ci.getProductName() + ". Only " + stock + " " + (ci.getUnit() != null ? ci.getUnit() : "units") + " currently available.";
                    response.sendRedirect(request.getContextPath() + "/cart?error=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                    return;
                }
            }

            BigDecimal subtotal = BigDecimal.ZERO;
            for (CartItem ci : cartItems) {
                subtotal = subtotal.add(ci.getItemTotal());
            }

            OrganizationDAO orgDAO = new OrganizationDAO();
            Organization org = orgDAO.getOrganizationByUserId(user.getUserId());

            WalletDAO walletDAO = new WalletDAO();
            Wallet wallet = walletDAO.getOrCreateWallet(user.getUserId());

            request.setAttribute("cartItems", cartItems);
            request.setAttribute("subtotal", subtotal);
            request.setAttribute("buyerProfile", bp);
            request.setAttribute("organization", org);
            request.setAttribute("wallet", wallet);
            request.setAttribute("walletBalance", wallet != null ? wallet.getCurrentBalance() : BigDecimal.ZERO);

            request.getRequestDispatcher("/buyer/checkout.jsp").forward(request, response);

        } else if ("/buyer/orders".equals(servletPath)) {
            BuyerDAO buyerDAO = new BuyerDAO();
            BuyerProfile bp = buyerDAO.getProfileByUserId(user.getUserId());
            List<Order> orders = (bp != null) ? orderDAO.getOrdersByBuyerProfileId(bp.getBuyerProfileId(), statusFilter) : new ArrayList<>();
            request.setAttribute("orders", orders);
            request.setAttribute("statusFilter", statusFilter);
            request.getRequestDispatcher("/buyer/orders.jsp").forward(request, response);

        } else if ("/commercial/orders".equals(servletPath)) {
            OrganizationDAO orgDAO = new OrganizationDAO();
            Organization org = orgDAO.getOrganizationByUserId(user.getUserId());
            List<Order> orders = (org != null) ? orderDAO.getOrdersByOrganizationId(org.getOrganizationId(), statusFilter) : new ArrayList<>();
            request.setAttribute("orders", orders);
            request.setAttribute("statusFilter", statusFilter);
            request.getRequestDispatcher("/commercial/orders.jsp").forward(request, response);

        } else if ("/farmer/orders".equals(servletPath)) {
            FarmerProfileDAO fpDAO = new FarmerProfileDAO();
            FarmerProfile fp = fpDAO.getProfileByUserId(user.getUserId());
            List<SubOrder> subOrders = (fp != null) ? orderDAO.getFarmerSubOrders(fp.getFarmerProfileId(), statusFilter) : new ArrayList<>();
            request.setAttribute("subOrders", subOrders);
            request.setAttribute("statusFilter", statusFilter);
            request.getRequestDispatcher("/farmer/orders.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String servletPath = request.getServletPath();
        OrderDAO orderDAO = new OrderDAO();

        if ("/order/place".equals(servletPath)) {
            BuyerDAO buyerDAO = new BuyerDAO();
            BuyerProfile bp = buyerDAO.getOrCreateBuyerProfile(user.getUserId());
            int buyerProfileId = bp.getBuyerProfileId();

            CartDAO cartDAO = new CartDAO();
            Cart cart = cartDAO.getOrCreateCart(buyerProfileId);
            List<CartItem> cartItems = (cart != null) ? cartDAO.getCartItems(cart.getCartId()) : new ArrayList<>();

            if (cartItems.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cart?error=" + URLEncoder.encode("Cart is empty!", StandardCharsets.UTF_8));
                return;
            }

            // Server-side multi-level stock validation prior to transaction
            for (CartItem ci : cartItems) {
                double availableStock = cartDAO.getAvailableStock(ci.getProductId());
                if (ci.getQuantity() > availableStock) {
                    String msg = "Insufficient stock. Only " + availableStock + " units are currently available.";
                    response.sendRedirect(request.getContextPath() + "/cart?error=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                    return;
                }
            }

            OrganizationDAO orgDAO = new OrganizationDAO();
            Organization org = orgDAO.getOrganizationByUserId(user.getUserId());

            String deliveryName = request.getParameter("deliveryName");
            String deliveryPhone = request.getParameter("deliveryPhone");
            String deliveryAddress = request.getParameter("deliveryAddress");
            String deliveryPincode = request.getParameter("deliveryPincode");
            String deliveryDateStr = request.getParameter("deliveryDate");
            String paymentMethod = request.getParameter("paymentMethod");

            // Strict Delivery Date Validation
            if (deliveryDateStr == null || deliveryDateStr.trim().isEmpty()) {
                String errorMsg = "Please select a requested delivery date to continue.";
                response.sendRedirect(request.getContextPath() + "/checkout?error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
                return;
            }

            java.sql.Date deliveryDateSql = null;
            try {
                java.time.LocalDate selDate = java.time.LocalDate.parse(deliveryDateStr.trim());
                java.time.LocalDate today = java.time.LocalDate.now();
                if (selDate.isBefore(today)) {
                    String errorMsg = "Requested delivery date cannot be in the past. Please select today or a future date.";
                    response.sendRedirect(request.getContextPath() + "/checkout?error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
                    return;
                }
                deliveryDateSql = java.sql.Date.valueOf(selDate);
            } catch (Exception e) {
                String errorMsg = "Invalid delivery date format. Please select a valid date.";
                response.sendRedirect(request.getContextPath() + "/checkout?error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
                return;
            }

            // Strict Payment Method Validation (Do NOT default to CASH)
            if (paymentMethod == null || paymentMethod.trim().isEmpty() || "NONE".equalsIgnoreCase(paymentMethod.trim())) {
                String errorMsg = "Please select a payment method to continue.";
                response.sendRedirect(request.getContextPath() + "/checkout?error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
                return;
            }

            paymentMethod = paymentMethod.trim().toUpperCase();
            if ("CASH_ON_DELIVERY".equals(paymentMethod) || "COD".equals(paymentMethod)) {
                paymentMethod = "CASH";
            }

            if (!"WALLET".equals(paymentMethod) && !"CASH".equals(paymentMethod) && !"UPI".equals(paymentMethod) && !"ONLINE".equals(paymentMethod)) {
                String errorMsg = "Unsupported payment method selected. Please select Wallet, Cash on Delivery, or UPI.";
                response.sendRedirect(request.getContextPath() + "/checkout?error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
                return;
            }

            BigDecimal subtotal = BigDecimal.ZERO;
            List<OrderItem> orderItems = new ArrayList<>();
            for (CartItem ci : cartItems) {
                OrderItem oi = new OrderItem();
                oi.setProductId(ci.getProductId());
                oi.setProductName(ci.getProductName());
                oi.setUnitPrice(ci.getUnitPrice());
                oi.setQuantity(ci.getQuantity());
                oi.setDiscountAmount(BigDecimal.ZERO);
                oi.setFinalUnitPrice(ci.getUnitPrice());
                oi.setSubtotal(ci.getItemTotal());
                orderItems.add(oi);
                subtotal = subtotal.add(ci.getItemTotal());
            }

            BigDecimal deliveryCharge = BigDecimal.valueOf(50.0);
            BigDecimal platformFee = BigDecimal.valueOf(10.0);
            BigDecimal totalAmount = subtotal.add(deliveryCharge).add(platformFee);

            // Server-side Wallet Balance Validation
            if ("WALLET".equalsIgnoreCase(paymentMethod)) {
                WalletDAO walletDAO = new WalletDAO();
                Wallet wallet = walletDAO.getOrCreateWallet(user.getUserId());
                if (wallet == null || wallet.getCurrentBalance().compareTo(totalAmount) < 0) {
                    BigDecimal bal = wallet != null ? wallet.getCurrentBalance() : BigDecimal.ZERO;
                    String errorMsg = "Insufficient KisaanConnect Wallet balance. Available balance: ₹" + bal + ". Order amount: ₹" + totalAmount + ". Please top up your wallet or choose another payment method.";
                    response.sendRedirect(request.getContextPath() + "/checkout?error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
                    return;
                }
            }

            Order order = new Order();
            if (org != null) {
                order.setOrganizationId(org.getOrganizationId());
                order.setBuyerType("COMMERCIAL");
                order.setGstinApplied(org.getGstin());
            } else {
                order.setBuyerProfileId(bp != null ? bp.getBuyerProfileId() : null);
                order.setBuyerType("INDIVIDUAL");
            }

            order.setDeliveryName(deliveryName != null ? deliveryName : user.getFullName());
            order.setDeliveryPhone(deliveryPhone != null ? deliveryPhone : user.getPhone());
            order.setDeliveryAddress(deliveryAddress);
            order.setDeliveryPincode(deliveryPincode);
            order.setDeliveryDate(deliveryDateSql);
            order.setSubtotalAmount(subtotal);
            order.setDiscountAmount(BigDecimal.ZERO);
            order.setDeliveryCharge(deliveryCharge);
            order.setPlatformFee(platformFee);
            order.setTotalAmount(totalAmount);
            order.setPaymentMethod(paymentMethod);
            order.setPaymentStatus("PENDING");
            order.setOrderStatus("PLACED");

            // Transactional atomic multi-farmer order placement & stock deduction
            boolean success = orderDAO.createOrder(order, orderItems, user.getUserId());
            if (success) {
                cartDAO.clearCart(cart.getCartId());
                String target = (org != null) ? "/commercial/orders" : "/buyer/orders";
                String msg = URLEncoder.encode("Order " + order.getOrderNumber() + " placed successfully!", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + target + "?success=" + msg);
            } else {
                String msg = URLEncoder.encode("Failed to place order due to insufficient stock or wallet balance. Please try again.", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/cart?error=" + msg);
            }

        } else if ("/farmer/order/update-status".equals(servletPath)) {
            String subOrderIdStr = request.getParameter("subOrderId");
            if (subOrderIdStr == null || subOrderIdStr.trim().isEmpty()) {
                subOrderIdStr = request.getParameter("orderId");
            }
            String targetStatus = request.getParameter("status");

            if (subOrderIdStr == null || targetStatus == null) {
                response.sendRedirect(request.getContextPath() + "/farmer/orders?error=" + URLEncoder.encode("Invalid order update parameters.", StandardCharsets.UTF_8));
                return;
            }

            try {
                int subOrderId = Integer.parseInt(subOrderIdStr.trim());
                FarmerProfileDAO fpDAO = new FarmerProfileDAO();
                FarmerProfile fp = fpDAO.getProfileByUserId(user.getUserId());
                if (fp == null) {
                    response.sendRedirect(request.getContextPath() + "/farmer/orders?error=" + URLEncoder.encode("Farmer profile not found.", StandardCharsets.UTF_8));
                    return;
                }

                // Disallow farmer from unilaterally completing order
                if ("COMPLETED".equalsIgnoreCase(targetStatus.trim())) {
                    response.sendRedirect(request.getContextPath() + "/farmer/orders?error=" + URLEncoder.encode("Order completion requires Buyer receipt confirmation.", StandardCharsets.UTF_8));
                    return;
                }

                boolean updated = orderDAO.updateFarmerSubOrderStatus(subOrderId, targetStatus, fp.getFarmerProfileId());
                if (updated) {
                    String msg = "Order item status updated to " + targetStatus + " successfully.";
                    response.sendRedirect(request.getContextPath() + "/farmer/orders?success=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                } else {
                    String errorMsg = "Invalid order status transition or unauthorized update.";
                    response.sendRedirect(request.getContextPath() + "/farmer/orders?error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8));
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/farmer/orders?error=" + URLEncoder.encode("Error processing order update.", StandardCharsets.UTF_8));
            }

        } else if ("/buyer/order/confirm-delivery".equals(servletPath) || "/commercial/order/confirm-delivery".equals(servletPath)) {
            String subOrderIdStr = request.getParameter("subOrderId");
            OrganizationDAO orgDAO = new OrganizationDAO();
            Organization org = orgDAO.getOrganizationByUserId(user.getUserId());
            String redirectTarget = (org != null || "COMMERCIAL".equals(user.getRole())) ? "/commercial/orders" : "/buyer/orders";

            if (subOrderIdStr == null || subOrderIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + redirectTarget + "?error=" + URLEncoder.encode("Invalid order parameter.", StandardCharsets.UTF_8));
                return;
            }

            try {
                int subOrderId = Integer.parseInt(subOrderIdStr.trim());
                boolean confirmed = orderDAO.confirmBuyerDelivery(subOrderId, user.getUserId());

                if (confirmed) {
                    String msg = "Thank you! Order receipt confirmed and payment released to farmer successfully.";
                    response.sendRedirect(request.getContextPath() + redirectTarget + "?success=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                } else {
                    response.sendRedirect(request.getContextPath() + redirectTarget + "?error=" + URLEncoder.encode("Unable to confirm order delivery. Ensure order is in delivered state.", StandardCharsets.UTF_8));
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + redirectTarget + "?error=" + URLEncoder.encode("Error confirming delivery.", StandardCharsets.UTF_8));
            }

        } else if ("/farmer/order/confirm-cash".equals(servletPath)) {
            String orderIdStr = request.getParameter("orderId");
            FarmerProfileDAO fpDAO = new FarmerProfileDAO();
            FarmerProfile fp = fpDAO.getProfileByUserId(user.getUserId());
            if (orderIdStr != null && fp != null) {
                orderDAO.confirmCashPayment(Integer.parseInt(orderIdStr), fp.getFarmerProfileId(), request.getRemoteAddr(), request.getHeader("User-Agent"), "Farmer cash confirmation");
            }
            response.sendRedirect(request.getContextPath() + "/farmer/orders?success=" + URLEncoder.encode("Cash payment confirmed and recorded!", StandardCharsets.UTF_8));
        }
    }
}
