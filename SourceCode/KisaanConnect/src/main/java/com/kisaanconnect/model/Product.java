package com.kisaanconnect.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Product {

    private int productId;
    private int farmerProfileId;
    private int categoryId;
    private String productName;
    private String description;
    private BigDecimal price;
    private String unit;
    private String productType;
    private String status;
    private boolean featured;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // View-helper joined attributes
    private String categoryName;
    private String farmName;
    private String farmerName;
    private String farmerLocation;
    private String primaryImageUrl;
    private double availableQuantity;
    private double minimumStock;

    public Product() {
    }

    public Product(int productId, int farmerProfileId, int categoryId,
                   String productName, String description, BigDecimal price,
                   String unit, String productType, String status,
                   boolean featured, Timestamp createdAt, Timestamp updatedAt) {
        this.productId = productId;
        this.farmerProfileId = farmerProfileId;
        this.categoryId = categoryId;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.unit = unit;
        this.productType = productType;
        this.status = status;
        this.featured = featured;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getFarmerProfileId() {
        return farmerProfileId;
    }

    public void setFarmerProfileId(int farmerProfileId) {
        this.farmerProfileId = farmerProfileId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getProductType() {
        return productType;
    }

    public void setProductType(String productType) {
        this.productType = productType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isFeatured() {
        return featured;
    }

    public void setFeatured(boolean featured) {
        this.featured = featured;
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

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
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

    public String getFarmerLocation() {
        return farmerLocation;
    }

    public void setFarmerLocation(String farmerLocation) {
        this.farmerLocation = farmerLocation;
    }

    public String getPrimaryImageUrl() {
        return primaryImageUrl;
    }

    public void setPrimaryImageUrl(String primaryImageUrl) {
        this.primaryImageUrl = primaryImageUrl;
    }

    public double getAvailableQuantity() {
        return availableQuantity;
    }

    public void setAvailableQuantity(double availableQuantity) {
        this.availableQuantity = availableQuantity;
    }

    public double getMinimumStock() {
        return minimumStock;
    }

    public void setMinimumStock(double minimumStock) {
        this.minimumStock = minimumStock;
    }
}
