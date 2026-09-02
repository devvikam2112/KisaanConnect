<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Notification"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    int unreadCount = (request.getAttribute("unreadCount") != null) ? (Integer) request.getAttribute("unreadCount") : 0;
    boolean isFarmer = "FARMER".equalsIgnoreCase(loggedInUser.getRole());
    boolean isCommercial = "COMMERCIAL".equalsIgnoreCase(loggedInUser.getRole());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification Center | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .header-box {
            background: <%= isFarmer ? "linear-gradient(135deg, #1B5E20, #2E7D32)" : (isCommercial ? "linear-gradient(135deg, #1E3A8A, #2563EB)" : "linear-gradient(135deg, #15803D, #16A34A)") %>;
            color: white;
            padding: 35px 0 40px 0;
            border-radius: 0 0 25px 25px;
            margin-bottom: 30px;
        }

        .notif-card {
            background: white;
            border-radius: 16px;
            border: 1px solid #E5E7EB;
            padding: 18px 22px;
            margin-bottom: 14px;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            display: flex;
            align-items: flex-start;
            gap: 16px;
        }

        .notif-card.unread {
            background: #F0FDF4;
            border-left: 5px solid #16A34A;
        }

        .notif-icon-box {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }

        .icon-order { background: #DBEAFE; color: #1E40AF; }
        .icon-wallet { background: #FEF08A; color: #854D0E; }
        .icon-chat { background: #DEF7EC; color: #03543F; }
        .icon-delivery { background: #E0E7FF; color: #4338CA; }
        .icon-system { background: #F3F4F6; color: #4B5563; }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="header-box">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="h2 fw-bold mb-1"><i class="fa-solid fa-bell"></i> Notification Center</h1>
                    <p class="mb-0 text-white-50">Real-time alerts for orders, payments, deliveries, and communication.</p>
                </div>
                <% if (unreadCount > 0) { %>
                    <form action="${pageContext.request.contextPath}/notifications/read-all" method="POST">
                        <button type="submit" class="btn btn-light rounded-pill px-4 fw-semibold text-success shadow-sm">
                            <i class="fa-solid fa-check-double me-1"></i> Mark All as Read (<%= unreadCount %>)
                        </button>
                    </form>
                <% } %>
            </div>
        </div>
    </div>

    <div class="container pb-5" style="max-width: 900px;">

        <%@ include file="/includes/alerts.jsp" %>

        <div id="notificationsEmptyState" class="card border-0 rounded-4 shadow-sm p-5 text-center" style="<%= (notifications != null && !notifications.isEmpty()) ? "display: none;" : "" %>">
            <i class="fa-regular fa-bell fs-1 text-muted mb-3"></i>
            <h4 class="fw-bold text-dark">No Notifications</h4>
            <p class="text-muted mb-0">You're all caught up! Updates regarding your orders and transactions will appear here.</p>
        </div>

        <div id="notificationsContainer">
        <% if (notifications != null && !notifications.isEmpty()) {
            for (Notification n : notifications) {
                String type = (n.getNotificationType() != null) ? n.getNotificationType().toUpperCase() : "SYSTEM";
                String iconClass = "icon-system";
                String iconFa = "fa-bell";

                if ("ORDER".equals(type)) {
                    iconClass = "icon-order";
                    iconFa = "fa-clipboard-list";
                } else if ("WALLET".equals(type)) {
                    iconClass = "icon-wallet";
                    iconFa = "fa-wallet";
                } else if ("CHAT".equals(type)) {
                    iconClass = "icon-chat";
                    iconFa = "fa-comment-dots";
                } else if ("DELIVERY".equals(type)) {
                    iconClass = "icon-delivery";
                    iconFa = "fa-truck";
                }
        %>
                <div class="notif-card <%= !n.isRead() ? "unread" : "" %>" data-notif-id="<%= n.getNotificationId() %>">
                    <div class="notif-icon-box <%= iconClass %>">
                        <i class="fa-solid <%= iconFa %>"></i>
                    </div>
                    <div class="flex-grow-1">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <h6 class="fw-bold mb-0 text-dark">
                                <%= n.getTitle() %>
                                <% if (!n.isRead()) { %>
                                    <span class="badge bg-success small ms-2" style="font-size: 10px;">NEW</span>
                                <% } %>
                            </h6>
                            <span class="small text-muted"><%= n.getCreatedAt() %></span>
                        </div>
                        <p class="text-muted mb-2 small"><%= n.getMessage() %></p>
                        <div class="d-flex gap-2 align-items-center">
                            <% if (n.getTargetUrl() != null && !n.getTargetUrl().isEmpty()) { %>
                                <a href="${pageContext.request.contextPath}/notifications/read?id=<%= n.getNotificationId() %>&target=<%= n.getTargetUrl() %>" 
                                   class="btn btn-sm btn-outline-success rounded-pill px-3 py-1 fw-semibold" style="font-size: 12px;">
                                    View Details <i class="fa-solid fa-arrow-right ms-1"></i>
                                </a>
                            <% } %>
                            <% if (!n.isRead()) { %>
                                <a href="${pageContext.request.contextPath}/notifications/read?id=<%= n.getNotificationId() %>" 
                                   class="btn btn-sm btn-light text-muted rounded-pill px-3 py-1" style="font-size: 12px;">
                                    Mark as read
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>
        <%  }
           } %>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script>window.KisaanContextPath = '${pageContext.request.contextPath}';</script>
    <script src="${pageContext.request.contextPath}/assets/js/notifications-poll.js"></script>
</body>
</html>
