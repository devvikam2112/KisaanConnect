<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create New Password | KisaanConnect</title>

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
        <p class="tagline">Set New Password</p>

        <div class="features">
            <div class="feature">🔑 Minimum 6 characters</div>
            <div class="feature"><i class="fa-solid fa-shield-halved"></i> Upgraded PBKDF2 Cryptographic Security</div>
        </div>
    </div>

    <div class="right-panel">
        <div class="login-card">
            <img src="${pageContext.request.contextPath}/assets/images/logo.png"
                 class="card-logo"
                 alt="Logo">

            <h2>Set New Password</h2>
            <p>Please enter your new strong password.</p>

            <%@ include file="/includes/alerts.jsp" %>

            <form action="${pageContext.request.contextPath}/auth/reset-password" method="post">
                <div class="input-group">
                    <label>New Password</label>
                    <div class="input-wrapper">
                        <input type="password"
                               name="newPassword"
                               class="input-field"
                               placeholder="Minimum 6 characters"
                               minlength="6"
                               required>
                    </div>
                </div>

                <div class="input-group" style="margin-top: 15px;">
                    <label>Confirm New Password</label>
                    <div class="input-wrapper">
                        <input type="password"
                               name="confirmPassword"
                               class="input-field"
                               placeholder="Repeat password"
                               minlength="6"
                               required>
                    </div>
                </div>

                <button type="submit" style="margin-top: 20px;">
                    Update & Save Password <i class="fa-solid fa-bolt"></i>
                </button>
            </form>
        </div>
    </div>

</div>

</body>
</html>
