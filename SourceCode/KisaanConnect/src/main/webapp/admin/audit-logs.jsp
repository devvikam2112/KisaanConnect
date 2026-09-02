<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.AdminAuditLog"%>
<%@page import="com.kisaanconnect.dao.AdminDAO"%>

<%
    List<AdminAuditLog> logs = (List<AdminAuditLog>) request.getAttribute("logs");
    if (logs == null) {
        AdminDAO adminDAO = new AdminDAO();
        logs = adminDAO.getAuditLogs(100);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Audit Logs | KisaanConnect Admin</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    

    <style>
        body { font-family: var(--kc-font); background: #f8fafc; }
    </style>
</head>

<body>

    <%@ include file="/includes/admin-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/admin-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1">📜 Governance & Admin Audit Trail</h1>
                    <p class="text-muted small mb-0">Immutable chronological log of all administrator approvals, rejections, suspensions, and platform actions.</p>
                </div>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">Timestamp</th>
                                <th>Admin User</th>
                                <th>Action Performed</th>
                                <th>Target User / Entity</th>
                                <th>Details / Reason</th>
                                <th>IP Address</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (logs != null && !logs.isEmpty()) {
                                for (AdminAuditLog l : logs) {
                            %>
                                <tr>
                                    <td class="ps-4 small text-muted font-monospace"><%= l.getCreatedAt() %></td>
                                    <td class="fw-semibold text-dark"><%= l.getAdminName() != null ? l.getAdminName() : "Admin #" + l.getAdminUserId() %></td>
                                    <td>
                                        <% if (l.getAction().contains("APPROVED")) { %>
                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1"><i class="bi bi-check-circle me-1"></i><%= l.getAction() %></span>
                                        <% } else if (l.getAction().contains("REJECTED")) { %>
                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1"><i class="bi bi-x-circle me-1"></i><%= l.getAction() %></span>
                                        <% } else if (l.getAction().contains("SUSPENDED")) { %>
                                            <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1"><i class="bi bi-slash-circle me-1"></i><%= l.getAction() %></span>
                                        <% } else { %>
                                            <span class="badge bg-secondary-subtle text-secondary px-2 py-1"><%= l.getAction() %></span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= l.getTargetUserName() != null ? l.getTargetUserName() : (l.getTargetUserId() != null ? "User #" + l.getTargetUserId() : (l.getTargetEntity() != null ? l.getTargetEntity() + " #" + l.getTargetEntityId() : "-")) %>
                                    </td>
                                    <td class="small text-muted"><%= l.getDetails() != null ? l.getDetails() : "-" %></td>
                                    <td class="small text-muted font-monospace"><%= l.getIpAddress() != null ? l.getIpAddress() : "127.0.0.1" %></td>
                                </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">No audit logs recorded yet.</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
