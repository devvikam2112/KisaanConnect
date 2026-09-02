<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.dao.FarmerProfileDAO"%>
<%@page import="com.kisaanconnect.model.User"%>

<%
    User checkUser = (User) session.getAttribute("loggedInUser");
    if (checkUser != null) {
        FarmerProfileDAO checkDAO = new FarmerProfileDAO();
        if (checkDAO.profileExists(checkUser.getUserId())) {
            response.sendRedirect(request.getContextPath() + "/farmer/profile");
            return;
        }
    }
%>

<!DOCTYPE html>
<html>

<head>

    <title>Farmer Profile | KisaanConnect</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/common.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/farmer-profile.css">

</head>

<body>

<div class="farmer-bg">

    <div class="profile-container">

        <img
            src="${pageContext.request.contextPath}/assets/images/logo.png"
            class="logo"
            alt="KisaanConnect">

        <h1>Complete Farmer Profile</h1>

        <p>
            Tell buyers about your farm.
        </p>

        <form action="${pageContext.request.contextPath}/farmer/setup-profile"
              method="post"
              enctype="multipart/form-data">

            <!-- Farm Name -->

            <div class="input-group">

                <label>Farm Name</label>

                <input
                    type="text"
                    name="farmName"
                    placeholder="Enter Farm's Name"
                    required>

            </div>

            <!-- Farm Address -->

            <div class="input-group">

                <label>Farm Address</label>

                <textarea
                    name="farmAddress"
                    rows="3"
                    placeholder="Enter Complete Farm Address"
                    required></textarea>

            </div>

            <!-- Village + Taluka -->

            <div class="form-row">

                <div class="input-group">

                    <label>Village</label>

                    <input
                        type="text"
                        name="village"
                        placeholder="Village"
                        required>

                </div>

                <div class="input-group">

                    <label>Taluka</label>

                    <input
                        type="text"
                        name="taluka"
                        placeholder="Taluka"
                        required>

                </div>

            </div>

            <!-- District + State -->

            <div class="form-row">

                <div class="input-group">

                    <label>District</label>

                    <input
                        type="text"
                        name="district"
                        placeholder="District"
                        required>

                </div>

                <div class="input-group">

                    <label>State</label>

                    <select name="state" required style="width: 100%; height: 48px; border: 1px solid #D1D5DB; border-radius: 12px; padding: 0 14px; background: white; font-family: inherit; font-size: 14px;">
                        <option value="">-- Select State / UT --</option>
                        <% for (String st : com.kisaanconnect.constants.AppConstants.INDIAN_STATES) { %>
                            <option value="<%= st %>"><%= st %></option>
                        <% } %>
                    </select>

                </div>

            </div>

            <!-- Pincode -->

            <div class="input-group">

                <label>Pincode</label>

                <input
                    type="text"
                    name="pincode"
                    maxlength="6"
                    placeholder="400001"
                    required>

            </div>

            <!-- Upload Box -->

            <div class="upload-group">

                <label>Profile Photo</label>

<label class="upload-box">

    <input
        type="file"
        name="profilePhoto"
        accept=".jpg,.jpeg,.png">

    <span class="upload-icon"><i class="fa-solid fa-user"></i></span>

    <h4>Upload Profile Photo</h4>

    <p>This photo will appear on your dashboard and profile.</p>

</label>

            </div>

            <button type="submit">

                Save & Continue

            </button>

        </form>

    </div>

    <!-- Decorative Wave -->

    <div class="wave"></div>

    <!-- Farm Illustration -->

    <div class="farm-land">

        <img
            src="${pageContext.request.contextPath}/assets/images/farm-land.png"
            alt="Farm Illustration">

    </div>

</div>

</body>

</html>