<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.kisaanconnect.model.Organization"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.WalletTransaction"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.SubOrder"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>
<%@page import="com.kisaanconnect.dao.ReportDAO"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    Map<String, Object> report = (Map<String, Object>) request.getAttribute("report");
    List<Map<String, Object>> suppliers = (List<Map<String, Object>>) request.getAttribute("suppliers");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    List<WalletTransaction> transactions = (List<WalletTransaction>) request.getAttribute("transactions");
    Wallet wallet = (Wallet) request.getAttribute("wallet");
    Organization commercialOrg = (Organization) request.getAttribute("organization");

    if (loggedInUser != null) {
        OrganizationDAO orgDAO = new OrganizationDAO();
        if (commercialOrg == null) commercialOrg = orgDAO.getOrganizationByUserId(loggedInUser.getUserId());

        if (commercialOrg != null) {
            ReportDAO rDAO = new ReportDAO();
            if (report == null) report = rDAO.getCommercialProcurementReport(commercialOrg.getOrganizationId());
            if (suppliers == null) suppliers = rDAO.getCommercialSupplierSummary(commercialOrg.getOrganizationId());
            if (orders == null) {
                OrderDAO oDAO = new OrderDAO();
                orders = oDAO.getOrdersByOrganizationId(commercialOrg.getOrganizationId());
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

    List<Map<String, Object>> topItems = (report != null) ? (List<Map<String, Object>>) report.get("topItems") : null;

    BigDecimal walletSpend = BigDecimal.ZERO;
    BigDecimal cashSpend = BigDecimal.ZERO;
    BigDecimal upiSpend = BigDecimal.ZERO;

    if (orders != null) {
        for (Order o : orders) {
            String pm = (o.getPaymentMethod() != null) ? o.getPaymentMethod().toUpperCase() : "CASH";
            if (pm.contains("WALLET")) walletSpend = walletSpend.add(o.getTotalAmount());
            else if (pm.contains("UPI") || pm.contains("ONLINE")) upiSpend = upiSpend.add(o.getTotalAmount());
            else cashSpend = cashSpend.add(o.getTotalAmount());
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Corporate Procurement Reports | KisaanConnect Commercial</title>

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
            gap: 6px;
            transition: 0.2s ease;
        }

        .tab-btn:hover {
            background: #E5E7EB;
            color: #1F2937;
        }

        .tab-btn.active {
            background: #1E3A8A;
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
                border-bottom: 2px solid #1E3A8A;
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

    <%@ include file="/includes/commercial-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/commercial-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <!-- Print Header -->
            <div class="print-header">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <img src="${pageContext.request.contextPath}/assets/images/logo.png" style="height: 50px;" alt="KisaanConnect">
                        <h2 style="color: #1E3A8A; margin: 4px 0;">Commercial Bulk Procurement & Financial Report</h2>
                    </div>
                    <div style="text-align: right; font-size: 13px; color: #4B5563;">
                        Generated: <%= new java.util.Date() %><br>
                        Enterprise: <%= commercialOrg != null ? commercialOrg.getOrgName() : "Commercial Org" %>
                    </div>
                </div>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 20px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-chart-line"></i> Corporate Procurement Analytics</h1>
                    <p style="color: #6B7280; font-size: 14px;">Enterprise audit of procurement orders, spend breakdown, supplier network, and logistics status.</p>
                </div>
                <button onclick="window.print();" class="no-print" style="background: #1E3A8A; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-print"></i> Print Procurement Audit
                </button>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- 8 Distinct Report Navigation Tabs -->
            <div class="report-tabs no-print">
                <button class="tab-btn active" onclick="showTab('tab-orders', this)"><i class="fa-solid fa-clipboard-list"></i> 1. Procurement Orders</button>
                <button class="tab-btn" onclick="showTab('tab-spend', this)"><i class="fa-solid fa-chart-line"></i> 2. Procurement Spend</button>
                <button class="tab-btn" onclick="showTab('tab-commodities', this)"><i class="fa-solid fa-cubes"></i> 3. Commodity Summary</button>
                <button class="tab-btn" onclick="showTab('tab-topups', this)"><i class="fa-solid fa-wallet"></i> 4. Wallet Top-Ups</button>
                <button class="tab-btn" onclick="showTab('tab-transactions', this)"><i class="fa-solid fa-receipt"></i> 5. Wallet Transactions</button>
                <button class="tab-btn" onclick="showTab('tab-cash-upi', this)"><i class="fa-solid fa-money-bill-wave"></i> 6. Cash / UPI Payments</button>
                <button class="tab-btn" onclick="showTab('tab-suppliers', this)"><i class="fa-solid fa-users-gear"></i> 7. Supplier Summary</button>
                <button class="tab-btn" onclick="showTab('tab-delivery', this)"><i class="fa-solid fa-truck"></i> 8. Delivery Status</button>
            </div>

            <!-- TAB 1: PROCUREMENT ORDERS -->
            <div id="tab-orders" class="tab-content active">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Purchase Orders</div>
                        <div style="font-size: 26px; font-weight: 700; color: #1F2937; margin-top: 4px;"><%= orders != null ? orders.size() : 0 %></div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Total Procurement Spend</div>
                        <div style="font-size: 26px; font-weight: 700; color: #1E3A8A; margin-top: 4px;">
                            ₹<%= (report != null && report.get("totalSpend") != null) ? report.get("totalSpend") : "0.00" %>
                        </div>
                    </div>
                </div>

                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-clipboard-list"></i> Purchase Order Records</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>PO Number</th>
                                <th>Date</th>
                                <th>Destination</th>
                                <th>Total (₹)</th>
                                <th>Payment Mode</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (orders == null || orders.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center; color: #9CA3AF; padding: 24px;">No procurement records found.</td></tr>
                            <% } else {
                                for (Order o : orders) { %>
                                    <tr>
                                        <td><strong>#<%= o.getOrderNumber() %></strong></td>
                                        <td><%= o.getOrderDate() %></td>
                                        <td><%= o.getDeliveryAddress() %></td>
                                        <td style="font-weight: 700; color: #1E3A8A;">₹<%= o.getTotalAmount() %></td>
                                        <td><span class="status-badge badge-info"><%= o.getPaymentMethod() %></span></td>
                                        <td><span class="status-badge badge-success"><%= o.getOrderStatus() %></span></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 2: PROCUREMENT SPEND -->
            <div id="tab-spend" class="tab-content">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Raw Agricultural Produce</div>
                        <div style="font-size: 26px; font-weight: 700; color: #047857; margin-top: 4px;">
                            ₹<%= (report != null && report.get("rawProduceCost") != null) ? report.get("rawProduceCost") : "0.00" %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Logistics & Transport</div>
                        <div style="font-size: 26px; font-weight: 700; color: #1F2937; margin-top: 4px;">
                            ₹<%= (report != null && report.get("logisticsCost") != null) ? report.get("logisticsCost") : "0.00" %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Platform & Compliance</div>
                        <div style="font-size: 26px; font-weight: 700; color: #6B7280; margin-top: 4px;">
                            ₹<%= (report != null && report.get("platformFees") != null) ? report.get("platformFees") : "0.00" %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB 3: COMMODITY SUMMARY -->
            <div id="tab-commodities" class="tab-content">
                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-wheat-awn"></i> Procured Produce Commodities</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Commodity</th>
                                <th>Volume Procured</th>
                                <th>Total Spend (₹)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (topItems == null || topItems.isEmpty()) { %>
                                <tr><td colspan="3" style="text-align: center; color: #9CA3AF; padding: 24px;">No commodity transactions recorded.</td></tr>
                            <% } else {
                                for (Map<String, Object> item : topItems) { %>
                                    <tr>
                                        <td><strong><i class="fa-solid fa-wheat-awn"></i> <%= item.get("productName") %></strong></td>
                                        <td><%= item.get("totalQty") %> units</td>
                                        <td style="font-weight: 700; color: #1E3A8A;">₹<%= item.get("totalSpent") %></td>
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
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Corporate Wallet Balance</div>
                        <div style="font-size: 26px; font-weight: 700; color: #1E3A8A; margin-top: 4px;">
                            ₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Lifetime Top-Up Volume</div>
                        <div style="font-size: 26px; font-weight: 700; color: #047857; margin-top: 4px;">
                            ₹<%= wallet != null ? wallet.getTotalCredited() : "0.00" %>
                        </div>
                    </div>
                </div>

                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-wallet"></i> Corporate Pre-Fund Statements</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Txn Ref</th>
                                <th>Date</th>
                                <th>Source</th>
                                <th>Amount (₹)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (transactions == null || transactions.isEmpty()) { %>
                                <tr><td colspan="5" style="text-align: center; color: #9CA3AF; padding: 24px;">No top-up records found.</td></tr>
                            <% } else {
                                boolean hasTopUps = false;
                                for (WalletTransaction txn : transactions) {
                                    if ("TOP_UP".equalsIgnoreCase(txn.getTransactionSource()) || "CREDIT".equalsIgnoreCase(txn.getTransactionType())) {
                                        hasTopUps = true; %>
                                        <tr>
                                            <td><code><%= txn.getTxnReferenceNo() %></code></td>
                                            <td><%= txn.getTransactionDate() %></td>
                                            <td><span class="status-badge badge-success"><%= txn.getTransactionSource() %></span></td>
                                            <td style="font-weight: 700; color: #047857;">+₹<%= txn.getAmount() %></td>
                                            <td><span class="status-badge badge-success"><%= txn.getStatus() %></span></td>
                                        </tr>
                            <%      }
                                }
                                if (!hasTopUps) { %>
                                    <tr><td colspan="5" style="text-align: center; color: #9CA3AF; padding: 24px;">No top-up operations recorded.</td></tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 5: WALLET TRANSACTIONS -->
            <div id="tab-transactions" class="tab-content">
                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;">📜 Corporate Ledger Audit Trail</h3>
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

            <!-- TAB 6: CASH / UPI PAYMENTS -->
            <div id="tab-cash-upi" class="tab-content">
                <div class="report-grid">
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Cash Procurements</div>
                        <div style="font-size: 26px; font-weight: 700; color: #059669; margin-top: 4px;">
                            ₹<%= cashSpend %>
                        </div>
                    </div>
                    <div class="report-card">
                        <div style="font-size: 13px; color: #6B7280; font-weight: 600;">Direct UPI / Bank Procurements</div>
                        <div style="font-size: 26px; font-weight: 700; color: #2563EB; margin-top: 4px;">
                            ₹<%= upiSpend %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB 7: SUPPLIER SUMMARY -->
            <div id="tab-suppliers" class="tab-content">
                <div class="report-table-container">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-seedling"></i> Contracted Farmer & Supplier Network</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>Farmer Name</th>
                                <th>Farm Facility</th>
                                <th>District / State</th>
                                <th>Orders</th>
                                <th>Units Procured</th>
                                <th>Total Value (₹)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (suppliers == null || suppliers.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center; color: #9CA3AF; padding: 24px;">No supplier records available.</td></tr>
                            <% } else {
                                for (Map<String, Object> sup : suppliers) { %>
                                    <tr>
                                        <td><strong><%= sup.get("farmerName") %></strong></td>
                                        <td><%= sup.get("farmName") %></td>
                                        <td><%= sup.get("district") %>, <%= sup.get("state") %></td>
                                        <td><%= sup.get("totalOrders") %></td>
                                        <td><%= sup.get("totalUnits") %></td>
                                        <td style="font-weight: 700; color: #1E3A8A;">₹<%= sup.get("totalValue") %></td>
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
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 16px;"><i class="fa-solid fa-truck-fast"></i> Logistics & Fulfillment Tracking</h3>
                    <table class="report-table">
                        <thead>
                            <tr>
                                <th>PO Number</th>
                                <th>Date</th>
                                <th>Destination</th>
                                <th>Amount (₹)</th>
                                <th>Current Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (orders == null || orders.isEmpty()) { %>
                                <tr><td colspan="5" style="text-align: center; color: #9CA3AF; padding: 24px;">No fulfillment shipments found.</td></tr>
                            <% } else {
                                for (Order o : orders) { %>
                                    <tr>
                                        <td><strong>#<%= o.getOrderNumber() %></strong></td>
                                        <td><%= o.getOrderDate() %></td>
                                        <td><%= o.getDeliveryAddress() %></td>
                                        <td style="font-weight: 700; color: #1E3A8A;">₹<%= o.getTotalAmount() %></td>
                                        <td><span class="status-badge badge-info"><%= o.getOrderStatus() %></span></td>
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
