package com.kisaanconnect.controller;

import com.kisaanconnect.dao.BuyerDAO;
import com.kisaanconnect.dao.UserDAO;
import com.kisaanconnect.model.BuyerProfile;
import com.kisaanconnect.model.User;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet(name = "BuyerProfileServlet", urlPatterns = {
    "/buyer/profile",
    "/buyer/setup-profile"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class BuyerProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        BuyerDAO buyerDAO = new BuyerDAO();
        BuyerProfile profile = buyerDAO.getProfileByUserId(user.getUserId());

        request.setAttribute("buyerProfile", profile);
        request.getRequestDispatcher("/buyer/profile.jsp").forward(request, response);
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
        BuyerDAO buyerDAO = new BuyerDAO();
        BuyerProfile existingProfile = buyerDAO.getProfileByUserId(user.getUserId());

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String district = request.getParameter("district");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");

        if (address == null || address.trim().isEmpty()
                || city == null || city.trim().isEmpty()
                || district == null || district.trim().isEmpty()
                || state == null || state.trim().isEmpty()
                || pincode == null || pincode.trim().isEmpty()) {

            String errorMsg = URLEncoder.encode("Please fill in all required delivery address fields.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/buyer/profile?error=" + errorMsg);
            return;
        }

        // Update user full name / phone if provided
        if (fullName != null && !fullName.trim().isEmpty()) {
            user.setFullName(fullName.trim());
        }
        if (phone != null && !phone.trim().isEmpty()) {
            user.setPhone(phone.trim());
        }
        UserDAO userDAO = new UserDAO();
        userDAO.updateUser(user);
        session.setAttribute("loggedInUser", user);

        // Handle Photo Upload
        String photoUrl = (existingProfile != null) ? existingProfile.getProfilePhoto() : null;
        try {
            Part photoPart = request.getPart("profilePhoto");
            if (photoPart != null && photoPart.getSize() > 0) {
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "profiles";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String submittedFileName = photoPart.getSubmittedFileName();
                String extension = "";
                int dot = submittedFileName.lastIndexOf(".");
                if (dot != -1) {
                    extension = submittedFileName.substring(dot);
                }

                String newFileName = "buyer_" + user.getUserId() + "_" + System.currentTimeMillis() + extension;
                photoPart.write(uploadPath + File.separator + newFileName);
                photoUrl = "uploads/profiles/" + newFileName;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        BuyerProfile profile = new BuyerProfile();
        profile.setUserId(user.getUserId());
        profile.setProfilePhoto(photoUrl);
        profile.setAddress(address.trim());
        profile.setCity(city.trim());
        profile.setDistrict(district.trim());
        profile.setState(state.trim());
        profile.setPincode(pincode.trim());

        String latStr = request.getParameter("latitude");
        String lonStr = request.getParameter("longitude");
        Double lat = null;
        Double lon = null;
        if (latStr != null && !latStr.trim().isEmpty()) {
            try {
                double val = Double.parseDouble(latStr.trim());
                if (val >= -90.0 && val <= 90.0) lat = val;
            } catch (Exception ignored) {}
        }
        if (lonStr != null && !lonStr.trim().isEmpty()) {
            try {
                double val = Double.parseDouble(lonStr.trim());
                if (val >= -180.0 && val <= 180.0) lon = val;
            } catch (Exception ignored) {}
        }
        if (lat == null && existingProfile != null) lat = existingProfile.getLatitude();
        if (lon == null && existingProfile != null) lon = existingProfile.getLongitude();
        profile.setLatitude(lat);
        profile.setLongitude(lon);

        boolean success;
        if (existingProfile != null) {
            profile.setBuyerProfileId(existingProfile.getBuyerProfileId());
            success = buyerDAO.updateProfile(profile);
        } else {
            success = buyerDAO.saveProfile(profile);
        }

        if (success) {
            String msg = URLEncoder.encode("Profile and delivery address updated successfully!", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/buyer/profile?success=" + msg);
        } else {
            String msg = URLEncoder.encode("Failed to update profile. Please try again.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/buyer/profile?error=" + msg);
        }
    }
}
