<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Product"%>
<%@page import="com.kisaanconnect.dao.ProductDAO"%>

<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) {
        ProductDAO pDAO = new ProductDAO();
        products = pDAO.getAllAvailableProducts();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Produce Moderation | KisaanConnect Admin</title>

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
</head>

<body>

    <%@ include file="/includes/admin-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/admin-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="margin-bottom: 24px;">
                <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-wheat-awn"></i> Marketplace Produce Moderation</h1>
                <p style="color: #6B7280; font-size: 14px;">Moderate active crop listings across all categories and farmers.</p>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <div style="background: white; border-radius: 20px; padding: 26px; border: 1px solid #E5E7EB; box-shadow: 0 8px 24px rgba(0,0,0,0.05); overflow-x: auto;">
                <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                    <thead>
                        <tr style="text-align: left; background: #F9FAFB; border-bottom: 2px solid #E5E7EB;">
                            <th style="padding: 14px 16px;">Product</th>
                            <th style="padding: 14px 16px;">Category</th>
                            <th style="padding: 14px 16px;">Farmer / Farm</th>
                            <th style="padding: 14px 16px;">Price</th>
                            <th style="padding: 14px 16px;">Stock</th>
                            <th style="padding: 14px 16px;">Status</th>
                            <th style="padding: 14px 16px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (products != null) {
                            for (Product p : products) { %>
                                <tr style="border-bottom: 1px solid #F3F4F6;">
                                    <td style="padding: 14px 16px;"><strong><%= p.getProductName() %></strong></td>
                                    <td style="padding: 14px 16px;"><%= p.getCategoryName() != null ? p.getCategoryName() : "Produce" %></td>
                                    <td style="padding: 14px 16px;"><%= p.getFarmerName() %> (<%= p.getFarmName() != null ? p.getFarmName() : "Farm" %>)</td>
                                    <td style="padding: 14px 16px; font-weight: 700; color: #2E7D32;">₹<%= p.getPrice() %> / <%= p.getUnit() %></td>
                                    <td style="padding: 14px 16px;"><%= p.getAvailableQuantity() %> <%= p.getUnit() %></td>
                                    <td style="padding: 14px 16px;">
                                        <span style="font-weight: 700; font-size: 12px; color: #03543F;">
                                            <%= p.getStatus() %>
                                        </span>
                                    </td>
                                    <td style="padding: 14px 16px;">
                                        <form action="${pageContext.request.contextPath}/admin/delete-product" method="post" onsubmit="return confirm('Delete this produce listing?');" style="margin: 0; display: inline;">
                                            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                            <button type="submit" style="background: #FEE2E2; color: #9B1C1C; border: none; padding: 6px 12px; border-radius: 8px; font-weight: 600; font-size: 12px; cursor: pointer;">
                                                Delete Listing
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>

        </div>

    </div>

</body>
</html>
