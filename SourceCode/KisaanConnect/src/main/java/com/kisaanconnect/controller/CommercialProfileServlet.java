package com.kisaanconnect.controller;

import com.kisaanconnect.dao.OrganizationDAO;
import com.kisaanconnect.model.Organization;
import com.kisaanconnect.model.OrganizationMember;
import com.kisaanconnect.model.OrganizationType;
import com.kisaanconnect.model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "CommercialProfileServlet", urlPatterns = {
    "/commercial/profile",
    "/commercial/setup-profile"
})
public class CommercialProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        OrganizationDAO orgDAO = new OrganizationDAO();
        Organization org = orgDAO.getOrganizationByUserId(user.getUserId());

        String servletPath = request.getServletPath();

        if ("/commercial/setup-profile".equals(servletPath)) {
            if (org != null) {
                response.sendRedirect(request.getContextPath() + "/commercial/profile");
                return;
            }
            List<OrganizationType> orgTypes = orgDAO.getActiveOrganizationTypes();
            request.setAttribute("orgTypes", orgTypes);
            request.getRequestDispatcher("/commercial/setup-profile.jsp").forward(request, response);
            return;
        }

        // For /commercial/profile
        if (org == null) {
            response.sendRedirect(request.getContextPath() + "/commercial/setup-profile");
            return;
        }

        List<OrganizationType> orgTypes = orgDAO.getActiveOrganizationTypes();
        List<OrganizationMember> members = orgDAO.getOrganizationMembers(org.getOrganizationId());

        request.setAttribute("organization", org);
        request.setAttribute("orgTypes", orgTypes);
        request.setAttribute("members", members);

        request.getRequestDispatcher("/commercial/profile.jsp").forward(request, response);
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
        OrganizationDAO orgDAO = new OrganizationDAO();
        Organization existingOrg = orgDAO.getOrganizationByUserId(user.getUserId());

        String orgName = request.getParameter("orgName");
        String orgTypeIdStr = request.getParameter("orgTypeId");
        String gstin = request.getParameter("gstin");
        String panNumber = request.getParameter("panNumber");
        String businessEmail = request.getParameter("businessEmail");
        String businessPhone = request.getParameter("businessPhone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String district = request.getParameter("district");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");

        if (orgName == null || orgName.trim().isEmpty()
                || orgTypeIdStr == null || orgTypeIdStr.trim().isEmpty()
                || businessEmail == null || businessEmail.trim().isEmpty()
                || businessPhone == null || businessPhone.trim().isEmpty()
                || address == null || address.trim().isEmpty()
                || city == null || city.trim().isEmpty()
                || district == null || district.trim().isEmpty()
                || state == null || state.trim().isEmpty()
                || pincode == null || pincode.trim().isEmpty()) {

            String errorMsg = URLEncoder.encode("Please fill in all required organization fields.", StandardCharsets.UTF_8);
            String target = (existingOrg != null) ? "/commercial/profile" : "/commercial/setup-profile";
            response.sendRedirect(request.getContextPath() + target + "?error=" + errorMsg);
            return;
        }

        int orgTypeId = Integer.parseInt(orgTypeIdStr);

        Organization org = new Organization();
        org.setOwnerUserId(user.getUserId());
        org.setOrgTypeId(orgTypeId);
        org.setOrgName(orgName.trim());
        org.setGstin(gstin != null && !gstin.trim().isEmpty() ? gstin.trim().toUpperCase() : null);
        org.setPanNumber(panNumber != null && !panNumber.trim().isEmpty() ? panNumber.trim().toUpperCase() : null);
        org.setBusinessEmail(businessEmail.trim().toLowerCase());
        org.setBusinessPhone(businessPhone.trim());
        org.setAddress(address.trim());
        org.setCity(city.trim());
        org.setDistrict(district.trim());
        org.setState(state.trim());
        org.setPincode(pincode.trim());
        org.setStatus("ACTIVE");

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
        if (lat == null && existingOrg != null) lat = existingOrg.getLatitude();
        if (lon == null && existingOrg != null) lon = existingOrg.getLongitude();
        org.setLatitude(lat);
        org.setLongitude(lon);

        if (existingOrg != null) {
            org.setOrganizationId(existingOrg.getOrganizationId());
            boolean updated = orgDAO.updateOrganization(org);
            if (updated) {
                session.setAttribute("organization", org);
                String msg = URLEncoder.encode("Organisation profile updated successfully!", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/commercial/profile?success=" + msg);
            } else {
                String msg = URLEncoder.encode("Failed to update organisation profile. Please try again.", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/commercial/profile?error=" + msg);
            }
        } else {
            boolean saved = orgDAO.saveOrganization(org);
            if (saved) {
                session.setAttribute("organization", org);
                String msg = URLEncoder.encode("Organisation registered successfully!", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/commercial/dashboard?success=" + msg);
            } else {
                String errorMsg = URLEncoder.encode("Unable to save organization profile. Please try again.", StandardCharsets.UTF_8);
                response.sendRedirect(request.getContextPath() + "/commercial/setup-profile?error=" + errorMsg);
            }
        }
    }
}
