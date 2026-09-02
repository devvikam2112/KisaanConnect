package com.kisaanconnect.dao;

import com.kisaanconnect.model.Notification;
import com.kisaanconnect.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean createNotification(int userId, Integer orderId, Integer subOrderId, Integer chatRoomId, String title, String message, String notificationType, String targetUrl) {
        String sql = "INSERT INTO notifications (user_id, order_id, sub_order_id, chat_room_id, title, message, notification_type, target_url, is_read) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            if (orderId != null) ps.setInt(2, orderId); else ps.setNull(2, java.sql.Types.INTEGER);
            if (subOrderId != null) ps.setInt(3, subOrderId); else ps.setNull(3, java.sql.Types.INTEGER);
            if (chatRoomId != null) ps.setInt(4, chatRoomId); else ps.setNull(4, java.sql.Types.INTEGER);
            ps.setString(5, title);
            ps.setString(6, message);
            ps.setString(7, notificationType);
            ps.setString(8, targetUrl);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> getNotificationsForUser(int userId, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT notification_id, user_id, order_id, sub_order_id, chat_room_id, title, message, notification_type, target_url, is_read, created_at "
                   + "FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit > 0 ? limit : 50);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationId(rs.getInt("notification_id"));
                    n.setUserId(rs.getInt("user_id"));
                    n.setOrderId((Integer) rs.getObject("order_id"));
                    n.setSubOrderId((Integer) rs.getObject("sub_order_id"));
                    n.setChatRoomId((Integer) rs.getObject("chat_room_id"));
                    n.setTitle(rs.getString("title"));
                    n.setMessage(rs.getString("message"));
                    n.setNotificationType(rs.getString("notification_type"));
                    n.setTargetUrl(rs.getString("target_url"));
                    n.setIsRead(rs.getBoolean("is_read"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
