<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Product"%>
<%@page import="com.kisaanconnect.model.FarmerProfile"%>
<%@page import="com.kisaanconnect.dao.ProductDAO"%>
<%@page import="com.kisaanconnect.dao.FarmerProfileDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) {
        FarmerProfileDAO fpDAO = new FarmerProfileDAO();
        FarmerProfile fp = fpDAO.getProfileByUserId(loggedInUser.getUserId());
        if (fp != null) {
            ProductDAO pDAO = new ProductDAO();
            products = pDAO.getProductsByFarmer(fp.getFarmerProfileId());
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Farm Produce & Pricing | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    

    <style>
        body { font-family: var(--kc-font); background: #f8fafc; }
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
            gap: 24px;
            margin-top: 15px;
        }
        .prod-card {
            background: white;
            border-radius: 18px;
            overflow: hidden;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.04);
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
        }
        .prod-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 14px 28px rgba(0,0,0,0.08);
        }
        .prod-img {
            width: 100%;
            height: 180px;
            object-fit: cover;
            background: #F3F4F6;
        }
        .prod-body {
            padding: 18px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .prod-badge {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            padding: 3px 8px;
            border-radius: 6px;
            background: #DEF7EC;
            color: #03543F;
            display: inline-block;
            margin-right: 4px;
        }
        .prod-title {
            font-size: 17px;
            font-weight: 700;
            color: #1F2937;
            margin: 10px 0 4px;
        }
        .prod-price {
            font-size: 20px;
            font-weight: 800;
            color: #16a34a;
            margin-bottom: 8px;
        }
        .stock-badge {
            font-size: 13px;
            color: #4B5563;
            background: #F9FAFB;
            padding: 8px 12px;
            border-radius: 10px;
            margin-bottom: 14px;
            border: 1px solid #E5E7EB;
        }
        .btn-action {
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            padding: 8px 12px;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/farmer-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/farmer-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1"><i class="fa-solid fa-wheat-awn"></i> My Farm Produce & Pricing</h1>
                    <p class="text-muted small mb-0">Manage listed crops, update selling prices with historical audit tracking, and restock inventory.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/farmer/inventory" class="btn btn-outline-success btn-action">
                        <i class="fa-solid fa-boxes-stacked me-1"></i> Full Inventory Table
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/add-product" class="btn btn-success btn-action">
                        <i class="fa-solid fa-plus me-1"></i> Add New Produce
                    </a>
                </div>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <% if (products == null || products.isEmpty()) { %>
                <div class="card border-0 shadow-sm rounded-4 p-5 text-center my-4">
                    <div class="fs-1 mb-2"><i class="fa-solid fa-wheat-awn"></i></div>
                    <h4 class="fw-bold text-dark">No produce listed yet</h4>
                    <p class="text-muted small mb-3">Start selling directly to verified consumers and businesses.</p>
                    <div>
                        <a href="${pageContext.request.contextPath}/farmer/add-product" class="btn btn-success fw-semibold px-4 py-2 rounded-3">
                            <i class="fa-solid fa-plus me-1"></i> Add First Crop
                        </a>
                    </div>
                </div>
            <% } else { %>
                <!-- Search Box -->
                <div class="card border-0 shadow-sm rounded-4 p-3 mb-4">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" id="cropSearchInput" class="form-control bg-light border-start-0" placeholder="Search produce by crop name or category..." onkeyup="filterCrops()">
                    </div>
                </div>

                <div class="product-grid" id="cropGrid">
                    <% for (Product p : products) {
                        String imgUrl = (p.getPrimaryImageUrl() != null && !p.getPrimaryImageUrl().isEmpty())
                                ? request.getContextPath() + "/" + p.getPrimaryImageUrl()
                                : request.getContextPath() + "/assets/images/farmer.png";
                        String catName = p.getCategoryName() != null ? p.getCategoryName() : "Produce";
                    %>
                        <div class="prod-card crop-card" data-name="<%= p.getProductName().toLowerCase() %>" data-cat="<%= catName.toLowerCase() %>">
                            <img src="<%= imgUrl %>" class="prod-img" alt="<%= p.getProductName() %>">
                            <div class="prod-body">
                                <div>
                                    <span class="prod-badge"><%= catName %></span>
                                    <% if (p.getProductType() != null) { %>
                                        <span class="prod-badge" style="background: #E0E7FF; color: #3730A3;"><%= p.getProductType() %></span>
                                    <% } %>
                                </div>

                                <h3 class="prod-title"><%= p.getProductName() %></h3>
                                <div class="prod-price">
                                    ₹<%= p.getPrice() %> <span style="font-size: 13px; color: #6B7280; font-weight: 400;">/ <%= p.getUnit() %></span>
                                </div>

                                <div class="stock-badge">
                                    <i class="fa-solid fa-boxes-stacked"></i> In Stock: <strong><%= p.getAvailableQuantity() %> <%= p.getUnit() %></strong>
                                    <% if (p.getAvailableQuantity() <= p.getMinimumStock()) { %>
                                        <span class="text-danger fw-bold ms-1">(Low Stock!)</span>
                                    <% } %>
                                </div>

                                <div class="d-flex flex-column gap-2 mt-auto">
                                    <div class="d-flex gap-2">
                                        <!-- Update Price Modal Button -->
                                        <button type="button" class="btn btn-outline-primary btn-action flex-grow-1" onclick="openPriceModal(<%= p.getProductId() %>, '<%= p.getProductName().replace("'", "\\'") %>', <%= p.getPrice() %>, '<%= p.getUnit() %>')">
                                            <i class="bi bi-tag-fill me-1"></i> Update Price
                                        </button>
                                        <!-- Quick Restock Modal Button -->
                                        <button type="button" class="btn btn-outline-success btn-action flex-grow-1" onclick="openRestockModal(<%= p.getProductId() %>, '<%= p.getProductName().replace("'", "\\'") %>', <%= p.getAvailableQuantity() %>, '<%= p.getUnit() %>')">
                                            <i class="fa-solid fa-plus me-1"></i> Restock
                                        </button>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/farmer/delete-product" method="post" onsubmit="return confirm('Delete this produce listing?');" class="m-0">
                                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                        <button type="submit" class="btn btn-sm btn-outline-danger btn-action w-100">
                                            <i class="fa-solid fa-trash-can me-1"></i> Remove Listing
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>

        </div>

    </div>

    <!-- Update Price & Price History Modal -->
    <div class="modal fade" id="priceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <form action="${pageContext.request.contextPath}/farmer/update-price" method="post">
                    <input type="hidden" name="productId" id="priceModalProductId">
                    <div class="modal-header border-bottom-0 pb-0">
                        <h5 class="modal-title fw-bold text-dark"><i class="bi bi-tags-fill me-2 text-success"></i>Update Selling Price</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="text-muted small">Produce</label>
                            <div class="fw-bold text-dark fs-6" id="priceModalCropName"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold text-dark">New Selling Price (₹ per <span id="priceModalUnit"></span>) *</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light fw-bold">₹</span>
                                <input type="number" name="newPrice" id="priceModalInput" class="form-control" step="0.5" min="1" required>
                            </div>
                            <div class="form-text small text-muted">Active placed orders retain the snapshot price at checkout. New orders will reflect this price.</div>
                        </div>

                        <!-- Historical Price Log -->
                        <div class="mt-4">
                            <h6 class="fw-bold text-dark small mb-2"><i class="bi bi-clock-history me-1 text-muted"></i> Price Change History</h6>
                            <div id="priceHistoryContainer" style="max-height: 180px; overflow-y: auto;">
                                <div class="text-center py-2 text-muted small">Loading history...</div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0">
                        <button type="button" class="btn btn-secondary btn-action" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success btn-action px-4">Save New Price</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Quick Restock Modal -->
    <div class="modal fade" id="restockModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <form action="${pageContext.request.contextPath}/farmer/update-stock" method="post">
                    <input type="hidden" name="productId" id="restockModalProductId">
                    <div class="modal-header border-bottom-0 pb-0">
                        <h5 class="modal-title fw-bold text-dark"><i class="fa-solid fa-boxes-stacked me-2 text-success"></i>Incremental Restock</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="text-muted small">Produce Name</label>
                            <div class="fw-bold text-dark fs-6" id="restockModalCropName"></div>
                        </div>
                        <div class="mb-3">
                            <label class="text-muted small">Currently Available Stock</label>
                            <div class="fw-semibold text-dark fs-6" id="restockModalCurrentStock"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold text-dark">Additional Stock to Add (+ <span id="restockModalUnit"></span>) *</label>
                            <div class="input-group">
                                <span class="input-group-text bg-success-subtle text-success fw-bold">+</span>
                                <input type="number" name="additionalQuantity" class="form-control" step="0.5" min="0.1" placeholder="e.g. 50" required>
                            </div>
                            <div class="form-text small text-muted">This quantity will be atomically added to current available inventory.</div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0">
                        <button type="button" class="btn btn-secondary btn-action" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success btn-action px-4">Add to Stock</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterCrops() {
            var query = document.getElementById('cropSearchInput').value.toLowerCase().trim();
            var cards = document.querySelectorAll('.crop-card');
            cards.forEach(function(card) {
                var name = card.getAttribute('data-name') || '';
                var cat = card.getAttribute('data-cat') || '';
                if (name.includes(query) || cat.includes(query)) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        function openPriceModal(productId, cropName, currentPrice, unit) {
            document.getElementById('priceModalProductId').value = productId;
            document.getElementById('priceModalCropName').innerText = cropName;
            document.getElementById('priceModalUnit').innerText = unit;
            document.getElementById('priceModalInput').value = currentPrice;

            const modal = new bootstrap.Modal(document.getElementById('priceModal'));
            modal.show();

            const histContainer = document.getElementById('priceHistoryContainer');
            histContainer.innerHTML = '<div class="text-center py-2 text-muted small"><div class="spinner-border spinner-border-sm text-success" role="status"></div> Loading history...</div>';

            fetch('${pageContext.request.contextPath}/farmer/price-history?productId=' + productId)
                .then(r => r.json())
                .then(history => {
                    if (!history || history.length === 0) {
                        histContainer.innerHTML = '<div class="text-muted small py-2">No previous price revisions recorded.</div>';
                        return;
                    }
                    let html = '<ul class="list-group list-group-flush small">';
                    history.forEach(h => {
                        const dateStr = h.changedAt ? h.changedAt.substring(0, 19).replace('T', ' ') : '';
                        html += `
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-2">
                                <div>
                                    <span class="text-decoration-line-through text-muted me-1">₹${h.oldPrice}</span>
                                    <span class="fw-bold text-success">→ ₹${h.newPrice}</span>
                                </div>
                                <div class="text-muted font-monospace text-xs">${dateStr}</div>
                            </li>
                        `;
                    });
                    html += '</ul>';
                    histContainer.innerHTML = html;
                })
                .catch(err => {
                    histContainer.innerHTML = '<div class="text-muted small py-2">No previous price revisions.</div>';
                });
        }

        function openRestockModal(productId, cropName, currentStock, unit) {
            document.getElementById('restockModalProductId').value = productId;
            document.getElementById('restockModalCropName').innerText = cropName;
            document.getElementById('restockModalCurrentStock').innerText = currentStock + ' ' + unit;
            document.getElementById('restockModalUnit').innerText = unit;

            const modal = new bootstrap.Modal(document.getElementById('restockModal'));
            modal.show();
        }
    </script>
</body>
</html>
