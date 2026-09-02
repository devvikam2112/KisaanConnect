package com.kisaanconnect.service.ai;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class GeminiAIProvider implements AIProvider {

    private final String apiKey;

    public GeminiAIProvider() {
        String key = System.getenv("GEMINI_API_KEY");
        if (key == null || key.trim().isEmpty()) {
            key = System.getenv("KISAAN_AI_KEY");
        }
        if (key == null || key.trim().isEmpty()) {
            try (InputStream in = getClass().getClassLoader().getResourceAsStream("application.properties")) {
                if (in != null) {
                    Properties prop = new Properties();
                    prop.load(in);
                    key = prop.getProperty("gemini.api.key");
                }
            } catch (Exception ignored) {}
        }
        this.apiKey = (key != null) ? key.trim() : "";
    }

    @Override
    public String getProviderName() {
        return "Google Gemini 1.5 Flash";
    }

    @Override
    public boolean isAvailable() {
        return apiKey != null && !apiKey.isEmpty();
    }

    @Override
    public String generateResponse(String userPrompt, String systemContext) throws Exception {
        if (!isAvailable()) {
            throw new IllegalStateException("Gemini API key is not configured.");
        }

        String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;
        URL url = new URL(endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(12000);
        conn.setRequestProperty("Content-Type", "application/json");

        String combinedPrompt = (systemContext != null ? systemContext + "\n\nUser Question: " : "") + userPrompt;
        String escapedText = escapeJson(combinedPrompt);

        String jsonPayload = "{\"contents\":[{\"parts\":[{\"text\":\"" + escapedText + "\"}]}],\"generationConfig\":{\"temperature\":0.3,\"maxOutputTokens\":400}}";

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
        }

        int statusCode = conn.getResponseCode();
        InputStream is = (statusCode >= 200 && statusCode < 300) ? conn.getInputStream() : conn.getErrorStream();
        StringBuilder resp = new StringBuilder();
        if (is != null) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) resp.append(line);
            }
        }

        if (statusCode >= 200 && statusCode < 300) {
            String text = extractTextFromGeminiResponse(resp.toString());
            if (text != null && !text.isEmpty()) {
                return text;
            }
        }

        throw new RuntimeException("Gemini API returned error HTTP " + statusCode + ": " + resp);
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private String extractTextFromGeminiResponse(String json) {
        int textIdx = json.indexOf("\"text\": \"");
        if (textIdx == -1) textIdx = json.indexOf("\"text\":\"");
        if (textIdx == -1) return null;

        int start = json.indexOf("\"", textIdx + 7) + 1;
        int end = json.indexOf("\"", start);
        while (end != -1 && json.charAt(end - 1) == '\\') {
            end = json.indexOf("\"", end + 1);
        }
        if (end == -1) return null;

        String raw = json.substring(start, end);
        return raw.replace("\\n", "\n")
                  .replace("\\\"", "\"")
                  .replace("\\\\", "\\")
                  .replace("\\t", "\t");
    }
}
