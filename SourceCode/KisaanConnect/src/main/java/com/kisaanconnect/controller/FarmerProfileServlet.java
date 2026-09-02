package com.kisaanconnect.controller;

import com.kisaanconnect.dao.FarmerProfileDAO;
import com.kisaanconnect.model.FarmerProfile;
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

@WebServlet(name = "FarmerProfileServlet", urlPatterns = {
    "/farmer/profile",
    "/farmer/setup-profile"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class FarmerProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        FarmerProfileDAO profileDAO = new FarmerProfileDAO();
        FarmerProfile profile = profileDAO.getProfileByUserId(user.getUserId());

        String servletPath = request.getServletPath();
        if ("/farmer/setup-profile".equals(servletPath)) {
            if (profile != null) {
                // Existing farmer who already has a profile should view/edit their profile
                response.sendRedirect(request.getContextPath() + "/farmer/profile");
                return;
            }
            // New farmer without a profile
            request.getRequestDispatcher("/farmer/setup-profile.jsp").forward(request, response);
            return;
        }

        // For /farmer/profile
        if (profile == null) {
            // No profile found for farmer -> redirect to setup profile
            response.sendRedirect(request.getContextPath() + "/farmer/setup-profile.jsp");
            return;
        }

        request.setAttribute("farmerProfile", profile);
        request.getRequestDispatcher("/farmer/profile.jsp").forward(request, response);
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

        // Read Form Data
        String farmName = request.getParameter("farmName");
        String farmAddress = request.getParameter("farmAddress");
        String village = request.getParameter("village");
        String taluka = request.getParameter("taluka");
        String district = request.getParameter("district");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");

        Part profilePhotoPart = null;
        try {
            profilePhotoPart = request.getPart("profilePhoto");
        } catch (Exception ignored) {
        }

        // Handle Profile Photo Upload
        String profilePhotoPath = null;
        if (profilePhotoPart != null && profilePhotoPart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("")
                    + File.separator + "uploads"
                    + File.separator + "profile";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String originalFileName = profilePhotoPart.getSubmittedFileName();
            String extension = "";
            if (originalFileName != null && originalFileName.contains(".")) {
                extension = originalFileName.substring(originalFileName.lastIndexOf("."));
            }

            String newFileName = "user_" + user.getUserId() + "_" + System.currentTimeMillis() + extension;
            profilePhotoPart.write(uploadPath + File.separator + newFileName);
            profilePhotoPath = "uploads/profile/" + newFileName;
        }

        FarmerProfileDAO profileDAO = new FarmerProfileDAO();
        FarmerProfile existing = profileDAO.getProfileByUserId(user.getUserId());

        // Retain previous photo if no new one was provided
        if (profilePhotoPath == null && existing != null) {
            profilePhotoPath = existing.getProfilePhoto();
        }

        FarmerProfile profile = new FarmerProfile();
        profile.setUserId(user.getUserId());
        profile.setFarmName(farmName != null ? farmName.trim() : null);
        profile.setProfilePhoto(profilePhotoPath);
        profile.setFarmAddress(farmAddress != null ? farmAddress.trim() : null);
        profile.setVillage(village != null ? village.trim() : null);
        profile.setTaluka(taluka != null ? taluka.trim() : null);
        profile.setDistrict(district != null ? district.trim() : null);
        profile.setState(state != null ? state.trim() : null);
        profile.setPincode(pincode != null ? pincode.trim() : null);

        String latStr = request.getParameter("latitude");
        String lonStr = request.getParameter("longitude");
        if (latStr != null && !latStr.isEmpty()) {
            try { profile.setLatitude(Double.parseDouble(latStr.trim())); } catch (Exception ignored) {}
        }
        if (lonStr != null && !lonStr.isEmpty()) {
            try { profile.setLongitude(Double.parseDouble(lonStr.trim())); } catch (Exception ignored) {}
        }
        if (profile.getLatitude() == null && existing != null) {
            profile.setLatitude(existing.getLatitude());
        }
        if (profile.getLongitude() == null && existing != null) {
            profile.setLongitude(existing.getLongitude());
        }

        if (existing != null) {
            profile.setFarmerProfileId(existing.getFarmerProfileId());
            boolean success = profileDAO.updateProfile(profile);
            if (success) {
                session.setAttribute("farmerProfile", profile);
                String msg = URLEncoder.encode("Farm profile updated successfully!", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/farmer/profile?success=" + msg);
            } else {
                String msg = URLEncoder.encode("Unable to update farm profile. Please try again.", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/farmer/profile?error=" + msg);
            }
        } else {
            boolean success = profileDAO.saveProfile(profile);
            if (success) {
                session.setAttribute("farmerProfile", profile);
                String msg = URLEncoder.encode("Farm profile created successfully!", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/farmer/dashboard?success=" + msg);
            } else {
                String msg = URLEncoder.encode("Unable to save farm profile. Please try again.", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/farmer/setup-profile.jsp?error=" + msg);
            }
        }
    }
}