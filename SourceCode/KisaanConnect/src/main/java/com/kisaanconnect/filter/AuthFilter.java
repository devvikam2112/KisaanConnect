package com.kisaanconnect.filter;

import com.kisaanconnect.dao.UserDAO;
import com.kisaanconnect.model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/farmer/*",
    "/buyer/*",
    "/commercial/*",
    "/admin/*",
    "/cart/*",
    "/checkout/*",
    "/order/*",
    "/chat/*",
    "/chat",
    "/chat-conversations",
    "/notifications",
    "/notifications/*"
})
public class AuthFilter implements Filter {

    private final UserDAO userDAO = new UserDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Prevent browser caching of protected application pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String relativePath = uri.substring(contextPath.length());

        // Allow public access to browse marketplace produce without logging in
        if (relativePath.equals("/buyer/products.jsp") || relativePath.equals("/buyer/products")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(httpRequest.getHeader("X-Requested-With"))
                || (httpRequest.getHeader("Accept") != null && httpRequest.getHeader("Accept").contains("application/json"))
                || relativePath.startsWith("/order/tracking-route")
                || relativePath.startsWith("/order/razorpay")
                || relativePath.startsWith("/chat/")
                || relativePath.startsWith("/notifications/count")
                || relativePath.startsWith("/notifications/poll");

        if (loggedInUser == null) {
            if (isAjax || relativePath.startsWith("/order/tracking-route")) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json;charset=UTF-8");
                httpResponse.getWriter().write("{\"success\":false,\"error\":\"Authentication required\"}");
                return;
            }
            String msg = URLEncoder.encode("Please login to access this page.", StandardCharsets.UTF_8);
            httpResponse.sendRedirect(contextPath + "/auth/login.jsp?error=" + msg);
            return;
        }

        String role = loggedInUser.getRole();

        if (role == null) {
            if (session != null) session.invalidate();
            httpResponse.sendRedirect(contextPath + "/auth/login.jsp?error=Invalid+session+role");
            return;
        }

        // DATABASE-AUTHORITATIVE STATUS CHECK:
        // Query live account status from database on every protected request
        String dbStatus = userDAO.getUserStatus(loggedInUser.getUserId());

        if (dbStatus == null || "SUSPENDED".equalsIgnoreCase(dbStatus)) {
            // User deleted or suspended: Immediately invalidate session and reject access
            if (session != null) {
                try {
                    session.invalidate();
                } catch (IllegalStateException ignored) {}
            }

            if (isAjax) {
                httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                httpResponse.setContentType("application/json;charset=UTF-8");
                httpResponse.getWriter().write("{\"success\":false,\"error\":\"Your account has been suspended by administrator.\"}");
                return;
            }

            String msg = URLEncoder.encode("Your account has been suspended. Please contact administrator.", StandardCharsets.UTF_8);
            httpResponse.sendRedirect(contextPath + "/auth/login.jsp?error=" + msg);
            return;
        }

        // Keep in-memory session user status synchronized with DB
        loggedInUser.setStatus(dbStatus);

        // Verification Check: REJECTED users are blocked from operational features
        if ("REJECTED".equalsIgnoreCase(dbStatus) && !"ADMIN".equalsIgnoreCase(role)) {
            if (isAjax) {
                httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                httpResponse.setContentType("application/json;charset=UTF-8");
                httpResponse.getWriter().write("{\"success\":false,\"error\":\"Account application has been rejected by administrator.\"}");
                return;
            }
            httpResponse.sendRedirect(contextPath + "/auth/pending-verification.jsp?status=REJECTED");
            return;
        }

        // PENDING accounts can access profile setup, dashboards, notifications, and profile pages to submit KYC details
        if ("PENDING".equalsIgnoreCase(dbStatus) && !"ADMIN".equalsIgnoreCase(role)) {
            boolean isAllowedPendingPath = relativePath.startsWith("/auth/")
                    || relativePath.equals("/farmer/setup-profile.jsp")
                    || relativePath.equals("/farmer/setup-profile")
                    || relativePath.equals("/farmer/profile.jsp")
                    || relativePath.equals("/farmer/profile")
                    || relativePath.equals("/farmer/dashboard")
                    || relativePath.equals("/farmer/dashboard.jsp")
                    || relativePath.equals("/commercial/setup-profile.jsp")
                    || relativePath.equals("/commercial/setup-profile")
                    || relativePath.equals("/commercial/profile.jsp")
                    || relativePath.equals("/commercial/profile")
                    || relativePath.equals("/commercial/dashboard")
                    || relativePath.equals("/commercial/dashboard.jsp")
                    || relativePath.startsWith("/buyer/")
                    || relativePath.startsWith("/notifications")
                    || relativePath.startsWith("/chat")
                    || relativePath.equals("/logout");

            if (!isAllowedPendingPath) {
                if (isAjax) {
                    httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    httpResponse.setContentType("application/json;charset=UTF-8");
                    httpResponse.getWriter().write("{\"success\":false,\"error\":\"Account verification pending by admin.\"}");
                    return;
                }
                httpResponse.sendRedirect(contextPath + "/auth/pending-verification.jsp");
                return;
            }
        }

        // Role-based access checks
        if (relativePath.startsWith("/farmer/") && !role.equalsIgnoreCase("FARMER") && !role.equalsIgnoreCase("ADMIN")) {
            redirectToAppropriateDashboard(httpResponse, contextPath, role);
            return;
        }

        if (relativePath.startsWith("/buyer/")) {
            boolean isProcurementShared = relativePath.equals("/buyer/cart.jsp") 
                    || relativePath.equals("/buyer/cart")
                    || relativePath.equals("/buyer/checkout.jsp")
                    || relativePath.equals("/buyer/checkout")
                    || relativePath.equals("/buyer/products.jsp")
                    || relativePath.equals("/buyer/products");
            if (isProcurementShared) {
                if (!role.equalsIgnoreCase("BUYER") && !role.equalsIgnoreCase("COMMERCIAL") && !role.equalsIgnoreCase("ADMIN")) {
                    redirectToAppropriateDashboard(httpResponse, contextPath, role);
                    return;
                }
            } else {
                if (!role.equalsIgnoreCase("BUYER") && !role.equalsIgnoreCase("ADMIN")) {
                    redirectToAppropriateDashboard(httpResponse, contextPath, role);
                    return;
                }
            }
        }

        if (relativePath.startsWith("/commercial/") && !role.equalsIgnoreCase("COMMERCIAL") && !role.equalsIgnoreCase("ADMIN")) {
            redirectToAppropriateDashboard(httpResponse, contextPath, role);
            return;
        }

        if (relativePath.startsWith("/admin/") && !role.equalsIgnoreCase("ADMIN")) {
            redirectToAppropriateDashboard(httpResponse, contextPath, role);
            return;
        }

        chain.doFilter(request, response);
    }

    private void redirectToAppropriateDashboard(HttpServletResponse response, String contextPath, String role) throws IOException {
        if ("FARMER".equalsIgnoreCase(role)) {
            response.sendRedirect(contextPath + "/farmer/dashboard");
        } else if ("BUYER".equalsIgnoreCase(role)) {
            response.sendRedirect(contextPath + "/buyer/dashboard.jsp");
        } else if ("COMMERCIAL".equalsIgnoreCase(role)) {
            response.sendRedirect(contextPath + "/commercial/dashboard");
        } else if ("ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(contextPath + "/admin/dashboard.jsp");
        } else {
            response.sendRedirect(contextPath + "/index.jsp");
        }
    }

    @Override
    public void destroy() {
    }
}
