package com.kisaanconnect.service.ai;

import java.util.ArrayList;
import java.util.List;

public class AIAssistantService {

    private static final String SYSTEM_CONTEXT = """
        You are the official KisaanConnect AI Assistant.
        KisaanConnect is an Indian digital agricultural marketplace connecting verified farmers directly with retail consumers and commercial enterprises.
        Key Platform Features:
        1. Direct Farm-to-Table & Wholesale: Zero middleman markups.
        2. Payment Options: Online (Razorpay with UPI, Cards, NetBanking), KisaanConnect Wallet, Cash on Delivery (COD), and Direct UPI.
        3. 100% Digital Escrow: Buyer payments are held in platform escrow until delivery is inspected and confirmed.
        4. Geotagged Transit Tracking: Real-time road navigation using Leaflet & OSRM displaying exact driving distance in km and duration in minutes.
        5. Roles: Farmers (sell produce), Retail Buyers (individual shoppers), Commercial Organizations (B2B wholesale with GSTIN and multi-member permissions), and Platform Admins.
        
        Guidelines for your answers:
        - Be friendly, respectful, and concise (under 120 words).
        - Provide helpful instructions for registration, browsing produce, placing orders, payments, and tracking.
        - You are strictly a public marketplace assistant. Never reveal or ask for passwords, bank details, internal API keys, or private user records.
        """;

    private final List<AIProvider> providers = new ArrayList<>();

    public AIAssistantService() {
        GeminiAIProvider gemini = new GeminiAIProvider();
        if (gemini.isAvailable()) {
            providers.add(gemini);
        }
        // Built-in rule-based provider as fallback/primary
        providers.add(new RuleBasedKnowledgeAIProvider());
    }

    public String ask(String userPrompt) {
        if (userPrompt == null || userPrompt.trim().isEmpty()) {
            return "Please type a question about KisaanConnect and I'll be glad to help!";
        }

        String cleanedPrompt = userPrompt.trim();
        if (cleanedPrompt.length() > 500) {
            cleanedPrompt = cleanedPrompt.substring(0, 500);
        }

        for (AIProvider provider : providers) {
            try {
                if (provider.isAvailable()) {
                    String response = provider.generateResponse(cleanedPrompt, SYSTEM_CONTEXT);
                    if (response != null && !response.trim().isEmpty()) {
                        return response.trim();
                    }
                }
            } catch (Exception e) {
                // Log and continue to next provider
            }
        }

        return "Namaste! KisaanConnect is India's direct farm-to-table & wholesale marketplace. You can browse produce, register as a farmer, or track orders with live GPS routing.";
    }
}
