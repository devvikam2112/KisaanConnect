package com.kisaanconnect.controller;

import com.kisaanconnect.dao.NotificationDAO;
import com.kisaanconnect.model.Notification;
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

@WebServlet(name = "NotificationServlet", urlPatterns = {
    "/notifications",
    "/notifications/read",
    "/notifications/read-all",
    "/notifications/count",
    "/notifications/poll"
})
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }

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
            if ("/notifications/count".equals(servletPath) || "/notifications/poll".equals(servletPath)) {
                response.setContentType("application/json");
                response.getWriter().write("{\"unreadCount\":0,\"notifications\":[]}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String path = request.getServletPath();

        if ("/notifications/count".equals(path)) {
            int count = notificationDAO.getUnreadCount(user.getUserId());
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.write("{\"unreadCount\":" + count + "}");
            out.flush();
            return;
        }

        if ("/notifications/poll".equals(path)) {
            int unreadCount = notificationDAO.getUnreadCount(user.getUserId());
            List<Notification> recent = notificationDAO.getNotificationsForUser(user.getUserId(), 15);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            StringBuilder sb = new StringBuilder();
            sb.append("{\"unreadCount\":").append(unreadCount).append(",\"notifications\":[");
            for (int i = 0; i < recent.size(); i++) {
                Notification n = recent.get(i);
                if (i > 0) sb.append(",");
                sb.append("{")
                  .append("\"id\":").append(n.getNotificationId()).append(",")
                  .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                  .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
                  .append("\"type\":\"").append(escapeJson(n.getNotificationType())).append("\",")
                  .append("\"isRead\":").append(n.isRead()).append(",")
                  .append("\"targetUrl\":\"").append(escapeJson(n.getTargetUrl())).append("\",")
                  .append("\"createdAt\":\"").append(n.getCreatedAt() != null ? n.getCreatedAt().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("]}");
            response.getWriter().write(sb.toString());
            return;
        }

        if ("/notifications/read".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr == null) idStr = request.getParameter("notificationId");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int notifId = Integer.parseInt(idStr);
                    notificationDAO.markAsRead(notifId, user.getUserId());
                } catch (NumberFormatException ignored) {}
            }

            String target = request.getParameter("target");
            if (target != null && !target.isEmpty()) {
                response.sendRedirect(request.getContextPath() + target);
                return;
            }

            String isAjax = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equalsIgnoreCase(isAjax)) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":true}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/notifications");
            return;
        }

        if ("/notifications/read-all".equals(path)) {
            notificationDAO.markAllAsRead(user.getUserId());
            String isAjax = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equalsIgnoreCase(isAjax)) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":true}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/notifications");
            return;
        }

        // Default: /notifications
        List<Notification> notifications = notificationDAO.getNotificationsForUser(user.getUserId(), 100);
        int unreadCount = notificationDAO.getUnreadCount(user.getUserId());

        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);
        request.getRequestDispatcher("/notifications.jsp").forward(request, response);
    }
}
