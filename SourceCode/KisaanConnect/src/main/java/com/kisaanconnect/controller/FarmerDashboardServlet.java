package com.kisaanconnect.controller;

import com.kisaanconnect.dao.FarmerProfileDAO;
import com.kisaanconnect.model.FarmerProfile;
import com.kisaanconnect.model.User;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(
    name = "FarmerDashboardServlet",
    urlPatterns = {"/farmer/dashboard"}
)
public class FarmerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                    request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");

        if (user == null) {

            response.sendRedirect(
                    request.getContextPath() + "/auth/login.jsp");
            return;
        }

        FarmerProfileDAO profileDAO = new FarmerProfileDAO();

        FarmerProfile profile =
                profileDAO.getProfileByUserId(user.getUserId());

        request.setAttribute("profile", profile);

        request.getRequestDispatcher("/farmer/dashboard.jsp")
                .forward(request, response);

    }

}