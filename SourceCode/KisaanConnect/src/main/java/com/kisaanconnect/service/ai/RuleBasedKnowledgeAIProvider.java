package com.kisaanconnect.service.ai;

import java.util.Locale;

public class RuleBasedKnowledgeAIProvider implements AIProvider {

    @Override
    public String getProviderName() {
        return "KisaanConnect Knowledge Engine (Built-in)";
    }

    @Override
    public boolean isAvailable() {
        return true;
    }

    @Override
    public String generateResponse(String userPrompt, String systemContext) {
        if (userPrompt == null || userPrompt.trim().isEmpty()) {
            return "Namaste! I am KisaanConnect Assistant. How can I assist you today with farm produce, registration, or order tracking?";
        }

        String q = userPrompt.toLowerCase(Locale.ENGLISH);

        if (q.contains("what is kisaanconnect") || q.contains("about") || q.contains("who are you")) {
            return "KisaanConnect is an agricultural marketplace bridging Indian farmers directly with retail consumers and commercial enterprises. It eliminates middlemen to ensure fair farmer earnings, fair buyer prices, digital escrow protection, and live GPS transit route tracking.";
        }

        if (q.contains("register") || q.contains("sign up") || q.contains("account") || q.contains("join")) {
            return "You can register on KisaanConnect in 3 easy roles:\n1. **Farmer**: Click 'Sell As Farmer' or Register -> Select 'Farmer'. List crops, set farm coordinates, and receive direct orders.\n2. **Retail Buyer**: Register as 'Buyer' to shop fresh farm produce delivered to your doorstep.\n3. **Commercial Enterprise**: Register as 'Commercial' to procure bulk lots with GSTIN verification and organizational multi-member teams.";
        }

        if (q.contains("payment") || q.contains("razorpay") || q.contains("upi") || q.contains("cod") || q.contains("cash")) {
            return "KisaanConnect supports 4 secure payment options:\n• **Online Payment (Razorpay)**: Pay securely via UPI, Cards, and NetBanking with automated digital escrow hold.\n• **KisaanConnect Wallet**: Instant digital escrow settlement.\n• **Cash on Delivery (COD)**: Pay when the produce is delivered, verified with farmer digital receipt.\n• **Direct UPI / Bank Transfer**: Direct settlement upon delivery.";
        }

        if (q.contains("escrow") || q.contains("safe") || q.contains("security") || q.contains("payout") || q.contains("refund")) {
            return "KisaanConnect uses a 100% Digital Escrow system. When you pay online or via wallet, funds are safely held by the platform in escrow. Once you inspect and confirm delivery, the funds are automatically disbursed into the farmer's wallet.";
        }

        if (q.contains("track") || q.contains("route") || q.contains("map") || q.contains("gps") || q.contains("delivery")) {
            return "All orders feature real-time Road Route & Delivery Navigation powered by OpenStreetMap & OSRM! Simply visit your Orders page, click **'Track Route'**, and view live driving distance in kilometers, estimated transit duration in minutes, and the exact turn-by-turn road route from farm pickup to your delivery location.";
        }

        if (q.contains("commercial") || q.contains("b2b") || q.contains("wholesale") || q.contains("bulk") || q.contains("gst")) {
            return "Commercial Buyers can procure bulk agricultural lots with wholesale volume discounts, assign member roles (Owner, Manager, Staff), generate GSTIN-compliant invoices, and track multi-farm aggregated deliveries seamlessly.";
        }

        if (q.contains("produce") || q.contains("crop") || q.contains("vegetable") || q.contains("grain") || q.contains("fruit") || q.contains("pulse")) {
            return "We list verified direct-harvest categories including **Grains & Cereals** (Wheat, Rice, Millets), **Pulses & Dal** (Toor, Moong, Chana), **Fresh Vegetables** (Onions, Potatoes, Tomatoes), **Fresh Fruits**, and **Spices & Herbs**. Check out the 'Browse Marketplace' section on our homepage!";
        }

        if (q.contains("contact") || q.contains("help") || q.contains("support") || q.contains("phone") || q.contains("email")) {
            return "You can reach KisaanConnect platform support via email at support@kisaanconnect.in or phone at +91 1800-KISAAN-CONNECT. Our farm desk operates 7 days a week.";
        }

        return "Thank you for asking! KisaanConnect helps you purchase fresh produce directly from verified Indian farmers with digital escrow safety and live GPS transit tracking. You can browse our marketplace, register as a farmer or commercial buyer, or track existing orders in your dashboard.";
    }
}
