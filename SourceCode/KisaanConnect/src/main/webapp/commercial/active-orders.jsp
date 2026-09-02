<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Organization"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    Organization commercialOrg = (Organization) request.getAttribute("organization");
    if (commercialOrg == null) {
        OrganizationDAO orgDAO = new OrganizationDAO();
        commercialOrg = orgDAO.getOrganizationByUserId(loggedInUser.getUserId());
    }

    List<Order> orders = null;
    if (commercialOrg != null) {
        OrderDAO oDAO = new OrderDAO();
        orders = oDAO.getOrdersByOrganizationId(commercialOrg.getOrganizationId());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Active Shipments & Deliveries | KisaanConnect Commercial</title>

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
        .shipment-card {
            background: white;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            padding: 22px;
            margin-bottom: 20px;
        }

        .badge-status {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-placed { background: #FEF3C7; color: #92400E; }
        .status-confirmed { background: #DBEAFE; color: #1E40AF; }
        .status-shipped { background: #E0E7FF; color: #3730A3; }
        .status-delivered { background: #D1FAE5; color: #065F46; }

        .timeline-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 20px 0 10px 0;
            padding: 14px 20px;
            background: #F9FAFB;
            border-radius: 12px;
        }

        .timeline-step {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 600;
            color: #6B7280;
        }

        .step-active {
            color: #1E40AF;
        }

        .step-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #D1D5DB;
        }

        .dot-active {
            background: #2563EB;
            box-shadow: 0 0 0 3px rgba(37,99,235,0.2);
        }
    </style>
</head>

<body>

    <%@ include file="/includes/commercial-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/commercial-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-truck-fast"></i> Active Shipments & In-Transit Produce</h1>
                    <p style="color: #6B7280; font-size: 14px;">Monitor ongoing farm dispatches and logistics fulfillment for <%= commercialOrg != null ? commercialOrg.getOrgName() : "your organisation" %>.</p>
                </div>

                <a href="${pageContext.request.contextPath}/buyer/products.jsp"
                   style="background: #1E40AF; color: white; padding: 12px 22px; border-radius: 12px; text-decoration: none; font-weight: 600; font-size: 14px;">
                    <i class="fa-solid fa-plus"></i> New Procurement Order
                </a>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <% if (orders == null || orders.isEmpty()) { %>
                <div style="background: white; border-radius: 18px; padding: 50px 20px; text-align: center; border: 1px solid #E5E7EB;">
                    <div style="font-size: 50px; margin-bottom: 12px;"><i class="fa-solid fa-truck-fast"></i></div>
                    <h3 style="font-size: 20px; color: #1F2937; margin-bottom: 8px;">No corporate shipments currently in-transit</h3>
                    <p style="color: #6B7280; font-size: 14px; margin-bottom: 20px;">Procure fresh agricultural crops in bulk directly from growers.</p>
                    <a href="${pageContext.request.contextPath}/buyer/products.jsp"
                       style="background: #1E40AF; color: white; padding: 12px 24px; border-radius: 12px; text-decoration: none; font-weight: 600;">
                        <i class="fa-solid fa-wheat-awn"></i> Browse Bulk Marketplace
                    </a>
                </div>
            <% } else { %>
                <% for (Order o : orders) {
                    String st = (o.getOrderStatus() != null) ? o.getOrderStatus().toUpperCase().trim() : "PLACED";
                    boolean isPlaced = true;
                    boolean isAccepted = "ACCEPTED".equals(st) || "PROCESSING".equals(st) || "PARTIALLY_DISPATCHED".equals(st) || "DISPATCHED".equals(st) || "PARTIALLY_DELIVERED".equals(st) || "DELIVERED".equals(st) || "COMPLETED".equals(st);
                    boolean isShipped = "PARTIALLY_DISPATCHED".equals(st) || "DISPATCHED".equals(st) || "PARTIALLY_DELIVERED".equals(st) || "DELIVERED".equals(st) || "COMPLETED".equals(st);
                    boolean isDelivered = "PARTIALLY_DELIVERED".equals(st) || "DELIVERED".equals(st) || "COMPLETED".equals(st);
                    boolean isCompleted = "COMPLETED".equals(st);
                %>
                    <div class="shipment-card">
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; border-bottom: 1px solid #F3F4F6; padding-bottom: 14px;">
                            <div>
                                <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 2px;">Shipment #<%= o.getOrderNumber() %></h3>
                                <span style="font-size: 13px; color: #6B7280;">Order Date: <%= o.getOrderDate() %></span>
                            </div>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <span class="badge-status <%= isCompleted ? "status-delivered" : (isDelivered ? "status-delivered" : (isShipped ? "status-shipped" : "status-placed")) %>">
                                    <%= st.replace("_", " ") %>
                                </span>
                                <strong style="font-size: 18px; color: #1E40AF;">₹<%= o.getTotalAmount() %></strong>
                            </div>
                        </div>

                        <!-- Logistics Status Pipeline -->
                        <div class="timeline-bar">
                            <div class="timeline-step <%= isPlaced ? "step-active" : "" %>">
                                <span class="step-dot <%= isPlaced ? "dot-active" : "" %>"></span>
                                <span>1. Placed</span>
                            </div>
                            <span style="color: #D1D5DB;">→</span>
                            <div class="timeline-step <%= isAccepted ? "step-active" : "" %>">
                                <span class="step-dot <%= isAccepted ? "dot-active" : "" %>"></span>
                                <span>2. Farm Confirmed</span>
                            </div>
                            <span style="color: #D1D5DB;">→</span>
                            <div class="timeline-step <%= isShipped ? "step-active" : "" %>">
                                <span class="step-dot <%= isShipped ? "dot-active" : "" %>"></span>
                                <span>3. In-Transit / Dispatched</span>
                            </div>
                            <span style="color: #D1D5DB;">→</span>
                            <div class="timeline-step <%= isDelivered ? "step-active" : "" %>">
                                <span class="step-dot <%= isDelivered ? "dot-active" : "" %>"></span>
                                <span>4. Delivered / Received</span>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-top: 14px;">
                            <div>
                                <h4 style="font-size: 12px; font-weight: 700; color: #6B7280; text-transform: uppercase; margin-bottom: 6px;">Procured Produce Items</h4>
                                <% if (o.getItems() != null && !o.getItems().isEmpty()) {
                                    for (OrderItem oi : o.getItems()) { %>
                                        <div style="font-size: 13px; color: #374151; padding: 2px 0;">
                                            • <strong><%= oi.getProductName() %></strong> (<%= oi.getQuantity() %> <%= oi.getUnit() != null ? oi.getUnit() : "" %>) — ₹<%= oi.getSubtotal() %>
                                        </div>
                                <%  }
                                   } else { %>
                                    <span style="font-size: 13px; color: #6B7280;">Standard procurement lot</span>
                                <% } %>
                            </div>

                            <div style="background: #F9FAFB; padding: 12px; border-radius: 10px; font-size: 13px;">
                                <h4 style="font-size: 12px; font-weight: 700; color: #6B7280; text-transform: uppercase; margin-bottom: 4px;">Delivery Destination</h4>
                                <strong><%= o.getDeliveryName() %></strong><br>
                                <i class="fa-solid fa-location-dot"></i> <%= o.getDeliveryAddress() %> - <%= o.getDeliveryPincode() %><br>
                                📅 Requested Delivery: <strong style="color: #1E40AF;"><%= o.getFormattedDeliveryDate() %></strong><br>
                                <i class="fa-solid fa-credit-card"></i> Payment: <strong><%= o.getPaymentMethod() %></strong> (<%= o.getPaymentStatus() %>)
                            </div>
                        </div>
                    </div>
                <% } %>
            <% } %>

        </div>

    </div>

</body>
</html>
