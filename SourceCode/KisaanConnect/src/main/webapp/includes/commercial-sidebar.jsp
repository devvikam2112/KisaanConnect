<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String commUri = request.getRequestURI();
%>

<div class="sidebar">
    <div class="sidebar-header">
        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             class="sidebar-logo"
             alt="KisaanConnect">
        <h2>KisaanConnect</h2>
        <span class="sidebar-role-badge" style="background: rgba(30, 58, 138, 0.4); color: #93C5FD;">
            <i class="fa-solid fa-building me-1"></i> Commercial Hub
        </span>
    </div>

    <ul class="sidebar-menu">
        <li class="<%= (commUri.endsWith("/commercial/dashboard") || commUri.endsWith("/commercial/dashboard.jsp")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/dashboard">
                <i class="fa-solid fa-gauge-high"></i> <span>Dashboard</span>
            </a>
        </li>

        <li class="menu-title">Bulk Procurement</li>

        <li class="<%= (commUri.contains("/buyer/products") || commUri.contains("/marketplace") || commUri.contains("/products")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/buyer/products.jsp">
                <i class="fa-solid fa-store"></i> <span>Browse Bulk Produce</span>
            </a>
        </li>

        <li class="<%= (commUri.contains("/buyer/cart") || commUri.contains("/cart")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/buyer/cart.jsp">
                <i class="fa-solid fa-cart-shopping"></i> <span>Procurement Cart</span>
            </a>
        </li>

        <li class="menu-title">Order Management</li>

        <li class="<%= (commUri.contains("/commercial/orders")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/orders">
                <i class="fa-solid fa-boxes-stacked"></i> <span>All Procurements</span>
            </a>
        </li>

        <li class="menu-title">Finance & Wallet</li>

        <li class="<%= (commUri.contains("/commercial/wallet")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/wallet">
                <i class="fa-solid fa-wallet"></i> <span>Corporate Wallet</span>
            </a>
        </li>

        <li class="<%= (commUri.contains("/commercial/transactions") || commUri.contains("/commercial/ledger")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/transactions.jsp">
                <i class="fa-solid fa-receipt"></i> <span>Payment Ledger</span>
            </a>
        </li>

        <li class="menu-title">Reports & Tax</li>

        <li class="<%= (commUri.contains("/commercial/reports")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/reports">
                <i class="fa-solid fa-chart-line"></i> <span>Procurement Reports</span>
            </a>
        </li>

        <li class="<%= (commUri.contains("/commercial/gst-ledger") || commUri.contains("/commercial/gst-invoices")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/gst-ledger.jsp">
                <i class="fa-solid fa-file-invoice-dollar"></i> <span>Tax & GST Invoices</span>
            </a>
        </li>

        <li class="menu-title">Enterprise</li>

        <li class="<%= (commUri.contains("/commercial/profile") || commUri.contains("/commercial/setup-profile")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/profile">
                <i class="fa-solid fa-building-user"></i> <span>Company Profile</span>
            </a>
        </li>

        <li class="<%= (commUri.contains("/commercial/members") || commUri.contains("/commercial/team")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/commercial/members.jsp">
                <i class="fa-solid fa-users"></i> <span>Staff & Authorised Roles</span>
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> <span>Logout</span>
            </a>
        </li>
    </ul>
</div>

