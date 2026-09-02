package com.kisaanconnect.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class ChatRoom implements Serializable {
    private static final long serialVersionUID = 1L;

    private int chatRoomId;
    private int orderId;
    private Integer subOrderId;
    private int buyerUserId;
    private int farmerUserId;
    private Integer buyerProfileId;
    private int farmerProfileId;
    private Integer organizationId;
    private String chatStatus; // ACTIVE, CLOSED
    private Timestamp createdAt;

    // Display / Context helpers
    private String orderNumber;
    private String subOrderNumber;
    private String farmName;
    private String farmerName;
    private String buyerName;
    private String subOrderStatus;
    private BigDecimal subOrderTotal;
    private String itemsSummary;
    private int unreadCount;
    private String lastMessageText;
    private Timestamp lastMessageTime;

    public ChatRoom() {
    }

    public int getChatRoomId() {
        return chatRoomId;
    }

    public void setChatRoomId(int chatRoomId) {
        this.chatRoomId = chatRoomId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public Integer getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(Integer subOrderId) {
        this.subOrderId = subOrderId;
    }

    public int getBuyerUserId() {
        return buyerUserId;
    }

    public void setBuyerUserId(int buyerUserId) {
        this.buyerUserId = buyerUserId;
    }

    public int getFarmerUserId() {
        return farmerUserId;
    }

    public void setFarmerUserId(int farmerUserId) {
        this.farmerUserId = farmerUserId;
    }

    public Integer getBuyerProfileId() {
        return buyerProfileId;
    }

    public void setBuyerProfileId(Integer buyerProfileId) {
        this.buyerProfileId = buyerProfileId;
    }

    public int getFarmerProfileId() {
        return farmerProfileId;
    }

    public void setFarmerProfileId(int farmerProfileId) {
        this.farmerProfileId = farmerProfileId;
    }

    public Integer getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(Integer organizationId) {
        this.organizationId = organizationId;
    }

    public String getChatStatus() {
        return chatStatus;
    }

    public void setChatStatus(String chatStatus) {
        this.chatStatus = chatStatus;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getOrderNumber() {
        return orderNumber;
    }

    public void setOrderNumber(String orderNumber) {
        this.orderNumber = orderNumber;
    }

    public String getSubOrderNumber() {
        return subOrderNumber;
    }

    public void setSubOrderNumber(String subOrderNumber) {
        this.subOrderNumber = subOrderNumber;
    }

    public String getFarmName() {
        return farmName;
    }

    public void setFarmName(String farmName) {
        this.farmName = farmName;
    }

    public String getFarmerName() {
        return farmerName;
    }

    public void setFarmerName(String farmerName) {
        this.farmerName = farmerName;
    }

    public String getBuyerName() {
        return buyerName;
    }

    public void setBuyerName(String buyerName) {
        this.buyerName = buyerName;
    }

    public String getSubOrderStatus() {
        return subOrderStatus;
    }

    public void setSubOrderStatus(String subOrderStatus) {
        this.subOrderStatus = subOrderStatus;
    }

    public BigDecimal getSubOrderTotal() {
        return subOrderTotal;
    }

    public void setSubOrderTotal(BigDecimal subOrderTotal) {
        this.subOrderTotal = subOrderTotal;
    }

    public String getItemsSummary() {
        return itemsSummary;
    }

    public void setItemsSummary(String itemsSummary) {
        this.itemsSummary = itemsSummary;
    }

    public int getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(int unreadCount) {
        this.unreadCount = unreadCount;
    }

    public String getLastMessageText() {
        return lastMessageText;
    }

    public void setLastMessageText(String lastMessageText) {
        this.lastMessageText = lastMessageText;
    }

    public Timestamp getLastMessageTime() {
        return lastMessageTime;
    }

    public void setLastMessageTime(Timestamp lastMessageTime) {
        this.lastMessageTime = lastMessageTime;
    }

    public boolean isReadOnly() {
        if ("CLOSED".equalsIgnoreCase(chatStatus)) return true;
        if (subOrderStatus == null) return false;
        String st = subOrderStatus.toUpperCase();
        return "COMPLETED".equals(st) || "CANCELLED".equals(st) || "REJECTED".equals(st);
    }
}
