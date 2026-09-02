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
    <title>KisaanConnect | Login</title>
    
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/login.css">
</head>
<body>

<div class="container">

    <!-- LEFT PANEL -->
    <div class="left-panel">
        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             class="left-logo"
             alt="KisaanConnect Logo">

        <h1>KisaanConnect</h1>

        <p class="tagline">
            Connecting Farmers Directly With Buyers & Commercial Organisations
        </p>

        <div class="features">
            <div class="feature"><i class="fa-solid fa-wheat-awn text-success me-2"></i> Direct Farm-to-Buyer Trading</div>
            <div class="feature"><i class="fa-solid fa-building me-2 text-primary"></i> Commercial & Bulk Procurement</div>
            <div class="feature"><i class="fa-solid fa-shield-halved me-2 text-success"></i> 100% Secure Digital Escrow</div>
            <div class="feature"><i class="fa-solid fa-route me-2 text-info"></i> Geotagged Road Navigation</div>
            <div class="feature"><i class="fa-solid fa-truck-fast me-2 text-warning"></i> Verified Quality Fulfillment</div>
        </div>
    </div>

    <!-- RIGHT PANEL -->
    <div class="right-panel">
        <div class="login-card">
            <img src="${pageContext.request.contextPath}/assets/images/logo.png"
                 class="card-logo"
                 alt="Logo">

            <h2>Welcome Back</h2>
            <p>Login to your KisaanConnect account</p>

            <%@ include file="/includes/alerts.jsp" %>

            <form id="loginForm" action="${pageContext.request.contextPath}/login" method="post">

                <div class="input-group">
                    <label>Email Address</label>
                    <div class="input-wrapper">
                        <input
                            id="email"
                            class="input-field"
                            type="email"
                            name="email"
                            placeholder="Enter your registered email"
                            required>
                    </div>
                </div>

                <div class="input-group" style="margin-top: 15px;">
                    <label>Password</label>
                    <div class="password-box">
                        <input
                            id="password"
                            class="input-field"
                            type="password"
                            name="password"
                            placeholder="Enter your password"
                            required>
                        <i class="fa-solid fa-eye toggle-password"
                           id="togglePassword"></i>
                    </div>
                </div>

                <div class="login-options options-row">
                    <label class="remember">
                        <input type="checkbox" name="remember">
                        <span>Remember Me</span>
                    </label>

                    <a href="${pageContext.request.contextPath}/auth/forgot-password.jsp" class="forgot">
                        Forgot Password?
                    </a>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-arrow-right-to-bracket"></i> Login to Account
                </button>
            </form>

            <div class="register-link register-prompt">
                Don't have an account?
                <a href="${pageContext.request.contextPath}/auth/register.jsp">
                    Create Account
                </a>
            </div>
        </div>
    </div>

</div>

<script src="${pageContext.request.contextPath}/assets/js/login.js"></script>
</body>
</html>