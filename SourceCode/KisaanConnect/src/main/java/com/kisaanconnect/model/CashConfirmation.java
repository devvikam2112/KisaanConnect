package com.kisaanconnect.model;

import java.sql.Timestamp;

public class CashConfirmation {

    private int confirmationId;
    private int orderId;
    private int farmerProfileId;
    private String confirmationStatus;
    private Timestamp confirmedAt;
    private String ipAddress;
    private String deviceInfo;
    private String remarks;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public CashConfirmation() {
    }

    public int getConfirmationId() {
        return confirmationId;
    }

    public void setConfirmationId(int confirmationId) {
        this.confirmationId = confirmationId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getFarmerProfileId() {
        return farmerProfileId;
    }

    public void setFarmerProfileId(int farmerProfileId) {
        this.farmerProfileId = farmerProfileId;
    }

    public String getConfirmationStatus() {
        return confirmationStatus;
    }

    public void setConfirmationStatus(String confirmationStatus) {
        this.confirmationStatus = confirmationStatus;
    }

    public Timestamp getConfirmedAt() {
        return confirmedAt;
    }

    public void setConfirmedAt(Timestamp confirmedAt) {
        this.confirmedAt = confirmedAt;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getDeviceInfo() {
        return deviceInfo;
    }

    public void setDeviceInfo(String deviceInfo) {
        this.deviceInfo = deviceInfo;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
