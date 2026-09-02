package com.kisaanconnect.service.ai;

public interface AIProvider {

    /**
     * Generates a conversational response based on user prompt and system context.
     * @param userPrompt The user's query (sanitized)
     * @param systemContext System prompt and public platform knowledge
     * @return AI generated response text
     * @throws Exception If generation fails
     */
    String generateResponse(String userPrompt, String systemContext) throws Exception;

    /**
     * Provider identification name.
     */
    String getProviderName();

    /**
     * Checks if this provider is currently configured and available.
     */
    boolean isAvailable();
}
