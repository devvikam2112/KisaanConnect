package com.kisaanconnect.model;

import java.sql.Timestamp;

public class Inventory {

    private int inventoryId;
    private int productId;
    private double availableQuantity;
    private double reservedQuantity;
    private double minimumStock;
    private Timestamp lastUpdated;

    // View helper
    private String productName;
    private String unit;

    public Inventory() {
    }

    public Inventory(int inventoryId, int productId, double availableQuantity,
                     double reservedQuantity, double minimumStock, Timestamp lastUpdated) {
        this.inventoryId = inventoryId;
        this.productId = productId;
        this.availableQuantity = availableQuantity;
        this.reservedQuantity = reservedQuantity;
        this.minimumStock = minimumStock;
        this.lastUpdated = lastUpdated;
    }

    public int getInventoryId() {
        return inventoryId;
    }

    public void setInventoryId(int inventoryId) {
        this.inventoryId = inventoryId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public double getAvailableQuantity() {
        return availableQuantity;
    }

    public void setAvailableQuantity(double availableQuantity) {
        this.availableQuantity = availableQuantity;
    }

    public double getReservedQuantity() {
        return reservedQuantity;
    }

    public void setReservedQuantity(double reservedQuantity) {
        this.reservedQuantity = reservedQuantity;
    }

    public double getMinimumStock() {
        return minimumStock;
    }

    public void setMinimumStock(double minimumStock) {
        this.minimumStock = minimumStock;
    }

    public Timestamp getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Timestamp lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }
}
