package com.kisaanconnect.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class OrderItem {

    private int orderItemId;
    private int orderId;
    private Integer subOrderId;
    private Integer farmerProfileId;
    private int productId;
    private String productName;
    private BigDecimal unitPrice;
    private double quantity;
    private BigDecimal discountAmount;
    private BigDecimal finalUnitPrice;
    private BigDecimal subtotal;
    private Timestamp createdAt;

    // View helper attributes
    private String unit;
    private String primaryImageUrl;
    private String farmerName;
    private String farmName;

    public String getFarmName() {
        return farmName;
    }

    public void setFarmName(String farmName) {
        this.farmName = farmName;
    }

    public OrderItem() {
    }

    public Integer getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(Integer subOrderId) {
        this.subOrderId = subOrderId;
    }

    public Integer getFarmerProfileId() {
        return farmerProfileId;
    }

    public void setFarmerProfileId(Integer farmerProfileId) {
        this.farmerProfileId = farmerProfileId;
    }

    public int getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(int orderItemId) {
        this.orderItemId = orderItemId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public double getQuantity() {
        return quantity;
    }

    public void setQuantity(double quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getFinalUnitPrice() {
        return finalUnitPrice;
    }

    public void setFinalUnitPrice(BigDecimal finalUnitPrice) {
        this.finalUnitPrice = finalUnitPrice;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getPrimaryImageUrl() {
        return primaryImageUrl;
    }

    public void setPrimaryImageUrl(String primaryImageUrl) {
        this.primaryImageUrl = primaryImageUrl;
    }

    public String getFarmerName() {
        return farmerName;
    }

    public void setFarmerName(String farmerName) {
        this.farmerName = farmerName;
    }
}
