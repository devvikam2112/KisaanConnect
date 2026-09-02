<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.kisaanconnect.model.CartItem"%>
<%@page import="com.kisaanconnect.model.Cart"%>
<%@page import="com.kisaanconnect.model.User"%>

<%@page import="com.kisaanconnect.dao.BuyerDAO"%>
<%@page import="com.kisaanconnect.dao.CartDAO"%>
<%@page import="com.kisaanconnect.model.BuyerProfile"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal subtotal = (BigDecimal) request.getAttribute("subtotal");
    if (subtotal == null) {
        subtotal = BigDecimal.ZERO;
    }

    if (cartItems == null && loggedInUser != null) {
        BuyerDAO bDAO = new BuyerDAO();
        BuyerProfile bp = bDAO.getProfileByUserId(loggedInUser.getUserId());
        int buyerProfileId = (bp != null) ? bp.getBuyerProfileId() : loggedInUser.getUserId();
        CartDAO cDAO = new CartDAO();
        Cart c = cDAO.getOrCreateCart(buyerProfileId);
        if (c != null) {
            cartItems = cDAO.getCartItems(c.getCartId());
            for (CartItem itm : cartItems) {
                subtotal = subtotal.add(itm.getItemTotal());
            }
        }
    }

    boolean hasInsufficientStock = false;
    if (cartItems != null) {
        for (CartItem itm : cartItems) {
            if (itm.getQuantity() > itm.getAvailableStock()) {
                hasInsufficientStock = true;
                break;
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F8FAFC;
            font-family: var(--kc-font, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif);
            color: #0F172A;
        }

        .cart-header-title {
            font-size: 1.65rem;
            font-weight: 800;
            color: #0F172A;
            letter-spacing: -0.02em;
        }

        .cart-card {
            background: #FFFFFF;
            border-radius: 16px;
            border: 1px solid #E2E8F0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            padding: 24px;
        }

        .item-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 0;
            border-bottom: 1px solid #F1F5F9;
            flex-wrap: wrap;
            gap: 16px;
        }

        .item-row:last-child {
            border-bottom: none;
        }

        .item-img {
            width: 72px;
            height: 72px;
            border-radius: 12px;
            object-fit: cover;
            background: #F1F5F9;
            border: 1px solid #E2E8F0;
            flex-shrink: 0;
        }

        .item-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: #0F172A;
            margin: 0 0 4px 0;
        }

        .farmer-tag {
            font-size: 0.8125rem;
            color: #15803D;
            background: #DCFCE7;
            padding: 2px 8px;
            border-radius: 6px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            margin-bottom: 6px;
        }

        .summary-card {
            background: #FFFFFF;
            border-radius: 16px;
            border: 1px solid #E2E8F0;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            position: sticky;
            top: 90px;
        }

        .stock-badge-good {
            font-size: 0.75rem;
            color: #15803D;
            background: #F0FDF4;
            border: 1px solid #BBF7D0;
            padding: 2px 8px;
            border-radius: 6px;
            font-weight: 600;
        }

        .stock-badge-warn {
            font-size: 0.75rem;
            color: #DC2626;
            background: #FEF2F2;
            border: 1px solid #FECACA;
            padding: 2px 8px;
            border-radius: 6px;
            font-weight: 700;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="container py-4 py-lg-5" style="max-width: 1200px;">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="cart-header-title mb-1">
                    <i class="fa-solid fa-cart-shopping text-success me-2"></i>Shopping Cart
                </h1>
                <p class="text-muted small mb-0">Direct farm produce from verified agricultural growers.</p>
            </div>
            <a href="${pageContext.request.contextPath}/buyer/products" class="btn btn-outline-success btn-sm rounded-pill px-3">
                <i class="fa-solid fa-store me-1"></i> Browse Marketplace
            </a>
        </div>

        <%@ include file="/includes/alerts.jsp" %>

        <% if (hasInsufficientStock) { %>
            <div class="alert alert-danger d-flex align-items-center mb-4 rounded-3 shadow-sm border-danger-subtle" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2 fs-5 text-danger"></i>
                <div>
                    <strong>Stock Alert:</strong> One or more produce items in your cart exceed available farm harvest. Please adjust quantities before checkout.
                </div>
            </div>
        <% } %>

        <% if (cartItems == null || cartItems.isEmpty()) { %>
            <div class="cart-card text-center py-5">
                <div style="font-size: 54px; color: #94A3B8; margin-bottom: 16px;">
                    <i class="fa-solid fa-wheat-awn"></i>
                </div>
                <h3 class="fw-bold text-dark mb-2">Your cart is currently empty</h3>
                <p class="text-muted mb-4">Discover farm-fresh harvests listed directly by local farmers.</p>
                <a href="${pageContext.request.contextPath}/buyer/products" class="btn btn-success px-4 py-2 rounded-pill fw-semibold">
                    <i class="fa-solid fa-store me-1"></i> Start Shopping
                </a>
            </div>
        <% } else { %>
            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="cart-card">
                        <div class="d-flex justify-content-between align-items-center pb-3 border-bottom mb-2">
                            <h4 class="fw-bold fs-6 text-uppercase text-muted mb-0">Cart Items (<%= cartItems.size() %>)</h4>
                            <span class="text-muted small">Escrow Protected</span>
                        </div>

                        <% for (CartItem item : cartItems) {
                            String imgUrl = (item.getPrimaryImageUrl() != null && !item.getPrimaryImageUrl().isEmpty())
                                    ? request.getContextPath() + "/" + item.getPrimaryImageUrl()
                                    : request.getContextPath() + "/assets/images/farmer.png";
                            boolean itemOverstock = item.getQuantity() > item.getAvailableStock();
                        %>
                            <div class="item-row">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="<%= imgUrl %>" class="item-img" alt="<%= item.getProductName() %>">
                                    <div>
                                        <h5 class="item-title"><%= item.getProductName() %></h5>
                                        <span class="farmer-tag">
                                            <i class="fa-solid fa-wheat-awn"></i> <%= item.getFarmerName() != null ? item.getFarmerName() : "Verified Farmer" %>
                                        </span>
                                        <div class="d-flex align-items-center gap-2 mt-1">
                                            <span class="text-dark fw-bold">₹<%= String.format("%.2f", item.getUnitPrice()) %> <span class="text-muted fw-normal small">/ <%= item.getUnit() %></span></span>
                                            <% if (itemOverstock) { %>
                                                <span class="stock-badge-warn"><i class="fa-solid fa-triangle-exclamation"></i> Max: <%= item.getAvailableStock() %></span>
                                            <% } else { %>
                                                <span class="stock-badge-good">Stock: <%= item.getAvailableStock() %> <%= item.getUnit() %></span>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex align-items-center gap-3 ms-auto">
                                    <form action="${pageContext.request.contextPath}/cart/update" method="post" class="d-flex align-items-center gap-1 m-0">
                                        <input type="hidden" name="cartItemId" value="<%= item.getCartItemId() %>">
                                        <input type="number"
                                               name="quantity"
                                               value="<%= item.getQuantity() %>"
                                               min="0.5"
                                               max="<%= item.getAvailableStock() %>"
                                               step="0.5"
                                               class="form-control text-center <%= itemOverstock ? "border-danger text-danger fw-bold" : "" %>"
                                               style="width: 75px; height: 36px; border-radius: 8px; font-size: 14px;">
                                        <button type="submit" class="btn btn-sm btn-outline-secondary" title="Update Quantity" style="height: 36px; width: 36px; border-radius: 8px;">
                                            <i class="fa-solid fa-arrows-rotate"></i>
                                        </button>
                                    </form>

                                    <div class="fw-bold text-end" style="min-width: 85px; font-size: 16px; color: #15803D;">
                                        ₹<%= String.format("%.2f", item.getItemTotal()) %>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/cart/remove" method="post" class="m-0">
                                        <input type="hidden" name="cartItemId" value="<%= item.getCartItemId() %>">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Remove item" style="height: 36px; width: 36px; border-radius: 8px;">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        <% } %>

                        <div class="mt-4 pt-3 border-top d-flex justify-content-between align-items-center">
                            <a href="${pageContext.request.contextPath}/buyer/products" class="text-success text-decoration-none fw-semibold small">
                                <i class="fa-solid fa-arrow-left me-1"></i> Add More Produce
                            </a>
                            <span class="text-muted small"><i class="fa-solid fa-shield-halved text-success me-1"></i> Direct Farmer Payout Escrow</span>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="summary-card">
                        <h4 class="fw-bold fs-5 mb-3 text-dark">Order Summary</h4>

                        <div class="d-flex justify-content-between mb-2 small">
                            <span class="text-muted">Produce Subtotal:</span>
                            <span class="fw-semibold text-dark">₹<%= String.format("%.2f", subtotal) %></span>
                        </div>

                        <div class="d-flex justify-content-between mb-2 small">
                            <span class="text-muted">Standard Delivery:</span>
                            <span class="fw-semibold text-dark">₹50.00</span>
                        </div>

                        <div class="d-flex justify-content-between mb-3 small">
                            <span class="text-muted">Platform Escrow Fee:</span>
                            <span class="fw-semibold text-dark">₹10.00</span>
                        </div>

                        <hr class="my-3">

                        <div class="d-flex justify-content-between mb-4">
                            <span class="fw-bold text-dark">Estimated Total:</span>
                            <span class="fw-bold fs-5 text-success">₹<%= String.format("%.2f", subtotal.add(BigDecimal.valueOf(60.0))) %></span>
                        </div>

                        <% if (hasInsufficientStock) { %>
                            <button class="btn btn-secondary w-100 py-3 rounded-pill fw-bold" disabled>
                                <i class="fa-solid fa-triangle-exclamation me-1"></i> Adjust Quantities to Checkout
                            </button>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/checkout" class="btn btn-success w-100 py-3 rounded-pill fw-bold shadow-sm d-flex justify-content-center align-items-center gap-2">
                                <span>Proceed to Checkout</span> <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        <% } %>

                        <div class="mt-3 text-center small text-muted">
                            <i class="fa-solid fa-lock text-success me-1"></i> 100% Safe & Secure Multi-Farmer Payout
                        </div>
                    </div>
                </div>
            </div>
        <% } %>

    </div>

    <%@ include file="/includes/footer.jsp" %>

</body>
</html>
