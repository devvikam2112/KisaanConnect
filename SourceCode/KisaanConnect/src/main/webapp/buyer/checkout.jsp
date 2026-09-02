<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.kisaanconnect.model.CartItem"%>
<%@page import="com.kisaanconnect.model.BuyerProfile"%>
<%@page import="com.kisaanconnect.model.Organization"%>
<%@page import="com.kisaanconnect.model.User"%>

<%@page import="com.kisaanconnect.dao.BuyerDAO"%>
<%@page import="com.kisaanconnect.dao.OrganizationDAO"%>
<%@page import="com.kisaanconnect.dao.CartDAO"%>
<%@page import="com.kisaanconnect.dao.WalletDAO"%>
<%@page import="com.kisaanconnect.model.Cart"%>
<%@page import="com.kisaanconnect.model.Wallet"%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    BuyerProfile buyerProfile = (BuyerProfile) request.getAttribute("buyerProfile");
    Organization commercialOrg = (Organization) request.getAttribute("organization");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal subtotal = (BigDecimal) request.getAttribute("subtotal");
    Wallet wallet = (Wallet) request.getAttribute("wallet");
    BigDecimal walletBalance = (BigDecimal) request.getAttribute("walletBalance");

    if (loggedInUser != null) {
        if (wallet == null) {
            WalletDAO wDAO = new WalletDAO();
            wallet = wDAO.getOrCreateWallet(loggedInUser.getUserId());
            walletBalance = wallet != null ? wallet.getCurrentBalance() : BigDecimal.ZERO;
        }
        if (buyerProfile == null && !"COMMERCIAL".equals(loggedInUser.getRole())) {
            BuyerDAO bDAO = new BuyerDAO();
            buyerProfile = bDAO.getProfileByUserId(loggedInUser.getUserId());
        }
        if (commercialOrg == null && "COMMERCIAL".equals(loggedInUser.getRole())) {
            OrganizationDAO orgDAO = new OrganizationDAO();
            commercialOrg = orgDAO.getOrganizationByUserId(loggedInUser.getUserId());
        }
        if (cartItems == null) {
            int buyerProfileId = (buyerProfile != null) ? buyerProfile.getBuyerProfileId() : loggedInUser.getUserId();
            CartDAO cDAO = new CartDAO();
            Cart c = cDAO.getOrCreateCart(buyerProfileId);
            if (c != null) {
                cartItems = cDAO.getCartItems(c.getCartId());
            }
        }
    }

    if (subtotal == null) {
        subtotal = BigDecimal.ZERO;
        if (cartItems != null) {
            for (CartItem itm : cartItems) {
                subtotal = subtotal.add(itm.getItemTotal());
            }
        }
    }
    BigDecimal deliveryCharge = BigDecimal.valueOf(50.0);
    BigDecimal platformFee = BigDecimal.valueOf(10.0);
    BigDecimal total = subtotal.add(deliveryCharge).add(platformFee);

    String defaultName = "";
    String defaultPhone = "";
    String defaultAddress = "";
    String defaultPincode = "";

    if (commercialOrg != null) {
        defaultName = commercialOrg.getOrgName();
        defaultPhone = commercialOrg.getBusinessPhone();
        defaultAddress = (commercialOrg.getAddress() != null ? commercialOrg.getAddress() : "") + 
                         (commercialOrg.getCity() != null ? ", " + commercialOrg.getCity() : "") + 
                         (commercialOrg.getState() != null ? ", " + commercialOrg.getState() : "");
        defaultPincode = commercialOrg.getPincode() != null ? commercialOrg.getPincode() : "";
    } else if (buyerProfile != null) {
        defaultName = loggedInUser != null ? loggedInUser.getFullName() : "";
        defaultPhone = loggedInUser != null ? loggedInUser.getPhone() : "";
        defaultAddress = (buyerProfile.getAddress() != null ? buyerProfile.getAddress() : "") + 
                         (buyerProfile.getCity() != null ? ", " + buyerProfile.getCity() : "") + 
                         (buyerProfile.getState() != null ? ", " + buyerProfile.getState() : "");
        defaultPincode = buyerProfile.getPincode() != null ? buyerProfile.getPincode() : "";
    } else if (loggedInUser != null) {
        defaultName = loggedInUser.getFullName();
        defaultPhone = loggedInUser.getPhone();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Checkout | KisaanConnect</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">

    <style>
        body {
            background-color: var(--kc-bg, #F8FAFC);
            font-family: var(--kc-font);
        }

        .checkout-box {
            background: #FFFFFF;
            border-radius: var(--kc-radius-lg, 16px);
            border: 1px solid var(--kc-border, #E2E8F0);
            box-shadow: var(--kc-shadow-sm, 0 1px 3px rgba(0,0,0,0.05));
            padding: 24px 28px;
        }

        .payment-option {
            border: 1.5px solid var(--kc-border, #E2E8F0);
            border-radius: var(--kc-radius-md, 12px);
            padding: 16px 20px;
            margin-bottom: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 14px;
            background: #FFFFFF;
        }

        .payment-option:hover {
            border-color: var(--kc-primary, #15803D);
            background: #F0FDF4;
        }

        .payment-option.active, .payment-option input[type="radio"]:checked ~ .payment-option-content {
            border-color: var(--kc-primary, #15803D);
        }

        .payment-option input[type="radio"] {
            accent-color: var(--kc-primary, #15803D);
            width: 18px;
            height: 18px;
            cursor: pointer;
        }
    </style>
</head>

<body>

    <%@ include file="/includes/navbar.jsp" %>

    <div class="container py-4 py-lg-5">

        <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
            <div>
                <h1 class="h3 fw-bold text-dark mb-1">
                    <i class="fa-solid fa-lock text-success me-2"></i>Secure Checkout
                </h1>
                <p class="text-muted small mb-0">Review delivery destination, select payment method & confirm your produce order.</p>
            </div>
            <a href="${pageContext.request.contextPath}/buyer/cart.jsp" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                <i class="fa-solid fa-arrow-left me-1"></i> Back to Cart
            </a>
        </div>

        <%@ include file="/includes/alerts.jsp" %>

        <form id="checkoutForm" action="${pageContext.request.contextPath}/order/place" method="post">
            <div class="row g-4">

                <!-- Delivery Details -->
                <div class="col-lg-7">
                    <div class="checkout-box mb-4">
                        <h4 class="fw-bold mb-3 fs-5 text-dark">
                            <i class="fa-solid fa-location-dot text-danger me-2"></i>Delivery Destination & Contact
                        </h4>

                        <% if (commercialOrg != null) { %>
                            <div class="alert alert-info py-2 px-3 small rounded-3 mb-3 d-flex align-items-center gap-2">
                                <i class="fa-solid fa-building text-primary fs-5"></i>
                                <div>
                                    Commercial Procurement for <strong><%= commercialOrg.getOrgName() %></strong>
                                    <% if (commercialOrg.getGstin() != null) { %> | GSTIN: <%= commercialOrg.getGstin() %><% } %>
                                </div>
                            </div>
                        <% } %>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold small text-secondary">Recipient / Contact Person *</label>
                                <input type="text"
                                       name="deliveryName"
                                       class="form-control rounded-3"
                                       value="<%= defaultName %>"
                                       required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold small text-secondary">Contact Phone Number *</label>
                                <input type="tel"
                                       name="deliveryPhone"
                                       class="form-control rounded-3"
                                       value="<%= defaultPhone %>"
                                       pattern="[0-9]{10}"
                                       placeholder="10-digit mobile number"
                                       required>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold small text-secondary">Complete Delivery Address *</label>
                                <textarea name="deliveryAddress"
                                          rows="3"
                                          class="form-control rounded-3"
                                          placeholder="Street address, building, premises, landmark..."
                                          required><%= defaultAddress %></textarea>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold small text-secondary">Postal Pincode *</label>
                                <input type="text"
                                       name="deliveryPincode"
                                       maxlength="6"
                                       pattern="[0-9]{6}"
                                       class="form-control rounded-3"
                                       value="<%= defaultPincode %>"
                                       placeholder="6-digit PIN code"
                                       required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold small text-secondary" for="deliveryDate">Preferred Delivery Date *</label>
                                <input type="date"
                                       name="deliveryDate"
                                       id="deliveryDate"
                                       class="form-control rounded-3"
                                       min="<%= java.time.LocalDate.now() %>"
                                       required>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Mode -->
                    <div class="checkout-box">
                        <h4 class="fw-bold mb-3 fs-5 text-dark">
                            <i class="fa-solid fa-credit-card text-success me-2"></i>Select Payment Method
                        </h4>
                        <p class="text-muted small mb-3">All online payments are securely held in escrow until you confirm delivery satisfaction.</p>

                        <label class="payment-option w-100">
                            <input type="radio" name="paymentMethod" value="ONLINE" id="payOnlineRadio" checked required>
                            <div class="w-100">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-1">
                                    <strong class="text-dark"><i class="fa-solid fa-globe text-primary me-2"></i>Online Payment Gateway</strong>
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2 py-1 small">
                                        UPI, Cards, NetBanking, Razorpay
                                    </span>
                                </div>
                                <div class="text-muted small mt-1">Instant digital payment with 100% buyer protection and escrow settlement.</div>
                            </div>
                        </label>

                        <label class="payment-option w-100">
                            <input type="radio" name="paymentMethod" value="CASH_ON_DELIVERY" required>
                            <div class="w-100">
                                <strong class="text-dark"><i class="fa-solid fa-money-bill-wave text-success me-2"></i>Cash on Delivery (COD)</strong>
                                <div class="text-muted small mt-1">Pay when the fresh produce is delivered. Verified with farmer digital receipt.</div>
                            </div>
                        </label>

                        <%
                            boolean hasEnoughWallet = (walletBalance != null && walletBalance.compareTo(total) >= 0);
                        %>
                        <label class="payment-option w-100" style="<%= !hasEnoughWallet ? "background: #FFFBEB; border-color: #F59E0B;" : "" %>">
                            <input type="radio" name="paymentMethod" value="WALLET" id="payWalletRadio" required <%= !hasEnoughWallet ? "disabled" : "" %>>
                            <div class="w-100">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-1">
                                    <strong class="text-dark"><i class="fa-solid fa-wallet text-warning me-2"></i>KisaanConnect Wallet</strong>
                                    <span class="badge <%= hasEnoughWallet ? "bg-success" : "bg-warning text-dark" %> rounded-pill px-3 py-1">
                                        Balance: ₹<%= walletBalance != null ? walletBalance : "0.00" %>
                                    </span>
                                </div>
                                <div class="text-muted small mt-1">Instant escrow hold & automated seller payout on confirmed receipt.</div>
                                <% if (!hasEnoughWallet) { %>
                                    <div class="text-danger small mt-1 fw-semibold">
                                        <i class="fa-solid fa-triangle-exclamation me-1"></i>Insufficient Wallet Balance (Need ₹<%= total %>, have ₹<%= walletBalance != null ? walletBalance : "0.00" %>).
                                    </div>
                                <% } %>
                            </div>
                        </label>

                        <label class="payment-option w-100">
                            <input type="radio" name="paymentMethod" value="UPI" required>
                            <div class="w-100">
                                <strong class="text-dark"><i class="fa-solid fa-qrcode text-info me-2"></i>Direct UPI / QR Settlement</strong>
                                <div class="text-muted small mt-1">Direct scan & pay at doorstep delivery.</div>
                            </div>
                        </label>
                    </div>
                </div>

                <!-- Order Review -->
                <div class="col-lg-5">
                    <div class="checkout-box sticky-top" style="top: 90px;">
                        <h4 class="fw-bold mb-3 fs-5 text-dark">
                            <i class="fa-solid fa-receipt text-primary me-2"></i>Order Summary (<%= cartItems != null ? cartItems.size() : 0 %> items)
                        </h4>

                        <% if (cartItems != null && !cartItems.isEmpty()) { %>
                            <div class="order-items-list mb-3" style="max-height: 240px; overflow-y: auto;">
                                <% for (CartItem ci : cartItems) { %>
                                    <div class="d-flex justify-content-between py-2 border-bottom small">
                                        <div>
                                            <strong class="text-dark"><%= ci.getProductName() %></strong>
                                            <div class="text-muted"><%= ci.getQuantity() %> <%= ci.getUnit() %> × ₹<%= ci.getUnitPrice() %></div>
                                        </div>
                                        <div class="fw-bold text-dark">₹<%= ci.getItemTotal() %></div>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>

                        <div class="d-flex justify-content-between mt-3 mb-2 small text-secondary">
                            <span>Produce Subtotal:</span>
                            <span class="fw-semibold text-dark">₹<%= subtotal %></span>
                        </div>

                        <div class="d-flex justify-content-between mb-2 small text-secondary">
                            <span>Logistics & Delivery Fee:</span>
                            <span class="text-success fw-semibold">₹<%= deliveryCharge %></span>
                        </div>

                        <div class="d-flex justify-content-between mb-3 small text-secondary">
                            <span>Platform Escrow Protection:</span>
                            <span class="text-dark fw-semibold">₹<%= platformFee %></span>
                        </div>

                        <hr class="my-2">

                        <div class="d-flex justify-content-between mb-4 fs-5 fw-bold text-dark">
                            <span>Grand Total:</span>
                            <span class="text-success">₹<%= total %></span>
                        </div>

                        <div id="checkoutErrorBox" class="alert alert-danger py-2 small mb-3" style="display: none;"></div>

                        <button type="submit" id="submitOrderBtn" class="btn btn-primary w-100 py-3 rounded-3 fw-bold fs-6 shadow">
                            <i class="fa-solid fa-lock me-2"></i>Confirm & Place Order
                        </button>
                    </div>
                </div>

            </div>
        </form>

    </div>

    <!-- Modal for Sandbox / Development Payment Simulation -->
    <div class="modal fade" id="devPaymentModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <div class="modal-header border-bottom-0 pb-0">
                    <div>
                        <h5 class="modal-title fw-bold text-dark">
                            <i class="fa-solid fa-shield-halved text-success me-2"></i>KisaanConnect Payment Gateway
                        </h5>
                        <span class="badge bg-warning text-dark border border-warning px-2 py-1 rounded-pill small mt-1">
                            <i class="fa-solid fa-flask me-1"></i>Sandbox Test Simulation Mode
                        </span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" id="devCloseModalBtn"></button>
                </div>
                <div class="modal-body py-4">
                    <div class="bg-light p-3 rounded-3 border mb-3">
                        <div class="d-flex justify-content-between small text-secondary mb-1">
                            <span>Payment Attempt ID:</span>
                            <strong id="modalAttemptId" class="text-dark">#0</strong>
                        </div>
                        <div class="d-flex justify-content-between small text-secondary mb-1">
                            <span>Razorpay Order Reference:</span>
                            <code id="modalRzpOrderId" class="text-dark">-</code>
                        </div>
                        <div class="d-flex justify-content-between fs-5 fw-bold text-dark mt-2 pt-2 border-top">
                            <span>Amount Payable:</span>
                            <span id="modalAmount" class="text-success">₹0.00</span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-secondary">Test Payment Simulation Option</label>
                        <div class="form-check p-3 border rounded-3 mb-2 bg-white">
                            <input class="form-check-input" type="radio" name="devSimResult" id="simSuccess" value="SUCCESS" checked>
                            <label class="form-check-label w-100" for="simSuccess">
                                <strong class="text-success"><i class="fa-solid fa-circle-check me-1"></i> Simulate Authorized & Captured Payment (Success)</strong>
                                <div class="text-muted small">Generates valid verification payload and confirms order instantly.</div>
                            </label>
                        </div>
                        <div class="form-check p-3 border rounded-3 bg-white">
                            <input class="form-check-input" type="radio" name="devSimResult" id="simFailure" value="FAILURE">
                            <label class="form-check-label w-100" for="simFailure">
                                <strong class="text-danger"><i class="fa-solid fa-circle-xmark me-1"></i> Simulate Bank Decline / Card Rejection (Failure)</strong>
                                <div class="text-muted small">Simulates bank transaction failure without creating an order.</div>
                            </label>
                        </div>
                    </div>

                    <div id="devModalAlert" class="alert alert-danger py-2 small" style="display: none;"></div>
                </div>
                <div class="modal-footer border-top-0 d-flex justify-content-between">
                    <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill px-3" data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="button" class="btn btn-success fw-bold rounded-pill px-4" id="confirmDevPaymentBtn">
                        <i class="fa-solid fa-check me-1"></i> Process Simulated Payment
                    </button>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/includes/footer.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const form = document.getElementById('checkoutForm');
            const submitBtn = document.getElementById('submitOrderBtn');
            const errorBox = document.getElementById('checkoutErrorBox');
            let currentRzpData = null;

            if (!form) return;

            form.addEventListener('submit', (e) => {
                const selectedMethod = form.querySelector('input[name="paymentMethod"]:checked');
                if (!selectedMethod) return;

                if (selectedMethod.value === 'ONLINE') {
                    e.preventDefault();
                    errorBox.style.display = 'none';

                    submitBtn.disabled = true;
                    submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Initializing Gateway...';

                    const formData = new FormData(form);
                    const params = new URLSearchParams(formData);

                    fetch('${pageContext.request.contextPath}/order/razorpay/create-order', {
                        method: 'POST',
                        body: params,
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                    })
                    .then(res => res.json().then(data => ({ status: res.status, ok: res.ok, data })))
                    .then(result => {
                        if (!result.ok || !result.data.success) {
                            throw new Error(result.data.error || 'Failed to initialize payment gateway');
                        }

                        currentRzpData = result.data;
                        const isDev = currentRzpData.paymentMode === 'DEVELOPMENT' || 
                                      !currentRzpData.keyId || 
                                      currentRzpData.keyId.startsWith('rzp_test_kisaanconnect');

                        if (isDev) {
                            // Launch In-App Sandbox Simulation Modal
                            document.getElementById('modalAttemptId').innerText = '#' + currentRzpData.attemptId;
                            document.getElementById('modalRzpOrderId').innerText = currentRzpData.razorpayOrderId;
                            document.getElementById('modalAmount').innerText = '₹' + currentRzpData.totalAmount.toFixed(2);
                            document.getElementById('devModalAlert').style.display = 'none';

                            const devModal = new bootstrap.Modal(document.getElementById('devPaymentModal'));
                            devModal.show();

                            submitBtn.disabled = false;
                            submitBtn.innerHTML = '<i class="fa-solid fa-lock me-2"></i>Confirm & Place Order';
                        } else {
                            // Launch Live Razorpay Checkout
                            const options = {
                                key: currentRzpData.keyId,
                                amount: currentRzpData.amount,
                                currency: currentRzpData.currency || 'INR',
                                name: 'KisaanConnect',
                                description: 'Agricultural Produce Order Payment',
                                image: '${pageContext.request.contextPath}/assets/images/logo.png',
                                order_id: currentRzpData.razorpayOrderId,
                                handler: function(response) {
                                    submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Verifying & Finalizing Order...';

                                    const verifyParams = new URLSearchParams();
                                    verifyParams.append('razorpay_order_id', response.razorpay_order_id);
                                    verifyParams.append('razorpay_payment_id', response.razorpay_payment_id);
                                    verifyParams.append('razorpay_signature', response.razorpay_signature);

                                    fetch('${pageContext.request.contextPath}/order/razorpay/verify-payment', {
                                        method: 'POST',
                                        body: verifyParams,
                                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                                    })
                                    .then(vRes => vRes.json().then(vData => ({ status: vRes.status, ok: vRes.ok, data: vData })))
                                    .then(vResult => {
                                        if (vResult.ok && vResult.data.success) {
                                            window.location.href = vResult.data.redirectUrl;
                                        } else {
                                            throw new Error(vResult.data.error || 'Payment verification failed');
                                        }
                                    })
                                    .catch(err => {
                                        submitBtn.disabled = false;
                                        submitBtn.innerHTML = '<i class="fa-solid fa-lock me-2"></i>Confirm & Place Order';
                                        errorBox.innerText = err.message;
                                        errorBox.style.display = 'block';
                                    });
                                },
                                prefill: {
                                    name: form.querySelector('input[name="deliveryName"]').value,
                                    contact: form.querySelector('input[name="deliveryPhone"]').value
                                },
                                theme: { color: '#15803D' },
                                modal: {
                                    ondismiss: function() {
                                        submitBtn.disabled = false;
                                        submitBtn.innerHTML = '<i class="fa-solid fa-lock me-2"></i>Confirm & Place Order';
                                    }
                                }
                            };

                            if (typeof Razorpay !== 'undefined') {
                                const rzp = new Razorpay(options);
                                rzp.on('payment.failed', function(resp) {
                                    submitBtn.disabled = false;
                                    submitBtn.innerHTML = '<i class="fa-solid fa-lock me-2"></i>Confirm & Place Order';
                                    errorBox.innerText = 'Payment failed: ' + (resp.error.description || resp.error.reason || 'Transaction declined.');
                                    errorBox.style.display = 'block';
                                });
                                rzp.open();
                            } else {
                                throw new Error('Payment gateway library could not be loaded.');
                            }
                        }
                    })
                    .catch(err => {
                        submitBtn.disabled = false;
                        submitBtn.innerHTML = '<i class="fa-solid fa-lock me-2"></i>Confirm & Place Order';
                        errorBox.innerText = err.message;
                        errorBox.style.display = 'block';
                    });
                }
            });

            // Handle Sandbox Modal Confirmation
            const confirmDevBtn = document.getElementById('confirmDevPaymentBtn');
            if (confirmDevBtn) {
                confirmDevBtn.addEventListener('click', () => {
                    const simChoice = document.querySelector('input[name="devSimResult"]:checked').value;
                    const modalAlert = document.getElementById('devModalAlert');
                    modalAlert.style.display = 'none';

                    if (simChoice === 'FAILURE') {
                        modalAlert.innerText = 'Simulated Bank Decline: Card was declined by issuing bank (Error 402).';
                        modalAlert.style.display = 'block';
                        return;
                    }

                    confirmDevBtn.disabled = true;
                    confirmDevBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Finalizing Order...';

                    const verifyParams = new URLSearchParams();
                    verifyParams.append('razorpay_order_id', currentRzpData.razorpayOrderId);
                    verifyParams.append('razorpay_payment_id', 'pay_dev_' + Date.now());
                    verifyParams.append('razorpay_signature', 'sig_dev_' + Date.now());

                    fetch('${pageContext.request.contextPath}/order/razorpay/verify-payment', {
                        method: 'POST',
                        body: verifyParams,
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                    })
                    .then(vRes => vRes.json().then(vData => ({ status: vRes.status, ok: vRes.ok, data: vData })))
                    .then(vResult => {
                        if (vResult.ok && vResult.data.success) {
                            window.location.href = vResult.data.redirectUrl;
                        } else {
                            throw new Error(vResult.data.error || 'Payment verification failed');
                        }
                    })
                    .catch(err => {
                        confirmDevBtn.disabled = false;
                        confirmDevBtn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Process Simulated Payment';
                        modalAlert.innerText = err.message;
                        modalAlert.style.display = 'block';
                    });
                });
            }
        });
    </script>
</body>
</html>

