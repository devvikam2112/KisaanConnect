package com.kisaanconnect.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.kisaanconnect.dao.BuyerDAO;
import com.kisaanconnect.dao.FarmerProfileDAO;
import com.kisaanconnect.dao.OrganizationDAO;
import com.kisaanconnect.dao.UserDAO;
import com.kisaanconnect.model.User;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/auth/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("loggedInUser") != null) {
            User user = (User) session.getAttribute("loggedInUser");
            String role = user.getRole();
            if ("FARMER".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/farmer/dashboard");
                return;
            } else if ("COMMERCIAL".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/commercial/dashboard");
                return;
            } else if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/buyer/dashboard.jsp");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Validate input
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            redirectWithError(request, response, "Email and Password are required");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.login(email.trim().toLowerCase(), password);

        if (user == null) {
            redirectWithError(request, response, "Invalid email or password");
            return;
        }

        // Establish user session
        HttpSession session = request.getSession(true);
        session.setAttribute("loggedInUser", user);
        userDAO.updateLastLogin(user.getUserId());

        String role = user.getRole();
        if (role == null || role.equalsIgnoreCase("USER")) {
            response.sendRedirect(request.getContextPath() + "/auth/select-role.jsp");
            return;
        }

        // Role-based routing
        if (role.equalsIgnoreCase("FARMER")) {
            FarmerProfileDAO farmerDAO = new FarmerProfileDAO();
            if (farmerDAO.profileExists(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/farmer/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/farmer/setup-profile.jsp");
            }
        } else if (role.equalsIgnoreCase("COMMERCIAL")) {
            OrganizationDAO orgDAO = new OrganizationDAO();
            if (orgDAO.organizationExists(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/commercial/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/commercial/setup-profile");
            }
        } else if (role.equalsIgnoreCase("BUYER")) {
            response.sendRedirect(request.getContextPath() + "/buyer/dashboard.jsp");
        } else if (role.equalsIgnoreCase("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        } else {
            redirectWithError(request, response, "Unknown user role: " + role);
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String errorMessage) throws IOException {
        String encoded = URLEncoder.encode(errorMessage, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp?error=" + encoded);
    }
}
