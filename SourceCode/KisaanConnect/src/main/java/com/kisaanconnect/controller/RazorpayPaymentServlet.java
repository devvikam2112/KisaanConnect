package com.kisaanconnect.controller;

import com.kisaanconnect.dao.*;
import com.kisaanconnect.model.*;
import com.kisaanconnect.service.RazorpayService;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "RazorpayPaymentServlet", urlPatterns = {
    "/order/razorpay/create-order",
    "/order/razorpay/verify-payment",
    "/order/razorpay/recovery-status"
})
public class RazorpayPaymentServlet extends HttpServlet {

    private final RazorpayService razorpayService = new RazorpayService();
    private final PaymentAttemptDAO paymentAttemptDAO = new PaymentAttemptDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final BuyerDAO buyerDAO = new BuyerDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final OrganizationDAO organizationDAO = new OrganizationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Authentication required. Please log in.\"}");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        String servletPath = request.getServletPath();

        if ("/order/razorpay/create-order".equals(servletPath)) {
            handleCreateOrder(request, response, user, out);
        } else if ("/order/razorpay/verify-payment".equals(servletPath)) {
            handleVerifyPayment(request, response, user, out);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print("{\"success\":false,\"error\":\"Endpoint not found\"}");
        }
    }

    private void handleCreateOrder(HttpServletRequest request, HttpServletResponse response, User user, PrintWriter out)
            throws IOException {

        BuyerProfile bp = buyerDAO.getOrCreateBuyerProfile(user.getUserId());
        int buyerProfileId = bp.getBuyerProfileId();

        Cart cart = cartDAO.getOrCreateCart(buyerProfileId);
        List<CartItem> cartItems = (cart != null) ? cartDAO.getCartItems(cart.getCartId()) : new ArrayList<>();

        if (cartItems.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Your shopping cart is empty.\"}");
            return;
        }

        // Initial stock validation
        for (CartItem ci : cartItems) {
            double stock = cartDAO.getAvailableStock(ci.getProductId());
            if (ci.getQuantity() > stock) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.printf("{\"success\":false,\"error\":\"Insufficient stock for %s. Only %.1f %s available.\"}",
                    escapeJson(ci.getProductName()), stock, escapeJson(ci.getUnit() != null ? ci.getUnit() : "units"));
                return;
            }
        }

        String deliveryName = request.getParameter("deliveryName");
        String deliveryPhone = request.getParameter("deliveryPhone");
        String deliveryAddress = request.getParameter("deliveryAddress");
        String deliveryPincode = request.getParameter("deliveryPincode");
        String deliveryDateStr = request.getParameter("deliveryDate");

        if (deliveryName == null || deliveryName.trim().isEmpty()) deliveryName = user.getFullName();
        if (deliveryPhone == null || deliveryPhone.trim().isEmpty()) deliveryPhone = user.getPhone();
        if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Delivery address is required.\"}");
            return;
        }
        if (deliveryPincode == null || deliveryPincode.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Delivery pincode is required.\"}");
            return;
        }

        Date deliveryDateSql = null;
        if (deliveryDateStr != null && !deliveryDateStr.trim().isEmpty()) {
            try {
                LocalDate selDate = LocalDate.parse(deliveryDateStr.trim());
                if (selDate.isBefore(LocalDate.now())) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\":false,\"error\":\"Delivery date cannot be in the past.\"}");
                    return;
                }
                deliveryDateSql = Date.valueOf(selDate);
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"error\":\"Invalid delivery date format.\"}");
                return;
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Delivery date is required.\"}");
            return;
        }

        // Server-side calculation
        BigDecimal subtotal = BigDecimal.ZERO;
        List<OrderItem> snapshotItems = new ArrayList<>();
        for (CartItem ci : cartItems) {
            Product prod = productDAO.getProductById(ci.getProductId());
            int farmerProfileId = (prod != null) ? prod.getFarmerProfileId() : 0;

            OrderItem oi = new OrderItem();
            oi.setProductId(ci.getProductId());
            oi.setFarmerProfileId(farmerProfileId);
            oi.setProductName(ci.getProductName());
            oi.setUnitPrice(ci.getUnitPrice());
            oi.setQuantity(ci.getQuantity());
            oi.setDiscountAmount(BigDecimal.ZERO);
            oi.setFinalUnitPrice(ci.getUnitPrice());
            oi.setSubtotal(ci.getItemTotal());
            oi.setUnit(ci.getUnit());
            snapshotItems.add(oi);
            subtotal = subtotal.add(ci.getItemTotal());
        }

        BigDecimal deliveryCharge = BigDecimal.valueOf(50.0);
        BigDecimal platformFee = BigDecimal.valueOf(10.0);
        BigDecimal totalAmount = subtotal.add(deliveryCharge).add(platformFee);

        Organization org = organizationDAO.getOrganizationByUserId(user.getUserId());

        // Step 1: Create durable pre-order snapshot BEFORE calling Razorpay
        PaymentAttempt attempt = new PaymentAttempt();
        attempt.setUserId(user.getUserId());
        attempt.setBuyerProfileId(bp.getBuyerProfileId());
        if (org != null) attempt.setOrganizationId(org.getOrganizationId());
        attempt.setAmount(totalAmount);
        attempt.setCurrency("INR");
        attempt.setDeliveryName(deliveryName);
        attempt.setDeliveryPhone(deliveryPhone);
        attempt.setDeliveryAddress(deliveryAddress);
        attempt.setDeliveryPincode(deliveryPincode);
        attempt.setDeliveryDate(deliveryDateSql);

        int attemptId = paymentAttemptDAO.createAttemptWithItems(attempt, snapshotItems);
        if (attemptId == 0) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"Failed to initialize payment attempt.\"}");
            return;
        }

        // Step 2: Call Razorpay Orders API
        String receipt = "rcpt_att_" + attemptId;
        RazorpayService.RazorpayOrderResult orderResult = razorpayService.createRazorpayOrder(totalAmount, receipt);
        if (!orderResult.success || orderResult.orderId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            out.print("{\"success\":false,\"error\":\"Razorpay gateway communication failed. Please try again.\"}");
            return;
        }

        // Step 3: Update attempt with gateway order id
        paymentAttemptDAO.updateGatewayOrderId(attemptId, orderResult.orderId);

        // Step 4: Return JSON details for frontend checkout.js
        out.printf("{\"success\":true,\"paymentMode\":\"%s\",\"keyId\":\"%s\",\"razorpayOrderId\":\"%s\",\"amount\":%d,\"currency\":\"INR\",\"attemptId\":%d,\"totalAmount\":%.2f}",
            razorpayService.isDevelopmentMode() ? "DEVELOPMENT" : "RAZORPAY",
            escapeJson(razorpayService.getKeyId()),
            escapeJson(orderResult.orderId),
            orderResult.amountPaise,
            attemptId,
            totalAmount.doubleValue()
        );
    }

    private void handleVerifyPayment(HttpServletRequest request, HttpServletResponse response, User user, PrintWriter out)
            throws IOException {

        String razorpayOrderId = request.getParameter("razorpay_order_id");
        String razorpayPaymentId = request.getParameter("razorpay_payment_id");
        String razorpaySignature = request.getParameter("razorpay_signature");

        if (razorpayOrderId == null || razorpayPaymentId == null || razorpaySignature == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Incomplete payment verification payload.\"}");
            return;
        }

        razorpayOrderId = razorpayOrderId.trim();
        razorpayPaymentId = razorpayPaymentId.trim();
        razorpaySignature = razorpaySignature.trim();

        // 1. Idempotency Check: if this payment was already processed, return existing order
        Order existingOrder = orderDAO.getOrderByGatewayPaymentId(razorpayPaymentId);
        if (existingOrder != null) {
            boolean isCommercial = existingOrder.getOrganizationId() != null && existingOrder.getOrganizationId() > 0;
            String redirectUrl = request.getContextPath() + (isCommercial ? "/commercial/orders.jsp" : "/buyer/orders.jsp") + "?orderNumber=" + existingOrder.getOrderNumber();
            out.printf("{\"success\":true,\"orderNumber\":\"%s\",\"redirectUrl\":\"%s\",\"alreadyProcessed\":true}",
                escapeJson(existingOrder.getOrderNumber()), escapeJson(redirectUrl));
            return;
        }

        // 2. Fetch durable attempt and immutable items
        PaymentAttempt attempt = paymentAttemptDAO.getAttemptByGatewayOrderId(razorpayOrderId);
        if (attempt == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Invalid payment attempt. No matching order found.\"}");
            return;
        }

        if (attempt.getUserId() != user.getUserId()) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"success\":false,\"error\":\"Unauthorized payment attempt ownership.\"}");
            return;
        }

        if ("SUCCESS".equalsIgnoreCase(attempt.getStatus()) && attempt.getOrderId() != null) {
            String redirectUrl = request.getContextPath() + (attempt.getOrganizationId() != null && attempt.getOrganizationId() > 0 ? "/commercial/orders.jsp" : "/buyer/orders.jsp");
            out.printf("{\"success\":true,\"redirectUrl\":\"%s\",\"alreadyProcessed\":true}", escapeJson(redirectUrl));
            return;
        }

        // 3. Cryptographic Signature Verification
        boolean sigValid = razorpayService.verifySignature(razorpayOrderId, razorpayPaymentId, razorpaySignature);
        if (!sigValid) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Cryptographic payment signature verification failed. Tampered payload detected.\"}");
            return;
        }

        // 4. Independent Razorpay Entity Query: Verify amount, currency INR, and STRICT captured status
        long expectedPaise = attempt.getAmount().multiply(BigDecimal.valueOf(100)).longValue();
        RazorpayService.RazorpayPaymentVerificationResult entityCheck = razorpayService.verifyPaymentEntity(razorpayPaymentId, razorpayOrderId, expectedPaise);
        if (!entityCheck.isValid || !entityCheck.isCaptured) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.printf("{\"success\":false,\"error\":\"Payment status verification failed. Status: %s. Only captured payments can be completed.\"}",
                escapeJson(entityCheck.status != null ? entityCheck.status : "unknown"));
            return;
        }

        // 5. Atomic state transition: CREATED -> PROCESSING
        paymentAttemptDAO.markProcessing(razorpayOrderId);

        // 6. Build Master Order from immutable snapshot
        Order order = new Order();
        if (attempt.getOrganizationId() != null && attempt.getOrganizationId() > 0) {
            order.setOrganizationId(attempt.getOrganizationId());
            order.setBuyerType("COMMERCIAL");
        } else {
            order.setBuyerProfileId(attempt.getBuyerProfileId());
            order.setBuyerType("INDIVIDUAL");
        }

        order.setDeliveryName(attempt.getDeliveryName());
        order.setDeliveryPhone(attempt.getDeliveryPhone());
        order.setDeliveryAddress(attempt.getDeliveryAddress());
        order.setDeliveryPincode(attempt.getDeliveryPincode());
        order.setDeliveryDate(attempt.getDeliveryDate());

        BigDecimal subtotal = BigDecimal.ZERO;
        for (OrderItem item : attempt.getItems()) {
            subtotal = subtotal.add(item.getSubtotal());
        }
        BigDecimal deliveryCharge = BigDecimal.valueOf(50.0);
        BigDecimal platformFee = BigDecimal.valueOf(10.0);

        order.setSubtotalAmount(subtotal);
        order.setDiscountAmount(BigDecimal.ZERO);
        order.setDeliveryCharge(deliveryCharge);
        order.setPlatformFee(platformFee);
        order.setTotalAmount(attempt.getAmount());

        // 7. Atomic internal database commit using immutable snapshot
        boolean orderCreated = orderDAO.createOnlineOrderWithSnapshot(
            order, attempt.getItems(), user.getUserId(), razorpayOrderId, razorpayPaymentId, razorpaySignature
        );

        if (orderCreated) {
            paymentAttemptDAO.markSuccess(razorpayOrderId, order.getOrderId());

            // Clear user cart
            Cart cart = cartDAO.getOrCreateCart(attempt.getBuyerProfileId() != null ? attempt.getBuyerProfileId() : 0);
            if (cart != null) {
                cartDAO.clearCart(cart.getCartId());
            }

            String target = (attempt.getOrganizationId() != null && attempt.getOrganizationId() > 0) ? "/commercial/orders.jsp" : "/buyer/orders.jsp";
            String redirectUrl = request.getContextPath() + target + "?success=Order+" + order.getOrderNumber() + "+placed+successfully!";

            out.printf("{\"success\":true,\"orderNumber\":\"%s\",\"redirectUrl\":\"%s\"}",
                escapeJson(order.getOrderNumber()), escapeJson(redirectUrl));
        } else {
            // Fail-safe auto-refund handling
            paymentAttemptDAO.logRecovery(user.getUserId(), razorpayPaymentId, razorpayOrderId, attempt.getAmount(), "Order placement inventory conflict");
            RazorpayService.RazorpayRefundResult refundResult = razorpayService.initiateRefund(razorpayPaymentId, attempt.getAmount(), "Order creation conflict auto-refund");

            if (refundResult.success) {
                paymentAttemptDAO.updateRecoveryRefund(razorpayPaymentId, "REFUND_COMPLETED", refundResult.refundId);
            } else {
                paymentAttemptDAO.updateRecoveryRefund(razorpayPaymentId, "REFUND_PENDING", null);
            }

            response.setStatus(HttpServletResponse.SC_CONFLICT);
            out.print("{\"success\":false,\"error\":\"Order placement failed due to an inventory conflict. An automatic refund has been initiated to your original payment source.\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
