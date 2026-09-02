<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.model.BuyerProfile"%>
<%@page import="com.kisaanconnect.dao.BuyerDAO"%>
<%@page import="com.kisaanconnect.constants.AppConstants"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    BuyerProfile buyerProfile = (BuyerProfile) request.getAttribute("buyerProfile");
    if (buyerProfile == null) {
        BuyerDAO bDAO = new BuyerDAO();
        buyerProfile = bDAO.getProfileByUserId(loggedInUser.getUserId());
    }

    String currentState = (buyerProfile != null && buyerProfile.getState() != null) ? buyerProfile.getState() : "";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile & Delivery Address | KisaanConnect Buyer</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .profile-banner {
            background: linear-gradient(135deg, #1B5E20, #2E7D32);
            color: white;
            padding: 35px 0 45px 0;
            border-radius: 0 0 25px 25px;
            margin-bottom: 30px;
        }

        .profile-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        .avatar-circle {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background: #E8F5E9;
            color: #2E7D32;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            font-weight: bold;
            border: 3px solid #C8E6C9;
            object-fit: cover;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="profile-banner">
        <div class="container">
            <h1 class="h3 fw-bold mb-1"><i class="fa-solid fa-user"></i> Buyer Profile & Delivery Settings</h1>
            <p class="mb-0 opacity-90 small">Manage your personal contact info and primary delivery destination for farm orders.</p>
        </div>
    </div>

    <div class="container pb-5">

        <%@ include file="/includes/alerts.jsp" %>

        <div class="row g-4">
            <!-- Left Column: Summary Card -->
            <div class="col-lg-4">
                <div class="profile-card text-center mb-4">
                    <div class="d-flex justify-content-center mb-3">
                        <% if (buyerProfile != null && buyerProfile.getProfilePhoto() != null && !buyerProfile.getProfilePhoto().isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/<%= buyerProfile.getProfilePhoto() %>"
                                 class="avatar-circle"
                                 alt="Profile Photo">
                        <% } else { %>
                            <div class="avatar-circle">
                                <%= loggedInUser.getFullName() != null && !loggedInUser.getFullName().isEmpty() ? loggedInUser.getFullName().substring(0, 1).toUpperCase() : "B" %>
                            </div>
                        <% } %>
                    </div>

                    <h5 class="fw-bold mb-1 text-dark"><%= loggedInUser.getFullName() %></h5>
                    <p class="text-muted small mb-2"><%= loggedInUser.getEmail() %></p>
                    <span class="badge bg-success-subtle text-success px-3 py-1 rounded-pill mb-3">
                        <i class="fa-solid fa-seedling"></i> Individual Buyer
                    </span>

                    <div class="border-top pt-3 text-start small">
                        <div class="mb-2">
                            <span class="text-muted">Contact Phone:</span>
                            <span class="fw-semibold text-dark float-end"><%= loggedInUser.getPhone() != null ? loggedInUser.getPhone() : "Not set" %></span>
                        </div>
                        <div class="mb-2">
                            <span class="text-muted">Primary City:</span>
                            <span class="fw-semibold text-dark float-end"><%= buyerProfile != null && buyerProfile.getCity() != null ? buyerProfile.getCity() : "Not set" %></span>
                        </div>
                        <div>
                            <span class="text-muted">State / Region:</span>
                            <span class="fw-semibold text-dark float-end"><%= buyerProfile != null && buyerProfile.getState() != null ? buyerProfile.getState() : "Not set" %></span>
                        </div>
                    </div>
                </div>

                <div class="profile-card">
                    <h6 class="fw-bold text-dark mb-3"><i class="fa-solid fa-bolt"></i> Quick Navigation</h6>
                    <div class="d-grid gap-2">
                        <a href="${pageContext.request.contextPath}/buyer/products.jsp" class="btn btn-outline-success btn-sm text-start py-2">
                            <i class="fa-solid fa-wheat-awn"></i> Browse Fresh Marketplace
                        </a>
                        <a href="${pageContext.request.contextPath}/buyer/orders.jsp" class="btn btn-outline-secondary btn-sm text-start py-2">
                            <i class="fa-solid fa-boxes-stacked"></i> My Orders
                        </a>
                        <a href="${pageContext.request.contextPath}/buyer/wallet" class="btn btn-outline-secondary btn-sm text-start py-2">
                            <i class="fa-solid fa-wallet"></i> My Wallet
                        </a>
                        <a href="${pageContext.request.contextPath}/buyer/reports" class="btn btn-outline-secondary btn-sm text-start py-2">
                            <i class="fa-solid fa-chart-line"></i> Spending Reports
                        </a>
                    </div>
                </div>
            </div>

            <!-- Right Column: Edit Profile & Address Form -->
            <div class="col-lg-8">
                <div class="profile-card">
                    <h5 class="fw-bold text-dark mb-3"><i class="fa-solid fa-pen-to-square"></i> Update Delivery Address & Details</h5>

                    <form action="${pageContext.request.contextPath}/buyer/profile" method="post" enctype="multipart/form-data">

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label text-muted small fw-semibold">Full Name *</label>
                                <input type="text"
                                       name="fullName"
                                       class="form-control rounded-3"
                                       value="<%= loggedInUser.getFullName() != null ? loggedInUser.getFullName() : "" %>"
                                       required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label text-muted small fw-semibold">Contact Phone *</label>
                                <input type="text"
                                       name="phone"
                                       class="form-control rounded-3"
                                       value="<%= loggedInUser.getPhone() != null ? loggedInUser.getPhone() : "" %>"
                                       placeholder="10-digit mobile number"
                                       required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label text-muted small fw-semibold">Street / Flat / House Address *</label>
                            <textarea name="address"
                                      rows="3"
                                      class="form-control rounded-3"
                                      placeholder="Apartment, building, street, area name"
                                      required><%= buyerProfile != null && buyerProfile.getAddress() != null ? buyerProfile.getAddress() : "" %></textarea>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label text-muted small fw-semibold">City / Town *</label>
                                <input type="text"
                                       name="city"
                                       class="form-control rounded-3"
                                       value="<%= buyerProfile != null && buyerProfile.getCity() != null ? buyerProfile.getCity() : "" %>"
                                       placeholder="e.g. Mumbai / Pune"
                                       required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label text-muted small fw-semibold">District *</label>
                                <input type="text"
                                       name="district"
                                       class="form-control rounded-3"
                                       value="<%= buyerProfile != null && buyerProfile.getDistrict() != null ? buyerProfile.getDistrict() : "" %>"
                                       placeholder="District"
                                       required>
                            </div>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label class="form-label text-muted small fw-semibold">State *</label>
                                <select name="state" class="form-select rounded-3" required>
                                    <option value="">-- Select State / UT --</option>
                                    <% for (String st : AppConstants.INDIAN_STATES) { %>
                                        <option value="<%= st %>" <%= st.equalsIgnoreCase(currentState) ? "selected" : "" %>><%= st %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label text-muted small fw-semibold">Pincode *</label>
                                <input type="text"
                                       name="pincode"
                                       maxlength="6"
                                       class="form-control rounded-3"
                                       value="<%= buyerProfile != null && buyerProfile.getPincode() != null ? buyerProfile.getPincode() : "" %>"
                                       placeholder="6-digit pincode"
                                       required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label text-muted small fw-semibold">Profile Photo</label>
                            <input type="file"
                                   name="profilePhoto"
                                   accept="image/*"
                                   class="form-control rounded-3">
                            <small class="text-muted">Supported formats: JPG, PNG, WEBP (Max 5MB)</small>
                        </div>

                        <button type="submit" class="btn btn-success px-4 py-2 rounded-3 fw-semibold">
                            💾 Save Profile & Address
                        </button>
                    </form>
                </div>
            </div>
        </div>

    </div>

</body>
</html>
