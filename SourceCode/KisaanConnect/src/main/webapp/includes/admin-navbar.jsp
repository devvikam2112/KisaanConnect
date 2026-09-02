<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User adminUser = (User) session.getAttribute("loggedInUser");
    String adminName = adminUser != null ? adminUser.getFullName() : "Administrator";
%>

<div class="top-navbar">
    <div class="nav-left">
        <button type="button" class="mobile-menu-toggle" onclick="document.querySelector('.sidebar').classList.toggle('open')" aria-label="Toggle Sidebar Navigation">
            <i class="fa-solid fa-bars"></i>
        </button>
        <h2>Platform Operations</h2>
    </div>

    <div class="nav-center">
        <div class="search-wrapper">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" placeholder="Search platform users, farmers, produce, orders..." class="search-box">
        </div>
    </div>

    <div class="nav-right">
        <div class="user-box">
            <div class="user-avatar" style="background: linear-gradient(135deg, #DC2626 0%, #991B1B 100%);">
                <i class="fa-solid fa-user-shield" style="font-size: 14px;"></i>
            </div>
            <div class="user-info">
                <span class="user-name"><%= adminName %></span>
                <span class="user-role">Super Admin</span>
            </div>
        </div>
    </div>
</div>

<script>window.KisaanContextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-poll.js"></script>

