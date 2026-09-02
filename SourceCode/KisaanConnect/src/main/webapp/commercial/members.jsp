<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Organization"%>
<%@page import="com.kisaanconnect.model.OrganizationMember"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    Organization commercialOrg = (Organization) request.getAttribute("organization");
    List<OrganizationMember> members = (List<OrganizationMember>) request.getAttribute("members");

    if (commercialOrg == null) {
        OrganizationDAO orgDAO = new OrganizationDAO();
        commercialOrg = orgDAO.getOrganizationByUserId(loggedInUser.getUserId());
        if (commercialOrg != null) {
            members = orgDAO.getOrganizationMembers(commercialOrg.getOrganizationId());
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff & Organisation Roles | KisaanConnect Commercial</title>

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
        .members-table {
            width: 100%;
            border-collapse: collapse;
        }

        .members-table th {
            text-align: left;
            padding: 14px 16px;
            background: #F9FAFB;
            color: #4B5563;
            font-size: 13px;
            font-weight: 600;
            border-bottom: 2px solid #E5E7EB;
        }

        .members-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #F3F4F6;
            font-size: 14px;
        }

        .role-badge {
            display: inline-block;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 12px;
            background: #EFF6FF;
            color: #1E40AF;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/commercial-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/commercial-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="margin-bottom: 24px;">
                <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-users"></i> Staff & Authorised Organisation Members</h1>
                <p style="color: #6B7280; font-size: 14px;">Manage internal procurement team access, roles, and authorization.</p>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <div style="background: white; border-radius: 20px; padding: 26px; border: 1px solid #E5E7EB; box-shadow: 0 8px 24px rgba(0,0,0,0.05);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3 style="font-size: 18px; color: #1F2937; margin: 0;">Authorised Users (<%= commercialOrg != null ? commercialOrg.getOrgName() : "Organisation" %>)</h3>
                </div>

                <% if (members == null || members.isEmpty()) { %>
                    <p style="color: #6B7280; text-align: center; padding: 40px 0;">No additional staff members listed.</p>
                <% } else { %>
                    <table class="members-table">
                        <thead>
                            <tr>
                                <th>Staff Name</th>
                                <th>Email</th>
                                <th>Contact Phone</th>
                                <th>Assigned Role</th>
                                <th>Status</th>
                                <th>Joined Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrganizationMember m : members) { %>
                                <tr>
                                    <td><strong><%= m.getFullName() != null ? m.getFullName() : "Staff Member" %></strong></td>
                                    <td><%= m.getEmail() != null ? m.getEmail() : "-" %></td>
                                    <td><%= m.getPhone() != null ? m.getPhone() : "-" %></td>
                                    <td>
                                        <span class="role-badge">
                                            <%= m.getMemberRole() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-size: 11px; font-weight: 700; color: #059669;">
                                            <%= m.getStatus() %>
                                        </span>
                                    </td>
                                    <td><%= m.getJoinedAt() %></td>
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
