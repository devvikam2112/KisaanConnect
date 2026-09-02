<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User navLoggedInUser = (User) session.getAttribute("loggedInUser");
%>

<style>
.navbar-nav .notification {
    position: relative;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    width: 38px !important;
    height: 38px !important;
    border-radius: 50% !important;
    background: rgba(255, 255, 255, 0.15) !important;
    color: #FFFFFF !important;
    font-size: 16px !important;
    transition: all 0.2s ease !important;
    text-decoration: none !important;
    border: 1px solid rgba(255, 255, 255, 0.25) !important;
    box-sizing: border-box !important;
}
.navbar-nav .notification:hover {
    background: rgba(255, 255, 255, 0.28) !important;
    color: #FFFFFF !important;
    transform: translateY(-1px);
}
.navbar-nav .notification-count {
    position: absolute !important;
    top: -4px !important;
    right: -4px !important;
    min-width: 18px !important;
    height: 18px !important;
    padding: 0 4px !important;
    border-radius: 9px !important;
    color: #FFFFFF !important;
    font-size: 10px !important;
    font-weight: 700 !important;
    line-height: 1 !important;
    display: inline-flex !important;
    justify-content: center !important;
    align-items: center !important;
    text-align: center !important;
    box-sizing: border-box !important;
    white-space: nowrap !important;
    border: 2px solid #0F291E !important;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2) !important;
    z-index: 10 !important;
}
</style>

