package com.kisaanconnect.controller;

import com.kisaanconnect.dao.EmailOTPDAO;
import com.kisaanconnect.dao.UserDAO;
import com.kisaanconnect.model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {
    "/auth/forgot-password",
    "/auth/verify-otp",
    "/auth/reset-password"
})
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String servletPath = request.getServletPath();
        if ("/auth/verify-otp".equals(servletPath)) {
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
        } else if ("/auth/reset-password".equals(servletPath)) {
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String servletPath = request.getServletPath();
        UserDAO userDAO = new UserDAO();
        EmailOTPDAO otpDAO = new EmailOTPDAO();
        HttpSession session = request.getSession();

        if ("/auth/forgot-password".equals(servletPath)) {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp?error=" + URLEncoder.encode("Please provide your registered email.", StandardCharsets.UTF_8));
                return;
            }

            User user = userDAO.getUserByEmail(email.trim());
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp?error=" + URLEncoder.encode("No account found with that email address.", StandardCharsets.UTF_8));
                return;
            }

            String otp = otpDAO.generateAndStoreOTP(email.trim(), "FORGOT_PASSWORD", 15);
            session.setAttribute("reset_email", email.trim());

            String msg = URLEncoder.encode("A 6-digit verification code has been sent to " + email.trim(), StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/auth/verify-otp.jsp?success=" + msg);

        } else if ("/auth/verify-otp".equals(servletPath)) {
            String email = (String) session.getAttribute("reset_email");
            String otpCode = request.getParameter("otpCode");

            if (email == null || otpCode == null || otpCode.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp?error=" + URLEncoder.encode("Session expired. Please request a new OTP.", StandardCharsets.UTF_8));
                return;
            }

            boolean verified = otpDAO.verifyOTP(email, otpCode.trim(), "FORGOT_PASSWORD");
            if (verified) {
                session.setAttribute("otp_verified", true);
                response.sendRedirect(request.getContextPath() + "/auth/reset-password.jsp?success=" + URLEncoder.encode("OTP verified successfully. Create a new password.", StandardCharsets.UTF_8));
            } else {
                response.sendRedirect(request.getContextPath() + "/auth/verify-otp.jsp?error=" + URLEncoder.encode("Invalid or expired OTP code. Please try again.", StandardCharsets.UTF_8));
            }

        } else if ("/auth/reset-password".equals(servletPath)) {
            String email = (String) session.getAttribute("reset_email");
            Boolean otpVerified = (Boolean) session.getAttribute("otp_verified");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (email == null || otpVerified == null || !otpVerified) {
                response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp?error=" + URLEncoder.encode("Unauthorized reset attempt.", StandardCharsets.UTF_8));
                return;
            }

            if (newPassword == null || newPassword.length() < 6 || !newPassword.equals(confirmPassword)) {
                response.sendRedirect(request.getContextPath() + "/auth/reset-password.jsp?error=" + URLEncoder.encode("Passwords do not match or are shorter than 6 characters.", StandardCharsets.UTF_8));
                return;
            }

            boolean updated = userDAO.updatePasswordByEmail(email, newPassword);
            session.removeAttribute("reset_email");
            session.removeAttribute("otp_verified");

            if (updated) {
                String msg = URLEncoder.encode("Password updated successfully! Please login with your new credentials.", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/auth/login.jsp?success=" + msg);
            } else {
                response.sendRedirect(request.getContextPath() + "/auth/reset-password.jsp?error=" + URLEncoder.encode("Failed to update password.", StandardCharsets.UTF_8));
            }
        }
    }
}
