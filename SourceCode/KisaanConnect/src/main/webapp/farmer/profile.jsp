<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.FarmerProfile"%>
<%@page import="com.kisaanconnect.dao.FarmerProfileDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    FarmerProfile farmerProfile = (FarmerProfile) request.getAttribute("farmerProfile");
    if (farmerProfile == null) {
        FarmerProfileDAO fpDAO = new FarmerProfileDAO();
        farmerProfile = fpDAO.getProfileByUserId(loggedInUser.getUserId());
    }

    if (farmerProfile == null) {
        response.sendRedirect(request.getContextPath() + "/farmer/setup-profile.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Farm Profile | KisaanConnect</title>

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
        .profile-layout {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 24px;
            margin-top: 24px;
        }

        @media (max-width: 900px) {
            .profile-layout {
                grid-template-columns: 1fr;
            }
        }

        .profile-card {
            background: white;
            border-radius: 18px;
            padding: 26px;
            border: 1px solid #E5E7EB;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        .avatar-container {
            text-align: center;
            padding-bottom: 20px;
            border-bottom: 1px solid #F3F4F6;
            margin-bottom: 20px;
        }

        .profile-img {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #DEF7EC;
            margin-bottom: 12px;
        }

        .profile-avatar-fallback {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, #2E7D32, #4CAF50);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 38px;
            margin: 0 auto 12px auto;
            border: 4px solid #DEF7EC;
        }

        .badge-verified {
            display: inline-block;
            background: #DEF7EC;
            color: #03543F;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-top: 6px;
        }

        .badge-pending {
            display: inline-block;
            background: #FEF08A;
            color: #854D0E;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-top: 6px;
        }

        .info-item {
            margin-bottom: 14px;
            font-size: 14px;
        }

        .info-label {
            color: #6B7280;
            display: block;
            margin-bottom: 2px;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-value {
            color: #1F2937;
            font-weight: 600;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        @media (max-width: 600px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
        }

        .form-control-input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #D1D5DB;
            border-radius: 10px;
            font-size: 14px;
            color: #1F2937;
            box-sizing: border-box;
            outline: none;
            transition: border-color 0.2s;
        }

        .form-control-input:focus {
            border-color: #2E7D32;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.15);
        }

        .save-btn {
            background: #2E7D32;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.2s;
        }

        .save-btn:hover {
            background: #1B5E20;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/farmer-sidebar.jsp" %>

    <div class="main-content">

        <%@ include file="/includes/farmer-navbar.jsp" %>

        <div class="dashboard-content" style="padding: 30px;">

            <%@ include file="/includes/alerts.jsp" %>

            <div>
                <h1 style="font-size: 26px; color: #1F2937; margin-bottom: 4px;"><i class="fa-solid fa-user"></i> Farm Profile & Details</h1>
                <p style="color: #6B7280; font-size: 14px;">View and edit your farm location, contact details, and registered profile information.</p>
            </div>

            <div class="profile-layout">

                <!-- Left Column: Profile Summary Card -->
                <div class="profile-card">
                    <div class="avatar-container">
                        <% if (farmerProfile.getProfilePhoto() != null && !farmerProfile.getProfilePhoto().trim().isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/<%= farmerProfile.getProfilePhoto() %>"
                                 alt="Profile Photo"
                                 class="profile-img">
                        <% } else { %>
                            <div class="profile-avatar-fallback">
                                <%= loggedInUser.getFullName() != null && !loggedInUser.getFullName().isEmpty() ? loggedInUser.getFullName().substring(0, 1).toUpperCase() : "F" %>
                            </div>
                        <% } %>

                        <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 4px;"><%= loggedInUser.getFullName() %></h3>
                        <p style="color: #6B7280; font-size: 13px; margin: 0;"><%= farmerProfile.getFarmName() != null ? farmerProfile.getFarmName() : "Farm" %></p>

                        <% if (farmerProfile.isVerified()) { %>
                            <span class="badge-verified">✓ Verified Farmer</span>
                        <% } else { %>
                            <span class="badge-pending">⏳ Verification Pending</span>
                        <% } %>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Account Email</span>
                        <span class="info-value"><%= loggedInUser.getEmail() %></span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Contact Phone</span>
                        <span class="info-value"><%= loggedInUser.getPhone() != null ? loggedInUser.getPhone() : "Not provided" %></span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Registered Location</span>
                        <span class="info-value">
                            <%= farmerProfile.getVillage() != null ? farmerProfile.getVillage() : "" %>,
                            <%= farmerProfile.getDistrict() != null ? farmerProfile.getDistrict() : "" %>,
                            <%= farmerProfile.getState() != null ? farmerProfile.getState() : "" %>
                        </span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Pincode</span>
                        <span class="info-value"><%= farmerProfile.getPincode() != null ? farmerProfile.getPincode() : "-" %></span>
                    </div>
                </div>

                <!-- Right Column: Edit Profile Form -->
                <div class="profile-card">
                    <h3 style="font-size: 18px; color: #1F2937; margin-bottom: 18px; padding-bottom: 10px; border-bottom: 1px solid #F3F4F6;">
                        <i class="fa-solid fa-pen-to-square" style="color: #2E7D32;"></i> Edit Farm Details
                    </h3>

                    <form action="${pageContext.request.contextPath}/farmer/profile"
                          method="post"
                          enctype="multipart/form-data">

                        <div class="form-grid">

                            <!-- Farm Name -->
                            <div class="form-group full-width">
                                <label>Farm Name *</label>
                                <input type="text"
                                       name="farmName"
                                       class="form-control-input"
                                       value="<%= farmerProfile.getFarmName() != null ? farmerProfile.getFarmName() : "" %>"
                                       placeholder="e.g. Green Valley Organic Farm"
                                       required>
                            </div>

                            <!-- Complete Farm Address -->
                            <div class="form-group full-width">
                                <label>Farm Address / Landmark *</label>
                                <textarea name="farmAddress"
                                          rows="3"
                                          class="form-control-input"
                                          placeholder="Enter complete farm address or survey number"
                                          required><%= farmerProfile.getFarmAddress() != null ? farmerProfile.getFarmAddress() : "" %></textarea>
                            </div>

                            <!-- Village -->
                            <div class="form-group">
                                <label>Village / Town *</label>
                                <input type="text"
                                       name="village"
                                       class="form-control-input"
                                       value="<%= farmerProfile.getVillage() != null ? farmerProfile.getVillage() : "" %>"
                                       placeholder="Village"
                                       required>
                            </div>

                            <!-- Taluka -->
                            <div class="form-group">
                                <label>Taluka / Block *</label>
                                <input type="text"
                                       name="taluka"
                                       class="form-control-input"
                                       value="<%= farmerProfile.getTaluka() != null ? farmerProfile.getTaluka() : "" %>"
                                       placeholder="Taluka"
                                       required>
                            </div>

                            <!-- District -->
                            <div class="form-group">
                                <label>District *</label>
                                <input type="text"
                                       name="district"
                                       class="form-control-input"
                                       value="<%= farmerProfile.getDistrict() != null ? farmerProfile.getDistrict() : "" %>"
                                       placeholder="District"
                                       required>
                            </div>

                            <!-- State -->
                            <div class="form-group">
                                <label>State *</label>
                                <select name="state" class="form-control-input" required>
                                    <option value="">-- Select State / UT --</option>
                                    <% for (String st : com.kisaanconnect.constants.AppConstants.INDIAN_STATES) { %>
                                        <option value="<%= st %>" <%= st.equalsIgnoreCase(farmerProfile.getState()) ? "selected" : "" %>><%= st %></option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- Pincode -->
                            <div class="form-group">
                                <label>Pincode *</label>
                                <input type="text"
                                       name="pincode"
                                       maxlength="6"
                                       class="form-control-input"
                                       value="<%= farmerProfile.getPincode() != null ? farmerProfile.getPincode() : "" %>"
                                       placeholder="6-digit pincode"
                                       required>
                            </div>

                            <!-- Photo Upload -->
                            <div class="form-group">
                                <label>Update Profile Photo</label>
                                <input type="file"
                                       name="profilePhoto"
                                       class="form-control-input"
                                       accept=".jpg,.jpeg,.png">
                            </div>

                        </div>

                        <div style="margin-top: 20px; display: flex; justify-content: flex-end;">
                            <button type="submit" class="save-btn">
                                <i class="fa-solid fa-floppy-disk"></i> Save Profile Changes
                            </button>
                        </div>

                    </form>
                </div>

            </div>

        </div>

    </div>

</body>
</html>
