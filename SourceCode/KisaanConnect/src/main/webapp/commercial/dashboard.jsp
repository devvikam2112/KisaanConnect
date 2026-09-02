<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.Organization"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.model.Category"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>
<%@page import="com.kisaanconnect.dao.ReportDAO"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.dao.CategoryDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    Organization commercialOrg = (Organization) request.getAttribute("organization");
    if (commercialOrg == null) {
        commercialOrg = (Organization) session.getAttribute("organization");
    }
    if (commercialOrg == null) {
        OrganizationDAO orgDAO = new OrganizationDAO();
        commercialOrg = orgDAO.getOrganizationByUserId(loggedInUser.getUserId());
    }

    if (commercialOrg == null) {
        response.sendRedirect(request.getContextPath() + "/commercial/setup-profile");
        return;
    }

    Map<String, Object> report = (Map<String, Object>) request.getAttribute("report");
    Wallet wallet = (Wallet) request.getAttribute("wallet");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    List<Category> categories = (List<Category>) request.getAttribute("categories");

    if (report == null) {
        ReportDAO rDAO = new ReportDAO();
        report = rDAO.getCommercialProcurementReport(commercialOrg.getOrganizationId());
    }
    if (wallet == null) {
        WalletDAO wDAO = new WalletDAO();
        wallet = wDAO.getOrCreateWallet(loggedInUser.getUserId());
    }
    if (orders == null) {
        OrderDAO oDAO = new OrderDAO();
        orders = oDAO.getOrdersByOrganizationId(commercialOrg.getOrganizationId());
    }
    if (categories == null) {
        CategoryDAO cDAO = new CategoryDAO();
        categories = cDAO.getActiveCategories();
    }

    int activeShipments = 0;
    if (orders != null) {
        for (Order o : orders) {
            String st = o.getOrderStatus();
            if ("PLACED".equalsIgnoreCase(st) || "ACCEPTED".equalsIgnoreCase(st) || "IN_TRANSIT".equalsIgnoreCase(st) || "DISPATCHED".equalsIgnoreCase(st)) {
                activeShipments++;
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Commercial Procurement Portal | KisaanConnect</title>

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
        .commercial-hero {
            background: linear-gradient(135deg, #1E3A8A, #2563EB);
            color: white;
            padding: 30px;
            border-radius: 20px;
            margin-bottom: 24px;
            box-shadow: 0 10px 30px rgba(30,58,138,0.2);
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
            background: #1E40AF;
            color: white;
            border-color: #1E40AF;
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

    <%@ include file="/includes/commercial-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/commercial-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <!-- Commercial Hero Banner -->
            <div class="commercial-hero">
                <div>
                    <span style="font-size: 12px; font-weight: 700; background: rgba(255,255,255,0.2); padding: 4px 12px; border-radius: 20px; text-transform: uppercase; letter-spacing: 0.5px;">
                        <i class="fa-solid fa-building"></i> Commercial Procurement Hub
                    </span>
                    <h1 style="font-size: 26px; font-weight: 800; margin-top: 8px; margin-bottom: 4px;">
                        <%= commercialOrg.getOrgName() %>
                    </h1>
                    <p style="margin: 0; opacity: 0.9; font-size: 14px;">
                        <%= commercialOrg.getOrgTypeName() != null ? commercialOrg.getOrgTypeName() : "Corporate Buyer" %> • GSTIN: <%= commercialOrg.getGstin() != null ? commercialOrg.getGstin() : "Unregistered" %> • <%= commercialOrg.getCity() %>, <%= commercialOrg.getState() %>
                    </p>
                </div>

                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/buyer/products.jsp"
                       style="background: white; color: #1E3A8A; padding: 12px 20px; border-radius: 12px; text-decoration: none; font-weight: 700; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
                        <i class="fa-solid fa-store"></i> Browse Bulk Produce
                    </a>
                    <a href="${pageContext.request.contextPath}/buyer/cart.jsp"
                       style="background: rgba(255,255,255,0.15); color: white; border: 1px solid rgba(255,255,255,0.4); padding: 12px 20px; border-radius: 12px; text-decoration: none; font-weight: 600; font-size: 14px; display: inline-flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-cart-shopping"></i> Bulk Cart
                    </a>
                </div>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background: #EFF6FF; color: #1E40AF;"><i class="fa-solid fa-credit-card"></i></div>
                    <div class="stat-info">
                        <h3>₹<%= report != null && report.get("totalSpend") != null ? report.get("totalSpend") : "0.00" %></h3>
                        <p>Total Procurement Spend</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #DEF7EC; color: #03543F;"><i class="fa-solid fa-wallet"></i></div>
                    <div class="stat-info">
                        <h3>₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %></h3>
                        <p>Corporate Wallet Balance</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #FEF08A; color: #854D0E;"><i class="fa-solid fa-boxes-stacked"></i></div>
                    <div class="stat-info">
                        <h3><%= report != null && report.get("totalProcurements") != null ? report.get("totalProcurements") : (orders != null ? orders.size() : 0) %></h3>
                        <p>Total Procurement Orders</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #F3E8FF; color: #6B21A8;"><i class="fa-solid fa-truck-fast"></i></div>
                    <div class="stat-info">
                        <h3><%= activeShipments %></h3>
                        <p>Active Shipments In-Transit</p>
                    </div>
                </div>
            </div>

            <!-- Quick Procurement Actions -->
            <div class="quick-actions">
                <h3 style="font-size: 18px; color: #1F2937; margin: 0;">Procurement & Operations Shortcuts</h3>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/buyer/products.jsp" class="action-btn">
                        <i class="fa-solid fa-wheat-awn text-success"></i> Browse Bulk Crops
                    </a>
                    <a href="${pageContext.request.contextPath}/buyer/cart.jsp" class="action-btn">
                        <i class="fa-solid fa-cart-flatbed text-primary"></i> Bulk Cart
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/orders" class="action-btn">
                        <i class="fa-solid fa-file-invoice text-info"></i> All Orders
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/active-orders.jsp" class="action-btn">
                        <i class="fa-solid fa-truck-ramp-box text-warning"></i> Active Shipments
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/wallet" class="action-btn">
                        <i class="fa-solid fa-building-columns text-danger"></i> Corporate Wallet
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/transactions.jsp" class="action-btn">
                        <i class="fa-solid fa-receipt text-secondary"></i> Payment Ledger
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/reports" class="action-btn">
                        <i class="fa-solid fa-chart-pie text-success"></i> Procurement Report
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/gst-ledger.jsp" class="action-btn">
                        <i class="fa-solid fa-file-shield text-primary"></i> Tax & GST Ledger
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/profile" class="action-btn">
                        <i class="fa-solid fa-building-gear text-info"></i> Company Profile
                    </a>
                    <a href="${pageContext.request.contextPath}/commercial/members.jsp" class="action-btn">
                        <i class="fa-solid fa-users-gear text-dark"></i> Staff & Roles
                    </a>
                </div>
            </div>

            <!-- Recent Corporate Orders Snippet -->
            <div class="order-table-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 style="font-size: 18px; color: #1F2937; margin: 0;"><i class="fa-solid fa-clipboard-list"></i> Recent Procurement Purchase Orders</h3>
                    <a href="${pageContext.request.contextPath}/commercial/orders" style="color: #1E40AF; font-size: 13px; font-weight: 600; text-decoration: none;">
                        View All Orders →
                    </a>
                </div>

                <% if (orders == null || orders.isEmpty()) { %>
                    <p style="color: #6B7280; text-align: center; padding: 30px 0;">No corporate purchase orders recorded yet.</p>
                <% } else { %>
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Items</th>
                                <th>Total (₹)</th>
                                <th>Delivery Destination</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int cOrderCount = 0;
                               for (Order o : orders) {
                                   if (cOrderCount++ >= 5) break;
                                   String st = (o.getOrderStatus() != null) ? o.getOrderStatus().toUpperCase().trim() : "PLACED";
                                   String stCls = "status-placed";
                                   if ("ACCEPTED".equals(st) || "PROCESSING".equals(st)) stCls = "status-accepted";
                                   else if ("IN_TRANSIT".equals(st) || "DISPATCHED".equals(st) || "PARTIALLY_DISPATCHED".equals(st)) stCls = "status-dispatched";
                                   else if ("DELIVERED".equals(st) || "PARTIALLY_DELIVERED".equals(st) || "COMPLETED".equals(st)) stCls = "status-delivered";
                                   else if ("CANCELLED".equals(st) || "REJECTED".equals(st)) stCls = "status-placed";
                            %>
                                <tr>
                                    <td><strong><%= o.getOrderNumber() %></strong></td>
                                    <td><%= o.getOrderDate() %></td>
                                    <td><%= o.getItems() != null ? o.getItems().size() : 0 %> items</td>
                                    <td style="font-weight: 700; color: #1E40AF;">₹<%= o.getTotalAmount() %></td>
                                    <td><%= o.getDeliveryAddress() %>, <%= o.getDeliveryPincode() %></td>
                                    <td><span class="badge-status <%= stCls %>"><%= st.replace("_", " ") %></span></td>
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
