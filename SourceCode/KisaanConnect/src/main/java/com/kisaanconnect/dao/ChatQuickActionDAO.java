package com.kisaanconnect.dao;

import com.kisaanconnect.model.ChatQuickAction;
import com.kisaanconnect.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ChatQuickActionDAO {

    public List<ChatQuickAction> getQuickActionsForRole(String role) {
        List<ChatQuickAction> list = new ArrayList<>();
        if (role == null) return list;

        String mappedRole = role.toUpperCase();
        if ("CUSTOMER".equals(mappedRole)) mappedRole = "BUYER";

        String sql = "SELECT action_id, sender_role, action_text, is_active, created_at "
                   + "FROM chat_quick_actions WHERE sender_role = ? AND is_active = 1 ORDER BY action_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, mappedRole);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatQuickAction a = new ChatQuickAction();
                    a.setActionId(rs.getInt("action_id"));
                    a.setSenderRole(rs.getString("sender_role"));
                    a.setActionText(rs.getString("action_text"));
                    a.setIsActive(rs.getBoolean("is_active"));
                    a.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
