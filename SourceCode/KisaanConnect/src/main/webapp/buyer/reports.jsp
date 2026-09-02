<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.kisaanconnect.model.Wallet"%>
<%@page import="com.kisaanconnect.model.WalletTransaction"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.SubOrder"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.model.BuyerProfile"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>
<%@page import="com.kisaanconnect.dao.ReportDAO"%>
<%@page import="com.kisaanconnect.dao.BuyerDAO"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    Map<String, Object> report = (Map<String, Object>) request.getAttribute("report");
    List<WalletTransaction> transactions = (List<WalletTransaction>) request.getAttribute("transactions");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    Wallet wallet = (Wallet) request.getAttribute("wallet");
    BuyerProfile bp = (BuyerProfile) request.getAttribute("buyerProfile");

    if (report == null) {
        ReportDAO rDAO = new ReportDAO();
        report = rDAO.getBuyerSpendingReport(loggedInUser.getUserId());
    }
    if (bp == null) {
        BuyerDAO bDAO = new BuyerDAO();
        bp = bDAO.getProfileByUserId(loggedInUser.getUserId());
    }
    if (orders == null && bp != null) {
        OrderDAO oDAO = new OrderDAO();
        orders = oDAO.getOrdersByBuyerProfileId(bp.getBuyerProfileId());
    }
    if (transactions == null || wallet == null) {
        WalletDAO wDAO = new WalletDAO();
        wallet = wDAO.getOrCreateWallet(loggedInUser.getUserId());
        if (wallet != null) {
            transactions = wDAO.getTransactionsByWalletId(wallet.getWalletId());
        }
    }

    List<Map<String, Object>> topItems = (report != null) ? (List<Map<String, Object>>) report.get("topItems") : null;

    // Compute Payment Method Breakdown
    BigDecimal totalWalletSpent = BigDecimal.ZERO;
    BigDecimal totalCashSpent = BigDecimal.ZERO;
    BigDecimal totalUpiSpent = BigDecimal.ZERO;

    if (orders != null) {
        for (Order o : orders) {
            String pm = (o.getPaymentMethod() != null) ? o.getPaymentMethod().toUpperCase() : "CASH";
            if (pm.contains("WALLET")) totalWalletSpent = totalWalletSpent.add(o.getTotalAmount());
            else if (pm.contains("UPI") || pm.contains("ONLINE")) totalUpiSpent = totalUpiSpent.add(o.getTotalAmount());
            else totalCashSpent = totalCashSpent.add(o.getTotalAmount());
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase & Spending Reports | KisaanConnect Buyer</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .report-header {
            background: linear-gradient(135deg, #1B5E20, #2E7D32);
            color: white;
            padding: 35px 0 40px 0;
            border-radius: 0 0 25px 25px;
            margin-bottom: 30px;
        }

        .report-tabs {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            border-bottom: 2px solid #E5E7EB;
            margin-bottom: 24px;
            padding-bottom: 8px;
        }

        .tab-btn {
            background: white;
            color: #4B5563;
            border: 1px solid #E5E7EB;
            padding: 9px 16px;
            border-radius: 12px;
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
            background: #1B5E20;
            color: white;
            border-color: #1B5E20;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            border: 1px solid #E5E7EB;
            padding: 24px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            margin-bottom: 24px;
        }

        .table-card {
            background: white;
            border-radius: 20px;
            border: 1px solid #E5E7EB;
            padding: 26px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            margin-bottom: 24px;
            overflow-x: auto;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-success { background: #DEF7EC; color: #03543F; }
        .badge-warning { background: #FEF08A; color: #854D0E; }
        .badge-danger { background: #FDE8E8; color: #9B1C1C; }
        .badge-info { background: #DBEAFE; color: #1E40AF; }

        @media print {
            .navbar, .report-header, .no-print, .report-tabs, button, footer, .alert-container {
                display: none !important;
            }
            body {
                background: #FFFFFF !important;
                color: #000000 !important;
                margin: 0 !important;
                padding: 0 !important;
            }
            .container {
                max-width: 100% !important;
                padding: 0 !important;
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
            .stat-card, .table-card {
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

    <%@ include file="/includes/navbar.jsp" %>

    <div class="report-header no-print">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="h2 fw-bold mb-1"><i class="fa-solid fa-chart-line"></i> Purchase & Spending Analytics</h1>
                    <p class="mb-0 text-white-50">Review farm purchases, wallet ledger history, spending distributions, and shipment reports.</p>
                </div>
                <button onclick="window.print();" class="btn btn-light fw-semibold rounded-pill px-4 shadow-sm">
                    <i class="fa-solid fa-print me-1"></i> Print Statement
                </button>
            </div>
        </div>
    </div>

    <div class="container pb-5">

        <!-- Print Header -->
        <div class="print-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <img src="${pageContext.request.contextPath}/assets/images/logo.png" style="height: 50px;" alt="KisaanConnect">
                    <h2 class="text-success mb-1">Customer Purchase & Spending Statement</h2>
                </div>
                <div class="text-end small text-muted">
                    Generated: <%= new java.util.Date() %><br>
                    Customer: <%= loggedInUser != null ? loggedInUser.getFullName() : "Customer" %>
                </div>
            </div>
        </div>

        <%@ include file="/includes/alerts.jsp" %>

        <!-- 7 Navigation Tabs -->
        <div class="report-tabs no-print">
            <button class="tab-btn active" onclick="showTab('tab-orders', this)"><i class="fa-solid fa-clipboard-list"></i> 1. Orders Report</button>
            <button class="tab-btn" onclick="showTab('tab-purchases', this)"><i class="fa-solid fa-basket-shopping"></i> 2. Purchases Report</button>
            <button class="tab-btn" onclick="showTab('tab-topups', this)"><i class="fa-solid fa-wallet"></i> 3. Wallet Top-Ups</button>
            <button class="tab-btn" onclick="showTab('tab-transactions', this)"><i class="fa-solid fa-receipt"></i> 4. Wallet Ledger</button>
            <button class="tab-btn" onclick="showTab('tab-spending', this)"><i class="fa-solid fa-chart-pie"></i> 5. Spending Summary</button>
            <button class="tab-btn" onclick="showTab('tab-payment-methods', this)"><i class="fa-solid fa-money-bill-transfer"></i> 6. Payment Modes</button>
            <button class="tab-btn" onclick="showTab('tab-delivery', this)"><i class="fa-solid fa-truck"></i> 7. Delivery Report</button>
        </div>

        <!-- TAB 1: ORDERS REPORT -->
        <div id="tab-orders" class="tab-content active">
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">Total Orders Placed</div>
                        <div class="fs-3 fw-bold text-dark"><%= orders != null ? orders.size() : 0 %></div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">Total Produce Purchases</div>
                        <div class="fs-3 fw-bold text-success">
                            ₹<%= (report != null && report.get("totalSpent") != null) ? report.get("totalSpent") : "0.00" %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="table-card">
                <h4 class="fw-bold mb-3 text-dark"><i class="fa-solid fa-clipboard-list"></i> All Orders Summary</h4>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Items Summary</th>
                                <th>Total (₹)</th>
                                <th>Payment Method</th>
                                <th>Order Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (orders == null || orders.isEmpty()) { %>
                                <tr><td colspan="6" class="text-center text-muted py-4">No order records found.</td></tr>
                            <% } else {
                                for (Order o : orders) { %>
                                    <tr>
                                        <td><strong>#<%= o.getOrderNumber() %></strong></td>
                                        <td><%= o.getOrderDate() %></td>
                                        <td>
                                            <% if (o.getItems() != null) {
                                                for (OrderItem item : o.getItems()) { %>
                                                    <span class="badge bg-light text-dark border me-1 mb-1">
                                                        <%= item.getProductName() %> (× <%= item.getQuantity() %>)
                                                    </span>
                                            <%  }
                                               } %>
                                        </td>
                                        <td class="fw-bold text-success">₹<%= o.getTotalAmount() %></td>
                                        <td><span class="status-badge badge-info"><%= o.getPaymentMethod() %></span></td>
                                        <td><span class="status-badge badge-success"><%= o.getOrderStatus() %></span></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- TAB 2: PURCHASES REPORT -->
        <div id="tab-purchases" class="tab-content">
            <div class="table-card">
                <h4 class="fw-bold mb-3 text-dark"><i class="fa-solid fa-wheat-awn"></i> Purchased Produce Varieties</h4>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Produce Item</th>
                                <th>Total Quantity Bought</th>
                                <th>Total Spend (₹)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (topItems == null || topItems.isEmpty()) { %>
                                <tr><td colspan="3" class="text-center text-muted py-4">No itemized purchases found.</td></tr>
                            <% } else {
                                for (Map<String, Object> item : topItems) { %>
                                    <tr>
                                        <td><strong><i class="fa-solid fa-wheat-awn"></i> <%= item.get("productName") %></strong></td>
                                        <td><%= item.get("totalQty") %> units</td>
                                        <td class="fw-bold text-success">₹<%= item.get("totalCost") %></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- TAB 3: WALLET TOP-UPS -->
        <div id="tab-topups" class="tab-content">
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">Available Wallet Balance</div>
                        <div class="fs-3 fw-bold text-success">₹<%= wallet != null ? wallet.getCurrentBalance() : "0.00" %></div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">Lifetime Top-Up Amount</div>
                        <div class="fs-3 fw-bold text-dark">₹<%= wallet != null ? wallet.getTotalCredited() : "0.00" %></div>
                    </div>
                </div>
            </div>

            <div class="table-card">
                <h4 class="fw-bold mb-3 text-dark"><i class="fa-solid fa-wallet"></i> Wallet Top-Up Statements</h4>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Txn Reference</th>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Amount (₹)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (transactions == null || transactions.isEmpty()) { %>
                                <tr><td colspan="5" class="text-center text-muted py-4">No wallet top-ups found.</td></tr>
                            <% } else {
                                boolean hasTopUps = false;
                                for (WalletTransaction txn : transactions) {
                                    if ("TOP_UP".equalsIgnoreCase(txn.getTransactionSource()) || "CREDIT".equalsIgnoreCase(txn.getTransactionType())) {
                                        hasTopUps = true; %>
                                        <tr>
                                            <td><code><%= txn.getTxnReferenceNo() %></code></td>
                                            <td><%= txn.getTransactionDate() %></td>
                                            <td><span class="status-badge badge-success"><%= txn.getTransactionSource() %></span></td>
                                            <td class="fw-bold text-success">+₹<%= txn.getAmount() %></td>
                                            <td><span class="status-badge badge-success"><%= txn.getStatus() %></span></td>
                                        </tr>
                            <%      }
                                }
                                if (!hasTopUps) { %>
                                    <tr><td colspan="5" class="text-center text-muted py-4">No wallet top-up records.</td></tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- TAB 4: WALLET TRANSACTION LEDGER -->
        <div id="tab-transactions" class="tab-content">
            <div class="table-card">
                <h4 class="fw-bold mb-3 text-dark">📜 Complete Wallet Ledger Audit</h4>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
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
                                <tr><td colspan="7" class="text-center text-muted py-4">No ledger transactions found.</td></tr>
                            <% } else {
                                for (WalletTransaction t : transactions) { %>
                                    <tr>
                                        <td><code><%= t.getTxnReferenceNo() %></code></td>
                                        <td><%= t.getTransactionDate() %></td>
                                        <td><%= t.getTransactionSource() %></td>
                                        <td><span class="status-badge <%= "CREDIT".equals(t.getTransactionType()) ? "badge-success" : "badge-danger" %>"><%= t.getTransactionType() %></span></td>
                                        <td class="fw-bold <%= "CREDIT".equals(t.getTransactionType()) ? "text-success" : "text-danger" %>">
                                            <%= "CREDIT".equals(t.getTransactionType()) ? "+" : "-" %>₹<%= t.getAmount() %>
                                        </td>
                                        <td class="fw-bold">₹<%= t.getBalanceAfter() %></td>
                                        <td class="small text-muted"><%= t.getRemarks() != null ? t.getRemarks() : "-" %></td>
                                    </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- TAB 5: SPENDING SUMMARY -->
        <div id="tab-spending" class="tab-content">
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">Gross Purchases</div>
                        <div class="fs-4 fw-bold text-dark">₹<%= (report != null && report.get("totalSpent") != null) ? report.get("totalSpent") : "0.00" %></div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">Total Quantity Purchased</div>
                        <div class="fs-4 fw-bold text-success"><%= (report != null && report.get("totalUnitsBought") != null) ? report.get("totalUnitsBought") : "0" %> Units</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">Average Spend Per Order</div>
                        <div class="fs-4 fw-bold text-primary">
                            <%
                                int ordCount = (orders != null) ? orders.size() : 0;
                                BigDecimal totSpent = (report != null && report.get("totalSpent") != null) ? (BigDecimal) report.get("totalSpent") : BigDecimal.ZERO;
                                BigDecimal avgSpend = (ordCount > 0) ? totSpent.divide(BigDecimal.valueOf(ordCount), 2, java.math.RoundingMode.HALF_UP) : BigDecimal.ZERO;
                            %>
                            ₹<%= avgSpend %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- TAB 6: PAYMENT METHOD SUMMARY -->
        <div id="tab-payment-methods" class="tab-content">
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold"><i class="fa-solid fa-wallet"></i> KisaanConnect Wallet</div>
                        <div class="fs-3 fw-bold text-success">₹<%= totalWalletSpent %></div>
                        <div class="text-muted small mt-1">Escrow held and released upon receipt confirmation.</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">💵 Cash on Delivery</div>
                        <div class="fs-3 fw-bold text-dark">₹<%= totalCashSpent %></div>
                        <div class="text-muted small mt-1">Settled directly with farmer at delivery.</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="text-muted small fw-semibold">📱 UPI / Net Banking</div>
                        <div class="fs-3 fw-bold text-primary">₹<%= totalUpiSpent %></div>
                        <div class="text-muted small mt-1">Settled via UPI / QR at delivery.</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- TAB 7: DELIVERY REPORT -->
        <div id="tab-delivery" class="tab-content">
            <div class="table-card">
                <h4 class="fw-bold mb-3 text-dark"><i class="fa-solid fa-truck-fast"></i> Shipment & Fulfillment Tracking</h4>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Destination</th>
                                <th>Amount (₹)</th>
                                <th>Current Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (orders == null || orders.isEmpty()) { %>
                                <tr><td colspan="5" class="text-center text-muted py-4">No shipments recorded.</td></tr>
                            <% } else {
                                for (Order o : orders) { %>
                                    <tr>
                                        <td><strong>#<%= o.getOrderNumber() %></strong></td>
                                        <td><%= o.getOrderDate() %></td>
                                        <td><%= o.getDeliveryAddress() %> (📞 <%= o.getDeliveryPhone() %>)</td>
                                        <td class="fw-bold text-success">₹<%= o.getTotalAmount() %></td>
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

    <%@ include file="/includes/footer.jsp" %>

    <script>
        function showTab(tabId, btn) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            btn.classList.add('active');
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
