<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.SubOrder"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.dao.FarmerProfileDAO"%>
<%@page import="com.kisaanconnect.model.FarmerProfile"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    List<SubOrder> subOrders = (List<SubOrder>) request.getAttribute("subOrders");
    String currentStatusFilter = (String) request.getAttribute("statusFilter");
    if (currentStatusFilter == null || currentStatusFilter.trim().isEmpty()) {
        currentStatusFilter = request.getParameter("status");
    }
    if (currentStatusFilter == null || currentStatusFilter.trim().isEmpty()) {
        currentStatusFilter = "ALL";
    }

    if (subOrders == null && loggedInUser != null) {
        FarmerProfileDAO fpDAO = new FarmerProfileDAO();
        FarmerProfile fp = fpDAO.getProfileByUserId(loggedInUser.getUserId());
        if (fp != null) {
            OrderDAO oDAO = new OrderDAO();
            subOrders = oDAO.getFarmerSubOrders(fp.getFarmerProfileId(), currentStatusFilter);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Orders Management | KisaanConnect Farmer</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
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
        .order-nav-tabs {
            display: flex;
            gap: 8px;
            overflow-x: auto;
            padding-bottom: 12px;
            margin-bottom: 24px;
            border-bottom: 2px solid #E5E7EB;
        }

        .order-tab {
            padding: 10px 18px;
            border-radius: 12px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            color: #4B5563;
            background: white;
            border: 1px solid #E5E7EB;
            white-space: nowrap;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .order-tab:hover {
            background: #F3F4F6;
            color: #1F2937;
        }

        .order-tab.active {
            background: #2E7D32;
            color: white;
            border-color: #2E7D32;
            box-shadow: 0 4px 12px rgba(46,125,50,0.25);
        }

        .order-card {
            background: white;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            padding: 24px;
            margin-bottom: 20px;
        }

        .status-badge {
            display: inline-block;
            padding: 5px 14px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-placed { background: #FEF08A; color: #854D0E; }
        .status-accepted { background: #DBEAFE; color: #1E40AF; }
        .status-ready_for_pickup { background: #FEF3C7; color: #92400E; }
        .status-dispatched { background: #E0E7FF; color: #3730A3; }
        .status-delivered { background: #FEF08A; color: #92400E; border: 1px solid #FCD34D; }
        .status-completed { background: #DEF7EC; color: #03543F; }
        .status-cancelled, .status-rejected { background: #FDE8E8; color: #9B1C1C; }

        .btn-action-primary {
            background: #2E7D32;
            color: white;
            border: none;
            padding: 9px 18px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: 0.2s ease;
        }

        .btn-action-primary:hover {
            background: #1B5E20;
        }

        .btn-action-cancel {
            background: #FEE2E2;
            color: #991B1B;
            border: 1px solid #FCA5A5;
            padding: 8px 16px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: 0.2s ease;
        }

        .btn-action-cancel:hover {
            background: #FCA5A5;
            color: #7F1D1D;
        }

        @media print {
            .sidebar, .top-navbar, .order-nav-tabs, .no-print, button, form, .alert-container {
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
            .order-card {
                border: 1px solid #CCCCCC !important;
                box-shadow: none !important;
                page-break-inside: avoid;
                margin-bottom: 20px;
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

            <!-- Print Header with Logo -->
            <div class="print-header">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <img src="${pageContext.request.contextPath}/assets/images/logo.png" style="height: 50px;" alt="KisaanConnect">
                        <h2 style="color: #2E7D32; margin: 4px 0;">KisaanConnect Farmer Orders Ledger</h2>
                    </div>
                    <div style="text-align: right; font-size: 13px; color: #4B5563;">
                        Generated on: <%= new java.util.Date() %><br>
                        Farmer: <%= loggedInUser != null ? loggedInUser.getFullName() : "Farmer" %>
                    </div>
                </div>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 20px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-truck-fast"></i> Customer Produce Orders</h1>
                    <p style="color: #6B7280; font-size: 14px;">Farmer-isolated order fulfillment: Accept &rarr; Ready for Pickup &rarr; Dispatch &rarr; Deliver &rarr; Buyer Confirmation.</p>
                </div>
                <button onclick="window.print();" class="no-print" style="background: #1F6F43; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-print"></i> Print Orders Statement
                </button>
            </div>

            <!-- Categorized Order Management Navigation Tabs -->
            <div class="order-nav-tabs no-print">
                <a href="${pageContext.request.contextPath}/farmer/orders?status=ALL" class="order-tab <%= "ALL".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-clipboard-list"></i> All Orders
                </a>
                <a href="${pageContext.request.contextPath}/farmer/orders?status=PLACED" class="order-tab <%= "PLACED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    ⏳ Pending Orders
                </a>
                <a href="${pageContext.request.contextPath}/farmer/orders?status=ACCEPTED" class="order-tab <%= "ACCEPTED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    ✓ Accepted Orders
                </a>
                <a href="${pageContext.request.contextPath}/farmer/orders?status=READY_FOR_PICKUP" class="order-tab <%= "READY_FOR_PICKUP".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-boxes-stacked"></i> Ready for Pickup
                </a>
                <a href="${pageContext.request.contextPath}/farmer/orders?status=DISPATCHED" class="order-tab <%= "DISPATCHED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-truck-fast"></i> Dispatched Orders
                </a>
                <a href="${pageContext.request.contextPath}/farmer/orders?status=DELIVERED" class="order-tab <%= "DELIVERED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-bell"></i> Awaiting Buyer Confirmation
                </a>
                <a href="${pageContext.request.contextPath}/farmer/orders?status=COMPLETED" class="order-tab <%= "COMPLETED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-circle-check"></i> Completed Orders
                </a>
                <a href="${pageContext.request.contextPath}/farmer/orders?status=CANCELLED" class="order-tab <%= "CANCELLED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-circle-xmark"></i> Cancelled / Rejected
                </a>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <% if (subOrders == null || subOrders.isEmpty()) { %>
                <div style="background: white; border-radius: 18px; padding: 50px 20px; text-align: center; border: 1px solid #E5E7EB;">
                    <div style="font-size: 50px; margin-bottom: 12px;"><i class="fa-solid fa-tractor"></i></div>
                    <h3 style="font-size: 20px; color: #1F2937; margin-bottom: 8px;">No orders found in this view</h3>
                    <p style="color: #6B7280; font-size: 14px;">Select another status tab above or explore the marketplace.</p>
                </div>
            <% } else { %>
                <% for (SubOrder so : subOrders) {
                    String st = (so.getSubOrderStatus() != null) ? so.getSubOrderStatus().toUpperCase().trim() : "PLACED";
                    String statusCls = "status-placed";
                    if ("ACCEPTED".equals(st)) statusCls = "status-accepted";
                    else if ("READY_FOR_PICKUP".equals(st)) statusCls = "status-ready_for_pickup";
                    else if ("DISPATCHED".equals(st)) statusCls = "status-dispatched";
                    else if ("DELIVERED".equals(st)) statusCls = "status-delivered";
                    else if ("COMPLETED".equals(st)) statusCls = "status-completed";
                    else if ("CANCELLED".equals(st) || "REJECTED".equals(st)) statusCls = "status-cancelled";
                %>
                    <div class="order-card">
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; padding-bottom: 14px; border-bottom: 1px solid #F3F4F6; margin-bottom: 16px;">
                            <div>
                                <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 2px;">
                                    Sub-Order #<%= so.getSubOrderNumber() %>
                                    <span style="font-size: 12px; color: #6B7280; font-weight: normal; margin-left: 8px;">(Master: <%= so.getMasterOrderNumber() != null ? so.getMasterOrderNumber() : ("#" + so.getOrderId()) %>)</span>
                                </h3>
                                <div style="font-size: 13px; color: #6B7280;">Ordered on: <%= so.getCreatedAt() %></div>
                            </div>

                            <div style="display: flex; align-items: center; gap: 14px;">
                                <span class="status-badge <%= statusCls %>">
                                    <%= "DELIVERED".equals(st) ? "DELIVERED (AWAITING CONFIRMATION)" : st.replace("_", " ") %>
                                </span>
                                <div>
                                    <span style="font-size: 11px; color: #6B7280; text-transform: uppercase; display: block; text-align: right;">Your Produce Total</span>
                                    <div style="font-size: 22px; font-weight: 800; color: #2E7D32;">₹<%= so.getSubtotalAmount() %></div>
                                </div>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-bottom: 20px;">
                            <!-- Farmer Items Only -->
                            <div>
                                <h4 style="font-size: 13px; font-weight: 700; color: #6B7280; text-transform: uppercase; margin-bottom: 10px;">Your Ordered Produce Items</h4>
                                <% if (so.getItems() != null && !so.getItems().isEmpty()) {
                                    for (OrderItem oi : so.getItems()) { %>
                                        <div style="display: flex; justify-content: space-between; font-size: 14px; padding: 6px 0; border-bottom: 1px dashed #F3F4F6;">
                                            <span><i class="fa-solid fa-wheat-awn"></i> <strong><%= oi.getProductName() %></strong> (× <%= oi.getQuantity() %> <%= oi.getUnit() != null ? oi.getUnit() : "kg" %> @ ₹<%= oi.getUnitPrice() %>)</span>
                                            <span style="font-weight: 600; color: #1F2937;">₹<%= oi.getSubtotal() %></span>
                                        </div>
                                <%  }
                                   } else { %>
                                    <p style="color: #9CA3AF; font-size: 13px;">No item details available.</p>
                                <% } %>
                            </div>

                            <!-- Customer & Delivery Info -->
                            <div style="background: #F9FAFB; padding: 14px; border-radius: 12px; font-size: 13px;">
                                <h4 style="font-size: 13px; font-weight: 700; color: #6B7280; text-transform: uppercase; margin-bottom: 8px;">Customer & Delivery Details</h4>
                                <strong><%= so.getDeliveryName() != null ? so.getDeliveryName() : so.getBuyerName() %></strong><br>
                                📞 <%= so.getDeliveryPhone() %><br>
                                <i class="fa-solid fa-location-dot"></i> <%= so.getDeliveryAddress() %> - <%= so.getDeliveryPincode() %><br>
                                📅 Requested Delivery Date: <strong style="color: #15803D;"><%= so.getFormattedDeliveryDate() %></strong><br>
                                <i class="fa-solid fa-credit-card"></i> Payment Mode: <strong><%= so.getPaymentMethod() %></strong> (<%= so.getPaymentStatus() %>)
                            </div>
                        </div>

                        <!-- Contextual State Machine Controls -->
                        <div class="no-print" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; padding-top: 14px; border-top: 1px solid #F3F4F6;">
                            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                                <span style="font-size: 13px; font-weight: 600; color: #4B5563;">Action:</span>

                                <% if ("PLACED".equals(st)) { %>
                                    <form action="${pageContext.request.contextPath}/farmer/order/update-status" method="post" style="display: inline; margin: 0;">
                                        <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                        <input type="hidden" name="status" value="ACCEPTED">
                                        <button type="submit" class="btn-action-primary">
                                            <i class="fa-solid fa-check"></i> Accept Order
                                        </button>
                                    </form>

                                    <form action="${pageContext.request.contextPath}/farmer/order/update-status" method="post" onsubmit="return confirm('Reject this sub-order? Product inventory will be restored.');" style="display: inline; margin: 0;">
                                        <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                        <input type="hidden" name="status" value="REJECTED">
                                        <button type="submit" class="btn-action-cancel">
                                            <i class="fa-solid fa-xmark"></i> Reject Order
                                        </button>
                                    </form>

                                <% } else if ("ACCEPTED".equals(st)) { %>
                                    <form action="${pageContext.request.contextPath}/farmer/order/update-status" method="post" style="display: inline; margin: 0;">
                                        <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                        <input type="hidden" name="status" value="READY_FOR_PICKUP">
                                        <button type="submit" class="btn-action-primary" style="background: #D97706;">
                                            <i class="fa-solid fa-box-open"></i> Mark Ready for Pickup
                                        </button>
                                    </form>

                                    <form action="${pageContext.request.contextPath}/farmer/order/update-status" method="post" onsubmit="return confirm('Cancel this accepted order? Inventory will be restored.');" style="display: inline; margin: 0;">
                                        <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                        <input type="hidden" name="status" value="CANCELLED">
                                        <button type="submit" class="btn-action-cancel">
                                            <i class="fa-solid fa-xmark"></i> Cancel Order
                                        </button>
                                    </form>

                                <% } else if ("READY_FOR_PICKUP".equals(st)) { %>
                                    <form action="${pageContext.request.contextPath}/farmer/order/update-status" method="post" style="display: inline; margin: 0;">
                                        <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                        <input type="hidden" name="status" value="DISPATCHED">
                                        <button type="submit" class="btn-action-primary" style="background: #4F46E5;">
                                            <i class="fa-solid fa-truck-fast"></i> Dispatch Produce
                                        </button>
                                    </form>

                                <% } else if ("DISPATCHED".equals(st)) { %>
                                    <form action="${pageContext.request.contextPath}/farmer/order/update-status" method="post" style="display: inline; margin: 0;">
                                        <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                        <input type="hidden" name="status" value="DELIVERED">
                                        <button type="submit" class="btn-action-primary" style="background: #059669;">
                                            <i class="fa-solid fa-circle-check"></i> Mark as Delivered
                                        </button>
                                    </form>

                                <% } else if ("DELIVERED".equals(st)) { %>
                                    <span style="color: #92400E; font-size: 13px; font-weight: 700; background: #FEF3C7; padding: 6px 14px; border-radius: 8px;">
                                        <i class="fa-solid fa-clock"></i> Delivery marked! Awaiting Buyer confirmation to finalize payout.
                                    </span>

                                <% } else if ("COMPLETED".equals(st)) { %>
                                    <span style="color: #047857; font-size: 13px; font-weight: 700; background: #DEF7EC; padding: 6px 14px; border-radius: 8px;">
                                        <i class="fa-solid fa-circle-check"></i> Order completed & Buyer confirmed receipt!
                                    </span>

                                <% } else if ("CANCELLED".equals(st) || "REJECTED".equals(st)) { %>
                                    <span style="color: #991B1B; font-size: 13px; font-weight: 700; background: #FDE8E8; padding: 6px 14px; border-radius: 8px;">
                                        <i class="fa-solid fa-circle-xmark"></i> Sub-Order <%= st %> (Inventory Restored)
                                    </span>
                                <% } %>

                                <button type="button" 
                                        class="btn-action-primary" 
                                        style="background: #0284C7; border: none;"
                                        onclick="openDeliveryMapModal(<%= so.getSubOrderId() %>, '<%= so.getSubOrderNumber() %>')">
                                    <i class="fa-solid fa-map-location-dot"></i> Track Route
                                </button>

                                <a href="${pageContext.request.contextPath}/chat?subOrderId=<%= so.getSubOrderId() %>" 
                                   class="btn-action-primary" 
                                   style="background: #2563EB; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                                    <i class="fa-solid fa-comments"></i> <%= ("COMPLETED".equals(st) || "CANCELLED".equals(st) || "REJECTED".equals(st)) ? "View Chat History" : "Chat with Buyer" %>
                                </a>
                            </div>

                            <% if ("CASH".equalsIgnoreCase(so.getPaymentMethod()) && !"PAID".equalsIgnoreCase(so.getPaymentStatus()) && !"CANCELLED".equals(st) && !"REJECTED".equals(st)) { %>
                                <form action="${pageContext.request.contextPath}/farmer/order/confirm-cash" method="post" onsubmit="return confirm('Confirm that you have received ₹<%= so.getSubtotalAmount() %> cash for Sub-Order #<%= so.getSubOrderNumber() %>?');" style="margin: 0;">
                                    <input type="hidden" name="orderId" value="<%= so.getOrderId() %>">
                                    <button type="submit" class="btn-cash" style="background: #059669; color: white; border: none; padding: 8px 16px; border-radius: 8px; font-weight: 600; cursor: pointer;">
                                        <i class="fa-solid fa-hand-holding-dollar"></i> Confirm Cash Received
                                    </button>
                                </form>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            <% } %>

        </div>

    </div>

    <!-- Leaflet Delivery Map Modal -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <div class="modal fade" id="mapModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <div class="modal-header border-bottom-0 pb-2">
                    <div>
                        <h5 class="modal-title fw-bold text-dark"><i class="fa-solid fa-route text-success me-2"></i>Road Route & Delivery Navigation</h5>
                        <p class="text-muted small mb-0">Sub-Order: <span id="mapModalSubOrder" class="fw-bold text-dark"></span> | Driving Route: <span id="mapModalDistance" class="badge bg-success-subtle text-success fw-bold"></span></p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-0">
                    <div id="mapRouteStatusAlert" class="alert alert-warning m-2 py-2 small" style="display: none;"></div>
                    <div id="deliveryMap" style="height: 400px; width: 100%;"></div>
                </div>
                <div class="modal-footer border-top-0 d-flex justify-content-between">
                    <div class="small text-muted">
                        <span class="text-success fw-bold">● Farm Pickup</span> → <span class="text-primary fw-bold">● Delivery Destination</span>
                    </div>
                    <button type="button" class="btn btn-secondary btn-sm rounded-3 px-3" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let mapInstance = null;
        let routeGeoJsonLayer = null;

        function openDeliveryMapModal(subOrderId, fallbackSubOrderNum) {
            const modalEl = document.getElementById('mapModal');
            const modal = new bootstrap.Modal(modalEl);
            modal.show();

            document.getElementById('mapModalSubOrder').innerText = '#' + (fallbackSubOrderNum || subOrderId);
            document.getElementById('mapModalDistance').innerText = 'Calculating road route...';
            const alertEl = document.getElementById('mapRouteStatusAlert');
            alertEl.style.display = 'none';

            setTimeout(() => {
                if (!mapInstance) {
                    mapInstance = L.map('deliveryMap').setView([18.5204, 73.8567], 12);
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: '© OpenStreetMap contributors'
                    }).addTo(mapInstance);
                }

                mapInstance.eachLayer((layer) => {
                    if (layer instanceof L.Marker || layer instanceof L.Polyline || layer instanceof L.GeoJSON) {
                        mapInstance.removeLayer(layer);
                    }
                });

                fetch('${pageContext.request.contextPath}/order/tracking-route?subOrderId=' + encodeURIComponent(subOrderId), {
                    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
                    credentials: 'same-origin'
                })
                    .then(res => {
                        if (!res.ok) throw new Error('Authorization error or route unavailable (HTTP ' + res.status + ')');
                        return res.json();
                    })
                    .then(data => {
                        if (!data.success || !data.hasValidCoords) {
                            showRouteUnavailable(data.error || 'Delivery route unavailable because the pickup or delivery location has not been set.');
                            return;
                        }

                        document.getElementById('mapModalSubOrder').innerText = '#' + data.subOrderNumber;

                        const pLat = data.pickupLat;
                        const pLon = data.pickupLon;
                        const dLat = data.deliveryLat;
                        const dLon = data.deliveryLon;

                        const pMarker = L.marker([pLat, pLon]).addTo(mapInstance)
                            .bindPopup('<b><i class="fa-solid fa-tractor"></i> Farm Pickup:</b><br>' + (data.pickupName || 'Farm Facility') + '<br><small class="text-muted">' + (data.pickupAddress || '') + '</small>').openPopup();

                        const dMarker = L.marker([dLat, dLon]).addTo(mapInstance)
                            .bindPopup('<b><i class="fa-solid fa-location-dot"></i> Customer Delivery:</b><br>' + (data.deliveryName || 'Destination') + '<br><small class="text-muted">' + (data.deliveryAddress || '') + '</small>');

                        // Call OSRM for actual road driving geometry
                        const osrmUrl = 'https://router.project-osrm.org/route/v1/driving/' + pLon + ',' + pLat + ';' + dLon + ',' + dLat + '?overview=full&geometries=geojson&steps=true';

                        fetch(osrmUrl)
                            .then(osrmRes => osrmRes.json())
                            .then(osrmData => {
                                if (osrmData.code === 'Ok' && osrmData.routes && osrmData.routes.length > 0) {
                                    const route = osrmData.routes[0];
                                    const distanceKm = (route.distance / 1000).toFixed(1);
                                    const durationMins = Math.round(route.duration / 60);

                                    document.getElementById('mapModalDistance').innerHTML = '<i class="fa-solid fa-road"></i> ' + distanceKm + ' km (~' + durationMins + ' mins)';

                                    routeGeoJsonLayer = L.geoJSON(route.geometry, {
                                        style: {
                                            color: '#16a34a',
                                            weight: 5,
                                            opacity: 0.85
                                        }
                                    }).addTo(mapInstance);

                                    mapInstance.fitBounds(routeGeoJsonLayer.getBounds(), {padding: [50, 50]});
                                } else {
                                    showRouteUnavailable('Road route calculation unavailable. Showing pickup & destination points.');
                                    const group = new L.featureGroup([pMarker, dMarker]);
                                    mapInstance.fitBounds(group.getBounds(), {padding: [50, 50]});
                                }
                            })
                            .catch(() => {
                                showRouteUnavailable('Road routing service unavailable. Showing pickup & destination points.');
                                const group = new L.featureGroup([pMarker, dMarker]);
                                mapInstance.fitBounds(group.getBounds(), {padding: [50, 50]});
                            });

                        mapInstance.invalidateSize();
                    })
                    .catch(err => {
                        showRouteUnavailable(err.message || 'Unable to retrieve tracking route.');
                    });
            }, 300);
        }

        function showRouteUnavailable(msg) {
            const alertEl = document.getElementById('mapRouteStatusAlert');
            alertEl.innerText = msg;
            alertEl.style.display = 'block';
            document.getElementById('mapModalDistance').innerText = 'Route unavailable';
        }
    </script>
</body>
</html>
