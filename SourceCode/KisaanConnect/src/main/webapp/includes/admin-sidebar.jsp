<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String adminUri = request.getRequestURI();
%>

<div class="sidebar">
    <div class="sidebar-header">
        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             class="sidebar-logo"
             alt="KisaanConnect">
        <h2>KisaanConnect</h2>
        <span class="sidebar-role-badge" style="background: rgba(220, 38, 38, 0.2); color: #FCA5A5; border: 1px solid rgba(220, 38, 38, 0.3);">
            <i class="fa-solid fa-shield-halved me-1"></i> Admin Console
        </span>
    </div>

    <ul class="sidebar-menu">
        <li class="<%= (adminUri.endsWith("/admin/dashboard") || adminUri.endsWith("/admin/dashboard.jsp")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="fa-solid fa-gauge-high"></i> <span>Operations Dashboard</span>
            </a>
        </li>

        <li class="menu-title">Governance & Users</li>

        <li class="<%= (adminUri.contains("/admin/users")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/admin/users">
                <i class="fa-solid fa-users"></i> <span>User Management</span>
            </a>
        </li>

        <li class="<%= (adminUri.contains("/admin/products")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/admin/products">
                <i class="fa-solid fa-wheat-awn"></i> <span>Produce Moderation</span>
            </a>
        </li>

        <li class="menu-title">Finance & Analytics</li>

        <li class="<%= (adminUri.contains("/admin/reports")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/admin/reports">
                <i class="fa-solid fa-chart-pie"></i> <span>Platform GMV & Analytics</span>
            </a>
        </li>

        <li class="<%= (adminUri.contains("/admin/audit-logs")) ? "active" : "" %>">
            <a href="${pageContext.request.contextPath}/admin/audit-logs">
                <i class="fa-solid fa-file-shield"></i> <span>Governance & Audit Trail</span>
            </a>
        </li>

        <li class="menu-title">System</li>

        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> <span>Logout</span>
            </a>
        </li>
    </ul>
</div>

