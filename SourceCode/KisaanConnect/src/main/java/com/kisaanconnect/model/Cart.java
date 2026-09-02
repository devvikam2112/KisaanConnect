package com.kisaanconnect.model;

import java.sql.Timestamp;

public class Cart {

    private int cartId;
    private int buyerProfileId;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Cart() {
    }

    public Cart(int cartId, int buyerProfileId, Timestamp createdAt, Timestamp updatedAt) {
        this.cartId = cartId;
        this.buyerProfileId = buyerProfileId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public int getBuyerProfileId() {
        return buyerProfileId;
    }

    public void setBuyerProfileId(int buyerProfileId) {
        this.buyerProfileId = buyerProfileId;
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
