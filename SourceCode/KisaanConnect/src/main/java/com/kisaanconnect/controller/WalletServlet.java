package com.kisaanconnect.controller;

import com.kisaanconnect.dao.WalletDAO;
import com.kisaanconnect.model.User;
import com.kisaanconnect.model.Wallet;
import com.kisaanconnect.model.WalletTransaction;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "WalletServlet", urlPatterns = {
    "/wallet",
    "/farmer/wallet",
    "/commercial/wallet",
    "/buyer/wallet",
    "/wallet/topup"
})
public class WalletServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        WalletDAO walletDAO = new WalletDAO();
        Wallet wallet = walletDAO.getOrCreateWallet(user.getUserId());
        List<WalletTransaction> transactions = walletDAO.getTransactionsByWalletId(wallet.getWalletId());

        request.setAttribute("wallet", wallet);
        request.setAttribute("transactions", transactions);

        String servletPath = request.getServletPath();
        if ("/farmer/wallet".equals(servletPath) || "FARMER".equals(user.getRole())) {
            request.getRequestDispatcher("/farmer/wallet.jsp").forward(request, response);
        } else if ("/commercial/wallet".equals(servletPath) || "COMMERCIAL".equals(user.getRole())) {
            request.getRequestDispatcher("/commercial/wallet.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/buyer/wallet.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        String amountStr = request.getParameter("amount");

        if (amountStr != null && !amountStr.trim().isEmpty()) {
            try {
                BigDecimal amount = new BigDecimal(amountStr.trim());
                if (amount.compareTo(BigDecimal.ZERO) > 0) {
                    WalletDAO walletDAO = new WalletDAO();
                    walletDAO.creditWallet(user.getUserId(), amount, "TOP_UP", null, "Wallet Top-up");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        String target = "/buyer/wallet";
        if ("FARMER".equals(user.getRole())) target = "/farmer/wallet";
        else if ("COMMERCIAL".equals(user.getRole())) target = "/commercial/wallet";

        String msg = URLEncoder.encode("Wallet balance updated successfully!", StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + target + "?success=" + msg);
    }
}