<nav class="navbar navbar-expand-lg navbar-dark sticky-top shadow-sm" style="background: linear-gradient(90deg, #0F291E 0%, #15803D 100%); border-bottom: 1px solid rgba(255,255,255,0.1); min-height: 70px;">
    <div class="container-fluid px-lg-4">
        <a class="navbar-brand fw-bold d-flex align-items-center gap-2"
           href="${pageContext.request.contextPath}/<%= (navLoggedInUser == null) ? "index.jsp" : (navLoggedInUser.getRole().equals("FARMER") ? "farmer/dashboard" : (navLoggedInUser.getRole().equals("COMMERCIAL") ? "commercial/dashboard" : (navLoggedInUser.getRole().equals("ADMIN") ? "admin/dashboard.jsp" : "buyer/dashboard.jsp"))) %>">
            <img src="${pageContext.request.contextPath}/assets/images/logo.png" style="height: 38px; width: 38px; object-fit: contain; border-radius: 10px; background: white; padding: 3px; box-shadow: 0 2px 8px rgba(0,0,0,0.15);" alt="KisaanConnect Logo">
            <span style="font-size: 1.25rem; letter-spacing: -0.02em;">KisaanConnect</span>
        </a>

        <button class="navbar-toggler border-0 shadow-none"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarNav"
                aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1">
                <% if (navLoggedInUser == null) { %>
                    <li class="nav-item">
                        <a class="nav-link px-3 fw-medium text-white" href="${pageContext.request.contextPath}/index.jsp">
                            <i class="fa-solid fa-house me-1 text-success-light"></i> Home
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-3 fw-medium text-white" href="${pageContext.request.contextPath}/products">
                            <i class="fa-solid fa-store me-1 text-success-light"></i> Browse Produce
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-3 fw-medium text-white" href="${pageContext.request.contextPath}/auth/login.jsp">
                            <i class="fa-solid fa-right-to-bracket me-1 text-success-light"></i> Login
                        </a>
                    </li>
                    <li class="nav-item ms-lg-2">
                        <a class="btn btn-light text-success fw-bold rounded-pill px-4 py-2" style="font-size: 0.875rem;"
                           href="${pageContext.request.contextPath}/auth/register.jsp">
                            Get Started →
                        </a>
                    </li>
                <% } else if ("BUYER".equals(navLoggedInUser.getRole())) { %>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/dashboard.jsp">
                            <i class="fa-solid fa-gauge-high me-1"></i> Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/products.jsp">
                            <i class="fa-solid fa-store me-1"></i> Marketplace
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/cart.jsp">
                            <i class="fa-solid fa-cart-shopping me-1"></i> Cart
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/orders.jsp">
                            <i class="fa-solid fa-boxes-stacked me-1"></i> Orders
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/wallet">
                            <i class="fa-solid fa-wallet me-1"></i> Wallet
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/reports">
                            <i class="fa-solid fa-chart-line me-1"></i> Reports
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/profile">
                            <i class="fa-solid fa-user-gear me-1"></i> Profile
                        </a>
                    </li>
                    <li class="nav-item ms-lg-2">
                        <a href="${pageContext.request.contextPath}/notifications" class="text-decoration-none">
                            <div class="notification" title="Notifications">
                                <i class="fa-solid fa-bell"></i>
                                <%
                                    int navNotifCount = new com.kisaanconnect.dao.NotificationDAO().getUnreadCount(navLoggedInUser.getUserId());
                                    if (navNotifCount > 0) {
                                %>
                                    <span class="notification-count" style="background: #DC2626;"><%= navNotifCount %></span>
                                <% } %>
                            </div>
                        </a>
                    </li>
                    <li class="nav-item ms-lg-1">
                        <a href="${pageContext.request.contextPath}/chat/conversations" class="text-decoration-none">
                            <div class="notification" title="Order Messages">
                                <i class="fa-solid fa-comments"></i>
                                <%
                                    int navChatCount = new com.kisaanconnect.dao.ChatDAO().getUnreadMessageCount(navLoggedInUser.getUserId());
                                    if (navChatCount > 0) {
                                %>
                                    <span class="notification-count" style="background: #2563EB;"><%= navChatCount %></span>
                                <% } %>
                            </div>
                        </a>
                    </li>
                    <li class="nav-item ms-lg-2">
                        <a class="btn btn-outline-light btn-sm rounded-pill px-3 py-1"
                           href="${pageContext.request.contextPath}/logout">
                            <i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout
                        </a>
                    </li>
                <% } else if ("COMMERCIAL".equals(navLoggedInUser.getRole())) { %>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/commercial/dashboard">
                            <i class="fa-solid fa-building me-1"></i> Commercial Hub
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/products.jsp">
                            <i class="fa-solid fa-store me-1"></i> Bulk Produce
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/buyer/cart.jsp">
                            <i class="fa-solid fa-cart-shopping me-1"></i> Bulk Cart
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/commercial/orders.jsp">
                            <i class="fa-solid fa-boxes-stacked me-1"></i> Orders
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/commercial/wallet">
                            <i class="fa-solid fa-wallet me-1"></i> Wallet
                        </a>
                    </li>
                    <li class="nav-item ms-lg-2">
                        <a href="${pageContext.request.contextPath}/notifications" class="text-decoration-none">
                            <div class="notification" title="Notifications">
                                <i class="fa-solid fa-bell"></i>
                                <%
                                    int navNotifCount = new com.kisaanconnect.dao.NotificationDAO().getUnreadCount(navLoggedInUser.getUserId());
                                    if (navNotifCount > 0) {
                                %>
                                    <span class="notification-count" style="background: #DC2626;"><%= navNotifCount %></span>
                                <% } %>
                            </div>
                        </a>
                    </li>
                    <li class="nav-item ms-lg-2">
                        <a class="btn btn-outline-light btn-sm rounded-pill px-3 py-1"
                           href="${pageContext.request.contextPath}/logout">
                            <i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout
                        </a>
                    </li>
                <% } else if ("FARMER".equals(navLoggedInUser.getRole())) { %>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/farmer/dashboard">
                            <i class="fa-solid fa-seedling me-1"></i> Farmer Portal
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/farmer/products">
                            <i class="fa-solid fa-wheat-awn me-1"></i> My Produce
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/farmer/orders">
                            <i class="fa-solid fa-boxes-stacked me-1"></i> Orders
                        </a>
                    </li>
                    <li class="nav-item ms-lg-2">
                        <a class="btn btn-outline-light btn-sm rounded-pill px-3 py-1"
                           href="${pageContext.request.contextPath}/logout">
                            <i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout
                        </a>
                    </li>
                <% } else if ("ADMIN".equals(navLoggedInUser.getRole())) { %>
                    <li class="nav-item">
                        <a class="nav-link px-2 fw-medium text-white" href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                            <i class="fa-solid fa-shield-halved me-1"></i> Admin Console
                        </a>
                    </li>
                    <li class="nav-item ms-lg-2">
                        <a class="btn btn-outline-light btn-sm rounded-pill px-3 py-1"
                           href="${pageContext.request.contextPath}/logout">
                            <i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout
                        </a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<% if (navLoggedInUser != null) { %>
<script>window.KisaanContextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-poll.js"></script>
<% } %>