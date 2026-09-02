package com.kisaanconnect.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ChatQuickAction implements Serializable {
    private static final long serialVersionUID = 1L;

    private int actionId;
    private String senderRole; // BUYER, FARMER, COMMERCIAL
    private String actionText;
    private boolean isActive;
    private Timestamp createdAt;

    public ChatQuickAction() {
    }

    public ChatQuickAction(int actionId, String senderRole, String actionText, boolean isActive) {
        this.actionId = actionId;
        this.senderRole = senderRole;
        this.actionText = actionText;
        this.isActive = isActive;
    }

    public int getActionId() {
        return actionId;
    }

    public void setActionId(int actionId) {
        this.actionId = actionId;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public String getActionText() {
        return actionText;
    }

    public void setActionText(String actionText) {
        this.actionText = actionText;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
