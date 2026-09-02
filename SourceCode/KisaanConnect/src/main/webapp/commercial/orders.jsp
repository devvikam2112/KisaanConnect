<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Order"%>
<%@page import="com.kisaanconnect.model.SubOrder"%>
<%@page import="com.kisaanconnect.model.OrderItem"%>
<%@page import="com.kisaanconnect.dao.OrderDAO"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>
<%@page import="com.kisaanconnect.model.Organization"%>
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
        OrganizationDAO orgDAO = new OrganizationDAO();
        Organization commercialOrg = orgDAO.getOrganizationByUserId(loggedInUser.getUserId());
        if (commercialOrg != null) {
            OrderDAO oDAO = new OrderDAO();
            orders = oDAO.getOrdersByOrganizationId(commercialOrg.getOrganizationId(), currentStatusFilter);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bulk Procurement Orders | KisaanConnect Commercial</title>

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
            padding-bottom: 8px;
            margin-bottom: 24px;
            border-bottom: 2px solid #E5E7EB;
        }

        .order-tab {
            padding: 8px 16px;
            border-radius: 12px;
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
            background: #1E3A8A;
            color: white;
            border-color: #1E3A8A;
        }

        .order-card {
            background: white;
            border-radius: 18px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
            padding: 22px;
            margin-bottom: 20px;
        }

        .sub-order-card {
            background: #F8FAFC;
            border-radius: 12px;
            border: 1px solid #E2E8F0;
            padding: 16px;
            margin-top: 14px;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
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
            .sidebar, .top-navbar, .order-nav-tabs, .no-print, button, a, .alert-container {
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

    <%@ include file="/includes/commercial-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/commercial-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <!-- Print Header -->
            <div class="print-header">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <img src="${pageContext.request.contextPath}/assets/images/logo.png" style="height: 50px;" alt="KisaanConnect">
                        <h2 style="color: #1E3A8A; margin: 4px 0;">Commercial Bulk Procurement Orders</h2>
                    </div>
                    <div style="text-align: right; font-size: 13px; color: #4B5563;">
                        Generated on: <%= new java.util.Date() %><br>
                        Organization: <%= loggedInUser != null ? loggedInUser.getFullName() : "Enterprise" %>
                    </div>
                </div>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 20px;">
                <div>
                    <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-building"></i> Bulk Procurement Orders</h1>
                    <p style="color: #6B7280; font-size: 14px;">Enterprise supply chain procurement ledger and multi-farmer delivery confirmation.</p>
                </div>
                <button onclick="window.print();" class="no-print" style="background: #1E3A8A; color: white; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-print"></i> Print Procurement Statement
                </button>
            </div>

            <!-- Navigation Tabs -->
            <div class="order-nav-tabs no-print">
                <a href="${pageContext.request.contextPath}/commercial/orders?status=ALL" class="order-tab <%= "ALL".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-clipboard-list"></i> All Procurements
                </a>
                <a href="${pageContext.request.contextPath}/commercial/orders?status=PLACED" class="order-tab <%= "PLACED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    ⏳ Pending Approval
                </a>
                <a href="${pageContext.request.contextPath}/commercial/orders?status=PROCESSING" class="order-tab <%= "PROCESSING".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-truck-fast"></i> In-Transit / Active
                </a>
                <a href="${pageContext.request.contextPath}/commercial/orders?status=DELIVERED" class="order-tab <%= "DELIVERED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-bell"></i> Awaiting Confirmation
                </a>
                <a href="${pageContext.request.contextPath}/commercial/orders?status=COMPLETED" class="order-tab <%= "COMPLETED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-circle-check"></i> Completed Procurements
                </a>
                <a href="${pageContext.request.contextPath}/commercial/orders?status=CANCELLED" class="order-tab <%= "CANCELLED".equalsIgnoreCase(currentStatusFilter) ? "active" : "" %>">
                    <i class="fa-solid fa-circle-xmark"></i> Cancelled / Rejected
                </a>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <% if (orders == null || orders.isEmpty()) { %>
                <div style="background: white; border-radius: 18px; padding: 50px 20px; text-align: center; border: 1px solid #E5E7EB;">
                    <div style="font-size: 50px; margin-bottom: 12px;"><i class="fa-solid fa-building"></i></div>
                    <h3 style="font-size: 20px; color: #1F2937; margin-bottom: 8px;">No bulk procurement orders found</h3>
                    <p style="color: #6B7280; font-size: 14px;">Place bulk orders from contracted farms in the wholesale marketplace!</p>
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
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; padding-bottom: 14px; border-bottom: 1px solid #F3F4F6; margin-bottom: 16px;">
                            <div>
                                <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 2px;">
                                    PO #<%= o.getOrderNumber() %>
                                    <% if (o.getGstinApplied() != null && !o.getGstinApplied().isEmpty()) { %>
                                        <span style="font-size: 11px; background: #DBEAFE; color: #1E40AF; padding: 2px 8px; border-radius: 8px; margin-left: 6px;">GST: <%= o.getGstinApplied() %></span>
                                    <% } %>
                                </h3>
                                <div style="font-size: 13px; color: #6B7280;">Procured on: <%= o.getOrderDate() %></div>
                            </div>

                            <div style="display: flex; align-items: center; gap: 14px;">
                                <span class="status-badge <%= mStatusCls %>"><%= mStatus.replace("_", " ") %></span>
                                <div style="font-size: 20px; font-weight: 700; color: #1E3A8A;">₹<%= o.getTotalAmount() %></div>
                            </div>
                                 <!-- Logistics Delivery Destination -->
                        <div style="background: #F8FAFC; padding: 12px 16px; border-radius: 10px; font-size: 13px; margin-bottom: 16px;">
                            <strong>Delivery Destination:</strong> <%= o.getDeliveryName() %> | 📞 <%= o.getDeliveryPhone() %> | <i class="fa-solid fa-location-dot"></i> <%= o.getDeliveryAddress() %> - <%= o.getDeliveryPincode() %> | 📅 <strong>Requested Delivery:</strong> <span style="color: #1E40AF; font-weight: 700;"><%= o.getFormattedDeliveryDate() %></span> | <i class="fa-solid fa-credit-card"></i> Mode: <strong><%= o.getPaymentMethod() %></strong> (<%= o.getPaymentStatus() %>)
                        </div>

                        <!-- Multi-Vendor Sub-Orders -->
                        <h4 style="font-size: 13px; font-weight: 700; color: #6B7280; text-transform: uppercase; margin-bottom: 10px;">Supplier Lots & Fulfillment Packages</h4>

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
                                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; padding-bottom: 8px; border-bottom: 1px solid #E2E8F0; margin-bottom: 10px;">
                                    <div>
                                        <strong style="color: #0F172A;"><i class="fa-solid fa-wheat-awn text-success me-1"></i> Supplier: <%= (so.getFarmerName() != null && !so.getFarmerName().isEmpty()) ? so.getFarmerName() : "Contract Farmer" %> <%= (so.getFarmName() != null && !so.getFarmName().isEmpty()) ? "(" + so.getFarmName() + ")" : "" %></strong>
                                        <span style="font-size: 12px; color: #64748B; margin-left: 8px;">Sub-Order #<%= so.getSubOrderNumber() %> | Est. Delivery: <strong style="color: #1E40AF;"><%= so.getFormattedDeliveryDate() %></strong></span>
                                    </div>
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <span class="status-badge <%= soCls %>"><%= soStatus.replace("_", " ") %></span>
                                        <span style="font-weight: 700; color: #0F172A;">₹<%= so.getTotalAmount() %></span>
                                    </div>
                                </div>

                                <!-- Items from this Farm -->
                                <% if (so.getItems() != null && !so.getItems().isEmpty()) {
                                    for (OrderItem oi : so.getItems()) { %>
                                        <div style="display: flex; justify-content: space-between; font-size: 13px; padding: 4px 0;">
                                            <span><i class="fa-solid fa-wheat-awn"></i> <%= oi.getProductName() %> (× <%= oi.getQuantity() %> <%= oi.getUnit() != null ? oi.getUnit() : "kg" %> @ ₹<%= oi.getUnitPrice() %>)</span>
                                            <span style="font-weight: 600;">₹<%= oi.getSubtotal() %></span>
                                        </div>
                                    <%  }
                                       } %>

                                <!-- Delivery Confirmation Action for Commercial Buyer & Chat -->
                                <div class="no-print" style="margin-top: 10px; padding-top: 8px; border-top: 1px solid #E2E8F0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                                    <div style="flex-grow: 1;">
                                        <% if ("DELIVERED".equals(soStatus)) { %>
                                            <div style="background: #FEF3C7; border: 1px solid #FCD34D; border-radius: 10px; padding: 10px 14px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                                                <div>
                                                    <strong style="color: #92400E;"><i class="fa-solid fa-truck-fast"></i> Lot Delivered by <%= so.getFarmerName() %>!</strong>
                                                    <div style="font-size: 12px; color: #78350F;">Produce received at facility. Verify quality and confirm receipt to release escrow payout.</div>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/commercial/order/confirm-delivery" method="post" style="margin: 0;" onsubmit="return confirm('Confirm inspection & receipt of lot from <%= so.getFarmerName() %>? This will release payout to the farmer.');">
                                                    <input type="hidden" name="subOrderId" value="<%= so.getSubOrderId() %>">
                                                    <button type="submit" style="background: #1E3A8A; color: white; border: none; padding: 8px 18px; border-radius: 8px; font-weight: 600; cursor: pointer;">
                                                        <i class="fa-solid fa-circle-check"></i> Confirm Lot Received
                                                    </button>
                                                </form>
                                            </div>
                                        <% } else if ("COMPLETED".equals(soStatus)) { %>
                                            <div style="color: #047857; font-size: 12px; font-weight: 600;">
                                                <i class="fa-solid fa-circle-check"></i> Lot verified & payment disbursed to <%= so.getFarmerName() %>.
                                            </div>
                                        <% } %>
                                    </div>

                                    <div style="display: flex; gap: 8px;">
                                        <button type="button" 
                                                style="background: #0284C7; color: white; border: none; padding: 7px 16px; border-radius: 8px; font-size: 12px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;"
                                                onclick="openDeliveryMapModal(<%= so.getSubOrderId() %>, '<%= so.getSubOrderNumber() %>')">
                                            <i class="fa-solid fa-map-location-dot"></i> Track Route
                                        </button>
                                        <a href="${pageContext.request.contextPath}/chat?subOrderId=<%= so.getSubOrderId() %>" 
                                           style="background: #1E3A8A; color: white; border: none; padding: 7px 16px; border-radius: 8px; font-size: 12px; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                                            <i class="fa-solid fa-comments"></i> <%= ("COMPLETED".equals(soStatus) || "CANCELLED".equals(soStatus) || "REJECTED".equals(soStatus)) ? "View Chat History" : "Chat with Supplier" %>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        <%  }
                           } %>

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
                        <span class="text-success fw-bold">● Farm Dispatch</span> → <span class="text-primary fw-bold">● Enterprise Delivery Destination</span>
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
                            .bindPopup('<b><i class="fa-solid fa-tractor"></i> Farm Dispatch:</b><br>' + (data.pickupName || 'Farm Facility') + '<br><small class="text-muted">' + (data.pickupAddress || '') + '</small>').openPopup();

                        const dMarker = L.marker([dLat, dLon]).addTo(mapInstance)
                            .bindPopup('<b><i class="fa-solid fa-building"></i> Enterprise Delivery:</b><br>' + (data.deliveryName || 'Facility') + '<br><small class="text-muted">' + (data.deliveryAddress || '') + '</small>');

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
                                            color: '#1E3A8A',
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
