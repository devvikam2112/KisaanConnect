<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Organization"%>
<%@page import="com.kisaanconnect.model.OrganizationType"%>
<%@page import="com.kisaanconnect.model.OrganizationMember"%>
<%@page import="com.kisaanconnect.model.User"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>
<%@page import="com.kisaanconnect.constants.AppConstants"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    Organization commercialOrg = (Organization) request.getAttribute("organization");
    List<OrganizationType> orgTypes = (List<OrganizationType>) request.getAttribute("orgTypes");
    List<OrganizationMember> members = (List<OrganizationMember>) request.getAttribute("members");

    if (commercialOrg == null) {
        OrganizationDAO orgDAO = new OrganizationDAO();
        commercialOrg = orgDAO.getOrganizationByUserId(loggedInUser.getUserId());
        if (commercialOrg != null) {
            orgTypes = orgDAO.getActiveOrganizationTypes();
            members = orgDAO.getOrganizationMembers(commercialOrg.getOrganizationId());
        }
    }

    if (commercialOrg == null) {
        response.sendRedirect(request.getContextPath() + "/commercial/setup-profile");
        return;
    }

    String currentState = (commercialOrg.getState() != null) ? commercialOrg.getState() : "";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Company Profile & Settings | KisaanConnect Commercial</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/forms.css">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">

    <style>
        .profile-container {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 24px;
            margin-top: 20px;
        }

        @media (max-width: 992px) {
            .profile-container {
                grid-template-columns: 1fr;
            }
        }

        .profile-card {
            background: white;
            border-radius: 20px;
            padding: 26px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        .info-item {
            margin-bottom: 16px;
        }

        .info-label {
            font-size: 12px;
            color: #6B7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }

        .info-value {
            font-size: 14px;
            color: #1F2937;
            font-weight: 600;
            margin-top: 2px;
        }

        .form-control-input {
            width: 100%;
            height: 46px;
            border: 1px solid #D1D5DB;
            border-radius: 10px;
            padding: 0 14px;
            font-family: inherit;
            font-size: 14px;
            background: #fff;
            box-sizing: border-box;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/commercial-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/commercial-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <div style="margin-bottom: 20px;">
                <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-building"></i> Commercial Organisation Profile</h1>
                <p style="color: #6B7280; font-size: 14px;">Manage your business entity details, GSTIN compliance, and procurement settings.</p>
            </div>

            <%@ include file="/includes/alerts.jsp" %>

            <div class="profile-container">

                <!-- Left Column: Company Summary Card -->
                <div class="profile-card">
                    <div style="text-align: center; margin-bottom: 20px;">
                        <div style="width: 80px; height: 80px; border-radius: 20px; background: #EFF6FF; color: #1E40AF; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 12px auto; border: 2px solid #BFDBFE;">
                            <i class="fa-solid fa-building"></i>
                        </div>
                        <h2 style="font-size: 20px; font-weight: 700; color: #1F2937; margin-bottom: 4px;">
                            <%= commercialOrg.getOrgName() %>
                        </h2>
                        <span style="font-size: 12px; font-weight: 600; padding: 4px 12px; border-radius: 20px; background: #EFF6FF; color: #1E40AF;">
                            <%= commercialOrg.getOrgTypeName() != null ? commercialOrg.getOrgTypeName() : "Corporate Buyer" %>
                        </span>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Account Status</div>
                        <div class="info-value">
                            <% if ("ACTIVE".equals(commercialOrg.getStatus())) { %>
                                <span style="color: #059669;"><i class="fa-solid fa-circle-check"></i> Active & Verified Entity</span>
                            <% } else { %>
                                <span style="color: #D97706;">⏳ Account Under Review</span>
                            <% } %>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">GSTIN / Tax ID</div>
                        <div class="info-value"><code><%= commercialOrg.getGstin() != null ? commercialOrg.getGstin() : "Not provided" %></code></div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">PAN Number</div>
                        <div class="info-value"><code><%= commercialOrg.getPanNumber() != null ? commercialOrg.getPanNumber() : "Not provided" %></code></div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Business Email</div>
                        <div class="info-value"><%= commercialOrg.getBusinessEmail() %></div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Contact Phone</div>
                        <div class="info-value"><%= commercialOrg.getBusinessPhone() %></div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Registered Location</div>
                        <div class="info-value"><%= commercialOrg.getCity() %>, <%= commercialOrg.getState() %> - <%= commercialOrg.getPincode() %></div>
                    </div>
                </div>

                <!-- Right Column: Edit Company Form -->
                <div class="profile-card">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 18px;"><i class="fa-solid fa-pen-to-square"></i> Edit Organisation Information</h3>

                    <form action="${pageContext.request.contextPath}/commercial/profile" method="post">

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">Organisation / Company Name *</label>
                                <input type="text"
                                       name="orgName"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getOrgName() %>"
                                       required>
                            </div>

                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">Organisation Type *</label>
                                <select name="orgTypeId" class="form-control-input" required>
                                    <% if (orgTypes != null) {
                                        for (OrganizationType t : orgTypes) { %>
                                            <option value="<%= t.getOrgTypeId() %>" <%= t.getOrgTypeId() == commercialOrg.getOrgTypeId() ? "selected" : "" %>>
                                                <%= t.getTypeName() %>
                                            </option>
                                    <%  }
                                       } %>
                                </select>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">GSTIN</label>
                                <input type="text"
                                       name="gstin"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getGstin() != null ? commercialOrg.getGstin() : "" %>"
                                       placeholder="15-digit GSTIN">
                            </div>

                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">PAN Number</label>
                                <input type="text"
                                       name="panNumber"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getPanNumber() != null ? commercialOrg.getPanNumber() : "" %>"
                                       placeholder="10-digit PAN">
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">Business Email *</label>
                                <input type="email"
                                       name="businessEmail"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getBusinessEmail() %>"
                                       required>
                            </div>

                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">Business Phone *</label>
                                <input type="text"
                                       name="businessPhone"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getBusinessPhone() %>"
                                       required>
                            </div>
                        </div>

                        <div style="margin-bottom: 16px;">
                            <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">Registered Office Address *</label>
                            <textarea name="address"
                                      rows="3"
                                      class="form-control-input"
                                      style="height: auto; padding: 10px 14px;"
                                      required><%= commercialOrg.getAddress() %></textarea>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">City / Town *</label>
                                <input type="text"
                                       name="city"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getCity() %>"
                                       required>
                            </div>

                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">District *</label>
                                <input type="text"
                                       name="district"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getDistrict() %>"
                                       required>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px;">
                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">State *</label>
                                <select name="state" class="form-control-input" required>
                                    <option value="">-- Select State / UT --</option>
                                    <% for (String st : AppConstants.INDIAN_STATES) { %>
                                        <option value="<%= st %>" <%= st.equalsIgnoreCase(currentState) ? "selected" : "" %>><%= st %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div>
                                <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px;">Pincode *</label>
                                <input type="text"
                                       name="pincode"
                                       maxlength="6"
                                       class="form-control-input"
                                       value="<%= commercialOrg.getPincode() %>"
                                       required>
                            </div>
                        </div>

                        <button type="submit" style="background: #1E40AF; color: white; border: none; padding: 12px 24px; border-radius: 10px; font-weight: 600; cursor: pointer;">
                            💾 Save Company Profile
                        </button>
                    </form>
                </div>

            </div>

        </div>

    </div>

</body>
</html>
