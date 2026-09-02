package com.kisaanconnect.controller;

import com.kisaanconnect.dao.OrderDAO;
import com.kisaanconnect.model.User;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "TrackingRouteServlet", urlPatterns = {"/order/tracking-route"})
public class TrackingRouteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"error\":\"Authentication required\"}");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        String subOrderIdStr = request.getParameter("subOrderId");
        if (subOrderIdStr == null || subOrderIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"subOrderId parameter is required\"}");
            return;
        }

        int subOrderId;
        try {
            subOrderId = Integer.parseInt(subOrderIdStr.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"error\":\"Invalid subOrderId format\"}");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Map<String, Object> trackingData = orderDAO.getSubOrderTrackingDetails(subOrderId, user.getUserId(), user.getRole());

        if (trackingData == null) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"success\":false,\"error\":\"Access denied: Unauthorized to track this sub-order route.\"}");
            return;
        }

        // Build JSON response
        StringBuilder json = new StringBuilder("{");
        json.append("\"success\":true,");
        json.append("\"subOrderId\":").append(trackingData.get("subOrderId")).append(",");
        json.append("\"subOrderNumber\":\"").append(escapeJson(trackingData.get("subOrderNumber"))).append("\",");
        json.append("\"masterOrderNumber\":\"").append(escapeJson(trackingData.get("masterOrderNumber"))).append("\",");
        json.append("\"subOrderStatus\":\"").append(escapeJson(trackingData.get("subOrderStatus"))).append("\",");
        json.append("\"pickupName\":\"").append(escapeJson(trackingData.get("pickupName"))).append("\",");
        json.append("\"pickupAddress\":\"").append(escapeJson(trackingData.get("pickupAddress"))).append("\",");
        json.append("\"pickupLat\":").append(trackingData.get("pickupLat")).append(",");
        json.append("\"pickupLon\":").append(trackingData.get("pickupLon")).append(",");
        json.append("\"deliveryName\":\"").append(escapeJson(trackingData.get("deliveryName"))).append("\",");
        json.append("\"deliveryAddress\":\"").append(escapeJson(trackingData.get("deliveryAddress"))).append("\",");
        json.append("\"deliveryPhone\":\"").append(escapeJson(trackingData.get("deliveryPhone"))).append("\",");
        json.append("\"deliveryLat\":").append(trackingData.get("deliveryLat")).append(",");
        json.append("\"deliveryLon\":").append(trackingData.get("deliveryLon")).append(",");
        json.append("\"requestedDeliveryDate\":").append(trackingData.get("requestedDeliveryDate") != null ? "\"" + escapeJson(trackingData.get("requestedDeliveryDate")) + "\"" : "null").append(",");
        json.append("\"estimatedDistanceKm\":").append(trackingData.get("estimatedDistanceKm")).append(",");
        json.append("\"hasValidCoords\":").append(trackingData.get("hasValidCoords"));
        json.append("}");

        out.print(json.toString());
    }

    private String escapeJson(Object obj) {
        if (obj == null) return "";
        return obj.toString().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
