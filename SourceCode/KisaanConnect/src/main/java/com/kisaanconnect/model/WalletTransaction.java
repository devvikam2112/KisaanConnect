package com.kisaanconnect.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class WalletTransaction {

    private int transactionId;
    private int walletId;
    private Integer orderId;
    private String transactionType;
    private String transactionSource;
    private BigDecimal amount;
    private BigDecimal balanceAfter;
    private String txnReferenceNo;
    private String remarks;
    private String status;
    private Timestamp transactionDate;

    public WalletTransaction() {
    }

    public WalletTransaction(int transactionId, int walletId, Integer orderId,
                             String transactionType, String transactionSource,
                             BigDecimal amount, BigDecimal balanceAfter,
                             String txnReferenceNo, String remarks,
                             String status, Timestamp transactionDate) {
        this.transactionId = transactionId;
        this.walletId = walletId;
        this.orderId = orderId;
        this.transactionType = transactionType;
        this.transactionSource = transactionSource;
        this.amount = amount;
        this.balanceAfter = balanceAfter;
        this.txnReferenceNo = txnReferenceNo;
        this.remarks = remarks;
        this.status = status;
        this.transactionDate = transactionDate;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getWalletId() {
        return walletId;
    }

    public void setWalletId(int walletId) {
        this.walletId = walletId;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getTransactionSource() {
        return transactionSource;
    }

    public void setTransactionSource(String transactionSource) {
        this.transactionSource = transactionSource;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public BigDecimal getBalanceAfter() {
        return balanceAfter;
    }

    public void setBalanceAfter(BigDecimal balanceAfter) {
        this.balanceAfter = balanceAfter;
    }

    public String getTxnReferenceNo() {
        return txnReferenceNo;
    }

    public void setTxnReferenceNo(String txnReferenceNo) {
        this.txnReferenceNo = txnReferenceNo;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }
}
