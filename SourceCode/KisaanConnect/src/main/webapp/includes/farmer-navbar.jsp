<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User navFarmer = (User) session.getAttribute("loggedInUser");

    String farmerNavFullName = "Farmer";

    if (navFarmer != null && navFarmer.getFullName() != null && !navFarmer.getFullName().trim().isEmpty()) {
        farmerNavFullName = navFarmer.getFullName().trim();
    }
%>

<div class="top-navbar">
    <div class="nav-left">
        <button type="button" class="mobile-menu-toggle" onclick="document.querySelector('.sidebar').classList.toggle('open')" aria-label="Toggle Sidebar Navigation">
            <i class="fa-solid fa-bars"></i>
        </button>
        <h2>Farmer Portal</h2>
    </div>

    <div class="nav-center">
        <div class="search-wrapper">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" placeholder="Search produce, customer orders, inventory..." class="search-box">
        </div>
    </div>

    <div class="nav-right">
        <%
            int fNotifCount = (navFarmer != null) ? new com.kisaanconnect.dao.NotificationDAO().getUnreadCount(navFarmer.getUserId()) : 0;
            int fChatCount = (navFarmer != null) ? new com.kisaanconnect.dao.ChatDAO().getUnreadMessageCount(navFarmer.getUserId()) : 0;
        %>
        <a href="${pageContext.request.contextPath}/notifications" class="nav-action-link" title="Notifications">
            <div class="notification">
                <i class="fa-solid fa-bell"></i>
                <% if (fNotifCount > 0) { %>
                    <span class="notification-count" style="background: #DC2626;"><%= fNotifCount %></span>
                <% } %>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/chat/conversations" class="nav-action-link" title="Customer Chats">
            <div class="notification">
                <i class="fa-solid fa-comments"></i>
                <% if (fChatCount > 0) { %>
                    <span class="notification-count" style="background: #2563EB;"><%= fChatCount %></span>
                <% } %>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/farmer/profile" class="nav-action-link" title="Farm Profile">
            <div class="user-box">
                <div class="user-avatar">
                    <%= farmerNavFullName.substring(0,1).toUpperCase() %>
                </div>
                <div class="user-info">
                    <span class="user-name"><%= farmerNavFullName %></span>
                    <span class="user-role">Verified Farmer</span>
                </div>
            </div>
        </a>
    </div>
</div>

<script>window.KisaanContextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-poll.js"></script>