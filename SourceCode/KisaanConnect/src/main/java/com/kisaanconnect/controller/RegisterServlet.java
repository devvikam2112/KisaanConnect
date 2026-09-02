package com.kisaanconnect.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.kisaanconnect.dao.UserDAO;
import com.kisaanconnect.model.User;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register", "/auth/register"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        // Validate required fields
        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || password == null || password.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {

            redirectWithError(request, response, "All fields are required");
            return;
        }

        // Validate role (FARMER, BUYER, COMMERCIAL)
        if (role == null || (!role.equals("FARMER") && !role.equals("BUYER") && !role.equals("COMMERCIAL"))) {
            redirectWithError(request, response, "Please select your role");
            return;
        }

        // Validate password confirmation
        if (!password.equals(confirmPassword)) {
            redirectWithError(request, response, "Passwords do not match");
            return;
        }

        // Validate password length
        if (password.length() < 6) {
            redirectWithError(request, response, "Password must be at least 6 characters");
            return;
        }

        UserDAO userDAO = new UserDAO();

        // Check if email already exists
        if (userDAO.emailExists(email.trim().toLowerCase())) {
            redirectWithError(request, response, "Email is already registered");
            return;
        }

        // Check if phone already exists
        if (userDAO.phoneExists(phone.trim())) {
            redirectWithError(request, response, "Phone number is already registered");
            return;
        }

        // Create and populate User object
        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPhone(phone.trim());
        user.setRole(role);
        user.setPasswordHash(password); // Will be securely hashed in UserDAO.register()
        if ("BUYER".equalsIgnoreCase(role)) {
            user.setStatus("ACTIVE");
        } else {
            user.setStatus("PENDING");
        }
        user.setDeleted(false);

        boolean registered = userDAO.register(user);

        if (registered) {
            String msgText = "BUYER".equalsIgnoreCase(role) 
                ? "Account created successfully! Please login to start browsing fresh harvest."
                : "Registration successful! Please login to complete your profile details.";
            String msg = URLEncoder.encode(msgText, StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp?success=" + msg);
        } else {
            redirectWithError(request, response, "Registration failed. Please try again.");
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String errorMessage) throws IOException {
        String encoded = URLEncoder.encode(errorMessage, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/auth/register.jsp?error=" + encoded);
    }
}