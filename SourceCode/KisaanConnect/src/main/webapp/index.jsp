<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.kisaanconnect.model.Product"%>
<%@page import="com.kisaanconnect.dao.ProductDAO"%>
<%@page import="com.kisaanconnect.model.Category"%>
<%@page import="com.kisaanconnect.dao.CategoryDAO"%>
<%
    ProductDAO productDAO = new ProductDAO();
    List<Product> featuredProducts = productDAO.getAllAvailableProducts();
    if (featuredProducts != null && featuredProducts.size() > 8) {
        featuredProducts = featuredProducts.subList(0, 8);
    }

    CategoryDAO categoryDAO = new CategoryDAO();
    List<Category> categories = categoryDAO.getActiveCategories();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KisaanConnect | Direct Farm-to-Table & Wholesale Agricultural Marketplace</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    

    <style>
        body { font-family: var(--kc-font); color: #1e293b; background: #ffffff; }
        
        .hero-section {
            background: linear-gradient(135deg, #f0fdf4 0%, #e2f7e8 50%, #f8fafc 100%);
            padding: 70px 0 60px;
            position: relative;
            overflow: hidden;
            border-bottom: 1px solid #dcfce7;
        }
        .hero-badge {
            background: #dcfce7;
            color: #15803d;
            font-weight: 700;
            font-size: 13px;
            padding: 8px 18px;
            border-radius: 50px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid #bbf7d0;
        }
        .hero-title {
            font-size: 3.2rem;
            font-weight: 800;
            line-height: 1.15;
            color: #0f172a;
            margin: 20px 0;
            letter-spacing: -0.5px;
        }
        .hero-title span {
            color: #16a34a;
        }
        .hero-lead {
            font-size: 1.15rem;
            color: #475569;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .hero-search-box {
            background: #ffffff;
            border-radius: 50px;
            padding: 8px;
            box-shadow: 0 15px 35px -5px rgba(22, 163, 74, 0.15);
            border: 2px solid #86efac;
            max-width: 580px;
        }
        .hero-search-input {
            border: none;
            padding-left: 20px;
            font-size: 15px;
            outline: none;
            width: 100%;
        }
        .hero-search-input:focus {
            box-shadow: none;
        }

        .category-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 18px;
            padding: 24px 18px;
            text-align: center;
            text-decoration: none;
            color: #1e293b;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: block;
        }
        .category-card:hover {
            transform: translateY(-5px);
            border-color: #86efac;
            box-shadow: 0 15px 30px -10px rgba(22, 163, 74, 0.15);
            color: #15803d;
        }
        .category-icon-wrapper {
            width: 65px;
            height: 65px;
            border-radius: 16px;
            background: #f0fdf4;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 12px;
            transition: 0.3s;
        }
        .category-card:hover .category-icon-wrapper {
            background: #16a34a;
            color: #ffffff;
        }

        .product-card {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            overflow: hidden;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .product-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 18px 36px -10px rgba(0,0,0,0.08);
            border-color: #cbd5e1;
        }
        .product-image-container {
            position: relative;
            height: 190px;
            background: #f1f5f9;
            overflow: hidden;
        }
        .product-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: 0.4s ease;
        }
        .product-card:hover .product-image {
            transform: scale(1.05);
        }
        .product-badge-cat {
            position: absolute;
            top: 12px;
            left: 12px;
            background: rgba(255, 255, 255, 0.92);
            backdrop-filter: blur(4px);
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 700;
            color: #0f172a;
            text-transform: uppercase;
        }

        .step-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 30px 24px;
            border: 1px solid #e2e8f0;
            height: 100%;
            position: relative;
            transition: all 0.3s;
        }
        .step-card:hover {
            border-color: #86efac;
            box-shadow: 0 10px 25px -5px rgba(22, 163, 74, 0.1);
            transform: translateY(-3px);
        }
        .step-number {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            background: #16a34a;
            color: #ffffff;
            font-weight: 800;
            font-size: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 18px;
        }

        .trust-box {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid #e2e8f0;
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }
        .trust-icon {
            font-size: 28px;
            color: #16a34a;
        }
    </style>
</head>

