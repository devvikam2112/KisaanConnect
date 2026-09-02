<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
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
    BigDecimal totalGross = BigDecimal.ZERO;
    BigDecimal totalLogistics = BigDecimal.ZERO;
    BigDecimal totalPlatform = BigDecimal.ZERO;

    if (commercialOrg != null) {
        OrderDAO oDAO = new OrderDAO();
        orders = oDAO.getOrdersByOrganizationId(commercialOrg.getOrganizationId());
        if (orders != null) {
            for (Order o : orders) {
                if (o.getSubtotalAmount() != null) totalGross = totalGross.add(o.getSubtotalAmount());
                if (o.getDeliveryCharge() != null) totalLogistics = totalLogistics.add(o.getDeliveryCharge());
                if (o.getPlatformFee() != null) totalPlatform = totalPlatform.add(o.getPlatformFee());
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tax & GST Invoices Ledger | KisaanConnect Commercial</title>

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
        .gst-summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .gst-card {
            background: white;
            padding: 20px;
            border-radius: 16px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
        }

        .gst-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .gst-table th {
            text-align: left;
            padding: 14px 16px;
            background: #F9FAFB;
            color: #4B5563;
            font-size: 13px;
            font-weight: 600;
            border-bottom: 2px solid #E5E7EB;
        }

        .gst-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #F3F4F6;
            vertical-align: middle;
        }

        @media print {
            .sidebar, .top-navbar, .no-print, button, .alert-container, input {
                display: none !important;
            }
            body {
                background: #FFFFFF !important;
                color: #000000 !important;
                margin: 0 !important;
                padding: 0 !important;
            }
            .main-content {
                margin-left: 0 !important;
                width: 100% !important;
                padding: 0 !important;
            }
            .dashboard-content {
                padding: 10px 0 !important;
            }
            .gst-card, .gst-table th, .gst-table td {
                border: 1px solid #D1D5DB !important;
                box-shadow: none !important;
            }
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
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-file-lines"></i> Tax & Billing Ledger</h1>
                    <p style="color: #6B7280; font-size: 14px;">GST compliant purchase statements, tax invoices, and financial breakdown for accounting compliance.</p>
                </div>
                <button onclick="window.print();" class="no-print" style="background: #1E40AF; color: white; border: none; padding: 12px 22px; border-radius: 12px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-print"></i> Print Tax Statement
                </button>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- GST & PAN Entity Overview -->
            <div class="gst-summary-grid">
                <div class="gst-card">
                    <span style="font-size: 12px; color: #6B7280; font-weight: 600; text-transform: uppercase;">Entity GSTIN</span>
                    <h3 style="font-size: 18px; color: #1F2937; margin-top: 4px; margin-bottom: 0;">
                        <code><%= (commercialOrg != null && commercialOrg.getGstin() != null) ? commercialOrg.getGstin() : "Unregistered" %></code>
                    </h3>
                </div>

                <div class="gst-card">
                    <span style="font-size: 12px; color: #6B7280; font-weight: 600; text-transform: uppercase;">Entity PAN</span>
                    <h3 style="font-size: 18px; color: #1F2937; margin-top: 4px; margin-bottom: 0;">
                        <code><%= (commercialOrg != null && commercialOrg.getPanNumber() != null) ? commercialOrg.getPanNumber() : "Unregistered" %></code>
                    </h3>
                </div>

                <div class="gst-card">
                    <span style="font-size: 12px; color: #6B7280; font-weight: 600; text-transform: uppercase;">Total Taxable Produce Value</span>
                    <h3 style="font-size: 18px; color: #059669; margin-top: 4px; margin-bottom: 0;">
                        ₹<%= totalGross %>
                    </h3>
                </div>

                <div class="gst-card">
                    <span style="font-size: 12px; color: #6B7280; font-weight: 600; text-transform: uppercase;">Total Logistics & Fees</span>
                    <h3 style="font-size: 18px; color: #1E40AF; margin-top: 4px; margin-bottom: 0;">
                        ₹<%= totalLogistics.add(totalPlatform) %>
                    </h3>
                </div>
            </div>

            <!-- Tax Invoice Breakdown Table -->
            <div style="background: white; border-radius: 20px; padding: 26px; border: 1px solid #E5E7EB; box-shadow: 0 8px 24px rgba(0,0,0,0.05);">
                <div style="margin-bottom: 18px;">
                    <h3 style="font-size: 18px; color: #1F2937; margin: 0;">Tax Invoices Statement (<%= commercialOrg != null ? commercialOrg.getOrgName() : "Organisation" %>)</h3>
                </div>

                <% if (orders == null || orders.isEmpty()) { %>
                    <p style="color: #6B7280; text-align: center; padding: 40px 0;">No tax invoices generated yet.</p>
                <% } else { %>
                    <table class="gst-table">
                        <thead>
                            <tr>
                                <th>Invoice #</th>
                                <th>Billing Date</th>
                                <th>Produce Taxable Value (₹)</th>
                                <th>Logistics (₹)</th>
                                <th>Platform Fee (₹)</th>
                                <th>Total Billed (₹)</th>
                                <th>GSTIN Applied</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Order o : orders) { %>
                                <tr>
                                    <td><strong>INV-<%= o.getOrderNumber() %></strong></td>
                                    <td><%= o.getOrderDate() %></td>
                                    <td>₹<%= o.getSubtotalAmount() != null ? o.getSubtotalAmount() : o.getTotalAmount() %></td>
                                    <td>₹<%= o.getDeliveryCharge() != null ? o.getDeliveryCharge() : "50.00" %></td>
                                    <td>₹<%= o.getPlatformFee() != null ? o.getPlatformFee() : "10.00" %></td>
                                    <td style="font-weight: 700; color: #1E40AF;">₹<%= o.getTotalAmount() %></td>
                                    <td><code><%= (o.getGstinApplied() != null && !o.getGstinApplied().isEmpty()) ? o.getGstinApplied() : (commercialOrg.getGstin() != null ? commercialOrg.getGstin() : "-") %></code></td>
                                    <td>
                                        <span style="font-size: 12px; font-weight: 700; color: #059669; background: #DEF7EC; padding: 4px 10px; border-radius: 12px;">
                                            <%= o.getPaymentStatus() %>
                                        </span>
                                    </td>
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
