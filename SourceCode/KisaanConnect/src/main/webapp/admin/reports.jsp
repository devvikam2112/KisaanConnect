<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.kisaanconnect.dao.ReportDAO"%>
<%@page import="com.kisaanconnect.model.WalletTransaction"%>

<%
    String selRange = (String) request.getAttribute("selectedRange");
    if (selRange == null) selRange = "all";

    Map<String, Object> report = (Map<String, Object>) request.getAttribute("report");
    if (report == null) {
        ReportDAO rDAO = new ReportDAO();
        report = rDAO.getAdminPlatformAnalytics(selRange);
    }

    List<Map<String, Object>> trendList = (List<Map<String, Object>>) request.getAttribute("gmvTrend");
    if (trendList == null) {
        ReportDAO rDAO = new ReportDAO();
        trendList = rDAO.getAdminGMVTrend(selRange);
    }

    Map<String, Integer> statusMap = (Map<String, Integer>) request.getAttribute("statusBreakdown");
    if (statusMap == null) {
        ReportDAO rDAO = new ReportDAO();
        statusMap = rDAO.getAdminOrderStatusBreakdown(selRange);
    }

    List<Map<String, Object>> topProds = (List<Map<String, Object>>) request.getAttribute("topProducts");
    if (topProds == null) {
        ReportDAO rDAO = new ReportDAO();
        topProds = rDAO.getAdminTopProducts(10);
    }

    List<Map<String, Object>> recActs = (List<Map<String, Object>>) request.getAttribute("recentActivity");
    if (recActs == null) {
        ReportDAO rDAO = new ReportDAO();
        recActs = rDAO.getAdminRecentActivity(15);
    }

    List<WalletTransaction> transactions = (List<WalletTransaction>) request.getAttribute("transactions");
    if (transactions == null) {
        ReportDAO rDAO = new ReportDAO();
        transactions = rDAO.getAllPlatformTransactions();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platform Analytics & GMV Report | KisaanConnect Admin</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        .stat-card {
            background: white;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            padding: 22px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.03);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.06);
        }
        .filter-btn {
            font-size: 13px;
            font-weight: 600;
            padding: 6px 14px;
            border-radius: 20px;
            text-decoration: none;
            border: 1px solid #D1D5DB;
            color: #4B5563;
            background: white;
            transition: all 0.2s;
        }
        .filter-btn.active {
            background: #15803D;
            color: white;
            border-color: #15803D;
        }
        .chart-box {
            background: white;
            border-radius: 20px;
            border: 1px solid #E5E7EB;
            padding: 24px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.03);
            height: 100%;
        }
        .table-custom {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }
        .table-custom th {
            background: #F9FAFB;
            color: #4B5563;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 12px 14px;
            border-bottom: 1px solid #E5E7EB;
        }
        .table-custom td {
            padding: 14px;
            font-size: 13px;
            border-bottom: 1px solid #F3F4F6;
            vertical-align: middle;
        }
        .table-custom tbody tr:hover {
            background: #F9FAFB;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/admin-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/admin-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <!-- Header & Filter Bar -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1"><i class="fa-solid fa-chart-line text-success me-2"></i>Platform Analytics & GMV Overview</h1>
                    <p class="text-muted small mb-0">Marketplace liquidity, gross transaction volume, fulfillments, and user activity.</p>
                </div>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <span class="text-muted small fw-semibold me-1"><i class="fa-regular fa-calendar me-1"></i>Period:</span>
                    <a href="${pageContext.request.contextPath}/admin/reports?range=all" class="filter-btn <%= "all".equals(selRange) ? "active" : "" %>">All Time</a>
                    <a href="${pageContext.request.contextPath}/admin/reports?range=1y" class="filter-btn <%= "1y".equals(selRange) ? "active" : "" %>">1 Year</a>
                    <a href="${pageContext.request.contextPath}/admin/reports?range=90d" class="filter-btn <%= "90d".equals(selRange) ? "active" : "" %>">90 Days</a>
                    <a href="${pageContext.request.contextPath}/admin/reports?range=30d" class="filter-btn <%= "30d".equals(selRange) ? "active" : "" %>">30 Days</a>
                    <a href="${pageContext.request.contextPath}/admin/reports?range=7d" class="filter-btn <%= "7d".equals(selRange) ? "active" : "" %>">7 Days</a>
                </div>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- Primary Metrics Grid -->
            <div class="row g-3 mb-4">
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <span class="text-muted small fw-semibold">Gross Merchandise Value (GMV)</span>
                                <h3 class="fw-bold text-success mt-2 mb-0">₹<%= report != null && report.get("totalGMV") != null ? report.get("totalGMV") : "0.00" %></h3>
                            </div>
                            <div class="p-3 bg-success bg-opacity-10 text-success rounded-4">
                                <i class="fa-solid fa-indian-rupee-sign fs-4"></i>
                            </div>
                        </div>
                        <div class="mt-2 text-muted small"><i class="fa-solid fa-circle-check text-success me-1"></i>Valid marketplace orders</div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <span class="text-muted small fw-semibold">Completed Fulfillment Value</span>
                                <h3 class="fw-bold text-dark mt-2 mb-0">₹<%= report != null && report.get("completedGMV") != null ? report.get("completedGMV") : "0.00" %></h3>
                            </div>
                            <div class="p-3 bg-primary bg-opacity-10 text-primary rounded-4">
                                <i class="fa-solid fa-truck-ramp-box fs-4"></i>
                            </div>
                        </div>
                        <div class="mt-2 text-muted small"><%= report != null && report.get("completedOrders") != null ? report.get("completedOrders") : 0 %> Orders fully settled</div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <span class="text-muted small fw-semibold">Total Orders Placed</span>
                                <h3 class="fw-bold text-dark mt-2 mb-0"><%= report != null && report.get("totalOrders") != null ? report.get("totalOrders") : 0 %></h3>
                            </div>
                            <div class="p-3 bg-warning bg-opacity-10 text-warning rounded-4">
                                <i class="fa-solid fa-box-open fs-4"></i>
                            </div>
                        </div>
                        <div class="mt-2 text-muted small">Period order throughput</div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <span class="text-muted small fw-semibold">Active Marketplace Users</span>
                                <h3 class="fw-bold text-info mt-2 mb-0"><%= report != null && report.get("activeUsers") != null ? report.get("activeUsers") : 0 %></h3>
                            </div>
                            <div class="p-3 bg-info bg-opacity-10 text-info rounded-4">
                                <i class="fa-solid fa-users fs-4"></i>
                            </div>
                        </div>
                        <div class="mt-2 text-muted small"><%= report != null && report.get("pendingUsers") != null ? report.get("pendingUsers") : 0 %> Pending | <%= report != null && report.get("suspendedUsers") != null ? report.get("suspendedUsers") : 0 %> Suspended</div>
                    </div>
                </div>
            </div>

            <!-- Secondary User Breakdown Grid -->
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="stat-card py-3">
                        <div class="d-flex align-items-center gap-3">
                            <div class="p-2 bg-success bg-opacity-10 text-success rounded-3 fs-5">
                                <i class="fa-solid fa-seedling"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Active Farmers</div>
                                <div class="fw-bold text-dark fs-5"><%= report != null && report.get("activeFarmers") != null ? report.get("activeFarmers") : 0 %></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="stat-card py-3">
                        <div class="d-flex align-items-center gap-3">
                            <div class="p-2 bg-primary bg-opacity-10 text-primary rounded-3 fs-5">
                                <i class="fa-solid fa-building"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Commercial Buyers / Orgs</div>
                                <div class="fw-bold text-dark fs-5"><%= report != null && report.get("activeCommercial") != null ? report.get("activeCommercial") : 0 %> (<%= report != null && report.get("totalOrganizations") != null ? report.get("totalOrganizations") : 0 %> Orgs)</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="stat-card py-3">
                        <div class="d-flex align-items-center gap-3">
                            <div class="p-2 bg-secondary bg-opacity-10 text-secondary rounded-3 fs-5">
                                <i class="fa-solid fa-bag-shopping"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Retail Consumers / Buyers</div>
                                <div class="fw-bold text-dark fs-5"><%= report != null && report.get("activeBuyers") != null ? report.get("activeBuyers") : 0 %></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Section -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8">
                    <div class="chart-box">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h5 class="fw-bold text-dark mb-0"><i class="fa-solid fa-chart-area text-success me-2"></i>GMV & Order Volume Trend</h5>
                                <span class="text-muted small">Timeline distribution for selected period</span>
                            </div>
                        </div>
                        <div style="position: relative; height: 280px; width: 100%;">
                            <canvas id="gmvTrendChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="chart-box">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h5 class="fw-bold text-dark mb-0"><i class="fa-solid fa-chart-pie text-primary me-2"></i>Order Fulfillment Status</h5>
                                <span class="text-muted small">Fulfillment stage breakdown</span>
                            </div>
                        </div>
                        <div style="position: relative; height: 280px; width: 100%;">
                            <canvas id="orderStatusChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Top Products & Recent Activity Section -->
            <div class="row g-4 mb-4">
                <div class="col-lg-6">
                    <div class="chart-box">
                        <h5 class="fw-bold text-dark mb-3"><i class="fa-solid fa-wheat-awn text-success me-2"></i>Top Performing Produce</h5>
                        <% if (topProds == null || topProds.isEmpty()) { %>
                            <div class="text-center py-4 text-muted small">No product sales records found.</div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th>Produce</th>
                                            <th>Category</th>
                                            <th>Quantity Sold</th>
                                            <th>Total GMV</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Map<String, Object> p : topProds) { %>
                                            <tr>
                                                <td class="fw-bold text-dark"><%= p.get("productName") %></td>
                                                <td><span class="badge bg-light text-secondary border"><%= p.get("category") %></span></td>
                                                <td><%= p.get("quantitySold") %> <%= p.get("unit") %></td>
                                                <td class="fw-bold text-success">₹<%= p.get("revenue") %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="chart-box">
                        <h5 class="fw-bold text-dark mb-3"><i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Recent Marketplace Orders</h5>
                        <% if (recActs == null || recActs.isEmpty()) { %>
                            <div class="text-center py-4 text-muted small">No recent orders recorded.</div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th>Order #</th>
                                            <th>Customer</th>
                                            <th>Payment</th>
                                            <th>Amount</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Map<String, Object> act : recActs) { %>
                                            <tr>
                                                <td class="fw-semibold font-monospace small">#<%= act.get("orderNumber") %></td>
                                                <td><%= act.get("customerName") %></td>
                                                <td><span class="badge bg-secondary-subtle text-secondary small"><%= act.get("paymentMethod") %></span></td>
                                                <td class="fw-bold text-dark">₹<%= act.get("totalAmount") %></td>
                                                <td>
                                                    <%
                                                        String st = (String) act.get("orderStatus");
                                                        String bg = "bg-warning-subtle text-warning";
                                                        if ("COMPLETED".equals(st)) bg = "bg-success-subtle text-success";
                                                        else if ("DELIVERED".equals(st)) bg = "bg-info-subtle text-info";
                                                        else if ("CANCELLED".equals(st) || "REJECTED".equals(st)) bg = "bg-danger-subtle text-danger";
                                                    %>
                                                    <span class="badge <%= bg %> px-2 py-1"><%= st %></span>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Platform Ledger Audit Table -->
            <div class="chart-box">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <h5 class="fw-bold text-dark mb-0"><i class="fa-solid fa-receipt text-secondary me-2"></i>Platform Escrow & Ledger Audit Trail</h5>
                        <span class="text-muted small">Direct wallet transfers, order escrows, and settlement logs</span>
                    </div>
                </div>

                <% if (transactions == null || transactions.isEmpty()) { %>
                    <div class="text-center py-4 text-muted small">No platform transactions recorded yet.</div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Txn Ref</th>
                                    <th>Wallet ID</th>
                                    <th>Date</th>
                                    <th>Type</th>
                                    <th>Source</th>
                                    <th>Amount</th>
                                    <th>Balance After</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (WalletTransaction txn : transactions) { %>
                                    <tr>
                                        <td><code class="text-dark"><%= txn.getTxnReferenceNo() %></code></td>
                                        <td>#<%= txn.getWalletId() %></td>
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
                                        <td><span class="badge bg-success-subtle text-success"><%= txn.getStatus() %></span></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Trend Line Chart
            const trendCtx = document.getElementById('gmvTrendChart').getContext('2d');
            const trendLabels = [
                <% if (trendList != null) {
                    for (int i = 0; i < trendList.size(); i++) {
                        if (i > 0) out.print(",");
                        out.print("\"" + trendList.get(i).get("date") + "\"");
                    }
                } %>
            ];
            const trendGmvData = [
                <% if (trendList != null) {
                    for (int i = 0; i < trendList.size(); i++) {
                        if (i > 0) out.print(",");
                        out.print(trendList.get(i).get("gmv"));
                    }
                } %>
            ];

            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: trendLabels.length > 0 ? trendLabels : ['Today'],
                    datasets: [{
                        label: 'GMV Volume (₹)',
                        data: trendGmvData.length > 0 ? trendGmvData : [0],
                        borderColor: '#16A34A',
                        backgroundColor: 'rgba(22, 163, 74, 0.1)',
                        tension: 0.35,
                        fill: true,
                        pointRadius: 4,
                        pointBackgroundColor: '#16A34A'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: '#F3F4F6' }
                        },
                        x: {
                            grid: { display: false }
                        }
                    }
                }
            });

            // Order Status Doughnut Chart
            const statusCtx = document.getElementById('orderStatusChart').getContext('2d');
            const statusLabels = [
                <% if (statusMap != null && !statusMap.isEmpty()) {
                    int i = 0;
                    for (String k : statusMap.keySet()) {
                        if (i > 0) out.print(",");
                        out.print("\"" + k + "\"");
                        i++;
                    }
                } else {
                    out.print("\"No Orders\"");
                } %>
            ];
            const statusCounts = [
                <% if (statusMap != null && !statusMap.isEmpty()) {
                    int i = 0;
                    for (Integer v : statusMap.values()) {
                        if (i > 0) out.print(",");
                        out.print(v);
                        i++;
                    }
                } else {
                    out.print("0");
                } %>
            ];

            new Chart(statusCtx, {
                type: 'doughnut',
                data: {
                    labels: statusLabels,
                    datasets: [{
                        data: statusCounts,
                        backgroundColor: [
                            '#16A34A', '#2563EB', '#F59E0B', '#10B981', '#8B5CF6', '#EF4444', '#6B7280'
                        ],
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { boxWidth: 12, font: { size: 11 } }
                        }
                    }
                }
            });
        });
    </script>
</body>
</html>
