package com.kisaanconnect.controller;

import com.kisaanconnect.dao.*;
import com.kisaanconnect.model.*;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ReportServlet", urlPatterns = {
    "/farmer/reports",
    "/commercial/reports",
    "/buyer/reports",
    "/admin/reports"
})
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        String servletPath = request.getServletPath();
        ReportDAO reportDAO = new ReportDAO();
        WalletDAO walletDAO = new WalletDAO();
        OrderDAO orderDAO = new OrderDAO();

        if ("/farmer/reports".equals(servletPath)) {
            FarmerProfileDAO fpDAO = new FarmerProfileDAO();
            FarmerProfile fp = fpDAO.getProfileByUserId(user.getUserId());
            if (fp != null) {
                Map<String, Object> salesReport = reportDAO.getFarmerSalesReport(fp.getFarmerProfileId());
                List<Map<String, Object>> inventoryReport = reportDAO.getFarmerInventoryReport(fp.getFarmerProfileId());
                List<Map<String, Object>> detailedEarnings = reportDAO.getFarmerEarningsDetailed(fp.getFarmerProfileId());
                List<SubOrder> subOrders = orderDAO.getFarmerSubOrders(fp.getFarmerProfileId(), "ALL");
                List<Order> orders = orderDAO.getOrdersForFarmer(fp.getFarmerProfileId());
                request.setAttribute("report", salesReport);
                request.setAttribute("inventoryReport", inventoryReport);
                request.setAttribute("detailedEarnings", detailedEarnings);
                request.setAttribute("subOrders", subOrders);
                request.setAttribute("orders", orders);
                request.setAttribute("farmerProfile", fp);
            }
            Wallet wallet = walletDAO.getOrCreateWallet(user.getUserId());
            List<WalletTransaction> transactions = wallet != null
                    ? walletDAO.getTransactionsByWalletId(wallet.getWalletId())
                    : Collections.emptyList();
            request.setAttribute("transactions", transactions);
            request.setAttribute("wallet", wallet);
            request.getRequestDispatcher("/farmer/reports.jsp").forward(request, response);

        } else if ("/commercial/reports".equals(servletPath)) {
            OrganizationDAO orgDAO = new OrganizationDAO();
            Organization org = orgDAO.getOrganizationByUserId(user.getUserId());
            if (org != null) {
                Map<String, Object> procReport = reportDAO.getCommercialProcurementReport(org.getOrganizationId());
                List<Map<String, Object>> suppliers = reportDAO.getCommercialSupplierSummary(org.getOrganizationId());
                List<Order> orders = orderDAO.getOrdersByOrganizationId(org.getOrganizationId());
                request.setAttribute("report", procReport);
                request.setAttribute("suppliers", suppliers);
                request.setAttribute("orders", orders);
                request.setAttribute("organization", org);
            }
            Wallet wallet = walletDAO.getOrCreateWallet(user.getUserId());
            List<WalletTransaction> transactions = wallet != null
                    ? walletDAO.getTransactionsByWalletId(wallet.getWalletId())
                    : Collections.emptyList();
            request.setAttribute("transactions", transactions);
            request.setAttribute("wallet", wallet);
            request.getRequestDispatcher("/commercial/reports.jsp").forward(request, response);

        } else if ("/buyer/reports".equals(servletPath)) {
            BuyerDAO buyerDAO = new BuyerDAO();
            BuyerProfile bp = buyerDAO.getProfileByUserId(user.getUserId());
            Map<String, Object> buyerReport = reportDAO.getBuyerSpendingReport(user.getUserId());
            List<Order> orders = (bp != null) ? orderDAO.getOrdersByBuyerProfileId(bp.getBuyerProfileId()) : Collections.emptyList();
            
            request.setAttribute("report", buyerReport);
            request.setAttribute("orders", orders);
            request.setAttribute("buyerProfile", bp);

            Wallet wallet = walletDAO.getOrCreateWallet(user.getUserId());
            List<WalletTransaction> transactions = wallet != null
                    ? walletDAO.getTransactionsByWalletId(wallet.getWalletId())
                    : Collections.emptyList();
            request.setAttribute("transactions", transactions);
            request.setAttribute("wallet", wallet);
            request.getRequestDispatcher("/buyer/reports.jsp").forward(request, response);

        } else if ("/admin/reports".equals(servletPath)) {
            String range = request.getParameter("range");
            if (range == null || range.trim().isEmpty()) {
                range = "all";
            }
            range = range.trim().toLowerCase();
            if (!range.equals("7d") && !range.equals("30d") && !range.equals("90d") && !range.equals("1y") && !range.equals("all")) {
                range = "all";
            }

            Map<String, Object> adminAnalytics = reportDAO.getAdminPlatformAnalytics(range);
            List<Map<String, Object>> gmvTrend = reportDAO.getAdminGMVTrend(range);
            Map<String, Integer> statusBreakdown = reportDAO.getAdminOrderStatusBreakdown(range);
            List<Map<String, Object>> topProducts = reportDAO.getAdminTopProducts(10);
            List<Map<String, Object>> recentActivity = reportDAO.getAdminRecentActivity(15);
            List<WalletTransaction> allTxns = reportDAO.getAllPlatformTransactions();

            request.setAttribute("report", adminAnalytics);
            request.setAttribute("analytics", adminAnalytics);
            request.setAttribute("gmvTrend", gmvTrend);
            request.setAttribute("statusBreakdown", statusBreakdown);
            request.setAttribute("topProducts", topProducts);
            request.setAttribute("recentActivity", recentActivity);
            request.setAttribute("transactions", allTxns);
            request.setAttribute("selectedRange", range);
            request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
        }
    }
}
