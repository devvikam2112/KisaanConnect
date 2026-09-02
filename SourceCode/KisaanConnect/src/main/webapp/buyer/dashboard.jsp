<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.model.BuyerProfile"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.Product"%>
<%@page import="com.kisaanconnect.model.Category"%>
<%@page import="com.kisaanconnect.dao.BuyerDAO"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.dao.ProductDAO"%>
<%@page import="com.kisaanconnect.dao.CategoryDAO"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    BuyerDAO buyerDAO = new BuyerDAO();
    BuyerProfile buyerProfile = buyerDAO.getProfileByUserId(loggedInUser.getUserId());

    WalletDAO walletDAO = new WalletDAO();
    Wallet wallet = walletDAO.getOrCreateWallet(loggedInUser.getUserId());

    OrderDAO orderDAO = new OrderDAO();
    List<Order> orders = null;
    if (buyerProfile != null) {
        orders = orderDAO.getOrdersByBuyerProfileId(buyerProfile.getBuyerProfileId());
    }

    CategoryDAO catDAO = new CategoryDAO();
    List<Category> categories = catDAO.getActiveCategories();

    ProductDAO productDAO = new ProductDAO();
    List<Product> featuredProducts = productDAO.getAllAvailableProducts();

    int totalOrdersCount = (orders != null) ? orders.size() : 0;
    long activeOrdersCount = 0;
    if (orders != null) {
        activeOrdersCount = orders.stream()
            .filter(o -> "PLACED".equalsIgnoreCase(o.getOrderStatus()) 
                      || "CONFIRMED".equalsIgnoreCase(o.getOrderStatus()) 
                      || "IN_TRANSIT".equalsIgnoreCase(o.getOrderStatus())
                      || "OUT_FOR_DELIVERY".equalsIgnoreCase(o.getOrderStatus()))
            .count();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buyer Dashboard | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .buyer-hero {
            background: linear-gradient(135deg, #1B5E20, #2E7D32);
            color: white;
            padding: 40px 0 50px 0;
            border-radius: 0 0 30px 30px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            transition: 0.25s;
            height: 100%;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.08);
        }

        .category-chip {
            display: inline-block;
            padding: 8px 18px;
            background: white;
            color: #374151;
            border-radius: 20px;
            text-decoration: none;
            font-weight: 500;
            font-size: 13px;
            border: 1px solid #E5E7EB;
            margin: 4px;
            transition: 0.2s;
        }

        .category-chip:hover {
            background: #2E7D32;
            color: white;
            border-color: #2E7D32;
        }

        .produce-card {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            transition: 0.3s;
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .produce-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 14px 28px rgba(0,0,0,0.09);
        }

        .produce-img {
            width: 100%;
            height: 160px;
            object-fit: cover;
            background: #F3F4F6;
        }

        .table-custom {
            width: 100%;
            border-collapse: collapse;
        }

        .table-custom th {
            background: #F9FAFB;
            color: #4B5563;
            font-size: 13px;
            font-weight: 600;
            padding: 12px 16px;
            border-bottom: 2px solid #E5E7EB;
        }

        .table-custom td {
            padding: 14px 16px;
            font-size: 14px;
            color: #1F2937;
            border-bottom: 1px solid #F3F4F6;
            vertical-align: middle;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <!-- Hero Banner -->
    <div class="buyer-hero">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <span class="badge bg-light text-success px-3 py-1 rounded-pill mb-2 fw-semibold">
                        <i class="fa-solid fa-seedling"></i> Individual Buyer Dashboard
                    </span>
                    <h1 class="display-6 fw-bold mb-1">Welcome back, <%= loggedInUser.getFullName() %>!</h1>
                    <p class="mb-0 opacity-90">Direct fresh farm produce delivered from verified local growers.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/buyer/products.jsp" class="btn btn-light fw-semibold rounded-3 px-3 py-2 shadow-sm">
                        <i class="fa-solid fa-wheat-awn"></i> Marketplace
                    </a>
                    <a href="${pageContext.request.contextPath}/buyer/cart.jsp" class="btn btn-outline-light fw-semibold rounded-3 px-3 py-2">
                        <i class="fa-solid fa-cart-shopping"></i> View Cart
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container pb-5">

        <%@ include file="/includes/alerts.jsp" %>

        <!-- Metrics Row -->
        <div class="row g-4 mb-4">
            <div class="col-lg-3 col-sm-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-muted small">Wallet Balance</span>
                        <span class="fs-4"><i class="fa-solid fa-wallet"></i></span>
                    </div>
                    <h3 class="fw-bold text-success mb-1">₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %></h3>
                    <a href="${pageContext.request.contextPath}/buyer/wallet" class="text-success small fw-semibold text-decoration-none">
                        + Add Money →
                    </a>
                </div>
            </div>

            <div class="col-lg-3 col-sm-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-muted small">Total Orders</span>
                        <span class="fs-4"><i class="fa-solid fa-boxes-stacked"></i></span>
                    </div>
                    <h3 class="fw-bold text-dark mb-1"><%= totalOrdersCount %></h3>
                    <a href="${pageContext.request.contextPath}/buyer/orders.jsp" class="text-muted small text-decoration-none">
                        View order history →
                    </a>
                </div>
            </div>

            <div class="col-lg-3 col-sm-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-muted small">Active Shipments</span>
                        <span class="fs-4"><i class="fa-solid fa-truck-fast"></i></span>
                    </div>
                    <h3 class="fw-bold text-primary mb-1"><%= activeOrdersCount %></h3>
                    <span class="text-muted small">In-transit or preparing</span>
                </div>
            </div>

            <div class="col-lg-3 col-sm-6">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-muted small">Produce Categories</span>
                        <span class="fs-4">🥗</span>
                    </div>
                    <h3 class="fw-bold text-dark mb-1"><%= categories != null ? categories.size() : 6 %></h3>
                    <a href="${pageContext.request.contextPath}/buyer/products.jsp" class="text-success small fw-semibold text-decoration-none">
                        Browse all crops →
                    </a>
                </div>
            </div>
        </div>

        <!-- Category Shortcuts -->
        <div class="card border-0 rounded-4 shadow-sm p-3 mb-4">
            <div class="d-flex align-items-center flex-wrap gap-2">
                <span class="fw-semibold text-dark me-2 small">Crop Categories:</span>
                <a href="${pageContext.request.contextPath}/buyer/products.jsp" class="category-chip"><i class="fa-solid fa-wheat-awn"></i> All Produce</a>
                <% if (categories != null) {
                    for (Category cat : categories) { %>
                        <a href="${pageContext.request.contextPath}/buyer/products.jsp?category=<%= cat.getCategoryId() %>" class="category-chip">
                            <%= cat.getCategoryName() %>
                        </a>
                <%  }
                   } %>
            </div>
        </div>

        <!-- Featured Products Showcase -->
        <div class="mb-5">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h4 class="fw-bold text-dark mb-0"><i class="fa-solid fa-wheat-awn"></i> Fresh Produce From Farmers</h4>
                    <p class="text-muted small mb-0">Direct harvest available for immediate purchase</p>
                </div>
                <a href="${pageContext.request.contextPath}/buyer/products.jsp" class="btn btn-outline-success btn-sm rounded-3">
                    View Full Marketplace →
                </a>
            </div>

            <% if (featuredProducts == null || featuredProducts.isEmpty()) { %>
                <div class="card border-0 rounded-4 p-5 text-center shadow-sm">
                    <span class="display-6 mb-2"><i class="fa-solid fa-wheat-awn"></i></span>
                    <h5 class="fw-bold text-dark">No crops currently listed</h5>
                    <p class="text-muted small">Check back shortly as farmers list fresh seasonal produce.</p>
                </div>
            <% } else { %>
                <div class="row g-4">
                    <% int count = 0;
                       for (Product prod : featuredProducts) {
                           if (count++ >= 4) break; %>
                        <div class="col-lg-3 col-md-6">
                            <div class="produce-card">
                                <% if (prod.getPrimaryImageUrl() != null && !prod.getPrimaryImageUrl().isEmpty()) { %>
                                    <img src="${pageContext.request.contextPath}/<%= prod.getPrimaryImageUrl() %>"
                                         class="produce-img"
                                         alt="<%= prod.getProductName() %>">
                                <% } else { %>
                                    <div class="produce-img d-flex align-items-center justify-content-center text-muted">
                                        <i class="fa-solid fa-seedling fs-2 text-success"></i>
                                    </div>
                                <% } %>
                                <div class="p-3 d-flex flex-column flex-grow-1">
                                    <span class="badge bg-success-subtle text-success align-self-start small mb-1">
                                        <%= prod.getProductType() != null ? prod.getProductType() : "Fresh" %>
                                    </span>
                                    <h6 class="fw-bold text-dark mb-1"><%= prod.getProductName() %></h6>
                                    <small class="text-muted mb-2">
                                        <%= prod.getFarmerName() != null ? prod.getFarmerName() : (prod.getFarmName() != null ? prod.getFarmName() : "Local Farm") %>
                                        <% if (prod.getFarmerLocation() != null && !prod.getFarmerLocation().isEmpty()) { %>
                                            • <%= prod.getFarmerLocation() %>
                                        <% } %>
                                    </small>
                                    <div class="mt-auto pt-2 d-flex justify-content-between align-items-center border-top">
                                        <div class="fw-bold text-success fs-5">
                                            ₹<%= prod.getPrice() %> <small class="text-muted fs-6 font-monospace">/<%= prod.getUnit() %></small>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/cart/add" method="post" class="m-0">
                                            <input type="hidden" name="productId" value="<%= prod.getProductId() %>">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="btn btn-success btn-sm rounded-3 px-3">
                                                <i class="fa-solid fa-cart-plus"></i> Add
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

        <!-- Recent Orders Snippet -->
        <div class="card border-0 rounded-4 shadow-sm p-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold text-dark mb-0"><i class="fa-solid fa-boxes-stacked"></i> Recent Order History</h5>
                <a href="${pageContext.request.contextPath}/buyer/orders.jsp" class="btn btn-outline-secondary btn-sm rounded-3">
                    View All Orders →
                </a>
            </div>

            <% if (orders == null || orders.isEmpty()) { %>
                <p class="text-muted text-center py-4 mb-0">You have not placed any orders yet. Visit the marketplace to start shopping!</p>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table-custom">
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Delivery Contact</th>
                                <th>Total (₹)</th>
                                <th>Payment Method</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int orderSnippetCount = 0;
                               for (Order o : orders) {
                                   if (orderSnippetCount++ >= 5) break; %>
                                <tr>
                                    <td><strong><%= o.getOrderNumber() %></strong></td>
                                    <td><%= o.getOrderDate() %></td>
                                    <td><%= o.getDeliveryName() %> (<%= o.getDeliveryPhone() %>)</td>
                                    <td class="fw-bold text-success">₹<%= o.getTotalAmount() %></td>
                                    <td><%= o.getPaymentMethod() %></td>
                                    <td>
                                        <span class="badge <%= "DELIVERED".equalsIgnoreCase(o.getOrderStatus()) ? "bg-success" : "bg-warning text-dark" %> px-2 py-1">
                                            <%= o.getOrderStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/buyer/orders.jsp#order-<%= o.getOrderId() %>" class="btn btn-light btn-sm rounded-2">
                                            Details
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

    </div>

</body>
</html>
