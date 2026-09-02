package com.kisaanconnect.controller;

import com.kisaanconnect.service.ai.AIAssistantService;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AssistantServlet", urlPatterns = {"/api/assistant/chat"})
public class AssistantServlet extends HttpServlet {

    private final AIAssistantService assistantService = new AIAssistantService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Rate limiting check per session
        HttpSession session = request.getSession(true);
        Long lastRequestTime = (Long) session.getAttribute("ai_last_req_time");
        long now = System.currentTimeMillis();
        if (lastRequestTime != null && (now - lastRequestTime) < 1000) { // Max 1 req per second
            response.setStatus(429);
            out.print("{\"success\":false,\"error\":\"Please wait a moment before sending another message.\"}");
            return;
        }
        session.setAttribute("ai_last_req_time", now);

        String message = request.getParameter("message");
        if (message == null || message.trim().isEmpty()) {
            // Check JSON body
            StringBuilder jb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) jb.append(line);
            }
            String raw = jb.toString();
            message = extractJsonString(raw, "message");
        }

        if (message == null || message.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Message cannot be empty.\"}");
            return;
        }

        if (message.length() > 500) {
            message = message.substring(0, 500);
        }

        String reply = assistantService.ask(message);

        out.printf("{\"success\":true,\"reply\":\"%s\"}", escapeJson(reply));
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private String extractJsonString(String json, String key) {
        String pattern = "\"" + key + "\":\"";
        int idx = json.indexOf(pattern);
        if (idx == -1) {
            pattern = "\"" + key + "\": \"";
            idx = json.indexOf(pattern);
        }
        if (idx == -1) return null;
        int start = idx + pattern.length();
        int end = json.indexOf("\"", start);
        while (end != -1 && json.charAt(end - 1) == '\\') {
            end = json.indexOf("\"", end + 1);
        }
        if (end == -1) return null;
        return json.substring(start, end).replace("\\\"", "\"").replace("\\n", "\n").replace("\\\\", "\\");
    }
}
