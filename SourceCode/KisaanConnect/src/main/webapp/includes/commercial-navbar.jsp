<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.model.Organization"%>

<%
    User navCommercialUser = (User) session.getAttribute("loggedInUser");
    Organization navCommercialOrg = (Organization) session.getAttribute("organization");

    String commercialDisplayName = "Commercial Buyer";
    String commercialOrgName = "Enterprise Hub";

    if (navCommercialUser != null && navCommercialUser.getFullName() != null && !navCommercialUser.getFullName().trim().isEmpty()) {
        commercialDisplayName = navCommercialUser.getFullName().trim();
    }
    if (navCommercialOrg != null && navCommercialOrg.getOrgName() != null && !navCommercialOrg.getOrgName().trim().isEmpty()) {
        commercialOrgName = navCommercialOrg.getOrgName().trim();
    }
%>

<div class="top-navbar">
    <div class="nav-left">
        <button type="button" class="mobile-menu-toggle" onclick="document.querySelector('.sidebar').classList.toggle('open')" aria-label="Toggle Sidebar Navigation">
            <i class="fa-solid fa-bars"></i>
        </button>
        <h2><%= commercialOrgName %></h2>
    </div>

    <div class="nav-center">
        <div class="search-wrapper">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" placeholder="Search bulk crops, verified suppliers, contracts..." class="search-box">
        </div>
    </div>

    <div class="nav-right">
        <%
            int cNotifCount = (navCommercialUser != null) ? new com.kisaanconnect.dao.NotificationDAO().getUnreadCount(navCommercialUser.getUserId()) : 0;
            int cChatCount = (navCommercialUser != null) ? new com.kisaanconnect.dao.ChatDAO().getUnreadMessageCount(navCommercialUser.getUserId()) : 0;
        %>
        <a href="${pageContext.request.contextPath}/notifications" class="nav-action-link" title="Notifications">
            <div class="notification">
                <i class="fa-solid fa-bell"></i>
                <% if (cNotifCount > 0) { %>
                    <span class="notification-count" style="background: #DC2626;"><%= cNotifCount %></span>
                <% } %>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/chat/conversations" class="nav-action-link" title="Supplier Messages">
            <div class="notification">
                <i class="fa-solid fa-comments"></i>
                <% if (cChatCount > 0) { %>
                    <span class="notification-count" style="background: #2563EB;"><%= cChatCount %></span>
                <% } %>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/commercial/profile" class="nav-action-link" title="Enterprise Profile">
            <div class="user-box">
                <div class="user-avatar" style="background: linear-gradient(135deg, #1E3A8A 0%, #2563EB 100%);">
                    <i class="fa-solid fa-building" style="font-size: 14px;"></i>
                </div>
                <div class="user-info">
                    <span class="user-name"><%= commercialDisplayName %></span>
                    <span class="user-role">Enterprise Buyer</span>
                </div>
            </div>
        </a>
    </div>
</div>

<script>window.KisaanContextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-poll.js"></script>

