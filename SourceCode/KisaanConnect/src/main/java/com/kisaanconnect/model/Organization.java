package com.kisaanconnect.model;

import java.sql.Timestamp;

public class Organization {

    private int organizationId;
    private int ownerUserId;
    private int orgTypeId;
    private String orgTypeName;
    private String orgName;
    private String gstin;
    private String panNumber;
    private String businessEmail;
    private String businessPhone;
    private String address;
    private String city;
    private String district;
    private String state;
    private String pincode;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Organization() {
    }

    public Organization(int organizationId, int ownerUserId, int orgTypeId,
                        String orgName, String gstin, String panNumber,
                        String businessEmail, String businessPhone,
                        String address, String city, String district,
                        String state, String pincode, String status,
                        Timestamp createdAt, Timestamp updatedAt) {
        this.organizationId = organizationId;
        this.ownerUserId = ownerUserId;
        this.orgTypeId = orgTypeId;
        this.orgName = orgName;
        this.gstin = gstin;
        this.panNumber = panNumber;
        this.businessEmail = businessEmail;
        this.businessPhone = businessPhone;
        this.address = address;
        this.city = city;
        this.district = district;
        this.state = state;
        this.pincode = pincode;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(int organizationId) {
        this.organizationId = organizationId;
    }

    public int getOwnerUserId() {
        return ownerUserId;
    }

    public void setOwnerUserId(int ownerUserId) {
        this.ownerUserId = ownerUserId;
    }

    public int getOrgTypeId() {
        return orgTypeId;
    }

    public void setOrgTypeId(int orgTypeId) {
        this.orgTypeId = orgTypeId;
    }

    public String getOrgTypeName() {
        return orgTypeName;
    }

    public void setOrgTypeName(String orgTypeName) {
        this.orgTypeName = orgTypeName;
    }

    public String getOrgName() {
        return orgName;
    }

    public void setOrgName(String orgName) {
        this.orgName = orgName;
    }

    public String getGstin() {
        return gstin;
    }

    public void setGstin(String gstin) {
        this.gstin = gstin;
    }

    public String getPanNumber() {
        return panNumber;
    }

    public void setPanNumber(String panNumber) {
        this.panNumber = panNumber;
    }

    public String getBusinessEmail() {
        return businessEmail;
    }

    public void setBusinessEmail(String businessEmail) {
        this.businessEmail = businessEmail;
    }

    public String getBusinessPhone() {
        return businessPhone;
    }

    public void setBusinessPhone(String businessPhone) {
        this.businessPhone = businessPhone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPincode() {
        return pincode;
    }

    public void setPincode(String pincode) {
        this.pincode = pincode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    private Double latitude;
    private Double longitude;

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
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
