<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.ChatRoom"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    List<ChatRoom> chatRooms = (List<ChatRoom>) request.getAttribute("chatRooms");
    boolean isFarmer = "FARMER".equalsIgnoreCase(loggedInUser.getRole());
    boolean isCommercial = "COMMERCIAL".equalsIgnoreCase(loggedInUser.getRole());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Conversations & Messages | KisaanConnect</title>

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

        .conv-card {
            background: white;
            border-radius: 16px;
            border: 1px solid #E5E7EB;
            padding: 20px;
            margin-bottom: 16px;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            text-decoration: none;
            color: inherit;
            display: block;
        }

        .conv-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            border-color: #10B981;
            color: inherit;
        }

        .status-pill {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .pill-active { background: #DEF7EC; color: #03543F; }
        .pill-readonly { background: #E5E7EB; color: #4B5563; }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="header-box">
        <div class="container">
            <h1 class="h2 fw-bold mb-1"><i class="fa-solid fa-comments"></i> Order Conversations</h1>
            <p class="mb-0 text-white-50">Direct order-specific communication between Buyers, Commercial Organisations, and Farmers.</p>
        </div>
    </div>

    <div class="container pb-5" style="max-width: 900px;">

        <%@ include file="/includes/alerts.jsp" %>

        <% if (chatRooms == null || chatRooms.isEmpty()) { %>
            <div class="card border-0 rounded-4 shadow-sm p-5 text-center">
                <i class="fa-regular fa-comments fs-1 text-muted mb-3"></i>
                <h4 class="fw-bold text-dark">No Conversations Yet</h4>
                <p class="text-muted mb-4">When an order is placed or processed, you can communicate with your trading partner directly here.</p>
                <div>
                    <a href="${pageContext.request.contextPath}/<%= isFarmer ? "farmer/orders" : (isCommercial ? "commercial/orders.jsp" : "buyer/orders.jsp") %>" 
                       class="btn btn-success rounded-pill px-4 fw-semibold">
                        <i class="fa-solid fa-clipboard-list me-1"></i> View My Orders
                    </a>
                </div>
            </div>
        <% } else {
            for (ChatRoom cr : chatRooms) {
                String otherParty = isFarmer ? cr.getBuyerName() : (cr.getFarmName() != null ? cr.getFarmName() : cr.getFarmerName());
                boolean isReadOnly = cr.isReadOnly();
        %>
                <a href="${pageContext.request.contextPath}/chat?chatRoomId=<%= cr.getChatRoomId() %>" class="conv-card">
                    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
                        <div>
                            <div class="d-flex align-items-center gap-2">
                                <h5 class="fw-bold mb-0 text-dark"><%= otherParty %></h5>
                                <span class="status-pill <%= isReadOnly ? "pill-readonly" : "pill-active" %>">
                                    <%= cr.getSubOrderStatus() %>
                                </span>
                                <% if (cr.getUnreadCount() > 0) { %>
                                    <span class="badge bg-danger rounded-pill"><%= cr.getUnreadCount() %> new</span>
                                <% } %>
                            </div>
                            <div class="small text-muted mt-1">
                                Sub-Order: <strong>#<%= cr.getSubOrderNumber() %></strong> | Amount: <strong class="text-success">₹<%= cr.getSubOrderTotal() %></strong>
                            </div>
                        </div>
                        <div class="text-end">
                            <span class="btn btn-sm btn-outline-success rounded-pill px-3 fw-semibold">
                                <i class="fa-solid fa-message me-1"></i> Open Chat
                            </span>
                        </div>
                    </div>

                    <div class="small text-muted mt-2 pt-2 border-top d-flex justify-content-between align-items-center">
                        <span class="text-truncate" style="max-width: 80%;">
                            <i class="fa-regular fa-comment-dots me-1"></i>
                            <%= (cr.getLastMessageText() != null && !cr.getLastMessageText().isEmpty()) ? cr.getLastMessageText() : "No messages exchanged yet." %>
                        </span>
                        <span class="small opacity-75">
                            <%= cr.getLastMessageTime() != null ? cr.getLastMessageTime() : "" %>
                        </span>
                    </div>
                </a>
        <%  }
           } %>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
