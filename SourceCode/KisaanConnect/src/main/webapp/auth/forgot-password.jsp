<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password | KisaanConnect</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/login.css">
</head>

<body>

<div class="container">

    <div class="left-panel">
        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             class="left-logo"
             alt="KisaanConnect">

        <h1>KisaanConnect</h1>
        <p class="tagline">Account Security & Password Recovery</p>

        <div class="features">
            <div class="feature"><i class="fa-solid fa-lock"></i> Secure Verification</div>
            <div class="feature"><i class="fa-solid fa-bolt"></i> Fast 6-Digit Email OTP</div>
            <div class="feature"><i class="fa-solid fa-shield-halved"></i> Protected Agricultural Data</div>
        </div>
    </div>

    <div class="right-panel">
        <div class="login-card">
            <img src="${pageContext.request.contextPath}/assets/images/logo.png"
                 class="card-logo"
                 alt="Logo">

            <h2>Reset Password</h2>
            <p>Enter your registered email address to receive a secure OTP code.</p>

            <%@ include file="/includes/alerts.jsp" %>

            <form action="${pageContext.request.contextPath}/auth/forgot-password" method="post">
                <div class="input-group">
                    <label>Registered Email Address</label>
                    <div class="input-wrapper">
                        <input type="email"
                               name="email"
                               class="input-field"
                               placeholder="e.g. farmer@gmail.com"
                               required>
                    </div>
                </div>

                <button type="submit" style="margin-top: 20px;">
                    Send Verification Code ✉️
                </button>
            </form>

            <div class="register-link" style="margin-top: 20px;">
                Remembered your password?
                <a href="${pageContext.request.contextPath}/auth/login.jsp">
                    Back to Login
                </a>
            </div>
        </div>
    </div>

</div>

</body>
</html>
