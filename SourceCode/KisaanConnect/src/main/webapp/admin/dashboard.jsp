<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.dao.ReportDAO"%>
<%@page import="com.kisaanconnect.dao.UserDAO"%>

<%
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<User> recentUsers = (List<User>) request.getAttribute("recentUsers");

    if (stats == null) {
        ReportDAO rDAO = new ReportDAO();
        stats = rDAO.getPlatformAdminOverview();
    }
    if (recentUsers == null) {
        UserDAO uDAO = new UserDAO();
        recentUsers = uDAO.getAllUsers();
        if (recentUsers.size() > 5) {
            recentUsers = recentUsers.subList(0, 5);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | KisaanConnect</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">

    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .stat-card {
            background: white;
            padding: 22px;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            border: 1px solid #E5E7EB;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .stat-icon {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        .stat-info h3 {
            font-size: 24px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 2px;
        }

        .stat-info p {
            font-size: 13px;
            color: #6B7280;
            margin: 0;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/admin-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/admin-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="margin-bottom: 24px;">
                <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-shield-halved"></i> Platform Administration Console</h1>
                <p style="color: #6B7280; font-size: 14px;">Real-time overview of users, marketplace GMV, farmer listings, and commercial buyers.</p>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background: #DEF7EC; color: #03543F;"><i class="fa-solid fa-users"></i></div>
                    <div class="stat-info">
                        <h3><%= (stats != null && stats.get("totalUsers") != null) ? stats.get("totalUsers") : 0 %></h3>
                        <p>Total Registered Users</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #E8F5E9; color: #2E7D32;"><i class="fa-solid fa-tractor"></i></div>
                    <div class="stat-info">
                        <h3><%= (stats != null && stats.get("totalFarmers") != null) ? stats.get("totalFarmers") : 0 %></h3>
                        <p>Registered Farmers</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #E0E7FF; color: #3730A3;"><i class="fa-solid fa-building"></i></div>
                    <div class="stat-info">
                        <h3><%= (stats != null && stats.get("totalCommercial") != null) ? stats.get("totalCommercial") : 0 %></h3>
                        <p>Commercial Buyers</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon" style="background: #FEF08A; color: #854D0E;"><i class="fa-solid fa-wallet"></i></div>
                    <div class="stat-info">
                        <h3>₹<%= (stats != null && stats.get("totalGMV") != null) ? stats.get("totalGMV") : "0.00" %></h3>
                        <p>Total Platform GMV</p>
                    </div>
                </div>
            </div>

            <!-- Recent Users Table -->
            <div style="background: white; border-radius: 20px; padding: 26px; border: 1px solid #E5E7EB; box-shadow: 0 8px 24px rgba(0,0,0,0.05); margin-top: 30px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 style="font-size: 18px; color: #1F2937;">Recently Registered Users</h3>
                    <a href="${pageContext.request.contextPath}/admin/users" style="color: #2E7D32; font-weight: 600; font-size: 14px; text-decoration: none;">View All Users →</a>
                </div>

                <% if (recentUsers != null && !recentUsers.isEmpty()) { %>
                    <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                        <thead>
                            <tr style="text-align: left; background: #F9FAFB; border-bottom: 2px solid #E5E7EB;">
                                <th style="padding: 12px 16px;">User</th>
                                <th style="padding: 12px 16px;">Email</th>
                                <th style="padding: 12px 16px;">Phone</th>
                                <th style="padding: 12px 16px;">Role</th>
                                <th style="padding: 12px 16px;">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User u : recentUsers) { %>
                                <tr style="border-bottom: 1px solid #F3F4F6;">
                                    <td style="padding: 12px 16px;"><strong><%= u.getFullName() %></strong></td>
                                    <td style="padding: 12px 16px;"><%= u.getEmail() %></td>
                                    <td style="padding: 12px 16px;"><%= u.getPhone() %></td>
                                    <td style="padding: 12px 16px;">
                                        <span style="font-weight: 600; font-size: 12px; padding: 3px 8px; border-radius: 10px; background: #E5E7EB; color: #374151;">
                                            <%= u.getRole() %>
                                        </span>
                                    </td>
                                    <td style="padding: 12px 16px;">
                                        <span style="font-weight: 600; font-size: 12px; color: <%= "ACTIVE".equalsIgnoreCase(u.getStatus()) ? "#03543F" : "#9B1C1C" %>;">
                                            <%= u.getStatus() %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

        </div>

    </div>

</body>
</html>
