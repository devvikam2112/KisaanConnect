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

    Wallet wallet = (Wallet) request.getAttribute("wallet");
    List<WalletTransaction> transactions = (List<WalletTransaction>) request.getAttribute("transactions");

    if (wallet == null) {
        WalletDAO wDAO = new WalletDAO();
        wallet = wDAO.getOrCreateWallet(loggedInUser.getUserId());
        if (wallet != null) {
            transactions = wDAO.getTransactionsByWalletId(wallet.getWalletId());
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Wallet & Payment History | KisaanConnect Buyer</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .wallet-banner {
            background: linear-gradient(135deg, #1B5E20, #2E7D32);
            color: white;
            padding: 35px 0 45px 0;
            border-radius: 0 0 25px 25px;
            margin-bottom: 30px;
        }

        .balance-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        .table-custom {
            width: 100%;
            border-collapse: collapse;
        }

        .table-custom th {
            background: #F9FAFB;
            color: #4B5563;
            font-size: 13px;
            font-weight: 600;
            padding: 12px 16px;
            border-bottom: 2px solid #E5E7EB;
        }

        .table-custom td {
            padding: 14px 16px;
            font-size: 14px;
            color: #1F2937;
            border-bottom: 1px solid #F3F4F6;
            vertical-align: middle;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="wallet-banner">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="h3 fw-bold mb-1"><i class="fa-solid fa-wallet"></i> KisaanConnect Wallet</h1>
                    <p class="mb-0 opacity-90 small">Quick 1-click checkout for farm-fresh produce and digital payment ledger.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="container pb-5">

        <%@ include file="/includes/alerts.jsp" %>

        <!-- Balance & Top-up Row -->
        <div class="row g-4 mb-4">
            <div class="col-lg-6">
                <div class="balance-card h-100 d-flex flex-column justify-content-between">
                    <div>
                        <span class="text-muted small">Available Spend Balance</span>
                        <h2 class="display-6 fw-bold text-success mt-1 mb-3">
                            ₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %>
                        </h2>
                    </div>

                    <div class="row g-2 pt-3 border-top">
                        <div class="col-6">
                            <span class="text-muted small">Total Added:</span>
                            <div class="fw-bold text-dark">₹<%= wallet != null ? wallet.getTotalCredited() : "0.00" %></div>
                        </div>
                        <div class="col-6">
                            <span class="text-muted small">Total Spent:</span>
                            <div class="fw-bold text-dark">₹<%= wallet != null ? wallet.getTotalDebited() : "0.00" %></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="balance-card h-100">
                    <h5 class="fw-bold text-dark mb-3"><i class="fa-solid fa-plus"></i> Add Money to Wallet</h5>
                    <form action="${pageContext.request.contextPath}/wallet/topup" method="post">
                        <div class="mb-3">
                            <label class="form-label text-muted small">Amount to Add (₹) *</label>
                            <input type="number"
                                   step="1"
                                   min="10"
                                   max="50000"
                                   name="amount"
                                   class="form-control form-control-lg rounded-3"
                                   placeholder="e.g. 500"
                                   required>
                        </div>
                        <div class="d-flex gap-2 mb-3">
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-3" onclick="document.getElementsByName('amount')[0].value=200;">+₹200</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-3" onclick="document.getElementsByName('amount')[0].value=500;">+₹500</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-3" onclick="document.getElementsByName('amount')[0].value=1000;">+₹1000</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-3" onclick="document.getElementsByName('amount')[0].value=2000;">+₹2000</button>
                        </div>
                        <button type="submit" class="btn btn-success w-100 py-2 rounded-3 fw-semibold">
                            <i class="fa-solid fa-credit-card"></i> Add Funds (Instant Top-up)
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Transaction History -->
        <div class="card border-0 rounded-4 shadow-sm p-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold text-dark mb-0">📜 Transaction & Payment History</h5>
                <a href="${pageContext.request.contextPath}/buyer/reports" class="btn btn-outline-secondary btn-sm rounded-3">
                    View Full Reports →
                </a>
            </div>

            <% if (transactions == null || transactions.isEmpty()) { %>
                <p class="text-muted text-center py-4 mb-0">No wallet transactions found.</p>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table-custom">
                        <thead>
                            <tr>
                                <th>Txn Ref / ID</th>
                                <th>Date & Time</th>
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
                                        <span class="badge <%= "CREDIT".equals(txn.getTransactionType()) ? "bg-success-subtle text-success" : "bg-danger-subtle text-danger" %> px-2 py-1">
                                            <%= txn.getTransactionType() %>
                                        </span>
                                    </td>
                                    <td><%= txn.getTransactionSource() %></td>
                                    <td class="fw-bold <%= "CREDIT".equals(txn.getTransactionType()) ? "text-success" : "text-danger" %>">
                                        <%= "CREDIT".equals(txn.getTransactionType()) ? "+₹" : "-₹" %><%= txn.getAmount() %>
                                    </td>
                                    <td>₹<%= txn.getBalanceAfter() %></td>
                                    <td>
                                        <span class="badge bg-success-subtle text-success">
                                            <%= txn.getStatus() %>
                                        </span>
                                    </td>
                                    <td class="text-muted small"><%= txn.getRemarks() != null ? txn.getRemarks() : "-" %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

    </div>

</body>
</html>
