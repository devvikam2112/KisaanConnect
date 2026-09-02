<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Category"%>
<%@page import="com.kisaanconnect.dao.CategoryDAO"%>

<%
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    if (categories == null || categories.isEmpty()) {
        CategoryDAO catDAO = new CategoryDAO();
        categories = catDAO.getActiveCategories();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Agricultural Produce | KisaanConnect</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/forms.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
</head>

<body>

    <%@ include file="/includes/farmer-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/farmer-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px; max-width: 900px;">

            <div style="margin-bottom: 24px;">
                <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-plus"></i> List New Produce</h1>
                <p style="color: #6B7280; font-size: 14px;">Add your fresh crop or agricultural product to the KisaanConnect marketplace.</p>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <div style="background: white; border-radius: 20px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 1px solid #E5E7EB;">

                <form action="${pageContext.request.contextPath}/farmer/add-product"
                      method="post"
                      enctype="multipart/form-data">

                    <!-- Crop Name & Category -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 18px; margin-bottom: 18px;">
                        <div>
                            <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Product / Crop Name *</label>
                            <input type="text"
                                   name="productName"
                                   placeholder="e.g. Fresh Red Onions / Organic Wheat"
                                   style="width: 100%; height: 50px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 16px; font-family: var(--kc-font);"
                                   required>
                        </div>

                        <div>
                            <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Category *</label>
                            <select name="categoryId"
                                    style="width: 100%; height: 50px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 16px; font-family: var(--kc-font); background: #fff;"
                                    required>
                                <option value="">-- Select Crop Category --</option>
                                <% if (categories != null) {
                                    for (Category cat : categories) { %>
                                        <option value="<%= cat.getCategoryId() %>"><%= cat.getCategoryName() %></option>
                                <%  }
                                   } %>
                            </select>
                        </div>
                    </div>

                    <!-- Price, Unit & Farming Type -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 18px; margin-bottom: 18px;">
                        <div>
                            <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Price (₹) *</label>
                            <input type="number"
                                   step="0.01"
                                   min="0.5"
                                   name="price"
                                   placeholder="e.g. 45.00"
                                   style="width: 100%; height: 50px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 16px; font-family: var(--kc-font);"
                                   required>
                        </div>

                        <div>
                            <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Measurement Unit *</label>
                            <select name="unit"
                                    style="width: 100%; height: 50px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 16px; font-family: var(--kc-font); background: #fff;"
                                    required>
                                <option value="kg">Per Kg</option>
                                <option value="quintal">Per Quintal (100 kg)</option>
                                <option value="ton">Per Metric Ton</option>
                                <option value="box">Per Box / Crate</option>
                                <option value="bunch">Per Bunch / Piece</option>
                                <option value="liter">Per Liter</option>
                            </select>
                        </div>

                        <div>
                            <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Farming Type</label>
                            <select name="productType"
                                    style="width: 100%; height: 50px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 16px; font-family: var(--kc-font); background: #fff;">
                                <option value="Organic Certified">Organic Certified</option>
                                <option value="Naturally Grown">Naturally Grown</option>
                                <option value="Conventional Fresh">Conventional Fresh</option>
                                <option value="Hydroponic">Hydroponic</option>
                            </select>
                        </div>
                    </div>

                    <!-- Stock Quantities -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; margin-bottom: 18px;">
                        <div>
                            <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Available Quantity (in selected units) *</label>
                            <input type="number"
                                   step="0.1"
                                   min="1"
                                   name="stock"
                                   placeholder="e.g. 500"
                                   style="width: 100%; height: 50px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 16px; font-family: var(--kc-font);"
                                   required>
                        </div>

                        <div>
                            <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Minimum Stock Alert Threshold</label>
                            <input type="number"
                                   step="0.1"
                                   min="0"
                                   name="minimumStock"
                                   placeholder="e.g. 20"
                                   style="width: 100%; height: 50px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 16px; font-family: var(--kc-font);">
                        </div>
                    </div>

                    <!-- Produce Image Upload -->
                    <div style="margin-bottom: 18px;">
                        <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Produce Photo</label>
                        <input type="file"
                               name="productImage"
                               accept=".jpg,.jpeg,.png,.webp"
                               style="width: 100%; padding: 12px; border: 1px dashed #9CA3AF; border-radius: 12px; background: #F9FAFB;">
                    </div>

                    <!-- Description -->
                    <div style="margin-bottom: 24px;">
                        <label style="display: block; font-size: 14px; font-weight: 600; color: #1F2937; margin-bottom: 8px;">Product Description & Harvest Details</label>
                        <textarea name="description"
                                  rows="3"
                                  placeholder="Describe the freshness, harvest date, quality grade, packaging..."
                                  style="width: 100%; border: 1px solid #D1D5DB; border-radius: 12px; padding: 14px; font-family: var(--kc-font); font-size: 14px;"></textarea>
                    </div>

                    <div style="display: flex; gap: 14px;">
                        <button type="submit"
                                style="flex: 1; height: 54px; font-size: 16px; font-weight: 600; border: none; border-radius: 14px; background: linear-gradient(135deg, #2E7D32, #1B5E20); color: white; cursor: pointer; transition: 0.3s;">
                            <i class="fa-solid fa-bolt"></i> Publish Produce to Marketplace
                        </button>
                        <a href="${pageContext.request.contextPath}/farmer/products"
                           style="padding: 14px 24px; border: 1px solid #D1D5DB; border-radius: 14px; text-decoration: none; color: #4B5563; font-weight: 600; display: inline-flex; align-items: center;">
                            Cancel
                        </a>
                    </div>

                </form>

            </div>

        </div>

    </div>

</body>
</html>
