<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String farmerUri = request.getRequestURI();
%>

<div class="sidebar">
    <div class="sidebar-header">
        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             class="sidebar-logo"
             alt="KisaanConnect">
        <h2>KisaanConnect</h2>
        <span class="sidebar-role-badge"><i class="fa-solid fa-tractor me-1"></i> Farmer Portal</span>
    </div>

    <ul class="sidebar-menu">
        <li class="<%= (farmerUri.endsWith("/farmer/dashboard") || farmerUri.endsWith("/farmer/dashboard.jsp")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/dashboard">
                <i class="fa-solid fa-gauge-high"></i> <span>Dashboard</span>
            </a>
        </li>

        <li class="menu-title">Produce & Inventory</li>

        <li class="<%= (farmerUri.contains("/add-product")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/add-product">
                <i class="fa-solid fa-circle-plus"></i> <span>Add Produce</span>
            </a>
        </li>

        <li class="<%= (farmerUri.contains("/farmer/products") || farmerUri.contains("/farmer/myProducts")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/products">
                <i class="fa-solid fa-wheat-awn"></i> <span>My Produce Listings</span>
            </a>
        </li>

        <li class="<%= (farmerUri.contains("/farmer/inventory")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/inventory.jsp">
                <i class="fa-solid fa-warehouse"></i> <span>Stock Inventory</span>
            </a>
        </li>

        <li class="menu-title">Order Management</li>

        <li class="<%= (farmerUri.contains("/farmer/orders")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/orders">
                <i class="fa-solid fa-boxes-stacked"></i> <span>Customer Orders</span>
            </a>
        </li>

        <li class="menu-title">Finance & Analytics</li>

        <li class="<%= (farmerUri.contains("/farmer/wallet")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/wallet">
                <i class="fa-solid fa-wallet"></i> <span>Wallet & Payouts</span>
            </a>
        </li>

        <li class="<%= (farmerUri.contains("/farmer/reports")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/reports">
                <i class="fa-solid fa-chart-line"></i> <span>Sales Reports</span>
            </a>
        </li>

        <li class="menu-title">Account</li>

        <li class="<%= (farmerUri.contains("/farmer/profile") || farmerUri.contains("/farmer/setup-profile")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/farmer/profile">
                <i class="fa-solid fa-user-gear"></i> <span>Farm Profile</span>
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> <span>Logout</span>
            </a>
        </li>
    </ul>
</div>