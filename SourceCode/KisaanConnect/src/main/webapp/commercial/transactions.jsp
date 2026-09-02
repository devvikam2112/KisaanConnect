<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.WalletTransaction"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    WalletDAO walletDAO = new WalletDAO();
    Wallet wallet = walletDAO.getOrCreateWallet(loggedInUser.getUserId());
    List<WalletTransaction> transactions = (wallet != null) ? walletDAO.getTransactionsByWalletId(wallet.getWalletId()) : null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Ledger | KisaanConnect Commercial</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">

    <style>
        .txn-table {
            width: 100%;
            border-collapse: collapse;
        }

        .txn-table th {
            text-align: left;
            padding: 14px 16px;
            background: #F9FAFB;
            color: #4B5563;
            font-size: 13px;
            font-weight: 600;
            border-bottom: 2px solid #E5E7EB;
        }

        .txn-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #F3F4F6;
            font-size: 14px;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/commercial-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/commercial-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-credit-card"></i> Corporate Payment Ledger</h1>
                    <p style="color: #6B7280; font-size: 14px;">Detailed transaction history and audit trail for commercial transactions.</p>
                </div>
                <div style="background: white; border: 1px solid #E5E7EB; padding: 10px 20px; border-radius: 12px;">
                    <span style="font-size: 12px; color: #6B7280;">Wallet Balance:</span>
                    <strong style="font-size: 18px; color: #1E40AF; margin-left: 8px;">₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %></strong>
                </div>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <div style="background: white; border-radius: 20px; padding: 26px; border: 1px solid #E5E7EB; box-shadow: 0 8px 24px rgba(0,0,0,0.05);">
                <% if (transactions == null || transactions.isEmpty()) { %>
                    <p style="color: #6B7280; text-align: center; padding: 40px 0;">No ledger transactions recorded yet.</p>
                <% } else { %>
                    <table class="txn-table">
                        <thead>
                            <tr>
                                <th>Txn Ref / ID</th>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Source</th>
                                <th>Amount</th>
                                <th>Balance After</th>
                                <th>Status</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (WalletTransaction txn : transactions) { %>
                                <tr>
                                    <td><code><%= txn.getTxnReferenceNo() %></code></td>
                                    <td><%= txn.getTransactionDate() %></td>
                                    <td>
                                        <span style="font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 6px; <%= "CREDIT".equals(txn.getTransactionType()) ? "background: #E8F5E9; color: #2E7D32;" : "background: #FEE2E2; color: #991B1B;" %>">
                                            <%= txn.getTransactionType() %>
                                        </span>
                                    </td>
                                    <td><%= txn.getTransactionSource() %></td>
                                    <td style="font-weight: 700; <%= "CREDIT".equals(txn.getTransactionType()) ? "color: #2E7D32;" : "color: #DC2626;" %>">
                                        <%= "CREDIT".equals(txn.getTransactionType()) ? "+₹" : "-₹" %><%= txn.getAmount() %>
                                    </td>
                                    <td>₹<%= txn.getBalanceAfter() %></td>
                                    <td>
                                        <span style="font-size: 11px; font-weight: 600; color: #059669;">
                                            <%= txn.getStatus() %>
                                        </span>
                                    </td>
                                    <td style="font-size: 12px; color: #6B7280;"><%= txn.getRemarks() != null ? txn.getRemarks() : "-" %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

        </div>

    </div>

</body>
</html>
