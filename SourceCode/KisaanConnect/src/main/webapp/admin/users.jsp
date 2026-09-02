<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.dao.AdminDAO"%>

<%
    List<User> users = (List<User>) request.getAttribute("users");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    String selectedRole = (String) request.getAttribute("selectedRole");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String searchQuery = (String) request.getAttribute("searchQuery");

    if (users == null) {
        AdminDAO adminDAO = new AdminDAO();
        users = adminDAO.getUsersByFilter(null, null, null);
        stats = adminDAO.getPlatformStats();
        selectedRole = "ALL";
        selectedStatus = "ALL";
        searchQuery = "";
    }
    if (selectedRole == null) selectedRole = "ALL";
    if (selectedStatus == null) selectedStatus = "ALL";
    if (searchQuery == null) searchQuery = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Verification & Management | KisaanConnect Admin</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    

    <style>
        body { font-family: var(--kc-font); background: #f8fafc; }
        .filter-btn { border-radius: 20px; font-weight: 600; font-size: 13px; padding: 6px 16px; border: 1px solid #e2e8f0; background: #ffffff; color: #475569; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; }
        .filter-btn.active { background: #16a34a; color: #ffffff; border-color: #16a34a; }
        .badge-pending { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .badge-active { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .badge-rejected { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .badge-suspended { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .user-table th { font-weight: 700; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; }
        .user-table td { vertical-align: middle; }
    </style>
</head>

<body>

    <%@ include file="/includes/admin-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/admin-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1"><i class="fa-solid fa-shield-halved"></i> User Verification & Governance Console</h1>
                    <p class="text-muted small mb-0">Review pending registrations, inspect farm & commercial details, approve or reject applications, and manage platform access.</p>
                </div>
                <div class="d-flex gap-2">
                    <span class="badge bg-warning text-dark px-3 py-2 fs-6 rounded-pill d-flex align-items-center gap-1">
                        <i class="bi bi-hourglass-split"></i> <%= stats != null && stats.get("pendingUsers") != null ? stats.get("pendingUsers") : 0 %> Pending Review
                    </span>
                </div>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <!-- Filters & Search Bar -->
            <div class="card border-0 shadow-sm rounded-4 p-3 mb-4">
                <form action="${pageContext.request.contextPath}/admin/users" method="get" class="row g-3 align-items-center">
                    <div class="col-lg-4">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" name="search" class="form-control bg-light border-start-0" placeholder="Search by name, email, phone..." value="<%= searchQuery %>">
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <select name="role" class="form-select bg-light">
                            <option value="ALL" <%= "ALL".equalsIgnoreCase(selectedRole) ? "selected" : "" %>>All Roles (Farmers, Buyers, Commercial)</option>
                            <option value="FARMER" <%= "FARMER".equalsIgnoreCase(selectedRole) ? "selected" : "" %>>Farmers Only</option>
                            <option value="BUYER" <%= "BUYER".equalsIgnoreCase(selectedRole) ? "selected" : "" %>>Buyers / Consumers Only</option>
                            <option value="COMMERCIAL" <%= "COMMERCIAL".equalsIgnoreCase(selectedRole) ? "selected" : "" %>>Commercial Organizations Only</option>
                            <option value="ADMIN" <%= "ADMIN".equalsIgnoreCase(selectedRole) ? "selected" : "" %>>Platform Administrators</option>
                        </select>
                    </div>
                    <div class="col-lg-3">
                        <select name="status" class="form-select bg-light">
                            <option value="ALL" <%= "ALL".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>All Statuses</option>
                            <option value="PENDING" <%= "PENDING".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>⏳ Verification Pending</option>
                            <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>><i class="fa-solid fa-circle-check"></i> Verified / Active</option>
                            <option value="REJECTED" <%= "REJECTED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>><i class="fa-solid fa-circle-xmark"></i> Verification Rejected</option>
                            <option value="SUSPENDED" <%= "SUSPENDED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>🚫 Suspended</option>
                        </select>
                    </div>
                    <div class="col-lg-2 d-flex gap-2">
                        <button type="submit" class="btn btn-success fw-semibold w-100"><i class="bi bi-funnel-fill me-1"></i> Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary"><i class="bi bi-x-circle"></i></a>
                    </div>
                </form>
            </div>

            <!-- Users Table -->
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover user-table mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">User</th>
                                <th>Contact Details</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Registered</th>
                                <th class="text-end pe-4">Verification & Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users != null && !users.isEmpty()) {
                                for (User u : users) {
                                    String st = u.getStatus() != null ? u.getStatus().toUpperCase() : "PENDING";
                            %>
                                <tr>
                                    <td class="ps-4">
                                        <div class="fw-bold text-dark"><%= u.getFullName() %></div>
                                        <div class="text-muted small">ID: #<%= u.getUserId() %></div>
                                    </td>
                                    <td>
                                        <div class="small fw-semibold text-dark"><i class="bi bi-envelope me-1 text-muted"></i><%= u.getEmail() %></div>
                                        <div class="small text-muted"><i class="bi bi-telephone me-1"></i><%= u.getPhone() != null ? u.getPhone() : "N/A" %></div>
                                    </td>
                                    <td>
                                        <% if ("FARMER".equalsIgnoreCase(u.getRole())) { %>
                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1"><i class="bi bi-flower1 me-1"></i>Farmer</span>
                                        <% } else if ("COMMERCIAL".equalsIgnoreCase(u.getRole())) { %>
                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1"><i class="bi bi-building me-1"></i>Commercial</span>
                                        <% } else if ("ADMIN".equalsIgnoreCase(u.getRole())) { %>
                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1"><i class="bi bi-shield-lock me-1"></i>Administrator</span>
                                        <% } else { %>
                                            <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle px-2 py-1"><i class="bi bi-person me-1"></i>Buyer</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if ("PENDING".equals(st)) { %>
                                            <span class="badge badge-pending px-2 py-1"><i class="bi bi-hourglass-split me-1"></i>Pending Review</span>
                                        <% } else if ("ACTIVE".equals(st)) { %>
                                            <span class="badge badge-active px-2 py-1"><i class="bi bi-check-circle-fill me-1"></i>Active</span>
                                        <% } else if ("REJECTED".equals(st)) { %>
                                            <span class="badge badge-rejected px-2 py-1"><i class="bi bi-x-circle me-1"></i>Rejected</span>
                                        <% } else if ("SUSPENDED".equals(st)) { %>
                                            <span class="badge badge-suspended px-2 py-1"><i class="bi bi-slash-circle me-1"></i>Suspended</span>
                                        <% } else { %>
                                            <span class="badge bg-light text-dark px-2 py-1"><%= st %></span>
                                        <% } %>
                                    </td>
                                    <td class="small text-muted">
                                        <%= u.getCreatedAt() != null ? u.getCreatedAt().toString().substring(0, 10) : "N/A" %>
                                    </td>
                                    <td class="text-end pe-4">
                                        <div class="d-inline-flex gap-1">
                                            <!-- Review Profile Modal Button -->
                                            <button type="button" class="btn btn-sm btn-outline-primary fw-semibold" onclick="openReviewModal(<%= u.getUserId() %>)">
                                                <i class="bi bi-eye me-1"></i> Inspect
                                            </button>

                                            <% if (!"ADMIN".equalsIgnoreCase(u.getRole())) { %>
                                                <% if ("PENDING".equals(st) || "REJECTED".equals(st)) { %>
                                                    <!-- Approve Button -->
                                                    <form action="${pageContext.request.contextPath}/admin/approve-user" method="post" class="d-inline">
                                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                                        <button type="submit" class="btn btn-sm btn-success fw-semibold" title="Approve Verification">
                                                            <i class="bi bi-check-lg"></i> Approve
                                                        </button>
                                                    </form>
                                                <% } %>

                                                <% if ("PENDING".equals(st)) { %>
                                                    <!-- Reject Button -->
                                                    <button type="button" class="btn btn-sm btn-danger fw-semibold" onclick="openRejectModal(<%= u.getUserId() %>, '<%= u.getFullName().replace("'", "\\'") %>')" title="Reject Application">
                                                        <i class="bi bi-x-lg"></i> Reject
                                                    </button>
                                                <% } %>

                                                <% if ("ACTIVE".equals(st)) { %>
                                                    <!-- Suspend Button -->
                                                    <form action="${pageContext.request.contextPath}/admin/toggle-user-status" method="post" class="d-inline">
                                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                                        <input type="hidden" name="status" value="SUSPENDED">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger fw-semibold" title="Suspend Account" onclick="return confirm('Suspend this user account?');">
                                                            <i class="bi bi-slash-circle"></i> Suspend
                                                        </button>
                                                    </form>
                                                <% } else if ("SUSPENDED".equals(st)) { %>
                                                    <!-- Reactivate Button -->
                                                    <form action="${pageContext.request.contextPath}/admin/toggle-user-status" method="post" class="d-inline">
                                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                                        <input type="hidden" name="status" value="ACTIVE">
                                                        <button type="submit" class="btn btn-sm btn-outline-success fw-semibold" title="Reactivate Account">
                                                            <i class="bi bi-arrow-counterclockwise"></i> Reactivate
                                                        </button>
                                                    </form>
                                                <% } %>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-person-x fs-1 d-block mb-2 text-secondary"></i>
                                        No users match the selected filters.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

    </div>

    <!-- Application Review Modal -->
    <div class="modal fade" id="reviewModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <div class="modal-header border-bottom-0 pb-0">
                    <h5 class="modal-title fw-bold" id="reviewModalTitle"><i class="bi bi-file-earmark-person me-2 text-success"></i>Application Profile Verification</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body pt-3" id="reviewModalBody">
                    <div class="text-center py-4">
                        <div class="spinner-border text-success" role="status"></div>
                        <p class="text-muted mt-2">Loading profile details...</p>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0" id="reviewModalFooter">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Rejection Reason Modal -->
    <div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <form action="${pageContext.request.contextPath}/admin/reject-user" method="post">
                    <input type="hidden" name="userId" id="rejectUserId">
                    <div class="modal-header border-bottom-0">
                        <h5 class="modal-title fw-bold text-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i>Reject Application</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p class="text-muted small">Please provide a clear reason for rejecting the application for <strong id="rejectUserName" class="text-dark"></strong>. This reason will be displayed on the applicant's status page.</p>
                        <div class="mb-3">
                            <label class="form-label fw-semibold text-dark">Reason for Rejection *</label>
                            <textarea name="reason" class="form-control" rows="3" required placeholder="e.g. Farm location or land documents could not be verified. Please re-submit with accurate address details."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger fw-semibold">Confirm Rejection</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function val(str, fallback) {
            if (str === null || str === undefined || str === '' || str === 'null') {
                return fallback || 'Not provided';
            }
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;');
        }

        function openReviewModal(userId) {
            const modal = new bootstrap.Modal(document.getElementById('reviewModal'));
            const modalBody = document.getElementById('reviewModalBody');
            modal.show();

            fetch('${pageContext.request.contextPath}/admin/user-details?userId=' + encodeURIComponent(userId))
                .then(r => r.json())
                .then(d => {
                    const role = d.role || 'Not provided';
                    const status = d.status || 'PENDING';
                    let statusBadge = '<span class="badge bg-warning text-dark px-2 py-1">' + val(status) + '</span>';
                    if (status === 'ACTIVE') statusBadge = '<span class="badge bg-success text-white px-2 py-1">Active / Verified</span>';
                    else if (status === 'REJECTED') statusBadge = '<span class="badge bg-danger text-white px-2 py-1">Rejected</span>';
                    else if (status === 'SUSPENDED') statusBadge = '<span class="badge bg-secondary text-white px-2 py-1">Suspended</span>';

                    let html = '<div class="row g-3">' +
                        '<div class="col-md-6">' +
                            '<label class="text-muted small">Full Name</label>' +
                            '<div class="fw-bold text-dark fs-6">' + val(d.fullName) + '</div>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<label class="text-muted small">Registered Role</label>' +
                            '<div><span class="badge bg-secondary-subtle text-secondary fw-bold px-2 py-1">' + val(role) + '</span></div>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<label class="text-muted small">Email Address</label>' +
                            '<div class="fw-semibold text-dark">' + val(d.email) + '</div>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<label class="text-muted small">Contact Phone</label>' +
                            '<div class="fw-semibold text-dark">' + val(d.phone) + '</div>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<label class="text-muted small">Status</label>' +
                            '<div>' + statusBadge + '</div>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<label class="text-muted small">Registration Date</label>' +
                            '<div class="text-dark">' + val(d.createdAt) + '</div>' +
                        '</div>';

                    if (role === 'FARMER') {
                        const locParts = [];
                        if (d.village) locParts.push(d.village);
                        if (d.taluka) locParts.push(d.taluka);
                        const villageTaluka = locParts.length > 0 ? locParts.join(', ') : 'Not provided';

                        const distStateParts = [];
                        if (d.district) distStateParts.push(d.district);
                        if (d.state) distStateParts.push(d.state);
                        let distState = distStateParts.length > 0 ? distStateParts.join(', ') : 'Not provided';
                        if (d.pincode) distState += ' - ' + d.pincode;

                        let gpsCoord = 'Not provided';
                        if (d.latitude !== null && d.latitude !== undefined && d.longitude !== null && d.longitude !== undefined) {
                            gpsCoord = 'Lat: ' + d.latitude + ', Lon: ' + d.longitude;
                        }

                        html += '<div class="col-12"><hr class="my-2"></div>' +
                            '<div class="col-12"><h6 class="fw-bold text-success mb-2"><i class="bi bi-flower1 me-1"></i> Agricultural Farm Details</h6></div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Farm Name</label>' +
                                '<div class="fw-semibold text-dark">' + val(d.farmName) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Village / Taluka</label>' +
                                '<div class="text-dark">' + val(villageTaluka) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">District / State / PIN</label>' +
                                '<div class="text-dark">' + val(distState) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Farm Address</label>' +
                                '<div class="text-dark">' + val(d.farmAddress) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Farm GPS Coordinates</label>' +
                                '<div class="text-dark font-monospace small"><i class="bi bi-geo-alt-fill text-danger me-1"></i>' + val(gpsCoord) + '</div>' +
                            '</div>';

                    } else if (role === 'COMMERCIAL') {
                        let addrParts = [];
                        if (d.address) addrParts.push(d.address);
                        if (d.city) addrParts.push(d.city);
                        if (d.district) addrParts.push(d.district);
                        if (d.state) addrParts.push(d.state);
                        let fullAddr = addrParts.length > 0 ? addrParts.join(', ') : 'Not provided';
                        if (d.pincode) fullAddr += ' - ' + d.pincode;

                        let contactParts = [];
                        if (d.businessEmail) contactParts.push(d.businessEmail);
                        if (d.businessPhone) contactParts.push(d.businessPhone);
                        const businessContact = contactParts.length > 0 ? contactParts.join(' / ') : 'Not provided';

                        let gpsCoord = 'Not provided';
                        if (d.latitude !== null && d.latitude !== undefined && d.longitude !== null && d.longitude !== undefined) {
                            gpsCoord = 'Lat: ' + d.latitude + ', Lon: ' + d.longitude;
                        }

                        html += '<div class="col-12"><hr class="my-2"></div>' +
                            '<div class="col-12"><h6 class="fw-bold text-primary mb-2"><i class="bi bi-building me-1"></i> Commercial Organization & Compliance</h6></div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Organization Name</label>' +
                                '<div class="fw-semibold text-dark">' + val(d.orgName) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">GSTIN</label>' +
                                '<div class="fw-bold text-dark font-monospace">' + val(d.gstin) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">PAN Number</label>' +
                                '<div class="fw-bold text-dark font-monospace">' + val(d.panNumber) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Business Contact</label>' +
                                '<div class="text-dark">' + val(businessContact) + '</div>' +
                            '</div>' +
                            '<div class="col-md-12">' +
                                '<label class="text-muted small">Registered Business Address</label>' +
                                '<div class="text-dark">' + val(fullAddr) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Premises GPS Coordinates</label>' +
                                '<div class="text-dark font-monospace small"><i class="bi bi-geo-alt-fill text-danger me-1"></i>' + val(gpsCoord) + '</div>' +
                            '</div>';

                    } else if (role === 'BUYER') {
                        let addrParts = [];
                        if (d.address) addrParts.push(d.address);
                        if (d.city) addrParts.push(d.city);
                        if (d.district) addrParts.push(d.district);
                        if (d.state) addrParts.push(d.state);
                        let fullAddr = addrParts.length > 0 ? addrParts.join(', ') : 'Not provided';
                        if (d.pincode) fullAddr += ' - ' + d.pincode;

                        let gpsCoord = 'Not provided';
                        if (d.latitude !== null && d.latitude !== undefined && d.longitude !== null && d.longitude !== undefined) {
                            gpsCoord = 'Lat: ' + d.latitude + ', Lon: ' + d.longitude;
                        }

                        html += '<div class="col-12"><hr class="my-2"></div>' +
                            '<div class="col-12"><h6 class="fw-bold text-info mb-2"><i class="bi bi-person-badge me-1"></i> Delivery & Address Profile</h6></div>' +
                            '<div class="col-md-12">' +
                                '<label class="text-muted small">Delivery Address</label>' +
                                '<div class="text-dark">' + val(fullAddr) + '</div>' +
                            '</div>' +
                            '<div class="col-md-6">' +
                                '<label class="text-muted small">Delivery GPS Coordinates</label>' +
                                '<div class="text-dark font-monospace small"><i class="bi bi-geo-alt-fill text-danger me-1"></i>' + val(gpsCoord) + '</div>' +
                            '</div>';
                    } else if (role === 'ADMIN') {
                        html += '<div class="col-12"><hr class="my-2"></div>' +
                            '<div class="col-12"><h6 class="fw-bold text-danger mb-2"><i class="bi bi-shield-lock me-1"></i> Platform Administration Profile</h6></div>' +
                            '<div class="col-md-12">' +
                                '<div class="text-muted small">System Administrator account with full platform governance access. Profile extended fields: <span class="badge bg-light text-dark border">Not applicable</span></div>' +
                            '</div>';
                    }

                    if (d.rejectionReason) {
                        html += '<div class="col-12">' +
                            '<div class="alert alert-danger mb-0 mt-2">' +
                                '<div class="fw-bold"><i class="bi bi-x-circle-fill me-1"></i> Rejection Reason:</div>' +
                                '<div>' + val(d.rejectionReason) + '</div>' +
                            '</div>' +
                        '</div>';
                    }

                    html += '</div>';
                    modalBody.innerHTML = html;
                })
                .catch(err => {
                    modalBody.innerHTML = '<div class="alert alert-danger">Failed to load user profile: ' + val(err) + '</div>';
                });
        }

        function openRejectModal(userId, userName) {
            document.getElementById('rejectUserId').value = userId;
            document.getElementById('rejectUserName').innerText = userName;
            const modal = new bootstrap.Modal(document.getElementById('rejectModal'));
            modal.show();
        }
    </script>
</body>
</html>
