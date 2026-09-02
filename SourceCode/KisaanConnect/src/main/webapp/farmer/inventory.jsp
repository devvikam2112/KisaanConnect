<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Product"%>
<%@page import="com.kisaanconnect.model.FarmerProfile"%>
<%@page import="com.kisaanconnect.dao.ProductDAO"%>
<%@page import="com.kisaanconnect.dao.FarmerProfileDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) {
        FarmerProfileDAO fpDAO = new FarmerProfileDAO();
        FarmerProfile fp = fpDAO.getProfileByUserId(loggedInUser.getUserId());
        if (fp != null) {
            ProductDAO pDAO = new ProductDAO();
            products = pDAO.getProductsByFarmer(fp.getFarmerProfileId());
        }
    }

    int totalItems = products != null ? products.size() : 0;
    int lowStockCount = 0;
    if (products != null) {
        for (Product p : products) {
            if (p.getAvailableQuantity() <= p.getMinimumStock()) {
                lowStockCount++;
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory & Stock Management | KisaanConnect</title>

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
        .inv-summary-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 18px;
            margin-bottom: 24px;
        }

        .inv-stat-card {
            background: white;
            padding: 20px 24px;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .inventory-table-card {
            background: white;
            border-radius: 18px;
            padding: 24px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            border: 1px solid #E5E7EB;
            overflow-x: auto;
        }

        table.inv-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        table.inv-table th {
            text-align: left;
            padding: 14px 16px;
            background: #F9FAFB;
            color: #4B5563;
            font-weight: 600;
            border-bottom: 2px solid #E5E7EB;
        }

        table.inv-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #F3F4F6;
            color: #1F2937;
            vertical-align: middle;
        }

        .stock-pill {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .stock-good {
            background: #DEF7EC;
            color: #03543F;
        }

        .stock-low {
            background: #FDE8E8;
            color: #9B1C1C;
        }

        .restock-form {
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 0;
        }

        .restock-input {
            width: 85px;
            height: 38px;
            border: 1px solid #D1D5DB;
            border-radius: 8px;
            padding: 0 10px;
            font-size: 13px;
            font-weight: 600;
            text-align: center;
            box-sizing: border-box;
        }

        .restock-btn {
            background: #2E7D32;
            color: white;
            border: none;
            height: 38px;
            padding: 0 14px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .restock-btn:hover {
            background: #1B5E20;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/farmer-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/farmer-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-wheat-awn"></i> Farm Inventory & Stock Control</h1>
                    <p style="color: #6B7280; font-size: 14px;">Monitor current stock levels, safety thresholds, and restock produce in real-time.</p>
                </div>

                <a href="${pageContext.request.contextPath}/farmer/add-product"
                   style="background: #2E7D32; color: white; padding: 12px 22px; border-radius: 12px; text-decoration: none; font-weight: 600; font-size: 14px; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-plus"></i> Add New Produce
                </a>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- Inventory Summary Metrics -->
            <div class="inv-summary-row">
                <div class="inv-stat-card">
                    <div>
                        <span style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Tracked Produce</span>
                        <h3 style="font-size: 24px; color: #1F2937; margin-top: 4px; margin-bottom: 0;"><%= totalItems %></h3>
                    </div>
                    <span style="font-size: 30px;"><i class="fa-solid fa-boxes-stacked"></i></span>
                </div>

                <div class="inv-stat-card">
                    <div>
                        <span style="font-size: 13px; color: #6B7280; font-weight: 600;">Adequate Stock</span>
                        <h3 style="font-size: 24px; color: #059669; margin-top: 4px; margin-bottom: 0;"><%= totalItems - lowStockCount %></h3>
                    </div>
                    <span style="font-size: 30px;"><i class="fa-solid fa-circle-check"></i></span>
                </div>

                <div class="inv-stat-card">
                    <div>
                        <span style="font-size: 13px; color: #6B7280; font-weight: 600;">Low Stock Warnings</span>
                        <h3 style="font-size: 24px; color: #DC2626; margin-top: 4px; margin-bottom: 0;"><%= lowStockCount %></h3>
                    </div>
                    <span style="font-size: 30px;"><i class="fa-solid fa-triangle-exclamation"></i></span>
                </div>
            </div>

            <div class="inventory-table-card">
                <% if (products == null || products.isEmpty()) { %>
                    <p style="text-align: center; color: #6B7280; padding: 40px 0;">No inventory records found. Add your produce to track stock.</p>
                <% } else { %>
                    <table class="inv-table">
                        <thead>
                            <tr>
                                <th>Produce</th>
                                <th>Category</th>
                                <th>Unit Price</th>
                                <th>Current Stock</th>
                                <th>Safety Threshold</th>
                                <th>Status</th>
                                <th>Quick Restock / Update</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Product p : products) {
                                boolean isLowStock = p.getAvailableQuantity() <= p.getMinimumStock();
                            %>
                                <tr>
                                    <td><strong><%= p.getProductName() %></strong></td>
                                    <td><%= p.getCategoryName() != null ? p.getCategoryName() : "General" %></td>
                                    <td>₹<%= p.getPrice() %> / <%= p.getUnit() %></td>
                                    <td><strong style="font-size: 15px;"><%= p.getAvailableQuantity() %></strong> <%= p.getUnit() %></td>
                                    <td><%= p.getMinimumStock() %> <%= p.getUnit() %></td>
                                    <td>
                                        <% if (isLowStock) { %>
                                            <span class="stock-pill stock-low"><i class="fa-solid fa-triangle-exclamation"></i> Low Stock</span>
                                        <% } else { %>
                                            <span class="stock-pill stock-good"><i class="fa-solid fa-circle-check"></i> Healthy Stock</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/farmer/update-stock" method="post" class="restock-form d-flex gap-2 align-items-center">
                                            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                            <div style="display: flex; align-items: center; gap: 6px;">
                                                <span style="font-weight: 700; color: #16a34a; font-size: 16px;">+</span>
                                                <input type="number"
                                                       name="additionalQuantity"
                                                       placeholder="Add Qty"
                                                       min="0.1"
                                                       step="0.1"
                                                       class="restock-input"
                                                       style="width: 100px; padding: 6px 10px; border-radius: 8px; border: 1px solid #d1d5db;"
                                                       required>
                                                <span style="font-size: 12px; color: #6b7280;"><%= p.getUnit() %></span>
                                                <button type="submit" class="restock-btn" title="Add to Available Stock" style="background: #16a34a; color: white; border: none; padding: 7px 14px; border-radius: 8px; font-weight: 600; font-size: 13px; cursor: pointer;">
                                                    <i class="fa-solid fa-plus"></i> Restock
                                                </button>
                                            </div>
                                        </form>
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
