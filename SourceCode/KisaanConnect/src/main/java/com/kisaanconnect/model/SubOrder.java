package com.kisaanconnect.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SubOrder implements Serializable {
    private static final long serialVersionUID = 1L;

    private int subOrderId;
    private int orderId;
    private int farmerProfileId;
    private String subOrderNumber;
    private BigDecimal subtotalAmount;
    private BigDecimal deliveryCharge;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private String paymentStatus;
    private String subOrderStatus;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Associated/Display fields
    private String farmerName;
    private String farmName;
    private String farmerPhone;
    private String masterOrderNumber;
    private String deliveryName;
    private String deliveryPhone;
    private String deliveryAddress;
    private String deliveryPincode;
    private String buyerName;
    private String organizationName;
    private List<OrderItem> items = new ArrayList<>();

    public SubOrder() {}

    public int getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(int subOrderId) {
        this.subOrderId = subOrderId;
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

    public String getSubOrderNumber() {
        return subOrderNumber;
    }

    public void setSubOrderNumber(String subOrderNumber) {
        this.subOrderNumber = subOrderNumber;
    }

    public BigDecimal getSubtotalAmount() {
        return subtotalAmount;
    }

    public void setSubtotalAmount(BigDecimal subtotalAmount) {
        this.subtotalAmount = subtotalAmount;
    }

    public BigDecimal getDeliveryCharge() {
        return deliveryCharge;
    }

    public void setDeliveryCharge(BigDecimal deliveryCharge) {
        this.deliveryCharge = deliveryCharge;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getSubOrderStatus() {
        return subOrderStatus;
    }

    public void setSubOrderStatus(String subOrderStatus) {
        this.subOrderStatus = subOrderStatus;
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

    public String getFarmerName() {
        return farmerName;
    }

    public void setFarmerName(String farmerName) {
        this.farmerName = farmerName;
    }

    public String getFarmName() {
        return farmName;
    }

    public void setFarmName(String farmName) {
        this.farmName = farmName;
    }

    public String getFarmerPhone() {
        return farmerPhone;
    }

    public void setFarmerPhone(String farmerPhone) {
        this.farmerPhone = farmerPhone;
    }

    public String getMasterOrderNumber() {
        return masterOrderNumber;
    }

    public void setMasterOrderNumber(String masterOrderNumber) {
        this.masterOrderNumber = masterOrderNumber;
    }

    public String getDeliveryName() {
        return deliveryName;
    }

    public void setDeliveryName(String deliveryName) {
        this.deliveryName = deliveryName;
    }

    public String getDeliveryPhone() {
        return deliveryPhone;
    }

    public void setDeliveryPhone(String deliveryPhone) {
        this.deliveryPhone = deliveryPhone;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public String getDeliveryPincode() {
        return deliveryPincode;
    }

    public void setDeliveryPincode(String deliveryPincode) {
        this.deliveryPincode = deliveryPincode;
    }

    public String getBuyerName() {
        return buyerName;
    }

    public void setBuyerName(String buyerName) {
        this.buyerName = buyerName;
    }

    public String getOrganizationName() {
        return organizationName;
    }

    public void setOrganizationName(String organizationName) {
        this.organizationName = organizationName;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }

    private Double pickupLatitude;
    private Double pickupLongitude;
    private Double deliveryLatitude;
    private Double deliveryLongitude;
    private Double estimatedDistanceKm;

    public Double getPickupLatitude() {
        return pickupLatitude;
    }

    public void setPickupLatitude(Double pickupLatitude) {
        this.pickupLatitude = pickupLatitude;
    }

    public Double getPickupLongitude() {
        return pickupLongitude;
    }

    public void setPickupLongitude(Double pickupLongitude) {
        this.pickupLongitude = pickupLongitude;
    }

    public Double getDeliveryLatitude() {
        return deliveryLatitude;
    }

    public void setDeliveryLatitude(Double deliveryLatitude) {
        this.deliveryLatitude = deliveryLatitude;
    }

    public Double getDeliveryLongitude() {
        return deliveryLongitude;
    }

    public void setDeliveryLongitude(Double deliveryLongitude) {
        this.deliveryLongitude = deliveryLongitude;
    }

    public Double getEstimatedDistanceKm() {
        return estimatedDistanceKm;
    }

    public void setEstimatedDistanceKm(Double estimatedDistanceKm) {
        this.estimatedDistanceKm = estimatedDistanceKm;
    }

    private java.sql.Date deliveryDate;

    public java.sql.Date getDeliveryDate() {
        return deliveryDate;
    }

    public void setDeliveryDate(java.sql.Date deliveryDate) {
        this.deliveryDate = deliveryDate;
    }

    public String getFormattedDeliveryDate() {
        if (deliveryDate == null) return "Not specified";
        try {
            return new java.text.SimpleDateFormat("dd MMM yyyy").format(deliveryDate);
        } catch (Exception e) {
            return deliveryDate.toString();
        }
    }
}
