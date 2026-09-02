<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.SubOrder"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.dao.BuyerDAO"%>
<%@page import="com.kisaanconnect.model.BuyerProfile"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    String currentStatusFilter = (String) request.getAttribute("statusFilter");
    if (currentStatusFilter == null || currentStatusFilter.trim().isEmpty()) {
        currentStatusFilter = request.getParameter("status");
    }
    if (currentStatusFilter == null || currentStatusFilter.trim().isEmpty()) {
        currentStatusFilter = "ALL";
    }

    if (orders == null && loggedInUser != null) {
        BuyerDAO bDAO = new BuyerDAO();
        BuyerProfile bp = bDAO.getProfileByUserId(loggedInUser.getUserId());
        if (bp != null) {
            OrderDAO oDAO = new OrderDAO();
            orders = oDAO.getOrdersByBuyerProfileId(bp.getBuyerProfileId(), currentStatusFilter);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders & Deliveries | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: #F4F7F3;
            font-family: var(--kc-font);
        }

        .order-nav-tabs {
            display: flex;
            gap: 8px;
            overflow-x: auto;
            padding-bottom: 8px;
            margin-bottom: 24px;
        }

        .order-tab {
            padding: 8px 16px;
            border-radius: 20px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            color: #4B5563;
            background: white;
            border: 1px solid #E5E7EB;
            white-space: nowrap;
            transition: 0.2s;
        }

        .order-tab:hover {
            background: #F3F4F6;
            color: #1F2937;
        }

        .order-tab.active {
            background: #2E7D32;
            color: white;
            border-color: #2E7D32;
        }

        .order-card {
            background: white;
            border-radius: 20px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            padding: 24px;
            margin-bottom: 24px;
        }

        .sub-order-card {
            background: #FAFAF9;
            border-radius: 14px;
            border: 1px solid #E7E5E4;
            padding: 16px;
            margin-top: 14px;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-placed { background: #FEF08A; color: #854D0E; }
        .status-accepted { background: #DBEAFE; color: #1E40AF; }
        .status-processing { background: #DBEAFE; color: #1E40AF; }
        .status-ready_for_pickup { background: #FEF3C7; color: #92400E; }
        .status-dispatched, .status-partially_dispatched { background: #E0E7FF; color: #3730A3; }
        .status-delivered, .status-partially_delivered { background: #FEF08A; color: #92400E; border: 1px solid #FCD34D; }
        .status-completed { background: #DEF7EC; color: #03543F; }
        .status-cancelled, .status-rejected { background: #FDE8E8; color: #9B1C1C; }

        @media print {
            .navbar, footer, .order-nav-tabs, .no-print, button, a, .alert-container {
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
            .order-card {
                border: 1px solid #D1D5DB !important;
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

    <%@ include file="/includes/navbar.jsp" %>

    <div class="container py-5">

        <!-- Print Header -->
        <div class="print-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <img src="${pageContext.request.contextPath}/assets/images/logo.png" style="height: 50px;" alt="KisaanConnect">
                    <h3 class="text-success mb-1">KisaanConnect Customer Orders Statement</h3>
                </div>
                <div class="text-end small text-muted">
                    Generated on: <%= new java.util.Date() %><br>
                    Customer: <%= loggedInUser != null ? loggedInUser.getFullName() : "Customer" %>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-3">
            <div>
                <h1 class="h3 fw-bold mb-1 text-dark"><i class="fa-solid fa-clipboard-list"></i> My Orders & Shipments</h1>
                <p class="text-muted small mb-0">Track farm shipments independently and confirm deliveries to release farmer payouts.</p>
            </div>
            <button onclick="window.print();" class="btn btn-outline-success rounded-pill fw-semibold px-4 no-print shadow-sm">
                <i class="fa-solid fa-print me-1"></i> Print Order History
            </button>
        </div>

        <!-- Navigation Tabs -->
        <div class="order-nav-tabs no-print">
            <a href="${pageContext.request.contextPath}/buyer/orders?status=ALL" class="order-tab <%= "ALL".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                All Orders
            </a>
            <a href="${pageContext.request.contextPath}/buyer/orders?status=PLACED" class="order-tab <%= "PLACED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                Pending
            </a>
            <a href="${pageContext.request.contextPath}/buyer/orders?status=PROCESSING" class="order-tab <%= "PROCESSING".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                Active / In-Transit
            </a>
            <a href="${pageContext.request.contextPath}/buyer/orders?status=DELIVERED" class="order-tab <%= "DELIVERED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                <i class="fa-solid fa-bell"></i> Awaiting Confirmation
            </a>
            <a href="${pageContext.request.contextPath}/buyer/orders?status=COMPLETED" class="order-tab <%= "COMPLETED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                Completed
            </a>
            <a href="${pageContext.request.contextPath}/buyer/orders?status=CANCELLED" class="order-tab <%= "CANCELLED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                Cancelled / Rejected
            </a>
        </div>

        <%@ include file="/includes/alerts.jsp" %>

        <% if (orders == null || orders.isEmpty()) { %>
            <div class="bg-white rounded-4 p-5 text-center shadow-sm my-4 border">
                <div style="font-size: 55px; margin-bottom: 12px;"><i class="fa-solid fa-boxes-stacked"></i></div>
                <h3 class="fw-bold text-dark">No orders found</h3>
                <p class="text-muted">No orders match this filter. Explore our fresh marketplace produce!</p>
                <a href="${pageContext.request.contextPath}/buyer/products" class="btn btn-success px-4 py-2 rounded-pill mt-2 fw-semibold">
                    Browse Fresh Produce <i class="fa-solid fa-wheat-awn"></i>
                </a>
            </div>
        <% } else { %>
            <% for (Order o : orders) {
                String mStatus = (o.getOrderStatus() != null) ? o.getOrderStatus().toUpperCase().trim() : "PLACED";
                String mStatusCls = "status-placed";
                if ("ACCEPTED".equals(mStatus) || "PROCESSING".equals(mStatus)) mStatusCls = "status-processing";
                else if ("DISPATCHED".equals(mStatus) || "PARTIALLY_DISPATCHED".equals(mStatus)) mStatusCls = "status-dispatched";
                else if ("DELIVERED".equals(mStatus) || "PARTIALLY_DELIVERED".equals(mStatus)) mStatusCls = "status-delivered";
                else if ("COMPLETED".equals(mStatus)) mStatusCls = "status-completed";
                else if ("CANCELLED".equals(mStatus)) mStatusCls = "status-cancelled";
            %>
                <div class="order-card">
                    <!-- Master Order Header -->
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pb-3 border-bottom mb-3">
                        <div>
                            <h5 class="fw-bold mb-1">
                                Order #<%= o.getOrderNumber() %>
                                <span class="badge bg-light text-dark border ms-2 small">Payment: <%= o.getPaymentMethod() %> (<%= o.getPaymentStatus() %>)</span>
                            </h5>
                            <div class="text-muted small">Placed on: <%= o.getOrderDate() %></div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <span class="status-badge <%= mStatusCls %>"><%= mStatus.replace("_", " ") %></span>
                            <div class="fs-4 fw-bold text-success">₹<%= o.getTotalAmount() %></div>
                        </div>
                    </div>

                    <!-- Delivery Information -->
                    <div class="bg-light p-3 rounded-3 mb-3 small">
                        <div class="row">
                            <div class="col-md-4">
                                <span class="text-muted">Delivering to:</span> <strong><%= o.getDeliveryName() %></strong> (📞 <%= o.getDeliveryPhone() %>)
                            </div>
                            <div class="col-md-5">
                                <span class="text-muted">Address:</span> <%= o.getDeliveryAddress() %> - <%= o.getDeliveryPincode() %>
                            </div>
                            <div class="col-md-3">
                                <span class="text-muted">Requested Delivery:</span> <strong class="text-success"><%= o.getFormattedDeliveryDate() %></strong>
                            </div>
                        </div>
                    </div>

                    <!-- Multi-Farmer Sub-Orders Section -->
                    <h6 class="fw-bold text-muted small text-uppercase mb-2">Farmer Shipments & Packages</h6>
                    
                    <% if (o.getSubOrders() != null && !o.getSubOrders().isEmpty()) {
                        for (SubOrder so : o.getSubOrders()) {
                            String soStatus = (so.getSubOrderStatus() != null) ? so.getSubOrderStatus().toUpperCase().trim() : "PLACED";
                            String soCls = "status-placed";
                            if ("ACCEPTED".equals(soStatus)) soCls = "status-accepted";
                            else if ("READY_FOR_PICKUP".equals(soStatus)) soCls = "status-ready_for_pickup";
                            else if ("DISPATCHED".equals(soStatus)) soCls = "status-dispatched";
                            else if ("DELIVERED".equals(soStatus)) soCls = "status-delivered";
                            else if ("COMPLETED".equals(soStatus)) soCls = "status-completed";
                            else if ("CANCELLED".equals(soStatus) || "REJECTED".equals(soStatus)) soCls = "status-cancelled";
                    %>
                        <div class="sub-order-card">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pb-2 border-bottom mb-2">
                                <div>
                                    <strong class="text-dark"><i class="fa-solid fa-wheat-awn text-success me-1"></i> Package from: <%= (so.getFarmerName() != null && !so.getFarmerName().isEmpty()) ? so.getFarmerName() : "Local Farmer" %> <%= (so.getFarmName() != null && !so.getFarmName().isEmpty()) ? "(" + so.getFarmName() + ")" : "" %></strong>
                                    <div class="text-muted small">Sub-Order #<%= so.getSubOrderNumber() %> | Est. Delivery: <strong class="text-success"><%= so.getFormattedDeliveryDate() %></strong></div>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="status-badge <%= soCls %>"><%= soStatus.replace("_", " ") %></span>
                                    <span class="fw-bold text-dark">₹<%= so.getTotalAmount() %></span>
                                </div>
                            </div>

                            <!-- Items from this Farmer -->
                            <% if (so.getItems() != null && !so.getItems().isEmpty()) {
                                for (OrderItem oi : so.getItems()) { %>
                                    <div class="d-flex justify-content-between py-1 small">
                                        <span><i class="fa-solid fa-wheat-awn"></i> <%= oi.getProductName() %> (× <%= oi.getQuantity() %> <%= oi.getUnit() != null ? oi.getUnit() : "kg" %>)</span>
                                        <span class="fw-semibold">₹<%= oi.getSubtotal() %></span>
                                    </div>
                            <%  }
                               } %>

                            <!-- Two-Step Delivery Confirmation Action & Chat -->
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-2 pt-2 border-top">
                                <div class="flex-grow-1">
                                    <% if ("DELIVERED".equals(soStatus)) { %>
                                        <div class="alert alert-warning d-flex justify-content-between align-items-center flex-wrap gap-2 mb-0 py-2 px-3 rounded-3">
                                            <div>
                                                <strong class="text-dark"><i class="fa-solid fa-truck-fast"></i> Produce Delivered!</strong>
                                                <div class="small text-muted">The farmer marked this package as delivered. Please inspect and confirm receipt.</div>
                                            </div>
                                            <form action="${pageContext.request.contextPath}/buyer/order/confirm-delivery" method="post" class="m-0 no-print" onsubmit="return confirm('Confirm receipt of package from <%= so.getFarmerName() %>? This will release payout to the farmer.');">
                                                <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                                <button type="submit" class="btn btn-success btn-sm px-3 fw-bold rounded-pill shadow-sm">
                                                    <i class="fa-solid fa-circle-check me-1"></i> Confirm Order Received
                                                </button>
                                            </form>
                                        </div>
                                    <% } else if ("COMPLETED".equals(soStatus)) { %>
                                        <div class="text-success small fw-semibold">
                                            <i class="fa-solid fa-circle-check me-1"></i> Delivery received and confirmed. Payment disbursed to farmer.
                                        </div>
                                    <% } else if ("CANCELLED".equals(soStatus) || "REJECTED".equals(soStatus)) { %>
                                        <div class="text-danger small fw-semibold">
                                            <i class="fa-solid fa-circle-xmark me-1"></i> This package was <%= soStatus.toLowerCase() %>. Any prepaid funds have been refunded to your wallet.
                                        </div>
                                    <% } %>
                                </div>

                                <div class="d-flex gap-2">
                                    <button type="button" 
                                            class="btn btn-sm btn-outline-info rounded-pill px-3 fw-semibold no-print"
                                            onclick="openDeliveryMapModal(<%= so.getSubOrderId() %>, '<%= so.getSubOrderNumber() %>')">
                                        <i class="fa-solid fa-map-location-dot me-1"></i> Track Route
                                    </button>
                                    <a href="${pageContext.request.contextPath}/chat?subOrderId=<%= so.getSubOrderId() %>" 
                                       class="btn btn-sm btn-outline-primary rounded-pill px-3 fw-semibold no-print">
                                        <i class="fa-solid fa-comments me-1"></i> <%= ("COMPLETED".equals(soStatus) || "CANCELLED".equals(soStatus) || "REJECTED".equals(soStatus)) ? "View Chat History" : "Chat with Farmer" %>
                                    </a>
                                </div>
                            </div>
                        </div>
                    <%  }
                       } else { %>
                        <!-- Fallback for legacy items -->
                        <% if (o.getItems() != null) {
                            for (OrderItem oi : o.getItems()) { %>
                                <div class="d-flex justify-content-between py-1 small">
                                    <span><i class="fa-solid fa-wheat-awn"></i> <strong><%= oi.getProductName() %></strong> (× <%= oi.getQuantity() %> <%= oi.getUnit() != null ? oi.getUnit() : "kg" %>)</span>
                                    <span class="fw-semibold">₹<%= oi.getSubtotal() %></span>
                                </div>
                        <%  }
                           } %>
                    <% } %>

                </div>
            <% } %>
        <% } %>

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
                        <span class="text-success fw-bold">● Farm Pickup</span> → <span class="text-primary fw-bold">● Your Delivery Location</span>
                    </div>
                    <button type="button" class="btn btn-secondary btn-sm rounded-3 px-3" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/includes/footer.jsp" %>
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

                fetch('${pageContext.request.contextPath}/order/tracking-route?subOrderId=' + encodeURIComponent(subOrderId))
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
                            .bindPopup('<b><i class="fa-solid fa-location-dot"></i> Delivery Destination:</b><br>' + (data.deliveryName || 'Destination') + '<br><small class="text-muted">' + (data.deliveryAddress || '') + '</small>');

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
