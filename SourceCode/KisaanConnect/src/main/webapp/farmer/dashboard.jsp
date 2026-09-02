<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.FarmerProfile"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.model.Product"%>
<%@page import="com.kisaanconnect.dao.FarmerProfileDAO"%>
<%@page import="com.kisaanconnect.dao.ReportDAO"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.dao.ProductDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    FarmerProfile profile = (FarmerProfile) session.getAttribute("farmerProfile");
    if (profile == null) {
        FarmerProfileDAO fpDAO = new FarmerProfileDAO();
        profile = fpDAO.getProfileByUserId(loggedInUser.getUserId());
    }

    Map<String, Object> report = null;
    Wallet wallet = null;
    List<Order> recentOrders = null;
    List<Product> products = null;
    int lowStockCount = 0;

    if (profile != null) {
        WalletDAO wDAO = new WalletDAO();
        wallet = wDAO.getOrCreateWallet(loggedInUser.getUserId());

        ReportDAO rDAO = new ReportDAO();
        report = rDAO.getFarmerSalesReport(profile.getFarmerProfileId());

        OrderDAO oDAO = new OrderDAO();
        recentOrders = oDAO.getOrdersForFarmer(profile.getFarmerProfileId());

        ProductDAO pDAO = new ProductDAO();
        products = pDAO.getProductsByFarmer(profile.getFarmerProfileId());
        if (products != null) {
            for (Product p : products) {
                if (p.getAvailableQuantity() <= p.getMinimumStock()) {
                    lowStockCount++;
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Farmer Dashboard | KisaanConnect</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">

    <style>
        .farmer-hero {
            background: linear-gradient(135deg, #1B5E20, #2E7D32);
            color: white;
            padding: 30px;
            border-radius: 20px;
            margin-bottom: 24px;
            box-shadow: 0 10px 30px rgba(46,125,50,0.2);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: white;
            padding: 22px;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            border: 1px solid #E5E7EB;
            display: flex;
            align-items: center;
            gap: 16px;
            transition: 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 14px 28px rgba(0,0,0,0.08);
        }

        .stat-icon {
            width: 56px;
            height: 56px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
        }

        .stat-info h3 {
            font-size: 24px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 2px;
        }

        .stat-info p {
            font-size: 13px;
            color: #6B7280;
            margin: 0;
        }

        .quick-actions {
            background: white;
            padding: 24px;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            margin-bottom: 24px;
        }

        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 14px;
            margin-top: 16px;
        }

        .action-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 14px 18px;
            background: #F9FAFB;
            color: #1F2937;
            text-decoration: none;
            border-radius: 14px;
            font-weight: 600;
            font-size: 14px;
            transition: 0.25s;
            border: 1px solid #E5E7EB;
        }

        .action-btn:hover {
            background: #2E7D32;
            color: white;
            border-color: #2E7D32;
            transform: translateY(-2px);
        }

        .order-table-card {
            background: white;
            border-radius: 18px;
            padding: 24px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        table.dash-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        table.dash-table th {
            text-align: left;
            padding: 12px 14px;
            background: #F9FAFB;
            color: #4B5563;
            font-weight: 600;
            border-bottom: 2px solid #E5E7EB;
        }

        table.dash-table td {
            padding: 12px 14px;
            border-bottom: 1px solid #F3F4F6;
            color: #1F2937;
            vertical-align: middle;
        }

        .badge-status {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-placed { background: #FEF08A; color: #854D0E; }
        .status-accepted { background: #DBEAFE; color: #1E40AF; }
        .status-dispatched { background: #E0E7FF; color: #3730A3; }
        .status-delivered { background: #DEF7EC; color: #03543F; }
    </style>
</head>

<body>

    <%@ include file="/includes/farmer-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/farmer-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <!-- Farmer Hero Banner -->
            <div class="farmer-hero">
                <div>
                    <span style="font-size: 12px; font-weight: 700; background: rgba(255,255,255,0.2); padding: 4px 12px; border-radius: 20px; text-transform: uppercase; letter-spacing: 0.5px;">
                        <i class="fa-solid fa-wheat-awn"></i> Farmer Management Portal
                    </span>
                    <h1 style="font-size: 26px; font-weight: 800; margin-top: 8px; margin-bottom: 4px;">
                        Namaste, <%= profile != null ? profile.getFarmName() : loggedInUser.getFullName() %>!
                    </h1>
                    <p style="margin: 0; opacity: 0.9; font-size: 14px;">
                        Manage your farm listings, track stock, fulfill customer orders, and access earnings.
                    </p>
                </div>

                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/farmer/add-product"
                       style="background: white; color: #1B5E20; padding: 12px 20px; border-radius: 12px; text-decoration: none; font-weight: 700; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
                        <i class="fa-solid fa-plus"></i> List New Produce
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/inventory.jsp"
                       style="background: rgba(255,255,255,0.15); color: white; border: 1px solid rgba(255,255,255,0.4); padding: 12px 20px; border-radius: 12px; text-decoration: none; font-weight: 600; font-size: 14px; display: inline-flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-boxes-stacked"></i> Stock Inventory
                    </a>
                </div>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <% if (lowStockCount > 0) { %>
                <div style="background: #FEF2F2; border: 1px solid #FCA5A5; color: #991B1B; padding: 14px 20px; border-radius: 14px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between;">
                    <div style="display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 600;">
                        <span style="font-size: 20px;"><i class="fa-solid fa-triangle-exclamation"></i></span>
                        <span>Attention: You have <%= lowStockCount %> crop item(s) running low on inventory stock.</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/farmer/inventory.jsp" style="color: #991B1B; font-weight: 700; text-decoration: underline; font-size: 13px;">
                        Restock Now →
                    </a>
                </div>
            <% } %>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background: #DEF7EC; color: #03543F;"><i class="fa-solid fa-wheat-awn"></i></div>
                    <div class="stat-info">
                        <h3><%= report != null && report.get("activeProducts") != null ? report.get("activeProducts") : (products != null ? products.size() : 0) %></h3>
                        <p>Active Listed Produce</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #DBEAFE; color: #1E40AF;"><i class="fa-solid fa-clipboard-list"></i></div>
                    <div class="stat-info">
                        <h3><%= report != null && report.get("totalOrders") != null ? report.get("totalOrders") : (recentOrders != null ? recentOrders.size() : 0) %></h3>
                        <p>Customer Orders</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #FEF08A; color: #854D0E;"><i class="fa-solid fa-wallet"></i></div>
                    <div class="stat-info">
                        <h3>₹<%= report != null && report.get("totalRevenue") != null ? report.get("totalRevenue") : "0.00" %></h3>
                        <p>Gross Crop Sales</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #F3E8FF; color: #6B21A8;"><i class="fa-solid fa-credit-card"></i></div>
                    <div class="stat-info">
                        <h3>₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %></h3>
                        <p>Wallet Balance</p>
                    </div>
                </div>
            </div>

            <!-- Quick Management Actions -->
            <div class="quick-actions">
                <h3 style="font-size: 18px; color: #1F2937; margin: 0;">Farm Management Shortcuts</h3>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/farmer/add-product" class="action-btn">
                        <i class="fa-solid fa-seedling text-success"></i> Add Produce
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/products" class="action-btn">
                        <i class="fa-solid fa-boxes-stacked text-primary"></i> My Produce
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/inventory.jsp" class="action-btn">
                        <i class="fa-solid fa-warehouse text-warning"></i> Stock Control
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/orders" class="action-btn">
                        <i class="fa-solid fa-truck-fast text-info"></i> Customer Orders
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/wallet" class="action-btn">
                        <i class="fa-solid fa-wallet text-danger"></i> Wallet & Payouts
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/reports" class="action-btn">
                        <i class="fa-solid fa-chart-line text-success"></i> Sales Reports
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/profile" class="action-btn">
                        <i class="fa-solid fa-user-gear text-secondary"></i> Farm Profile
                    </a>
                </div>
            </div>

            <!-- Recent Customer Orders Snippet -->
            <div class="order-table-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 style="font-size: 18px; color: #1F2937; margin: 0;"><i class="fa-solid fa-boxes-stacked"></i> Recent Customer Orders</h3>
                    <a href="${pageContext.request.contextPath}/farmer/orders" style="color: #2E7D32; font-size: 13px; font-weight: 600; text-decoration: none;">
                        View All Orders →
                    </a>
                </div>

                <% if (recentOrders == null || recentOrders.isEmpty()) { %>
                    <p style="color: #6B7280; text-align: center; padding: 30px 0;">No customer orders received yet.</p>
                <% } else { %>
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Buyer / Delivery</th>
                                <th>Amount</th>
                                <th>Payment</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int orderCount = 0;
                               for (Order o : recentOrders) {
                                   if (orderCount++ >= 5) break;
                                   String st = o.getOrderStatus();
                                   String stCls = "status-placed";
                                   if ("ACCEPTED".equalsIgnoreCase(st)) stCls = "status-accepted";
                                   else if ("IN_TRANSIT".equalsIgnoreCase(st) || "DISPATCHED".equalsIgnoreCase(st)) stCls = "status-dispatched";
                                   else if ("DELIVERED".equalsIgnoreCase(st)) stCls = "status-delivered";
                            %>
                                <tr>
                                    <td><strong><%= o.getOrderNumber() %></strong></td>
                                    <td><%= o.getOrderDate() %></td>
                                    <td><%= o.getDeliveryName() %> (<%= o.getDeliveryAddress() != null ? o.getDeliveryAddress() : "Direct Delivery" %>)</td>
                                    <td style="font-weight: 700; color: #2E7D32;">₹<%= o.getTotalAmount() %></td>
                                    <td><%= o.getPaymentMethod() %> (<%= o.getPaymentStatus() %>)</td>
                                    <td><span class="badge-status <%= stCls %>"><%= o.getOrderStatus() %></span></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

        </div>

    </div>

</body>
</html>