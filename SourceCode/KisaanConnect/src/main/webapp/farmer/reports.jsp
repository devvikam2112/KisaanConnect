<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.FarmerProfile"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.WalletTransaction"%>
<%@page import="com.kisaanconnect.model.SubOrder"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.dao.FarmerProfileDAO"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>
<%@page import="com.kisaanconnect.dao.ReportDAO"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    Map<String, Object> report = (Map<String, Object>) request.getAttribute("report");
    List<Map<String, Object>> inventoryReport = (List<Map<String, Object>>) request.getAttribute("inventoryReport");
    List<Map<String, Object>> detailedEarnings = (List<Map<String, Object>>) request.getAttribute("detailedEarnings");
    List<SubOrder> subOrders = (List<SubOrder>) request.getAttribute("subOrders");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    List<WalletTransaction> transactions = (List<WalletTransaction>) request.getAttribute("transactions");
    Wallet wallet = (Wallet) request.getAttribute("wallet");
    FarmerProfile fp = (FarmerProfile) request.getAttribute("farmerProfile");

    if (loggedInUser != null) {
        FarmerProfileDAO fpDAO = new FarmerProfileDAO();
        if (fp == null) fp = fpDAO.getProfileByUserId(loggedInUser.getUserId());

        if (fp != null) {
            ReportDAO rDAO = new ReportDAO();
            if (report == null) report = rDAO.getFarmerSalesReport(fp.getFarmerProfileId());
            if (inventoryReport == null) inventoryReport = rDAO.getFarmerInventoryReport(fp.getFarmerProfileId());
            if (detailedEarnings == null) detailedEarnings = rDAO.getFarmerEarningsDetailed(fp.getFarmerProfileId());
            if (subOrders == null) {
                OrderDAO oDAO = new OrderDAO();
                subOrders = oDAO.getFarmerSubOrders(fp.getFarmerProfileId(), "ALL");
            }
        }
        if (wallet == null || transactions == null) {
            WalletDAO wDAO = new WalletDAO();
            if (wallet == null) wallet = wDAO.getOrCreateWallet(loggedInUser.getUserId());
            if (transactions == null && wallet != null) {
                transactions = wDAO.getTransactionsByWalletId(wallet.getWalletId());
            }
        }
    }

    List<Map<String, Object>> topCrops = (report != null) ? (List<Map<String, Object>>) report.get("topCrops") : null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Farmer Reports & Analytics | KisaanConnect</title>

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
        .report-tabs {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            border-bottom: 2px solid #E5E7EB;
            margin-bottom: 24px;
            padding-bottom: 8px;
        }

        .tab-btn {
            background: #F3F4F6;
            color: #4B5563;
            border: none;
            padding: 10px 16px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: 0.2s ease;
        }

        .tab-btn:hover {
            background: #E5E7EB;
            color: #1F2937;
        }

        .tab-btn.active {
            background: #1F6F43;
            color: white;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .report-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }

        .report-card {
            background: white;
            padding: 22px;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        .report-table-container {
            background: white;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            padding: 24px;
            margin-bottom: 24px;
            overflow-x: auto;
        }

        .report-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .report-table th {
            text-align: left;
            padding: 12px 14px;
            background: #F9FAFB;
            color: #4B5563;
            font-weight: 600;
            border-bottom: 2px solid #E5E7EB;
        }

        .report-table td {
            padding: 12px 14px;
            border-bottom: 1px solid #F3F4F6;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-success { background: #DEF7EC; color: #03543F; }
        .badge-warning { background: #FEF08A; color: #854D0E; }
        .badge-danger { background: #FDE8E8; color: #9B1C1C; }
        .badge-info { background: #DBEAFE; color: #1E40AF; }

        @media print {
            .sidebar, .top-navbar, .no-print, .report-tabs, button, .alert-container {
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
            .print-header {
                display: block !important;
                margin-bottom: 20px;
                border-bottom: 2px solid #2E7D32;
                padding-bottom: 10px;
            }
            .tab-content {
                display: block !important;
                page-break-after: always;
            }
            .report-card, .report-table-container {
                border: 1px solid #D1D5DB !important;
                box-shadow: none !important;
            }
        }

        .print-header {
            display: none;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/farmer-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/farmer-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <!-- Print Header -->
            <div class="print-header">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <img src="${pageContext.request.contextPath}/assets/images/logo.png" style="height: 50px;" alt="KisaanConnect">
                        <h2 style="color: #2E7D32; margin: 4px 0;">Farmer Comprehensive Business & Financial Report</h2>
                    </div>
                    <div style="text-align: right; font-size: 13px; color: #4B5563;">
                        Generated: <%= new java.util.Date() %><br>
                        Farmer: <%= loggedInUser != null ? loggedInUser.getFullName() : "Farmer" %>
                    </div>
                </div>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 20px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-chart-line"></i> Farm Reports & Analytics</h1>
                    <p style="color: #6B7280; font-size: 14px;">Complete transparent breakdown of crop sales, stock movement, wallet payouts, and cash/UPI earnings.</p>
                </div>
                <button onclick="window.print();" class="no-print" style="background: #1F6F43; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-print"></i> Print Statement
                </button>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- 8 Distinct Report Navigation Tabs -->
            <div class="report-tabs no-print">
                <button class="tab-btn active" onclick="showTab('tab-orders', this)"><i class="fa-solid fa-clipboard-list"></i> 1. Customer Orders</button>
                <button class="tab-btn" onclick="showTab('tab-sales', this)"><i class="fa-solid fa-wheat-awn"></i> 2. Sales & Revenue</button>
                <button class="tab-btn" onclick="showTab('tab-inventory', this)"><i class="fa-solid fa-boxes-stacked"></i> 3. Stock Movement</button>
                <button class="tab-btn" onclick="showTab('tab-topups', this)"><i class="fa-solid fa-wallet"></i> 4. Wallet Top-Ups</button>
                <button class="tab-btn" onclick="showTab('tab-transactions', this)"><i class="fa-solid fa-receipt"></i> 5. Wallet Ledger</button>
                <button class="tab-btn" onclick="showTab('tab-cash-upi', this)"><i class="fa-solid fa-money-bill-wave"></i> 6. Cash & UPI Earnings</button>
                <button class="tab-btn" onclick="showTab('tab-earnings', this)"><i class="fa-solid fa-hand-holding-dollar"></i> 7. Earnings Summary</button>
                <button class="tab-btn" onclick="showTab('tab-delivery', this)"><i class="fa-solid fa-truck"></i> 8. Delivery Status</button>
            </div>

            <!-- TAB 1: CUSTOMER ORDERS REPORT -->
            <div id="tab-orders" class="tab-content active">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Orders Received</div>
                        <div style="font-size: 26px; font-weight: 700; color: #1F2937; margin-top: 4px;"><%= subOrders != null ? subOrders.size() : 0 %></div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Gross Farmer Revenue</div>
                        <div style="font-size: 26px; font-weight: 700; color: #2E7D32; margin-top: 4px;">
                            ₹<%= (report != null && report.get("totalRevenue") != null) ? report.get("totalRevenue") : "0.00" %>
                        </div>
                    </div>
                </div>

                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-clipboard-list"></i> Customer Orders Summary</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Sub-Order #</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Produce Items</th>
                                <th>Farmer Total (₹)</th>
                                <th>Payment Mode</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (subOrders == null || subOrders.isEmpty()) { %>
                                <tr><td colspan="7" style="text-align: center; color: #9CA3AF; padding: 24px;">No customer orders found.</td></tr>
                            <% } else {
                                for (SubOrder so : subOrders) { %>
                                    <tr>
                                        <td><strong>#<%= so.getSubOrderNumber() %></strong></td>
                                        <td><%= so.getCreatedAt() %></td>
                                        <td><%= so.getDeliveryName() != null ? so.getDeliveryName() : so.getBuyerName() %></td>
                                        <td>
                                            <% if (so.getItems() != null) {
                                                for (OrderItem itm : so.getItems()) { %>
                                                    <div><i class="fa-solid fa-wheat-awn"></i> <%= itm.getProductName() %> (<%= itm.getQuantity() %> <%= itm.getUnit() != null ? itm.getUnit() : "kg" %>)</div>
                                            <%  }
                                               } %>
                                        </td>
                                        <td style="font-weight: 700; color: #2E7D32;">₹<%= so.getTotalAmount() %></td>
                                        <td><span class="status-badge badge-info"><%= so.getPaymentMethod() %></span></td>
                                        <td><span class="status-badge badge-success"><%= so.getSubOrderStatus() %></span></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 2: SALES & REVENUE REPORT -->
            <div id="tab-sales" class="tab-content">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Revenue</div>
                        <div style="font-size: 26px; font-weight: 700; color: #2E7D32; margin-top: 4px;">
                            ₹<%= (report != null && report.get("totalRevenue") != null) ? report.get("totalRevenue") : "0.00" %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Quantity Sold</div>
                        <div style="font-size: 26px; font-weight: 700; color: #1F2937; margin-top: 4px;">
                            <%= (report != null && report.get("totalUnitsSold") != null) ? report.get("totalUnitsSold") : "0" %> Units
                        </div>
                    </div>
                </div>

                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-wheat-awn"></i> Top Selling Crop Varieties</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Crop Variety</th>
                                <th>Unit</th>
                                <th>Quantity Sold</th>
                                <th>Revenue Earned (₹)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (topCrops == null || topCrops.isEmpty()) { %>
                                <tr><td colspan="4" style="text-align: center; color: #9CA3AF; padding: 24px;">No produce sales recorded yet.</td></tr>
                            <% } else {
                                for (Map<String, Object> crop : topCrops) { %>
                                    <tr>
                                        <td><strong><%= crop.get("productName") %></strong></td>
                                        <td><%= crop.get("unit") %></td>
                                        <td><%= crop.get("quantitySold") %></td>
                                        <td style="font-weight: 700; color: #2E7D32;">₹<%= crop.get("revenue") %></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 3: STOCK & INVENTORY MOVEMENT -->
            <div id="tab-inventory" class="tab-content">
                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-boxes-stacked"></i> Produce Inventory & Stock Audit</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Produce Name</th>
                                <th>Category</th>
                                <th>Price / Unit (₹)</th>
                                <th>Available Stock</th>
                                <th>Units Sold</th>
                                <th>Total Sales Value (₹)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (inventoryReport == null || inventoryReport.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center; color: #9CA3AF; padding: 24px;">No inventory records available.</td></tr>
                            <% } else {
                                for (Map<String, Object> inv : inventoryReport) { %>
                                    <tr>
                                        <td><strong><%= inv.get("productName") %></strong></td>
                                        <td><%= inv.get("categoryName") %></td>
                                        <td>₹<%= inv.get("price") %> / <%= inv.get("unit") %></td>
                                        <td style="font-weight: 700; color: #047857;"><%= inv.get("availableStock") %> <%= inv.get("unit") %></td>
                                        <td><%= inv.get("unitsSold") %> <%= inv.get("unit") %></td>
                                        <td style="font-weight: 700; color: #2E7D32;">₹<%= inv.get("totalSalesValue") %></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 4: WALLET TOP-UPS -->
            <div id="tab-topups" class="tab-content">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Current Wallet Balance</div>
                        <div style="font-size: 26px; font-weight: 700; color: #2E7D32; margin-top: 4px;">
                            ₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Payouts / Credits</div>
                        <div style="font-size: 26px; font-weight: 700; color: #047857; margin-top: 4px;">
                            ₹<%= wallet != null ? wallet.getTotalCredited() : "0.00" %>
                        </div>
                    </div>
                </div>

                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-wallet"></i> Wallet Top-Up & Payout History</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Txn Ref</th>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Source</th>
                                <th>Amount (₹)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (transactions == null || transactions.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center; color: #9CA3AF; padding: 24px;">No wallet operations recorded.</td></tr>
                            <% } else {
                                for (WalletTransaction txn : transactions) {
                                    if ("TOP_UP".equalsIgnoreCase(txn.getTransactionSource()) || "ORDER_PAYOUT".equalsIgnoreCase(txn.getTransactionSource()) || "WITHDRAWAL".equalsIgnoreCase(txn.getTransactionSource())) { %>
                                        <tr>
                                            <td><code><%= txn.getTxnReferenceNo() %></code></td>
                                            <td><%= txn.getTransactionDate() %></td>
                                            <td><strong><%= txn.getTransactionType() %></strong></td>
                                            <td><%= txn.getTransactionSource() %></td>
                                            <td style="color: <%= "CREDIT".equals(txn.getTransactionType()) ? "#047857" : "#B91C1C" %>; font-weight: 700;">
                                                <%= "CREDIT".equals(txn.getTransactionType()) ? "+" : "-" %>₹<%= txn.getAmount() %>
                                            </td>
                                            <td><span class="status-badge badge-success"><%= txn.getStatus() %></span></td>
                                        </tr>
                            <%      }
                                }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 5: TRANSACTION LEDGER -->
            <div id="tab-transactions" class="tab-content">
                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;">📜 Digital Wallet Financial Audit Ledger</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Reference #</th>
                                <th>Date</th>
                                <th>Source</th>
                                <th>Type</th>
                                <th>Amount (₹)</th>
                                <th>Balance After (₹)</th>
                                <th>Remarks</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (transactions == null || transactions.isEmpty()) { %>
                                <tr><td colspan="7" style="text-align: center; color: #9CA3AF; padding: 24px;">No transactions recorded.</td></tr>
                            <% } else {
                                for (WalletTransaction t : transactions) { %>
                                    <tr>
                                        <td><code><%= t.getTxnReferenceNo() %></code></td>
                                        <td><%= t.getTransactionDate() %></td>
                                        <td><%= t.getTransactionSource() %></td>
                                        <td><span class="status-badge <%= "CREDIT".equals(t.getTransactionType()) ? "badge-success" : "badge-danger" %>"><%= t.getTransactionType() %></span></td>
                                        <td style="font-weight: 700; color: <%= "CREDIT".equals(t.getTransactionType()) ? "#047857" : "#B91C1C" %>;">
                                            <%= "CREDIT".equals(t.getTransactionType()) ? "+" : "-" %>₹<%= t.getAmount() %>
                                        </td>
                                        <td><strong>₹<%= t.getBalanceAfter() %></strong></td>
                                        <td><%= t.getRemarks() != null ? t.getRemarks() : "-" %></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 6: CASH & UPI EARNINGS -->
            <div id="tab-cash-upi" class="tab-content">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Cash Collections</div>
                        <div style="font-size: 26px; font-weight: 700; color: #059669; margin-top: 4px;">
                            ₹<%= (report != null && report.get("cashRevenue") != null) ? report.get("cashRevenue") : "0.00" %>
                        </div>
                        <div class="text-muted small mt-1">Physical cash handed directly by customer.</div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Direct UPI Collections</div>
                        <div style="font-size: 26px; font-weight: 700; color: #2563EB; margin-top: 4px;">
                            ₹<%= (report != null && report.get("upiRevenue") != null) ? report.get("upiRevenue") : "0.00" %>
                        </div>
                        <div class="text-muted small mt-1">Direct UPI / QR scan settlements.</div>
                    </div>
                </div>

                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 8px;">💵 Physical & External Payment Receipts</h3>
                    <p style="color: #6B7280; font-size: 13px; margin-bottom: 16px;">Note: Cash and direct UPI transactions are sales earnings settled directly in person and do NOT credit digital KisaanConnect wallet balances.</p>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Sub-Order #</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Payment Method</th>
                                <th>Amount (₹)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (detailedEarnings == null || detailedEarnings.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center; color: #9CA3AF; padding: 24px;">No cash/UPI earnings recorded.</td></tr>
                            <% } else {
                                boolean hasCashUpi = false;
                                for (Map<String, Object> de : detailedEarnings) {
                                    String pm = (String) de.get("paymentMethod");
                                    if ("CASH".equalsIgnoreCase(pm) || "UPI".equalsIgnoreCase(pm)) {
                                        hasCashUpi = true; %>
                                        <tr>
                                            <td><strong>#<%= de.get("subOrderNumber") %></strong></td>
                                            <td><%= de.get("createdAt") %></td>
                                            <td><%= de.get("customerName") %></td>
                                            <td><span class="status-badge badge-warning"><%= pm %></span></td>
                                            <td style="font-weight: 700; color: #2E7D32;">₹<%= de.get("amount") %></td>
                                            <td><span class="status-badge badge-success"><%= de.get("status") %></span></td>
                                        </tr>
                            <%      }
                                }
                                if (!hasCashUpi) { %>
                                    <tr><td colspan="6" style="text-align: center; color: #9CA3AF; padding: 24px;">No cash/UPI orders found.</td></tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 7: EARNINGS SUMMARY -->
            <div id="tab-earnings" class="tab-content">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Farm Sales</div>
                        <div style="font-size: 26px; font-weight: 700; color: #2E7D32; margin-top: 4px;">
                            ₹<%= (report != null && report.get("totalRevenue") != null) ? report.get("totalRevenue") : "0.00" %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Wallet Escrow Revenue</div>
                        <div style="font-size: 26px; font-weight: 700; color: #047857; margin-top: 4px;">
                            ₹<%= (report != null && report.get("walletRevenue") != null) ? report.get("walletRevenue") : "0.00" %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Cash & UPI Sales</div>
                        <div style="font-size: 26px; font-weight: 700; color: #1F2937; margin-top: 4px;">
                            ₹<%= (report != null && report.get("cashRevenue") != null && report.get("upiRevenue") != null) ? ((java.math.BigDecimal)report.get("cashRevenue")).add((java.math.BigDecimal)report.get("upiRevenue")) : "0.00" %>
                        </div>
                    </div>
                </div>

                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-chart-line"></i> Comprehensive Earnings Breakdown</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Sub-Order #</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Produce Summary</th>
                                <th>Mode</th>
                                <th>Amount (₹)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (detailedEarnings == null || detailedEarnings.isEmpty()) { %>
                                <tr><td colspan="7" style="text-align: center; color: #9CA3AF; padding: 24px;">No earnings records found.</td></tr>
                            <% } else {
                                for (Map<String, Object> de : detailedEarnings) { %>
                                    <tr>
                                        <td><strong>#<%= de.get("subOrderNumber") %></strong></td>
                                        <td><%= de.get("createdAt") %></td>
                                        <td><%= de.get("customerName") %></td>
                                        <td style="max-width: 250px;"><%= de.get("productsSummary") %></td>
                                        <td><span class="status-badge badge-info"><%= de.get("paymentMethod") %></span></td>
                                        <td style="font-weight: 700; color: #2E7D32;">₹<%= de.get("amount") %></td>
                                        <td><span class="status-badge badge-success"><%= de.get("status") %></span></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 8: DELIVERY STATUS -->
            <div id="tab-delivery" class="tab-content">
                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-truck-fast"></i> Order Fulfillment & Delivery Status</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Sub-Order #</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Delivery Destination</th>
                                <th>Amount (₹)</th>
                                <th>Current Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (subOrders == null || subOrders.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center; color: #9CA3AF; padding: 24px;">No delivery records found.</td></tr>
                            <% } else {
                                for (SubOrder so : subOrders) { %>
                                    <tr>
                                        <td><strong>#<%= so.getSubOrderNumber() %></strong></td>
                                        <td><%= so.getCreatedAt() %></td>
                                        <td><%= so.getDeliveryName() != null ? so.getDeliveryName() : so.getBuyerName() %></td>
                                        <td><%= so.getDeliveryAddress() %> (📞 <%= so.getDeliveryPhone() %>)</td>
                                        <td style="font-weight: 700; color: #2E7D32;">₹<%= so.getTotalAmount() %></td>
                                        <td><span class="status-badge badge-info"><%= so.getSubOrderStatus() %></span></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

    </div>

    <script>
        function showTab(tabId, btn) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            btn.classList.add('active');
        }
    </script>

</body>
</html>
