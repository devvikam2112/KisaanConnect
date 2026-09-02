package com.kisaanconnect.controller;

import com.kisaanconnect.dao.AdminDAO;
import com.kisaanconnect.dao.ProductDAO;
import com.kisaanconnect.model.AdminAuditLog;
import com.kisaanconnect.model.Product;
import com.kisaanconnect.model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AdminServlet", urlPatterns = {
    "/admin/dashboard",
    "/admin/users",
    "/admin/user-details",
    "/admin/approve-user",
    "/admin/reject-user",
    "/admin/toggle-user-status",
    "/admin/products",
    "/admin/delete-product",
    "/admin/audit-logs"
})
public class AdminServlet extends HttpServlet {

    private final AdminDAO adminDAO = new AdminDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp?error=" + URLEncoder.encode("Access Denied: Admins Only", StandardCharsets.UTF_8));
            return;
        }

        String servletPath = request.getServletPath();

        if ("/admin/user-details".equals(servletPath)) {
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null) {
                try {
                    int uid = Integer.parseInt(userIdStr.trim());
                    Map<String, Object> details = adminDAO.getUserFullProfile(uid);
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    
                    StringBuilder json = new StringBuilder("{");
                    int count = 0;
                    for (Map.Entry<String, Object> entry : details.entrySet()) {
                        if (count > 0) json.append(",");
                        json.append("\"").append(entry.getKey()).append("\":");
                        if (entry.getValue() == null) {
                            json.append("null");
                        } else if (entry.getValue() instanceof Number || entry.getValue() instanceof Boolean) {
                            json.append(entry.getValue());
                        } else {
                            String val = entry.getValue().toString()
                                .replace("\\", "\\\\")
                                .replace("\"", "\\\"")
                                .replace("\r", "")
                                .replace("\n", "\\n");
                            json.append("\"").append(val).append("\"");
                        }
                        count++;
                    }
                    json.append("}");
                    response.getWriter().write(json.toString());
                    return;
                } catch (Exception ignored) {}
            }
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;

        } else if ("/admin/users".equals(servletPath)) {
            String roleFilter = request.getParameter("role");
            String statusFilter = request.getParameter("status");
            String search = request.getParameter("search");

            List<User> users = adminDAO.getUsersByFilter(roleFilter, statusFilter, search);
            Map<String, Object> stats = adminDAO.getPlatformStats();

            request.setAttribute("users", users);
            request.setAttribute("stats", stats);
            request.setAttribute("selectedRole", roleFilter != null ? roleFilter : "ALL");
            request.setAttribute("selectedStatus", statusFilter != null ? statusFilter : "ALL");
            request.setAttribute("searchQuery", search != null ? search : "");
            request.getRequestDispatcher("/admin/users.jsp").forward(request, response);

        } else if ("/admin/products".equals(servletPath)) {
            List<Product> products = productDAO.getAllAvailableProducts();
            request.setAttribute("products", products);
            request.getRequestDispatcher("/admin/products.jsp").forward(request, response);

        } else if ("/admin/audit-logs".equals(servletPath)) {
            List<AdminAuditLog> logs = adminDAO.getAuditLogs(100);
            request.setAttribute("logs", logs);
            request.getRequestDispatcher("/admin/audit-logs.jsp").forward(request, response);

        } else {
            // Dashboard
            Map<String, Object> stats = adminDAO.getPlatformStats();
            List<User> pendingUsers = adminDAO.getUsersByFilter(null, "PENDING", null);
            List<AdminAuditLog> recentLogs = adminDAO.getAuditLogs(10);

            request.setAttribute("stats", stats);
            request.setAttribute("pendingUsers", pendingUsers);
            request.setAttribute("recentLogs", recentLogs);
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String servletPath = request.getServletPath();
        String ip = request.getRemoteAddr();

        if ("/admin/approve-user".equals(servletPath)) {
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null) {
                try {
                    int targetUserId = Integer.parseInt(userIdStr.trim());
                    adminDAO.approveUser(targetUserId, user.getUserId(), ip);
                    String msg = URLEncoder.encode("User account approved and verified successfully!", StandardCharsets.UTF_8);
                    response.sendRedirect(request.getContextPath() + "/admin/users?success=" + msg);
                    return;
                } catch (Exception ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Failed to approve user.", StandardCharsets.UTF_8));

        } else if ("/admin/reject-user".equals(servletPath)) {
            String userIdStr = request.getParameter("userId");
            String reason = request.getParameter("reason");
            if (userIdStr != null) {
                try {
                    int targetUserId = Integer.parseInt(userIdStr.trim());
                    adminDAO.rejectUser(targetUserId, reason, user.getUserId(), ip);
                    String msg = URLEncoder.encode("User registration rejected.", StandardCharsets.UTF_8);
                    response.sendRedirect(request.getContextPath() + "/admin/users?success=" + msg);
                    return;
                } catch (Exception ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Failed to reject user.", StandardCharsets.UTF_8));

        } else if ("/admin/toggle-user-status".equals(servletPath)) {
            String userIdStr = request.getParameter("userId");
            String newStatus = request.getParameter("status");
            if (userIdStr != null && newStatus != null) {
                try {
                    int targetUserId = Integer.parseInt(userIdStr.trim());
                    adminDAO.toggleUserStatus(targetUserId, newStatus.trim().toUpperCase(), user.getUserId(), ip);
                    String msg = URLEncoder.encode("User status changed to " + newStatus, StandardCharsets.UTF_8);
                    response.sendRedirect(request.getContextPath() + "/admin/users?success=" + msg);
                    return;
                } catch (Exception ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Failed to update status.", StandardCharsets.UTF_8));

        } else if ("/admin/delete-product".equals(servletPath)) {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null) {
                try {
                    int prodId = Integer.parseInt(productIdStr.trim());
                    productDAO.deleteProduct(prodId);
                    adminDAO.logAdminAction(user.getUserId(), "ADMIN_DELETED_PRODUCT", null, "PRODUCT", prodId, "Deleted product ID " + prodId, ip);
                    String msg = URLEncoder.encode("Product listing removed successfully.", StandardCharsets.UTF_8);
                    response.sendRedirect(request.getContextPath() + "/admin/products?success=" + msg);
                    return;
                } catch (Exception ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + URLEncoder.encode("Failed to delete product.", StandardCharsets.UTF_8));
        }
    }
}
