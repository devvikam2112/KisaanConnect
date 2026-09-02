package com.kisaanconnect.controller;

import com.kisaanconnect.dao.ChatDAO;
import com.kisaanconnect.dao.ChatQuickActionDAO;
import com.kisaanconnect.model.ChatQuickAction;
import com.kisaanconnect.model.ChatRoom;
import com.kisaanconnect.model.Message;
import com.kisaanconnect.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ChatServlet", urlPatterns = {
    "/chat",
    "/chat/room",
    "/chat/send",
    "/chat/messages",
    "/chat/conversations",
    "/chat/count"
})
public class ChatServlet extends HttpServlet {

    private final ChatDAO chatDAO = new ChatDAO();
    private final ChatQuickActionDAO quickActionDAO = new ChatQuickActionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (user == null) {
            String servletPath = request.getServletPath();
            if ("/chat/messages".equals(servletPath) || "/chat/count".equals(servletPath)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                response.getWriter().write("{\"error\":\"Unauthorized\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String path = request.getServletPath();

        if ("/chat/count".equals(path)) {
            int count = chatDAO.getUnreadMessageCount(user.getUserId());
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.write("{\"unreadCount\":" + count + "}");
            out.flush();
            return;
        }

        if ("/chat/conversations".equals(path)) {
            List<ChatRoom> rooms = chatDAO.getChatRoomsForUser(user.getUserId());
            request.setAttribute("chatRooms", rooms);
            request.getRequestDispatcher("/chat-conversations.jsp").forward(request, response);
            return;
        }

        if ("/chat/send".equals(path)) {
            String roomParam = request.getParameter("chatRoomId");
            String text = request.getParameter("messageText");
            String messageType = request.getParameter("messageType");
            if (messageType == null || messageType.isEmpty()) messageType = "TEXT";

            if (roomParam == null || text == null || text.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            try {
                int chatRoomId = Integer.parseInt(roomParam);
                boolean sent = chatDAO.sendMessage(chatRoomId, user.getUserId(), user.getRole(), messageType, text);
                if (!sent) {
                    // Could be unauthorized or read-only
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
                        response.setContentType("application/json");
                        response.getWriter().write("{\"error\":\"Cannot send message. Chat is either read-only or unauthorized.\"}");
                    } else {
                        session.setAttribute("errorMessage", "Cannot send message. Chat is either read-only or unauthorized.");
                        response.sendRedirect(request.getContextPath() + "/chat?chatRoomId=" + chatRoomId);
                    }
                    return;
                }

                if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":true}");
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/chat?chatRoomId=" + chatRoomId);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        if ("/chat/messages".equals(path)) {
            String roomParam = request.getParameter("chatRoomId");
            if (roomParam != null && !roomParam.isEmpty()) {
                try {
                    int chatRoomId = Integer.parseInt(roomParam);
                    List<Message> messages = chatDAO.getMessages(chatRoomId, user.getUserId());
                    response.setContentType("application/json");
                    PrintWriter out = response.getWriter();
                    out.write("[");
                    for (int i = 0; i < messages.size(); i++) {
                        Message m = messages.get(i);
                        if (i > 0) out.write(",");
                        out.write("{");
                        out.write("\"messageId\":" + m.getMessageId() + ",");
                        out.write("\"senderUserId\":" + m.getSenderUserId() + ",");
                        out.write("\"senderRole\":\"" + escapeJson(m.getSenderRole()) + "\",");
                        out.write("\"senderName\":\"" + escapeJson(m.getSenderName()) + "\",");
                        out.write("\"messageType\":\"" + escapeJson(m.getMessageType()) + "\",");
                        out.write("\"messageText\":\"" + escapeJson(m.getMessageText()) + "\",");
                        out.write("\"sentAt\":\"" + (m.getSentAt() != null ? m.getSentAt().toString() : "") + "\",");
                        out.write("\"isMine\":" + (m.getSenderUserId() == user.getUserId()));
                        out.write("}");
                    }
                    out.write("]");
                    out.flush();
                    return;
                } catch (NumberFormatException ignored) {}
            }
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // Default: /chat or /chat/room
        String subOrderIdParam = request.getParameter("subOrderId");
        String chatRoomIdParam = request.getParameter("chatRoomId");

        ChatRoom room = null;
        if (subOrderIdParam != null && !subOrderIdParam.isEmpty()) {
            try {
                int subOrderId = Integer.parseInt(subOrderIdParam);
                room = chatDAO.getOrCreateChatRoom(subOrderId, user.getUserId());
            } catch (NumberFormatException ignored) {}
        } else if (chatRoomIdParam != null && !chatRoomIdParam.isEmpty()) {
            try {
                int chatRoomId = Integer.parseInt(chatRoomIdParam);
                room = chatDAO.getChatRoomById(chatRoomId, user.getUserId());
            } catch (NumberFormatException ignored) {}
        }

        // STRICT AUTHORIZATION CHECK
        if (room == null) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            session.setAttribute("errorMessage", "Access Denied: You are not authorized to view this order conversation.");
            String role = user.getRole() != null ? user.getRole().toUpperCase() : "BUYER";
            if ("FARMER".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/farmer/orders");
            } else if ("COMMERCIAL".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/commercial/orders.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/buyer/orders.jsp");
            }
            return;
        }

        List<Message> messages = chatDAO.getMessages(room.getChatRoomId(), user.getUserId());
        List<ChatQuickAction> quickActions = quickActionDAO.getQuickActionsForRole(user.getRole());

        request.setAttribute("chatRoom", room);
        request.setAttribute("messages", messages);
        request.setAttribute("quickActions", quickActions);

        request.getRequestDispatcher("/chat.jsp").forward(request, response);
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
