package com.kisaanconnect.controller;

import com.kisaanconnect.dao.CategoryDAO;
import com.kisaanconnect.dao.OrderDAO;
import com.kisaanconnect.dao.OrganizationDAO;
import com.kisaanconnect.dao.ReportDAO;
import com.kisaanconnect.dao.WalletDAO;
import com.kisaanconnect.model.Category;
import com.kisaanconnect.model.Order;
import com.kisaanconnect.model.Organization;
import com.kisaanconnect.model.User;
import com.kisaanconnect.model.Wallet;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "CommercialDashboardServlet", urlPatterns = {"/commercial/dashboard"})
public class CommercialDashboardServlet extends HttpServlet {

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

        Organization org = orgDAO.getOrganizationByOwnerUserId(user.getUserId());
        if (org == null) {
            org = orgDAO.getOrganizationByMemberUserId(user.getUserId());
        }

        if (org == null) {
            response.sendRedirect(request.getContextPath() + "/commercial/setup-profile");
            return;
        }

        ReportDAO reportDAO = new ReportDAO();
        Map<String, Object> report = reportDAO.getCommercialProcurementReport(org.getOrganizationId());

        WalletDAO walletDAO = new WalletDAO();
        Wallet wallet = walletDAO.getOrCreateWallet(user.getUserId());

        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getOrdersByOrganizationId(org.getOrganizationId());

        CategoryDAO categoryDAO = new CategoryDAO();
        List<Category> categories = categoryDAO.getActiveCategories();

        request.setAttribute("organization", org);
        request.setAttribute("report", report);
        request.setAttribute("wallet", wallet);
        request.setAttribute("orders", orders);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/commercial/dashboard.jsp").forward(request, response);
    }
}
