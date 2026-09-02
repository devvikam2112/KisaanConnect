package com.kisaanconnect.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Wallet {

    private int walletId;
    private int userId;
    private BigDecimal currentBalance;
    private BigDecimal totalCredited;
    private BigDecimal totalDebited;
    private Timestamp lastTransactionAt;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Wallet() {
    }

    public Wallet(int walletId, int userId, BigDecimal currentBalance,
                  BigDecimal totalCredited, BigDecimal totalDebited,
                  Timestamp lastTransactionAt, String status,
                  Timestamp createdAt, Timestamp updatedAt) {
        this.walletId = walletId;
        this.userId = userId;
        this.currentBalance = currentBalance;
        this.totalCredited = totalCredited;
        this.totalDebited = totalDebited;
        this.lastTransactionAt = lastTransactionAt;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getWalletId() {
        return walletId;
    }

    public void setWalletId(int walletId) {
        this.walletId = walletId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public BigDecimal getCurrentBalance() {
        return currentBalance;
    }

    public void setCurrentBalance(BigDecimal currentBalance) {
        this.currentBalance = currentBalance;
    }

    public BigDecimal getTotalCredited() {
        return totalCredited;
    }

    public void setTotalCredited(BigDecimal totalCredited) {
        this.totalCredited = totalCredited;
    }

    public BigDecimal getTotalDebited() {
        return totalDebited;
    }

    public void setTotalDebited(BigDecimal totalDebited) {
        this.totalDebited = totalDebited;
    }

    public Timestamp getLastTransactionAt() {
        return lastTransactionAt;
    }

    public void setLastTransactionAt(Timestamp lastTransactionAt) {
        this.lastTransactionAt = lastTransactionAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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
