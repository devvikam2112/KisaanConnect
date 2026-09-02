<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.kisaanconnect.model.User"%>
<%
    User footerUser = (User) session.getAttribute("loggedInUser");
    if (footerUser == null) {
%>
<!-- Full Public Marketplace & Homepage Footer -->
<footer class="bg-dark text-white pt-5 pb-4 mt-5">
    <div class="container">
        <div class="row g-4">
            <!-- Brand Info -->
            <div class="col-lg-4 col-md-6">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <img src="${pageContext.request.contextPath}/assets/images/logo.png" alt="KisaanConnect Logo" height="40" style="filter: brightness(0) invert(1);" onerror="this.style.display='none'">
                    <span class="fs-4 fw-bold text-success">KisaanConnect</span>
                </div>
                <p class="text-secondary small mb-4" style="line-height: 1.7;">
                    Empowering Indian farmers through a direct B2B/B2C marketplace. Transparent pricing, zero middleman exploitation, secure digital escrow, and geotagged transit tracking.
                </p>
                <div class="d-flex gap-3">
                    <a href="#" class="text-secondary fs-5"><i class="fa-brands fa-facebook"></i></a>
                    <a href="#" class="text-secondary fs-5"><i class="fa-brands fa-twitter"></i></a>
                    <a href="#" class="text-secondary fs-5"><i class="fa-brands fa-instagram"></i></a>
                    <a href="#" class="text-secondary fs-5"><i class="fa-brands fa-linkedin"></i></a>
                </div>
            </div>

            <!-- Quick Links -->
            <div class="col-lg-2 col-md-6 col-6">
                <h6 class="fw-bold text-white mb-3 text-uppercase small letter-spacing-1">Marketplace</h6>
                <ul class="list-unstyled text-secondary small d-flex flex-column gap-2">
                    <li><a href="${pageContext.request.contextPath}/buyer/products" class="text-secondary text-decoration-none">Fresh Produce</a></li>
                    <li><a href="${pageContext.request.contextPath}/buyer/products?cat=Grains" class="text-secondary text-decoration-none">Grains & Cereals</a></li>
                    <li><a href="${pageContext.request.contextPath}/buyer/products?cat=Pulses" class="text-secondary text-decoration-none">Pulses & Legumes</a></li>
                    <li><a href="${pageContext.request.contextPath}/buyer/products?cat=Vegetables" class="text-secondary text-decoration-none">Organic Vegetables</a></li>
                    <li><a href="${pageContext.request.contextPath}/buyer/products?cat=Fruits" class="text-secondary text-decoration-none">Seasonal Fruits</a></li>
                </ul>
            </div>

            <!-- Public Portals -->
            <div class="col-lg-2 col-md-6 col-6">
                <h6 class="fw-bold text-white mb-3 text-uppercase small letter-spacing-1">Portals</h6>
                <ul class="list-unstyled text-secondary small d-flex flex-column gap-2">
                    <li><a href="${pageContext.request.contextPath}/auth/login.jsp" class="text-secondary text-decoration-none">Farmer Login</a></li>
                    <li><a href="${pageContext.request.contextPath}/auth/register.jsp" class="text-secondary text-decoration-none">Register Farm</a></li>
                    <li><a href="${pageContext.request.contextPath}/commercial/dashboard" class="text-secondary text-decoration-none">Commercial B2B</a></li>
                    <li><a href="${pageContext.request.contextPath}/buyer/orders.jsp" class="text-secondary text-decoration-none">Order Tracking</a></li>
                    <li><a href="${pageContext.request.contextPath}/notifications" class="text-secondary text-decoration-none">Notifications</a></li>
                </ul>
            </div>

            <!-- Contact & Support -->
            <div class="col-lg-4 col-md-6">
                <h6 class="fw-bold text-white mb-3 text-uppercase small letter-spacing-1">Contact & Support</h6>
                <ul class="list-unstyled text-secondary small d-flex flex-column gap-3 mb-3">
                    <li class="d-flex align-items-start gap-2">
                        <i class="fa-solid fa-location-dot mt-1 text-success"></i>
                        <span>KisaanConnect Agri Hub, Shivajinagar, Pune, Maharashtra 411005</span>
                    </li>
                    <li class="d-flex align-items-center gap-2">
                        <i class="fa-solid fa-phone text-success"></i>
                        <span>+91 99999 99999 / 1800-KISAAN-CONNECT</span>
                    </li>
                    <li class="d-flex align-items-center gap-2">
                        <i class="fa-solid fa-envelope text-success"></i>
                        <span>support@kisaanconnect.in</span>
                    </li>
                </ul>
                <div class="p-2 rounded-3 bg-secondary bg-opacity-10 border border-secondary border-opacity-25 small text-secondary">
                    <i class="fa-solid fa-shield-halved text-success me-1"></i> Admin & Digital Escrow Verified System
                </div>
            </div>
        </div>

        <hr class="border-secondary my-4 opacity-25">

        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-2 text-secondary small">
            <div>
                &copy; <%= java.time.Year.now().getValue() %> KisaanConnect Technologies Pvt. Ltd. All rights reserved.
            </div>
            <div class="d-flex gap-3">
                <a href="#" class="text-secondary text-decoration-none">Privacy Policy</a>
                <a href="#" class="text-secondary text-decoration-none">Terms of Trade</a>
                <a href="#" class="text-secondary text-decoration-none">Farmer Charter</a>
            </div>
        </div>
    </div>
</footer>
<% } else { %>
<!-- Compact Authenticated Application Footer -->
<footer class="app-compact-footer bg-white border-top py-3 mt-4 no-print">
    <div class="container d-flex flex-column flex-md-row justify-content-between align-items-center gap-2 text-muted small">
        <div class="d-flex align-items-center gap-2">
            <span class="fw-bold text-success">KisaanConnect</span>
            <span>&copy; <%= java.time.Year.now().getValue() %> All rights reserved.</span>
            <span class="badge bg-success-subtle text-success border border-success-subtle ms-2"><i class="fa-solid fa-shield-halved me-1"></i>Escrow Protected</span>
        </div>
        <div class="d-flex align-items-center gap-3">
            <span><i class="fa-solid fa-headset me-1 text-secondary"></i>Support: <a href="mailto:support@kisaanconnect.in" class="text-muted text-decoration-none">support@kisaanconnect.in</a></span>
            <span class="text-muted">|</span>
            <a href="#" class="text-muted text-decoration-none">Terms of Trade</a>
            <a href="#" class="text-muted text-decoration-none">Privacy</a>
        </div>
    </div>
</footer>
<% } %>
