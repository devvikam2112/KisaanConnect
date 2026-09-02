<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.kisaanconnect.model.User" %>
<%@ page import="com.kisaanconnect.dao.UserDAO" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    // Refresh user record from database
    UserDAO userDAO = new UserDAO();
    User freshUser = userDAO.getUserById(loggedInUser.getUserId());
    if (freshUser != null) {
        session.setAttribute("loggedInUser", freshUser);
        loggedInUser = freshUser;
    }

    String status = loggedInUser.getStatus();
    String role = loggedInUser.getRole();
    String rejectionReason = loggedInUser.getRejectionReason();

    // If active, redirect immediately to dashboard
    if ("ACTIVE".equalsIgnoreCase(status) || "ADMIN".equalsIgnoreCase(role)) {
        if ("FARMER".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/farmer/dashboard");
        } else if ("COMMERCIAL".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/commercial/dashboard");
        } else if ("ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/buyer/dashboard.jsp");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Status | KisaanConnect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    
    <style>
        body {
            font-family: var(--kc-font);
            background-color: #f8fafc;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .status-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 20px 40px -15px rgba(0,0,0,0.07);
            border: 1px solid #e2e8f0;
            max-width: 580px;
            width: 100%;
            overflow: hidden;
        }
        .status-header {
            padding: 35px 30px 20px;
            text-align: center;
        }
        .status-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 38px;
            margin-bottom: 20px;
        }
        .icon-pending {
            background: #fffbeb;
            color: #d97706;
            border: 2px solid #fde68a;
        }
        .icon-rejected {
            background: #fef2f2;
            color: #dc2626;
            border: 2px solid #fecaca;
        }
        .icon-suspended {
            background: #f1f5f9;
            color: #475569;
            border: 2px solid #cbd5e1;
        }
        .status-body {
            padding: 10px 35px 35px;
        }
        .details-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px;
            margin: 20px 0;
        }
        .btn-refresh {
            background-color: #16a34a;
            color: #ffffff;
            font-weight: 600;
            border-radius: 10px;
            padding: 12px 24px;
            border: none;
            transition: all 0.2s;
        }
        .btn-refresh:hover {
            background-color: #15803d;
            color: #ffffff;
            transform: translateY(-1px);
        }
        .btn-logout {
            border-radius: 10px;
            padding: 12px 24px;
            font-weight: 600;
        }
    </style>
</head>
<body>

<div class="status-card">
    <div class="status-header">
        <img src="<%= request.getContextPath() %>/assets/images/logo.png" alt="KisaanConnect" height="42" class="mb-3" onerror="this.style.display='none'">
        
        <% if ("REJECTED".equalsIgnoreCase(status)) { %>
            <div>
                <div class="status-icon icon-rejected">
                    <i class="bi bi-x-circle-fill"></i>
                </div>
                <h3 class="fw-bold text-danger mb-2">Application Rejected</h3>
                <p class="text-muted">Your account verification could not be approved at this time.</p>
            </div>
        <% } else if ("SUSPENDED".equalsIgnoreCase(status)) { %>
            <div>
                <div class="status-icon icon-suspended">
                    <i class="bi bi-slash-circle-fill"></i>
                </div>
                <h3 class="fw-bold text-dark mb-2">Account Suspended</h3>
                <p class="text-muted">Your KisaanConnect account has been temporarily suspended by the administrator.</p>
            </div>
        <% } else { %>
            <div>
                <div class="status-icon icon-pending">
                    <i class="bi bi-hourglass-split"></i>
                </div>
                <h3 class="fw-bold text-dark mb-2">Verification Pending</h3>
                <p class="text-muted">Thank you for registering on KisaanConnect. Your profile is currently undergoing administrator review.</p>
            </div>
        <% } %>
    </div>

    <div class="status-body">
        <div class="details-box">
            <div class="row g-2 text-sm">
                <div class="col-sm-4 text-muted">Registered Name:</div>
                <div class="col-sm-8 fw-semibold text-dark"><%= loggedInUser.getFullName() %></div>
                
                <div class="col-sm-4 text-muted">Account Email:</div>
                <div class="col-sm-8 fw-semibold text-dark"><%= loggedInUser.getEmail() %></div>
                
                <div class="col-sm-4 text-muted">Applied Role:</div>
                <div class="col-sm-8">
                    <span class="badge bg-secondary-subtle text-secondary fw-bold px-2 py-1"><%= loggedInUser.getRole() %></span>
                </div>
                
                <div class="col-sm-4 text-muted">Current Status:</div>
                <div class="col-sm-8">
                    <% if ("REJECTED".equalsIgnoreCase(status)) { %>
                        <span class="badge bg-danger text-white px-2 py-1">REJECTED</span>
                    <% } else if ("SUSPENDED".equalsIgnoreCase(status)) { %>
                        <span class="badge bg-secondary text-white px-2 py-1">SUSPENDED</span>
                    <% } else { %>
                        <span class="badge bg-warning text-dark px-2 py-1">PENDING VERIFICATION</span>
                    <% } %>
                </div>
            </div>

            <% if ("REJECTED".equalsIgnoreCase(status) && rejectionReason != null && !rejectionReason.trim().isEmpty()) { %>
                <div class="alert alert-danger mt-3 mb-0 border-0 bg-danger-subtle text-danger-emphasis">
                    <div class="fw-bold mb-1"><i class="bi bi-info-circle-fill me-1"></i> Reason for Rejection:</div>
                    <div><%= rejectionReason %></div>
                </div>
            <% } %>
        </div>

        <div class="alert alert-info border-0 bg-primary-subtle text-primary-emphasis text-sm mb-4">
            <% if ("REJECTED".equalsIgnoreCase(status)) { %>
                <i class="bi bi-shield-exclamation me-1"></i> If you believe this is in error or wish to submit updated documentation, please contact our support desk at <a href="mailto:support@kisaanconnect.in" class="fw-semibold">support@kisaanconnect.in</a>.
            <% } else if ("SUSPENDED".equalsIgnoreCase(status)) { %>
                <i class="bi bi-shield-lock me-1"></i> For questions regarding this suspension or account reactivation, please reach out to our platform compliance team.
            <% } else { %>
                <i class="bi bi-shield-check me-1"></i> To protect our farmers and buyers from fraud, every new registration is verified. Most reviews complete within 24 business hours.
            <% } %>
        </div>

        <div class="d-flex gap-2">
            <a href="<%= request.getContextPath() %>/auth/pending-verification.jsp" class="btn btn-refresh flex-grow-1">
                <i class="bi bi-arrow-clockwise me-1"></i> Check Status
            </a>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-secondary btn-logout">
                <i class="bi bi-box-arrow-right me-1"></i> Sign Out
            </a>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
