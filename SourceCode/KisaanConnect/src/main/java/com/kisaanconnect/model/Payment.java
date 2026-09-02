package com.kisaanconnect.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Payment {

    private int paymentId;
    private int orderId;
    private String paymentMethod;
    private String paymentStatus;
    private String transactionReference;
    private BigDecimal paidAmount;
    private Timestamp paymentDate;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Payment() {
    }

    public Payment(int paymentId, int orderId, String paymentMethod,
                   String paymentStatus, String transactionReference,
                   BigDecimal paidAmount, Timestamp paymentDate,
                   Timestamp createdAt, Timestamp updatedAt) {
        this.paymentId = paymentId;
        this.orderId = orderId;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.transactionReference = transactionReference;
        this.paidAmount = paidAmount;
        this.paymentDate = paymentDate;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
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

    public String getTransactionReference() {
        return transactionReference;
    }

    public void setTransactionReference(String transactionReference) {
        this.transactionReference = transactionReference;
    }

    public BigDecimal getPaidAmount() {
        return paidAmount;
    }

    public void setPaidAmount(BigDecimal paidAmount) {
        this.paidAmount = paidAmount;
    }

    public Timestamp getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Timestamp paymentDate) {
        this.paymentDate = paymentDate;
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
