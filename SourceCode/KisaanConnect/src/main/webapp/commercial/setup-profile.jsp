<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.OrganizationType"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>

<%
    List<OrganizationType> orgTypes = (List<OrganizationType>) request.getAttribute("orgTypes");
    if (orgTypes == null || orgTypes.isEmpty()) {
        OrganizationDAO orgDAO = new OrganizationDAO();
        orgTypes = orgDAO.getActiveOrganizationTypes();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Setup Commercial Organisation | KisaanConnect</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/farmer-profile.css">
</head>
<body>

<div class="farmer-bg">

    <div class="profile-container" style="max-width: 680px;">

        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             class="logo"
             alt="KisaanConnect">

        <h1>Organisation Profile</h1>
        <p>Register your commercial establishment for bulk agricultural procurement.</p>

        <%@ include file="/includes/alerts.jsp" %>

        <form action="${pageContext.request.contextPath}/commercial/setup-profile" method="post">

            <!-- Org Name & Type -->
            <div class="form-row">
                <div class="input-group">
                    <label>Organisation / Business Name *</label>
                    <input type="text"
                           name="orgName"
                           placeholder="e.g. Royal Palace Hotel / ABC Caterers"
                           required>
                </div>

                <div class="input-group">
                    <label>Organisation Type *</label>
                    <select name="orgTypeId"
                            style="width: 100%; height: 54px; border: 1px solid #E5E7EB; border-radius: 14px; padding: 0 16px; font-family: var(--kc-font); font-size: 15px; background: #fff;"
                            required>
                        <option value="">-- Select Type --</option>
                        <% if (orgTypes != null) {
                            for (OrganizationType type : orgTypes) { %>
                                <option value="<%= type.getOrgTypeId() %>"><%= type.getTypeName() %></option>
                        <%  }
                           } %>
                    </select>
                </div>
            </div>

            <!-- Tax & Legal Identifiers -->
            <div class="form-row">
                <div class="input-group">
                    <label>GSTIN (Optional)</label>
                    <input type="text"
                           name="gstin"
                           maxlength="15"
                           placeholder="27AAAAA0000A1Z5">
                </div>

                <div class="input-group">
                    <label>PAN Number (Optional)</label>
                    <input type="text"
                           name="panNumber"
                           maxlength="10"
                           placeholder="ABCDE1234F">
                </div>
            </div>

            <!-- Business Contact -->
            <div class="form-row">
                <div class="input-group">
                    <label>Business Email *</label>
                    <input type="email"
                           name="businessEmail"
                           placeholder="procurement@company.com"
                           required>
                </div>

                <div class="input-group">
                    <label>Business Contact Phone *</label>
                    <input type="text"
                           name="businessPhone"
                           placeholder="Official contact number"
                           required>
                </div>
            </div>

            <!-- Business Address -->
            <div class="input-group">
                <label>Commercial Address *</label>
                <textarea name="address"
                          rows="2"
                          placeholder="Premises, Street, Area / Landmark"
                          required></textarea>
            </div>

            <!-- City + District -->
            <div class="form-row">
                <div class="input-group">
                    <label>City / Town *</label>
                    <input type="text"
                           name="city"
                           placeholder="City"
                           required>
                </div>

                <div class="input-group">
                    <label>District *</label>
                    <input type="text"
                           name="district"
                           placeholder="District"
                           required>
                </div>
            </div>

            <!-- State + Pincode -->
            <div class="form-row">
                <div class="input-group">
                    <label>State *</label>
                    <select name="state" required style="width: 100%; height: 48px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 14px; background: white; font-family: inherit; font-size: 14px;">
                        <option value="">-- Select State / UT --</option>
                        <% for (String st : com.kisaanconnect.constants.AppConstants.INDIAN_STATES) { %>
                            <option value="<%= st %>"><%= st %></option>
                        <% } %>
                    </select>
                </div>

                <div class="input-group">
                    <label>Pincode *</label>
                    <input type="text"
                           name="pincode"
                           maxlength="6"
                           placeholder="400001"
                           required>
                </div>
            </div>

            <button type="submit" style="margin-top: 15px;">
                Complete Organisation Setup
            </button>
        </form>
    </div>

    <div class="wave"></div>
    <div class="farm-land">
        <img src="${pageContext.request.contextPath}/assets/images/farm-land.png"
             alt="Farm Illustration">
    </div>

</div>

</body>
</html>
