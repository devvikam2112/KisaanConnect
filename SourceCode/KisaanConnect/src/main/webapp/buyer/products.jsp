<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Product"%>
<%@page import="com.kisaanconnect.model.Category"%>
<%@page import="com.kisaanconnect.dao.ProductDAO"%>
<%@page import="com.kisaanconnect.dao.CategoryDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Integer selectedCategory = (Integer) request.getAttribute("selectedCategory");
    String searchQuery = (String) request.getAttribute("searchQuery");

    if (products == null) {
        ProductDAO pDAO = new ProductDAO();
        products = pDAO.getAllAvailableProducts();
    }
    if (categories == null) {
        CategoryDAO cDAO = new CategoryDAO();
        categories = cDAO.getActiveCategories();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fresh Agricultural Produce Marketplace | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .market-header {
            background: linear-gradient(135deg, #2E7D32, #1B5E20);
            color: white;
            padding: 40px 0 50px 0;
            border-radius: 0 0 30px 30px;
            margin-bottom: 30px;
        }

        .search-container {
            max-width: 650px;
            margin: 20px auto 0 auto;
            position: relative;
        }

        .search-input {
            width: 100%;
            height: 56px;
            border-radius: 28px;
            border: none;
            padding: 0 55px 0 25px;
            font-size: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            outline: none;
        }

        .search-btn {
            position: absolute;
            right: 8px;
            top: 7px;
            height: 42px;
            width: 42px;
            border-radius: 50%;
            background: #2E7D32;
            color: white;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
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

        .category-chip:hover, .category-chip.active {
            background: #2E7D32;
            color: white;
            border-color: #2E7D32;
        }

        .market-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(270px, 1fr));
            gap: 24px;
            margin-top: 24px;
        }

        .produce-card {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            transition: 0.3s;
            display: flex;
            flex-direction: column;
        }

        .produce-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.1);
        }

        .produce-img {
            width: 100%;
            height: 190px;
            object-fit: cover;
            background: #F3F4F6;
        }

        .produce-body {
            padding: 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .badge-cat {
            display: inline-block;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 12px;
            background: #E8F5E9;
            color: #2E7D32;
            margin-bottom: 8px;
        }

        .produce-title {
            font-size: 18px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 4px;
        }

        .farm-loc {
            font-size: 12px;
            color: #6B7280;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .produce-price {
            font-size: 22px;
            font-weight: 700;
            color: #2E7D32;
            margin-top: auto;
            margin-bottom: 12px;
        }

        .add-cart-btn {
            background: #2E7D32;
            color: white;
            border: none;
            padding: 12px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            width: 100%;
            transition: 0.25s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-decoration: none;
        }

        .add-cart-btn:hover {
            background: #1B5E20;
            color: white;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="market-header text-center">
        <div class="container">
            <h1 class="display-6 fw-bold">Fresh Farm Marketplace</h1>
            <p class="lead opacity-90">Direct agricultural produce from verified local farmers</p>

            <form action="${pageContext.request.contextPath}/buyer/products" method="get" class="search-container">
                <input type="text"
                       name="search"
                       class="search-input"
                       placeholder="Search fresh crops, vegetables, grains, district..."
                       value="<%= searchQuery != null ? searchQuery : "" %>">
                <% if (selectedCategory != null) { %>
                    <input type="hidden" name="category" value="<%= selectedCategory %>">
                <% } %>
                <button type="submit" class="search-btn">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </button>
            </form>
        </div>
    </div>

    <div class="container pb-5">

        <%@ include file="/includes/alerts.jsp" %>

        <!-- Category Filter Chips -->
        <div class="text-center mb-4">
            <a href="${pageContext.request.contextPath}/buyer/products<%= searchQuery != null && !searchQuery.isEmpty() ? "?search=" + searchQuery : "" %>"
               class="category-chip <%= selectedCategory == null ? "active" : "" %>">
                <i class="fa-solid fa-seedling"></i> All Produce
            </a>
            <% if (categories != null) {
                for (Category c : categories) {
                    boolean isActive = selectedCategory != null && selectedCategory == c.getCategoryId();
            %>
                <a href="${pageContext.request.contextPath}/buyer/products?category=<%= c.getCategoryId() %><%= searchQuery != null && !searchQuery.isEmpty() ? "&search=" + searchQuery : "" %>"
                   class="category-chip <%= isActive ? "active" : "" %>">
                    <%= c.getCategoryName() %>
                </a>
            <%  }
               } %>
        </div>

        <!-- Products List -->
        <% if (products == null || products.isEmpty()) { %>
            <div class="bg-white rounded-4 p-5 text-center shadow-sm my-4">
                <div style="font-size: 55px; margin-bottom: 12px;"><i class="fa-solid fa-wheat-awn"></i></div>
                <h3 class="fw-bold text-dark">No produce found</h3>
                <p class="text-muted">Try adjusting your search query or selecting another category.</p>
                <a href="${pageContext.request.contextPath}/buyer/products" class="btn btn-success px-4 py-2 rounded-pill mt-2">
                    View All Products
                </a>
            </div>
        <% } else { %>
            <div class="market-grid">
                <% for (Product p : products) {
                    String imgUrl = (p.getPrimaryImageUrl() != null && !p.getPrimaryImageUrl().isEmpty())
                            ? request.getContextPath() + "/" + p.getPrimaryImageUrl()
                            : request.getContextPath() + "/assets/images/farmer.png";
                %>
                    <div class="produce-card">
                        <img src="<%= imgUrl %>" class="produce-img" alt="<%= p.getProductName() %>">
                        <div class="produce-body">
                            <div>
                                <span class="badge-cat"><%= p.getCategoryName() != null ? p.getCategoryName() : "Produce" %></span>
                                <% if (p.getProductType() != null) { %>
                                    <span class="badge-cat" style="background: #E0E7FF; color: #3730A3;"><%= p.getProductType() %></span>
                                <% } %>
                            </div>

                            <h3 class="produce-title"><%= p.getProductName() %></h3>

                            <div class="farm-loc">
                                <i class="fa-solid fa-location-dot text-success"></i>
                                <span><%= p.getFarmName() != null ? p.getFarmName() : "Local Farm" %> <%= p.getFarmerLocation() != null ? " • " + p.getFarmerLocation() : "" %></span>
                            </div>

                            <% if (p.getDescription() != null && !p.getDescription().isEmpty()) { %>
                                <p style="font-size: 13px; color: #4B5563; margin-bottom: 12px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                    <%= p.getDescription() %>
                                </p>
                            <% } %>

                            <div class="produce-price">
                                ₹<%= p.getPrice() %> <span style="font-size: 13px; color: #6B7280; font-weight: 400;">/ <%= p.getUnit() %></span>
                            </div>

                            <div style="font-size: 12px; color: #4B5563; margin-bottom: 12px;">
                                <i class="fa-solid fa-boxes-stacked"></i> Available: <strong><%= p.getAvailableQuantity() %> <%= p.getUnit() %></strong>
                            </div>

                            <form action="${pageContext.request.contextPath}/cart/add" method="post" style="margin: 0;">
                                <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                <div style="display: flex; gap: 8px;">
                                    <input type="number"
                                           name="quantity"
                                           value="1"
                                           min="0.5"
                                           max="<%= p.getAvailableQuantity() > 0 ? p.getAvailableQuantity() : 999 %>"
                                           step="0.5"
                                           style="width: 75px; height: 46px; border: 1px solid #D1D5DB; border-radius: 10px; text-align: center; font-weight: 600; font-family: var(--kc-font);"
                                           required>
                                    <button type="submit" class="add-cart-btn" style="height: 46px;">
                                        <i class="fa-solid fa-cart-plus"></i> Add to Cart
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>

    </div>

    <%@ include file="/includes/footer.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
