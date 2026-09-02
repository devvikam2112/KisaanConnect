<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.ChatRoom"%>
<%@page import="com.kisaanconnect.model.Message"%>
<%@page import="com.kisaanconnect.model.ChatQuickAction"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    ChatRoom room = (ChatRoom) request.getAttribute("chatRoom");
    List<Message> messages = (List<Message>) request.getAttribute("messages");
    List<ChatQuickAction> quickActions = (List<ChatQuickAction>) request.getAttribute("quickActions");

    if (room == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    boolean isFarmer = "FARMER".equalsIgnoreCase(loggedInUser.getRole());
    boolean isCommercial = "COMMERCIAL".equalsIgnoreCase(loggedInUser.getRole());
    boolean isReadOnly = room.isReadOnly();

    String otherPartyTitle = isFarmer ? "Customer / Buyer" : "Farmer / Producer";
    String otherPartyName = isFarmer ? room.getBuyerName() : (room.getFarmName() != null ? room.getFarmName() : room.getFarmerName());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Communication | <%= room.getSubOrderNumber() %> | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .chat-container {
            max-width: 900px;
            margin: 25px auto 40px auto;
        }

        .chat-card {
            background: white;
            border-radius: 20px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 10px 30px rgba(0,0,0,0.06);
            display: flex;
            flex-direction: column;
            height: 75vh;
            min-height: 550px;
            overflow: hidden;
        }

        .chat-header {
            background: <%= isFarmer ? "linear-gradient(135deg, #1B5E20, #2E7D32)" : (isCommercial ? "linear-gradient(135deg, #1E3A8A, #2563EB)" : "linear-gradient(135deg, #15803D, #16A34A)") %>;
            color: white;
            padding: 18px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }

        .chat-context-bar {
            background: #F9FAFB;
            border-bottom: 1px solid #E5E7EB;
            padding: 12px 24px;
            font-size: 13px;
            color: #4B5563;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        .chat-body {
            flex: 1;
            padding: 24px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 16px;
            background: #FAFAFA;
        }

        .message-bubble {
            max-width: 75%;
            padding: 12px 18px;
            border-radius: 16px;
            font-size: 14px;
            line-height: 1.5;
            position: relative;
            word-wrap: break-word;
        }

        .msg-mine {
            align-self: flex-end;
            background: <%= isFarmer ? "#2E7D32" : (isCommercial ? "#1E40AF" : "#16A34A") %>;
            color: white;
            border-bottom-right-radius: 4px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }

        .msg-theirs {
            align-self: flex-start;
            background: white;
            color: #1F2937;
            border: 1px solid #E5E7EB;
            border-bottom-left-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }

        .msg-time {
            font-size: 10px;
            opacity: 0.75;
            margin-top: 4px;
            text-align: right;
        }

        .msg-sender {
            font-size: 11px;
            font-weight: 700;
            margin-bottom: 4px;
            color: #6B7280;
        }

        .quick-actions-bar {
            background: #F3F4F6;
            padding: 10px 20px;
            border-top: 1px solid #E5E7EB;
            display: flex;
            gap: 8px;
            overflow-x: auto;
            white-space: nowrap;
        }

        .quick-btn {
            background: white;
            border: 1px solid #D1D5DB;
            border-radius: 20px;
            padding: 5px 14px;
            font-size: 12px;
            font-weight: 600;
            color: #374151;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .quick-btn:hover:not(:disabled) {
            background: #E5E7EB;
            color: #111827;
            border-color: #9CA3AF;
        }

        .quick-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .chat-footer {
            padding: 16px 20px;
            background: white;
            border-top: 1px solid #E5E7EB;
        }

        .readonly-banner {
            background: #FEF3C7;
            border-top: 1px solid #FCD34D;
            color: #92400E;
            padding: 12px 20px;
            text-align: center;
            font-weight: 600;
            font-size: 13px;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-active { background: #DEF7EC; color: #03543F; }
        .badge-read { background: #E5E7EB; color: #374151; }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="container chat-container">

        <%@ include file="/includes/alerts.jsp" %>

        <div class="chat-card">

            <!-- Header -->
            <div class="chat-header">
                <div>
                    <div class="d-flex align-items-center gap-2">
                        <h5 class="mb-0 fw-bold"><i class="fa-solid fa-comments"></i> <%= otherPartyName %></h5>
                        <span class="badge bg-white text-dark small"><%= otherPartyTitle %></span>
                    </div>
                    <div class="small text-white-50 mt-1">
                        Sub-Order: <strong>#<%= room.getSubOrderNumber() %></strong> (Master #<%= room.getOrderNumber() %>)
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="status-badge <%= isReadOnly ? "badge-read" : "badge-active" %>">
                        <%= room.getSubOrderStatus() %>
                    </span>
                    <a href="${pageContext.request.contextPath}/<%= isFarmer ? "farmer/orders" : (isCommercial ? "commercial/orders.jsp" : "buyer/orders.jsp") %>" 
                       class="btn btn-sm btn-outline-light rounded-pill px-3">
                        <i class="fa-solid fa-arrow-left me-1"></i> Back to Orders
                    </a>
                </div>
            </div>

            <!-- Context Bar -->
            <div class="chat-context-bar">
                <div>
                    <strong><i class="fa-solid fa-wheat-awn"></i> Produce:</strong> <%= (room.getItemsSummary() != null && !room.getItemsSummary().isEmpty()) ? room.getItemsSummary() : "Order Items" %>
                </div>
                <div>
                    <strong><i class="fa-solid fa-wallet"></i> Package Subtotal:</strong> <span class="text-success fw-bold">₹<%= room.getSubOrderTotal() %></span>
                </div>
            </div>

            <!-- Messages Stream -->
            <div class="chat-body" id="chatStream">
                <% if (messages == null || messages.isEmpty()) { %>
                    <div class="text-center text-muted my-auto" id="noMsgPrompt">
                        <i class="fa-regular fa-comments fs-1 mb-2 text-muted"></i>
                        <p class="mb-0">No messages yet. Start the conversation regarding this order below.</p>
                    </div>
                <% } else {
                    for (Message m : messages) {
                        boolean isMine = (m.getSenderUserId() == loggedInUser.getUserId());
                %>
                        <div class="message-bubble <%= isMine ? "msg-mine" : "msg-theirs" %>">
                            <% if (!isMine) { %>
                                <div class="msg-sender"><%= m.getSenderName() %> (<%= m.getSenderRole() %>)</div>
                            <% } %>
                            <div><%= m.getMessageText() %></div>
                            <div class="msg-time"><%= m.getSentAt() %></div>
                        </div>
                <%  }
                   } %>
            </div>

            <!-- Quick Actions Bar -->
            <% if (!isReadOnly && quickActions != null && !quickActions.isEmpty()) { %>
                <div class="quick-actions-bar">
                    <span class="small fw-bold text-muted my-auto me-1"><i class="fa-solid fa-bolt"></i> Shortcuts:</span>
                    <% for (ChatQuickAction qa : quickActions) { %>
                        <button type="button" class="quick-btn" onclick="sendQuickMessage('<%= qa.getActionText().replace("'", "\\'") %>')">
                            <%= qa.getActionText() %>
                        </button>
                    <% } %>
                </div>
            <% } %>

            <!-- Footer / Input Form -->
            <% if (isReadOnly) { %>
                <div class="readonly-banner">
                    <i class="fa-solid fa-lock me-1"></i>
                    This order is <strong><%= room.getSubOrderStatus() %></strong>. Chat history is preserved as read-only.
                </div>
            <% } else { %>
                <div class="chat-footer">
                    <form id="chatForm" onsubmit="handleChatSubmit(event);" class="d-flex gap-2">
                        <input type="hidden" name="chatRoomId" id="chatRoomId" value="<%= room.getChatRoomId() %>">
                        <input type="hidden" name="messageType" id="messageType" value="TEXT">
                        <input type="text" 
                               name="messageText" 
                               id="messageInput" 
                               class="form-control rounded-pill px-4" 
                               placeholder="Type a message regarding Sub-Order #<%= room.getSubOrderNumber() %>..." 
                               required 
                               autocomplete="off">
                        <button type="submit" class="btn btn-success rounded-pill px-4 fw-semibold" id="sendBtn">
                            <i class="fa-solid fa-paper-plane me-1"></i> Send
                        </button>
                    </form>
                </div>
            <% } %>

        </div>

    </div>

    <script>
        const chatStream = document.getElementById('chatStream');
        const chatRoomId = <%= room.getChatRoomId() %>;
        const currentUserId = <%= loggedInUser.getUserId() %>;
        const isReadOnly = <%= isReadOnly %>;

        // Auto scroll to bottom
        function scrollToBottom() {
            chatStream.scrollTop = chatStream.scrollHeight;
        }
        scrollToBottom();

        // Send Quick Message
        function sendQuickMessage(text) {
            if (isReadOnly) return;
            document.getElementById('messageInput').value = text;
            document.getElementById('messageType').value = 'QUICK_ACTION';
            document.getElementById('chatForm').requestSubmit();
        }

        // Handle AJAX Submit
        function handleChatSubmit(e) {
            e.preventDefault();
            const input = document.getElementById('messageInput');
            const typeInput = document.getElementById('messageType');
            const text = input.value.trim();
            if (!text) return;

            const sendBtn = document.getElementById('sendBtn');
            sendBtn.disabled = true;

            const formData = new URLSearchParams();
            formData.append('chatRoomId', chatRoomId);
            formData.append('messageText', text);
            formData.append('messageType', typeInput.value || 'TEXT');

            fetch('${pageContext.request.contextPath}/chat/send', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData.toString()
            })
            .then(res => {
                if (res.ok) {
                    input.value = '';
                    typeInput.value = 'TEXT';
                    pollMessages();
                } else {
                    alert('Could not send message. Chat might be read-only or session expired.');
                }
            })
            .catch(err => console.error(err))
            .finally(() => {
                sendBtn.disabled = false;
                input.focus();
            });
        }

        // Poll messages periodically
        function pollMessages() {
            fetch('${pageContext.request.contextPath}/chat/messages?chatRoomId=' + chatRoomId, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
            .then(res => res.json())
            .then(messages => {
                if (!Array.isArray(messages)) return;
                const noPrompt = document.getElementById('noMsgPrompt');
                if (noPrompt && messages.length > 0) noPrompt.remove();

                let html = '';
                messages.forEach(m => {
                    const isMine = (m.senderUserId === currentUserId);
                    html += '<div class="message-bubble ' + (isMine ? 'msg-mine' : 'msg-theirs') + '">';
                    if (!isMine) {
                        html += '<div class="msg-sender">' + escapeHtml(m.senderName) + ' (' + escapeHtml(m.senderRole) + ')</div>';
                    }
                    html += '<div>' + escapeHtml(m.messageText) + '</div>';
                    html += '<div class="msg-time">' + (m.sentAt || '') + '</div>';
                    html += '</div>';
                });
                chatStream.innerHTML = html;
                scrollToBottom();
            })
            .catch(err => console.error(err));
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        // Live polling every 3.5s
        if (!isReadOnly) {
            setInterval(pollMessages, 3500);
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
