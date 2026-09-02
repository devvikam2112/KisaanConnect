package com.kisaanconnect.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Message implements Serializable {
    private static final long serialVersionUID = 1L;

    private int messageId;
    private int chatRoomId;
    private int senderUserId;
    private String senderRole; // BUYER, FARMER, COMMERCIAL
    private String messageType; // TEXT, QUICK_ACTION
    private String messageText;
    private boolean isRead;
    private Timestamp sentAt;
    private String senderName;

    public Message() {
    }

    public Message(int chatRoomId, int senderUserId, String senderRole, String messageType, String messageText) {
        this.chatRoomId = chatRoomId;
        this.senderUserId = senderUserId;
        this.senderRole = senderRole;
        this.messageType = messageType;
        this.messageText = messageText;
        this.isRead = false;
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public int getChatRoomId() {
        return chatRoomId;
    }

    public void setChatRoomId(int chatRoomId) {
        this.chatRoomId = chatRoomId;
    }

    public int getSenderUserId() {
        return senderUserId;
    }

    public void setSenderUserId(int senderUserId) {
        this.senderUserId = senderUserId;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public String getMessageType() {
        return messageType;
    }

    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public String getMessageText() {
        return messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public boolean isIsRead() {
        return isRead;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setIsRead(boolean isRead) {
        this.isRead = isRead;
    }

    public void setRead(boolean isRead) {
        this.isRead = isRead;
    }

    public Timestamp getSentAt() {
        return sentAt;
    }

    public void setSentAt(Timestamp sentAt) {
        this.sentAt = sentAt;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }
}
