<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.WalletTransaction"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    Wallet wallet = (Wallet) request.getAttribute("wallet");
    List<WalletTransaction> transactions = (List<WalletTransaction>) request.getAttribute("transactions");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Farmer Wallet & Earnings | KisaanConnect</title>

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
        .balance-card {
            background: linear-gradient(135deg, #1B5E20, #2E7D32);
            color: white;
            padding: 30px;
            border-radius: 22px;
            box-shadow: 0 15px 35px rgba(46,125,50,0.25);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .txn-card {
            background: white;
            border-radius: 20px;
            padding: 26px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            margin-top: 24px;
        }

        .txn-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .txn-table th {
            text-align: left;
            padding: 14px 16px;
            background: #F9FAFB;
            color: #4B5563;
            font-weight: 600;
            border-bottom: 2px solid #E5E7EB;
        }

        .txn-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #F3F4F6;
        }

        .badge-credit {
            background: #DEF7EC;
            color: #03543F;
            padding: 4px 10px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 12px;
        }

        .badge-debit {
            background: #FDE8E8;
            color: #9B1C1C;
            padding: 4px 10px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 12px;
        }

        @media print {
            .sidebar, .top-navbar, .no-print, button, .alert-container {
                display: none !important;
            }
            body {
                background: #FFFFFF !important;
                color: #000000 !important;
                margin: 0 !important;
                padding: 0 !important;
            }
            .main-content {
                margin-left: 0 !important;
                width: 100% !important;
                padding: 0 !important;
            }
            .dashboard-content {
                padding: 10px 0 !important;
            }
            .balance-card, .txn-card {
                border: 1px solid #D1D5DB !important;
                box-shadow: none !important;
                color: #000000 !important;
                background: #F9FAFB !important;
            }
        }
    </style>
</head>

<body>

    <%@ include file="/includes/farmer-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/farmer-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-wallet"></i> Farmer Wallet & Earnings</h1>
                    <p style="color: #6B7280; font-size: 14px;">Instant settlement records, earnings ledger, and bank withdrawal history.</p>
                </div>
                <button onclick="window.print();" class="no-print" style="background: #1F6F43; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-print"></i> Print Wallet Statement
                </button>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- Balance Card -->
            <div class="balance-card">
                <div>
                    <span style="opacity: 0.85; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;">Available Settlement Balance</span>
                    <h2 style="font-size: 38px; font-weight: 800; margin: 6px 0;">₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %></h2>
                    <div style="font-size: 13px; opacity: 0.9;">Total Earnings: ₹<%= wallet != null ? wallet.getTotalCredited() : "0.00" %></div>
                </div>

                <div style="display: flex; gap: 12px;">
                    <button style="background: white; color: #2E7D32; border: none; padding: 12px 24px; border-radius: 12px; font-weight: 700; cursor: pointer;" onclick="alert('Bank Withdrawal feature: Direct payout to registered account initiated!')">
                        🏦 Withdraw to Bank
                    </button>
                </div>
            </div>

            <!-- Transaction Ledger -->
            <div class="txn-card">
                <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;">Ledger History</h3>

                <% if (transactions == null || transactions.isEmpty()) { %>
                    <p style="text-align: center; color: #6B7280; padding: 30px 0;">No wallet transactions found.</p>
                <% } else { %>
                    <table class="txn-table">
                        <thead>
                            <tr>
                                <th>Ref #</th>
                                <th>Date</th>
                                <th>Source</th>
                                <th>Remarks</th>
                                <th>Type</th>
                                <th>Amount</th>
                                <th>Balance After</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (WalletTransaction txn : transactions) { %>
                                <tr>
                                    <td><code><%= txn.getTxnReferenceNo() %></code></td>
                                    <td><%= txn.getTransactionDate() %></td>
                                    <td><strong><%= txn.getTransactionSource() %></strong></td>
                                    <td><%= txn.getRemarks() != null ? txn.getRemarks() : "-" %></td>
                                    <td>
                                        <% if ("CREDIT".equalsIgnoreCase(txn.getTransactionType())) { %>
                                            <span class="badge-credit">+ CREDIT</span>
                                        <% } else { %>
                                            <span class="badge-debit">- DEBIT</span>
                                        <% } %>
                                    </td>
                                    <td style="font-weight: 700; color: <%= "CREDIT".equalsIgnoreCase(txn.getTransactionType()) ? "#03543F" : "#9B1C1C" %>;">
                                        <%= "CREDIT".equalsIgnoreCase(txn.getTransactionType()) ? "+" : "-" %>₹<%= txn.getAmount() %>
                                    </td>
                                    <td>₹<%= txn.getBalanceAfter() %></td>
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
