<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String email = (String) session.getAttribute("reset_email");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify OTP | KisaanConnect</title>

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
        <p class="tagline">OTP Verification</p>

        <div class="features">
            <div class="feature">📬 Check your Email Inbox / Spam</div>
            <div class="feature">⏳ Valid for 15 Minutes</div>
        </div>
    </div>

    <div class="right-panel">
        <div class="login-card">
            <img src="${pageContext.request.contextPath}/assets/images/logo.png"
                 class="card-logo"
                 alt="Logo">

            <h2>Enter OTP Code</h2>
            <p>We've sent a 6-digit verification code to <strong><%= email != null ? email : "your email" %></strong></p>

            <%@ include file="/includes/alerts.jsp" %>

            <form action="${pageContext.request.contextPath}/auth/verify-otp" method="post">
                <div class="input-group">
                    <label>6-Digit OTP Code</label>
                    <div class="input-wrapper">
                        <input type="text"
                               name="otpCode"
                               maxlength="6"
                               class="input-field"
                               placeholder="123456"
                               style="letter-spacing: 6px; font-size: 20px; font-weight: 700; text-align: center;"
                               required>
                    </div>
                </div>

                <button type="submit" style="margin-top: 20px;">
                    Verify Code 🔐
                </button>
            </form>

            <div class="register-link" style="margin-top: 20px;">
                Didn't receive the code?
                <a href="${pageContext.request.contextPath}/auth/forgot-password.jsp">
                    Resend Code
                </a>
            </div>
        </div>
    </div>

</div>

</body>
</html>
