<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.User"%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User activeAuthUser = (User) session.getAttribute("loggedInUser");
    if (activeAuthUser != null && activeAuthUser.getRole() != null) {
        String role = activeAuthUser.getRole();
        if ("FARMER".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/farmer/dashboard");
            return;
        } else if ("COMMERCIAL".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/commercial/dashboard");
            return;
        } else if ("ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            return;
        } else {
            response.sendRedirect(request.getContextPath() + "/buyer/dashboard.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KisaanConnect | Register</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/register.css">
</head>
<body>

<div class="page">

    <!-- LEFT SIDE -->
    <section class="left-section">
        <div class="hero-content">
            <img src="${pageContext.request.contextPath}/assets/images/logo.png"
                 class="hero-logo"
                 alt="KisaanConnect Logo">

            <h1>
                Join
                <span>KisaanConnect</span>
            </h1>

            <p class="hero-subtitle">
                India's Smart Agriculture Marketplace
            </p>

            <div class="feature-list">
                <div class="feature">
                    <i class="fa-solid fa-seedling text-success me-2" style="font-size: 20px;"></i>
                    <p>Sell agricultural produce directly</p>
                </div>

                <div class="feature">
                    <i class="fa-solid fa-building text-primary me-2" style="font-size: 20px;"></i>
                    <p>Bulk purchasing for organisations</p>
                </div>

                <div class="feature">
                    <i class="fa-solid fa-shield-halved text-success me-2" style="font-size: 20px;"></i>
                    <p>Direct farmer profits & fair prices</p>
                </div>

                <div class="feature">
                    <i class="fa-solid fa-handshake text-info me-2" style="font-size: 20px;"></i>
                    <p>Trusted agricultural community</p>
                </div>
            </div>
        </div>
    </section>

    <!-- RIGHT SIDE -->
    <section class="right-section">
        <div class="register-card">
            <img src="${pageContext.request.contextPath}/assets/images/logo.png"
                 class="card-logo"
                 alt="Logo">

            <h2>Create Account</h2>
            <p>
                Join India's Smart Agriculture Marketplace
            </p>

            <%@ include file="/includes/alerts.jsp" %>

            <form action="${pageContext.request.contextPath}/register" method="post">

                <!-- Row 1 -->
                <div class="form-row">
                    <div class="input-group">
                        <label>Full Name</label>
                        <input type="text"
                               name="fullName"
                               placeholder="Enter your full name"
                               required>
                    </div>

                    <div class="input-group">
                        <label>Mobile Phone</label>
                        <input type="tel"
                               name="phone"
                               placeholder="10-digit mobile number"
                               pattern="[0-9]{10}"
                               required>
                    </div>
                </div>

                <!-- Row 2 -->
                <div class="input-group" style="margin-bottom: 16px;">
                    <label>Email Address</label>
                    <input type="email"
                           name="email"
                           placeholder="Enter your email"
                           required>
                </div>

                <!-- Row 3 -->
                <div class="form-row">
                    <div class="input-group">
                        <label>Password</label>
                        <input type="password"
                               name="password"
                               placeholder="Create password"
                               minlength="6"
                               required>
                    </div>

                    <div class="input-group">
                        <label>Confirm Password</label>
                        <input type="password"
                               name="confirmPassword"
                               placeholder="Confirm password"
                               minlength="6"
                               required>
                    </div>
                </div>

                <label class="role-title">
                    Register As:
                </label>

                <div class="role-selection">
                    <label class="role-card active">
                        <input type="radio"
                               name="role"
                               value="FARMER"
                               checked
                               required>
                        <div class="role-icon" style="margin-bottom: 8px;"><i class="fa-solid fa-tractor text-success" style="font-size: 24px;"></i></div>
                        <h4>Farmer</h4>
                        <p>Sell agricultural products</p>
                    </label>

                    <label class="role-card">
                        <input type="radio"
                               name="role"
                               value="BUYER"
                               required>
                        <div class="role-icon" style="margin-bottom: 8px;"><i class="fa-solid fa-basket-shopping text-primary" style="font-size: 24px;"></i></div>
                        <h4>Individual Buyer</h4>
                        <p>Buy for personal consumption</p>
                    </label>

                    <label class="role-card">
                        <input type="radio"
                               name="role"
                               value="COMMERCIAL"
                               required>
                        <div class="role-icon" style="margin-bottom: 8px;"><i class="fa-solid fa-building text-info" style="font-size: 24px;"></i></div>
                        <h4>Commercial Lot Buyer</h4>
                        <p>Hotels, caterers & hostels</p>
                    </label>
                </div>

                <button type="submit">
                    Create Account
                </button>
            </form>

            <div class="login">
                Already have an account?
                <a href="${pageContext.request.contextPath}/auth/login.jsp">
                    Login
                </a>
            </div>
        </div>
    </section>

</div>

<script src="${pageContext.request.contextPath}/assets/js/register.js"></script>
</body>
</html>