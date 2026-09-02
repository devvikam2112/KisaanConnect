package com.kisaanconnect.dao;

import com.kisaanconnect.model.ChatRoom;
import com.kisaanconnect.model.Message;
import com.kisaanconnect.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    public ChatRoom getOrCreateChatRoom(int subOrderId, int userId) {
        // 1. Verify sub_order and ownership
        String authSql = "SELECT so.sub_order_id, so.order_id, so.farmer_profile_id, so.sub_order_number, "
                       + "so.total_amount, so.sub_order_status, "
                       + "o.order_number, o.buyer_profile_id, o.organization_id, "
                       + "fp.user_id AS farmer_user_id, fp.farm_name, u_f.full_name AS farmer_name, "
                       + "COALESCE(bp.user_id, org.owner_user_id) AS buyer_user_id, "
                       + "COALESCE(u_b.full_name, org.org_name) AS buyer_name "
                       + "FROM sub_orders so "
                       + "JOIN orders o ON so.order_id = o.order_id "
                       + "JOIN farmer_profiles fp ON so.farmer_profile_id = fp.farmer_profile_id "
                       + "JOIN users u_f ON fp.user_id = u_f.user_id "
                       + "LEFT JOIN buyer_profiles bp ON o.buyer_profile_id = bp.buyer_profile_id "
                       + "LEFT JOIN users u_b ON bp.user_id = u_b.user_id "
                       + "LEFT JOIN organizations org ON o.organization_id = org.organization_id "
                       + "WHERE so.sub_order_id = ?";

        int orderId = 0;
        int farmerProfileId = 0;
        int farmerUserId = 0;
        int buyerUserId = 0;
        Integer buyerProfileId = null;
        Integer organizationId = null;
        String orderNumber = null;
        String subOrderNumber = null;
        String farmName = null;
        String farmerName = null;
        String buyerName = null;
        String subOrderStatus = null;
        java.math.BigDecimal subOrderTotal = java.math.BigDecimal.ZERO;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(authSql)) {
            ps.setInt(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    orderId = rs.getInt("order_id");
                    farmerProfileId = rs.getInt("farmer_profile_id");
                    farmerUserId = rs.getInt("farmer_user_id");
                    buyerUserId = rs.getInt("buyer_user_id");
                    buyerProfileId = (Integer) rs.getObject("buyer_profile_id");
                    organizationId = (Integer) rs.getObject("organization_id");
                    orderNumber = rs.getString("order_number");
                    subOrderNumber = rs.getString("sub_order_number");
                    farmName = rs.getString("farm_name");
                    farmerName = rs.getString("farmer_name");
                    buyerName = rs.getString("buyer_name");
                    subOrderStatus = rs.getString("sub_order_status");
                    subOrderTotal = rs.getBigDecimal("total_amount");
                } else {
                    return null; // sub-order not found
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }

        // STRICT AUTHORIZATION CHECK
        if (userId != farmerUserId && userId != buyerUserId) {
            return null; // Forbidden
        }

        // 2. Fetch or create chat_room
        String selectRoom = "SELECT chat_room_id, order_id, sub_order_id, buyer_user_id, farmer_user_id, "
                          + "buyer_profile_id, farmer_profile_id, organization_id, chat_status, created_at "
                          + "FROM chat_rooms WHERE sub_order_id = ?";
        ChatRoom room = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectRoom)) {
            ps.setInt(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    room = new ChatRoom();
                    room.setChatRoomId(rs.getInt("chat_room_id"));
                    room.setOrderId(rs.getInt("order_id"));
                    room.setSubOrderId(rs.getInt("sub_order_id"));
                    room.setBuyerUserId(rs.getInt("buyer_user_id"));
                    room.setFarmerUserId(rs.getInt("farmer_user_id"));
                    room.setBuyerProfileId((Integer) rs.getObject("buyer_profile_id"));
                    room.setFarmerProfileId(rs.getInt("farmer_profile_id"));
                    room.setOrganizationId((Integer) rs.getObject("organization_id"));
                    room.setChatStatus(rs.getString("chat_status"));
                    room.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (room == null) {
            // Insert chat room
            String insertRoom = "INSERT INTO chat_rooms (order_id, sub_order_id, buyer_user_id, farmer_user_id, "
                              + "buyer_profile_id, farmer_profile_id, organization_id, chat_status) "
                              + "VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(insertRoom, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, orderId);
                ps.setInt(2, subOrderId);
                ps.setInt(3, buyerUserId);
                ps.setInt(4, farmerUserId);
                if (buyerProfileId != null) ps.setInt(5, buyerProfileId); else ps.setNull(5, java.sql.Types.INTEGER);
                ps.setInt(6, farmerProfileId);
                if (organizationId != null) ps.setInt(7, organizationId); else ps.setNull(7, java.sql.Types.INTEGER);
                ps.executeUpdate();
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) {
                        room = new ChatRoom();
                        room.setChatRoomId(gk.getInt(1));
                        room.setOrderId(orderId);
                        room.setSubOrderId(subOrderId);
                        room.setBuyerUserId(buyerUserId);
                        room.setFarmerUserId(farmerUserId);
                        room.setBuyerProfileId(buyerProfileId);
                        room.setFarmerProfileId(farmerProfileId);
                        room.setOrganizationId(organizationId);
                        room.setChatStatus("ACTIVE");
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        if (room != null) {
            room.setOrderNumber(orderNumber);
            room.setSubOrderNumber(subOrderNumber);
            room.setFarmName(farmName);
            room.setFarmerName(farmerName);
            room.setBuyerName(buyerName);
            room.setSubOrderStatus(subOrderStatus);
            room.setSubOrderTotal(subOrderTotal);
            room.setItemsSummary(getItemsSummaryForSubOrder(subOrderId));
        }

        return room;
    }

    public ChatRoom getChatRoomById(int chatRoomId, int userId) {
        String sql = "SELECT cr.chat_room_id, cr.order_id, cr.sub_order_id, cr.buyer_user_id, cr.farmer_user_id, "
                   + "cr.buyer_profile_id, cr.farmer_profile_id, cr.organization_id, cr.chat_status, cr.created_at, "
                   + "so.sub_order_number, so.total_amount, so.sub_order_status, o.order_number, "
                   + "fp.farm_name, u_f.full_name AS farmer_name, "
                   + "COALESCE(u_b.full_name, org.org_name) AS buyer_name "
                   + "FROM chat_rooms cr "
                   + "JOIN sub_orders so ON cr.sub_order_id = so.sub_order_id "
                   + "JOIN orders o ON cr.order_id = o.order_id "
                   + "JOIN farmer_profiles fp ON cr.farmer_profile_id = fp.farmer_profile_id "
                   + "JOIN users u_f ON fp.user_id = u_f.user_id "
                   + "LEFT JOIN buyer_profiles bp ON cr.buyer_profile_id = bp.buyer_profile_id "
                   + "LEFT JOIN users u_b ON bp.user_id = u_b.user_id "
                   + "LEFT JOIN organizations org ON cr.organization_id = org.organization_id "
                   + "WHERE cr.chat_room_id = ?";

        ChatRoom room = null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chatRoomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int buyerUserId = rs.getInt("buyer_user_id");
                    int farmerUserId = rs.getInt("farmer_user_id");

                    // STRICT AUTHORIZATION CHECK
                    if (userId != buyerUserId && userId != farmerUserId) {
                        return null; // Forbidden
                    }

                    room = new ChatRoom();
                    room.setChatRoomId(rs.getInt("chat_room_id"));
                    room.setOrderId(rs.getInt("order_id"));
                    room.setSubOrderId(rs.getInt("sub_order_id"));
                    room.setBuyerUserId(buyerUserId);
                    room.setFarmerUserId(farmerUserId);
                    room.setBuyerProfileId((Integer) rs.getObject("buyer_profile_id"));
                    room.setFarmerProfileId(rs.getInt("farmer_profile_id"));
                    room.setOrganizationId((Integer) rs.getObject("organization_id"));
                    room.setChatStatus(rs.getString("chat_status"));
                    room.setCreatedAt(rs.getTimestamp("created_at"));
                    room.setOrderNumber(rs.getString("order_number"));
                    room.setSubOrderNumber(rs.getString("sub_order_number"));
                    room.setFarmName(rs.getString("farm_name"));
                    room.setFarmerName(rs.getString("farmer_name"));
                    room.setBuyerName(rs.getString("buyer_name"));
                    room.setSubOrderStatus(rs.getString("sub_order_status"));
                    room.setSubOrderTotal(rs.getBigDecimal("total_amount"));
                    room.setItemsSummary(getItemsSummaryForSubOrder(room.getSubOrderId()));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return room;
    }

    public List<ChatRoom> getChatRoomsForUser(int userId) {
        List<ChatRoom> list = new ArrayList<>();
        String sql = "SELECT cr.chat_room_id, cr.order_id, cr.sub_order_id, cr.buyer_user_id, cr.farmer_user_id, "
                   + "cr.buyer_profile_id, cr.farmer_profile_id, cr.organization_id, cr.chat_status, cr.created_at, "
                   + "so.sub_order_number, so.total_amount, so.sub_order_status, o.order_number, "
                   + "fp.farm_name, u_f.full_name AS farmer_name, "
                   + "COALESCE(u_b.full_name, org.org_name) AS buyer_name, "
                   + "(SELECT message_text FROM messages WHERE chat_room_id = cr.chat_room_id ORDER BY sent_at DESC LIMIT 1) AS last_message_text, "
                   + "(SELECT sent_at FROM messages WHERE chat_room_id = cr.chat_room_id ORDER BY sent_at DESC LIMIT 1) AS last_message_time, "
                   + "(SELECT COUNT(*) FROM messages WHERE chat_room_id = cr.chat_room_id AND sender_user_id != ? AND is_read = 0) AS unread_count "
                   + "FROM chat_rooms cr "
                   + "JOIN sub_orders so ON cr.sub_order_id = so.sub_order_id "
                   + "JOIN orders o ON cr.order_id = o.order_id "
                   + "JOIN farmer_profiles fp ON cr.farmer_profile_id = fp.farmer_profile_id "
                   + "JOIN users u_f ON fp.user_id = u_f.user_id "
                   + "LEFT JOIN buyer_profiles bp ON cr.buyer_profile_id = bp.buyer_profile_id "
                   + "LEFT JOIN users u_b ON bp.user_id = u_b.user_id "
                   + "LEFT JOIN organizations org ON cr.organization_id = org.organization_id "
                   + "WHERE cr.buyer_user_id = ? OR cr.farmer_user_id = ? "
                   + "ORDER BY COALESCE(last_message_time, cr.created_at) DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatRoom room = new ChatRoom();
                    room.setChatRoomId(rs.getInt("chat_room_id"));
                    room.setOrderId(rs.getInt("order_id"));
                    room.setSubOrderId(rs.getInt("sub_order_id"));
                    room.setBuyerUserId(rs.getInt("buyer_user_id"));
                    room.setFarmerUserId(rs.getInt("farmer_user_id"));
                    room.setBuyerProfileId((Integer) rs.getObject("buyer_profile_id"));
                    room.setFarmerProfileId(rs.getInt("farmer_profile_id"));
                    room.setOrganizationId((Integer) rs.getObject("organization_id"));
                    room.setChatStatus(rs.getString("chat_status"));
                    room.setCreatedAt(rs.getTimestamp("created_at"));
                    room.setOrderNumber(rs.getString("order_number"));
                    room.setSubOrderNumber(rs.getString("sub_order_number"));
                    room.setFarmName(rs.getString("farm_name"));
                    room.setFarmerName(rs.getString("farmer_name"));
                    room.setBuyerName(rs.getString("buyer_name"));
                    room.setSubOrderStatus(rs.getString("sub_order_status"));
                    room.setSubOrderTotal(rs.getBigDecimal("total_amount"));
                    room.setLastMessageText(rs.getString("last_message_text"));
                    room.setLastMessageTime(rs.getTimestamp("last_message_time"));
                    room.setUnreadCount(rs.getInt("unread_count"));
                    list.add(room);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean sendMessage(int chatRoomId, int senderUserId, String senderRole, String messageType, String text) {
        if (text == null || text.trim().isEmpty()) return false;

        ChatRoom room = getChatRoomById(chatRoomId, senderUserId);
        if (room == null) {
            return false; // Unauthorized or not found
        }

        if (room.isReadOnly()) {
            return false; // Cannot send message to completed, cancelled, or rejected orders
        }

        String mappedRole = senderRole != null ? senderRole.toUpperCase() : "BUYER";
        if ("CUSTOMER".equals(mappedRole)) mappedRole = "BUYER";

        String insertSql = "INSERT INTO messages (chat_room_id, sender_user_id, sender_role, message_type, message_text, is_read) "
                         + "VALUES (?, ?, ?, ?, ?, 0)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, chatRoomId);
            ps.setInt(2, senderUserId);
            ps.setString(3, mappedRole);
            ps.setString(4, messageType != null ? messageType : "TEXT");
            ps.setString(5, text.trim());
            int rows = ps.executeUpdate();

            if (rows > 0) {
                // Send notification to recipient
                int recipientUserId = (senderUserId == room.getBuyerUserId()) ? room.getFarmerUserId() : room.getBuyerUserId();
                String senderDisplayName = (senderUserId == room.getBuyerUserId()) ? room.getBuyerName() : (room.getFarmName() != null ? room.getFarmName() : room.getFarmerName());
                String notifTitle = "New message from " + senderDisplayName;
                String snippet = text.trim();
                if (snippet.length() > 60) snippet = snippet.substring(0, 57) + "...";
                String notifMsg = snippet + " (Sub-Order #" + room.getSubOrderNumber() + ")";
                String targetUrl = "/chat?subOrderId=" + room.getSubOrderId();

                notificationDAO.createNotification(recipientUserId, room.getOrderId(), room.getSubOrderId(), chatRoomId, notifTitle, notifMsg, "CHAT", targetUrl);
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Message> getMessages(int chatRoomId, int userId) {
        List<Message> list = new ArrayList<>();
        ChatRoom room = getChatRoomById(chatRoomId, userId);
        if (room == null) {
            return list; // Unauthorized
        }

        String sql = "SELECT m.message_id, m.chat_room_id, m.sender_user_id, m.sender_role, m.message_type, "
                   + "m.message_text, m.is_read, m.sent_at, u.full_name AS sender_name "
                   + "FROM messages m "
                   + "JOIN users u ON m.sender_user_id = u.user_id "
                   + "WHERE m.chat_room_id = ? "
                   + "ORDER BY m.sent_at ASC, m.message_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chatRoomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Message m = new Message();
                    m.setMessageId(rs.getInt("message_id"));
                    m.setChatRoomId(rs.getInt("chat_room_id"));
                    m.setSenderUserId(rs.getInt("sender_user_id"));
                    m.setSenderRole(rs.getString("sender_role"));
                    m.setMessageType(rs.getString("message_type"));
                    m.setMessageText(rs.getString("message_text"));
                    m.setIsRead(rs.getBoolean("is_read"));
                    m.setSentAt(rs.getTimestamp("sent_at"));
                    m.setSenderName(rs.getString("sender_name"));
                    list.add(m);
                }
            }

            // Mark received messages as read
            String markRead = "UPDATE messages SET is_read = 1 WHERE chat_room_id = ? AND sender_user_id != ? AND is_read = 0";
            try (PreparedStatement psRead = conn.prepareStatement(markRead)) {
                psRead.setInt(1, chatRoomId);
                psRead.setInt(2, userId);
                psRead.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getUnreadMessageCount(int userId) {
        String sql = "SELECT COUNT(*) FROM messages m "
                   + "JOIN chat_rooms cr ON m.chat_room_id = cr.chat_room_id "
                   + "WHERE (cr.buyer_user_id = ? OR cr.farmer_user_id = ?) "
                   + "AND m.sender_user_id != ? AND m.is_read = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
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

    private String getItemsSummaryForSubOrder(Integer subOrderId) {
        if (subOrderId == null) return "";
        String sql = "SELECT oi.quantity, p.product_name, p.unit "
                   + "FROM order_items oi "
                   + "JOIN products p ON oi.product_id = p.product_id "
                   + "WHERE oi.sub_order_id = ?";
        StringBuilder sb = new StringBuilder();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (sb.length() > 0) sb.append(", ");
                    sb.append(rs.getString("product_name"))
                      .append(" (").append(rs.getInt("quantity")).append(" ").append(rs.getString("unit")).append(")");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return sb.toString();
    }
}