<body>

    <%@include file="includes/navbar.jsp" %>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-7">
                    <div class="hero-badge mb-3">
                        <i class="fa-solid fa-wheat-awn"></i> Direct Farmer Marketplace & Wholesale
                    </div>
                    <h1 class="hero-title">
                        Fresh Farm Produce, <span>Direct From The Source.</span>
                    </h1>
                    <p class="hero-lead">
                        Connecting verified Indian farmers directly with retail consumers and commercial enterprises. Fair pricing, zero middleman markups, 100% digital escrow safety, and geotagged transit tracking.
                    </p>

                    <!-- Search Form -->
                    <form action="${pageContext.request.contextPath}/buyer/products" method="get" class="hero-search-box d-flex align-items-center mb-4">
                        <input type="text" name="search" class="form-control hero-search-input" placeholder="Search grains, pulses, fresh vegetables, fruits...">
                        <button type="submit" class="btn btn-success rounded-pill px-4 py-2 fw-semibold d-flex align-items-center gap-2">
                            <i class="fa-solid fa-magnifying-glass"></i> Explore
                        </button>
                    </form>

                    <div class="d-flex flex-wrap gap-3">
                        <a href="${pageContext.request.contextPath}/buyer/products" class="btn btn-success btn-lg rounded-pill px-4 fw-semibold shadow-sm">
                            <i class="fa-solid fa-store me-2"></i> Browse Marketplace
                        </a>
                        <a href="${pageContext.request.contextPath}/auth/register.jsp" class="btn btn-outline-success btn-lg rounded-pill px-4 fw-semibold">
                            <i class="fa-solid fa-seedling me-2"></i> Sell As Farmer
                        </a>
                        <a href="${pageContext.request.contextPath}/commercial/dashboard" class="btn btn-outline-primary btn-lg rounded-pill px-4 fw-semibold">
                            <i class="fa-solid fa-building me-2"></i> Commercial Lots
                        </a>
                    </div>
                </div>

                <div class="col-lg-5 text-center">
                    <div class="position-relative">
                        <div class="card border-0 rounded-4 shadow-lg overflow-hidden" style="background: linear-gradient(180deg, #ffffff 0%, #f0fdf4 100%); border: 1px solid #bbf7d0 !important;">
                            <img src="${pageContext.request.contextPath}/assets/images/banner.png" class="img-fluid" alt="KisaanConnect Direct Farmer Marketplace" style="max-height: 380px; width: 100%; object-fit: contain; padding: 12px;">
                            <div class="card-body p-3 bg-white border-top text-start d-flex align-items-center justify-content-between">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="bg-success-subtle text-success p-2.5 rounded-3 fs-5">
                                        <i class="fa-solid fa-shield-halved"></i>
                                    </div>
                                    <div>
                                        <div class="fw-bold text-dark small">100% Escrow Protected</div>
                                        <div class="text-muted" style="font-size: 11px;">Direct farmer payout upon confirmed delivery</div>
                                    </div>
                                </div>
                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1 rounded-pill small">Verified Farms</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Categories Grid -->
    <section class="py-5 bg-light">
        <div class="container">
            <div class="text-center mb-5">
                <span class="badge bg-success-subtle text-success px-3 py-2 rounded-pill fw-bold mb-2">PRODUCE CATEGORIES</span>
                <h2 class="fw-bold text-dark">Explore By Agricultural Category</h2>
                <p class="text-muted">Direct harvest sorted into verified crop classifications</p>
            </div>

            <div class="row g-4">
                <div class="col-lg-2 col-md-4 col-6">
                    <a href="${pageContext.request.contextPath}/buyer/products?cat=Grains" class="category-card">
                        <div class="category-icon-wrapper"><i class="fa-solid fa-wheat-awn text-success"></i></div>
                        <h6 class="fw-bold mb-1">Grains & Cereals</h6>
                        <span class="text-muted small">Wheat, Rice, Millets</span>
                    </a>
                </div>
                <div class="col-lg-2 col-md-4 col-6">
                    <a href="${pageContext.request.contextPath}/buyer/products?cat=Pulses" class="category-card">
                        <div class="category-icon-wrapper"><i class="fa-solid fa-seedling text-success"></i></div>
                        <h6 class="fw-bold mb-1">Pulses & Dal</h6>
                        <span class="text-muted small">Toor, Moong, Chana</span>
                    </a>
                </div>
                <div class="col-lg-2 col-md-4 col-6">
                    <a href="${pageContext.request.contextPath}/buyer/products?cat=Vegetables" class="category-card">
                        <div class="category-icon-wrapper"><i class="fa-solid fa-carrot text-warning"></i></div>
                        <h6 class="fw-bold mb-1">Fresh Vegetables</h6>
                        <span class="text-muted small">Onion, Potato, Tomato</span>
                    </a>
                </div>
                <div class="col-lg-2 col-md-4 col-6">
                    <a href="${pageContext.request.contextPath}/buyer/products?cat=Fruits" class="category-card">
                        <div class="category-icon-wrapper"><i class="fa-solid fa-apple-whole text-danger"></i></div>
                        <h6 class="fw-bold mb-1">Seasonal Fruits</h6>
                        <span class="text-muted small">Mango, Banana, Pomegranate</span>
                    </a>
                </div>
                <div class="col-lg-2 col-md-4 col-6">
                    <a href="${pageContext.request.contextPath}/buyer/products?cat=Spices" class="category-card">
                        <div class="category-icon-wrapper"><i class="fa-solid fa-pepper-hot text-danger"></i></div>
                        <h6 class="fw-bold mb-1">Spices & Herbs</h6>
                        <span class="text-muted small">Turmeric, Chilli, Ginger</span>
                    </a>
                </div>
                <div class="col-lg-2 col-md-4 col-6">
                    <a href="${pageContext.request.contextPath}/buyer/products?cat=Organic" class="category-card">
                        <div class="category-icon-wrapper"><i class="fa-solid fa-leaf text-success"></i></div>
                        <h6 class="fw-bold mb-1">Organic Produce</h6>
                        <span class="text-muted small">100% Chemical-Free</span>
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Live Produce Showcase -->
    <section class="py-5">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div>
                    <span class="badge bg-success-subtle text-success px-3 py-2 rounded-pill fw-bold mb-2">LIVE MARKETPLACE</span>
                    <h2 class="fw-bold text-dark mb-0">Fresh Harvest Produce Listings</h2>
                </div>
                <a href="${pageContext.request.contextPath}/buyer/products" class="btn btn-outline-success rounded-pill fw-semibold">
                    View All Produce <i class="fa-solid fa-arrow-right ms-1"></i>
                </a>
            </div>

            <div class="row g-4">
                <% if (featuredProducts != null && !featuredProducts.isEmpty()) {
                    for (Product p : featuredProducts) {
                        String imgUrl = (p.getPrimaryImageUrl() != null && !p.getPrimaryImageUrl().isEmpty())
                                ? (p.getPrimaryImageUrl().startsWith("http") ? p.getPrimaryImageUrl() : request.getContextPath() + "/" + p.getPrimaryImageUrl())
                                : request.getContextPath() + "/assets/images/banner.png";
                %>
                    <div class="col-lg-3 col-md-6">
                        <div class="product-card">
                            <div class="product-image-container">
                                <img src="<%= imgUrl %>" class="product-image" alt="<%= p.getProductName() %>">
                                <span class="product-badge-cat"><%= p.getCategoryName() != null ? p.getCategoryName() : "Produce" %></span>
                            </div>
                            <div class="p-3 d-flex flex-column flex-grow-1">
                                <h5 class="fw-bold text-dark mb-1 fs-6"><%= p.getProductName() %></h5>
                                <div class="text-muted small mb-2"><i class="fa-solid fa-location-dot text-danger me-1"></i><%= p.getFarmerName() != null ? p.getFarmerName() : "Maharashtra Farm" %></div>
                                
                                <div class="d-flex justify-content-between align-items-baseline mt-auto pt-3 border-top">
                                    <div>
                                        <span class="fs-5 fw-bold text-success">₹<%= p.getPrice() %></span>
                                        <span class="text-muted small">/ <%= p.getUnit() %></span>
                                    </div>
                                    <span class="badge bg-light text-secondary border small">
                                        <i class="fa-solid fa-boxes-stacked"></i> <%= p.getAvailableQuantity() %> <%= p.getUnit() %>
                                    </span>
                                </div>
                                <div class="mt-3">
                                    <a href="${pageContext.request.contextPath}/buyer/products" class="btn btn-success btn-sm w-100 rounded-3 fw-semibold">
                                        <i class="fa-solid fa-cart-shopping me-1"></i> View Produce
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                <%  }
                   } else { %>
                    <div class="col-12 text-center py-5">
                        <p class="text-muted">Loading active marketplace produce...</p>
                    </div>
                <% } %>
            </div>
        </div>
    </section>

    <!-- 6-Step "How It Works" -->
    <section class="py-5 bg-light">
        <div class="container">
            <div class="text-center mb-5">
                <span class="badge bg-success-subtle text-success px-3 py-2 rounded-pill fw-bold mb-2">END-TO-END WORKFLOW</span>
                <h2 class="fw-bold text-dark">How KisaanConnect Operates</h2>
                <p class="text-muted">A transparent, fair, and secure agricultural trading cycle</p>
            </div>

            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="step-card">
                        <div class="step-number">1</div>
                        <h5 class="fw-bold text-dark">Farmer Registration & Verification</h5>
                        <p class="text-muted small mb-0">Every farmer is verified by platform administrators to ensure legitimate produce origin, fair landholding documentation, and quality standards.</p>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="step-card">
                        <div class="step-number">2</div>
                        <h5 class="fw-bold text-dark">Produce Listing & Price Transparency</h5>
                        <p class="text-muted small mb-0">Farmers list crops with real-time stock, minimum safety thresholds, and self-determined prices backed by comprehensive audit trails.</p>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="step-card">
                        <div class="step-number">3</div>
                        <h5 class="fw-bold text-dark">Digital Escrow Protection</h5>
                        <p class="text-muted small mb-0">Buyers and commercial organizations place orders. Prepaid funds are held safely in escrow until delivery is verified.</p>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="step-card">
                        <div class="step-number">4</div>
                        <h5 class="fw-bold text-dark">Isolated Sub-Orders & Geotagged Routes</h5>
                        <p class="text-muted small mb-0">Multi-farmer orders are split into isolated sub-orders. Live transit maps display pickup-to-delivery coordinates and route distance.</p>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="step-card">
                        <div class="step-number">5</div>
                        <h5 class="fw-bold text-dark">Order Chat & Live Notification Center</h5>
                        <p class="text-muted small mb-0">Direct order-scoped chat allows buyers and farmers to communicate about packaging, dispatch schedules, and logistics seamlessly.</p>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="step-card">
                        <div class="step-number">6</div>
                        <h5 class="fw-bold text-dark">Buyer Receipt & Instant Payout</h5>
                        <p class="text-muted small mb-0">Once the buyer inspects the delivered produce and confirms receipt, escrow funds are instantly released into the farmer's digital wallet.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Trust & Platform Security -->
    <section class="py-5">
        <div class="container">
            <div class="row g-4">
                <div class="col-lg-3 col-md-6">
                    <div class="trust-box">
                        <div class="trust-icon"><i class="fa-solid fa-handshake-angle"></i></div>
                        <div>
                            <h6 class="fw-bold text-dark mb-1">Zero Middlemen</h6>
                            <p class="text-muted small mb-0">100% direct transactions ensuring maximum earnings for farmers and fresh produce for buyers.</p>
                        </div>
                    </div>
                </div>

                <div class="col-lg-3 col-md-6">
                    <div class="trust-box">
                        <div class="trust-icon"><i class="fa-solid fa-wallet"></i></div>
                        <div>
                            <h6 class="fw-bold text-dark mb-1">Escrow Safety</h6>
                            <p class="text-muted small mb-0">Automated wallet escrow locks funds securely until successful receipt confirmation.</p>
                        </div>
                    </div>
                </div>

                <div class="col-lg-3 col-md-6">
                    <div class="trust-box">
                        <div class="trust-icon"><i class="fa-solid fa-map-location-dot"></i></div>
                        <div>
                            <h6 class="fw-bold text-dark mb-1">GPS Route Tracking</h6>
                            <p class="text-muted small mb-0">OpenStreetMap integration providing transparent transit routing for every farm sub-order.</p>
                        </div>
                    </div>
                </div>

                <div class="col-lg-3 col-md-6">
                    <div class="trust-box">
                        <div class="trust-icon"><i class="fa-solid fa-user-shield"></i></div>
                        <div>
                            <h6 class="fw-bold text-dark mb-1">Admin Vetting</h6>
                            <p class="text-muted small mb-0">Strict admin approval for farmers, commercial organizations, and GSTIN/PAN compliance.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Banner CTA -->
    <section class="py-5 text-white" style="background: linear-gradient(135deg, #15803d 0%, #166534 100%);">
        <div class="container text-center py-4">
            <h2 class="display-6 fw-bold mb-3">Join the Direct Agricultural Revolution</h2>
            <p class="lead text-white-50 mb-4 mx-auto" style="max-width: 650px;">Whether you're a farmer looking to maximize crop revenues, a family seeking chemical-free farm produce, or an enterprise procuring wholesale agricultural lots.</p>
            <div class="d-flex justify-content-center gap-3 flex-wrap">
                <a href="${pageContext.request.contextPath}/auth/register.jsp" class="btn btn-light btn-lg rounded-pill px-5 fw-bold text-success shadow">
                    Register Today
                </a>
                <a href="${pageContext.request.contextPath}/auth/login.jsp" class="btn btn-outline-light btn-lg rounded-pill px-4 fw-semibold">
                    Sign In to Portal
                </a>
            </div>
        </div>
    </section>

    <%@include file="includes/footer.jsp" %>
            
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/ai-assistant.js"></script>
</body>
</html>
