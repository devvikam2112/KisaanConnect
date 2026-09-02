package com.kisaanconnect.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductPriceHistory {
    private int priceHistoryId;
    private int productId;
    private String productName;
    private BigDecimal oldPrice;
    private BigDecimal newPrice;
    private int changedByUserId;
    private String changedByUserName;
    private Timestamp changedAt;

    public ProductPriceHistory() {}

    public int getPriceHistoryId() {
        return priceHistoryId;
    }

    public void setPriceHistoryId(int priceHistoryId) {
        this.priceHistoryId = priceHistoryId;
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

    public BigDecimal getOldPrice() {
        return oldPrice;
    }

    public void setOldPrice(BigDecimal oldPrice) {
        this.oldPrice = oldPrice;
    }

    public BigDecimal getNewPrice() {
        return newPrice;
    }

    public void setNewPrice(BigDecimal newPrice) {
        this.newPrice = newPrice;
    }

    public int getChangedByUserId() {
        return changedByUserId;
    }

    public void setChangedByUserId(int changedByUserId) {
        this.changedByUserId = changedByUserId;
    }

    public String getChangedByUserName() {
        return changedByUserName;
    }

    public void setChangedByUserName(String changedByUserName) {
        this.changedByUserName = changedByUserName;
    }

    public Timestamp getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(Timestamp changedAt) {
        this.changedAt = changedAt;
    }
}
