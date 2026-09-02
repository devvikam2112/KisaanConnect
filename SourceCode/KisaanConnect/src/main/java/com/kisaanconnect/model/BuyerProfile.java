package com.kisaanconnect.model;

import java.sql.Timestamp;

public class BuyerProfile {

    private int buyerProfileId;
    private int userId;
    private String profilePhoto;
    private String address;
    private String city;
    private String district;
    private String state;
    private String pincode;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public BuyerProfile() {
    }

    public BuyerProfile(int buyerProfileId, int userId, String profilePhoto,
                        String address, String city, String district,
                        String state, String pincode, Timestamp createdAt,
                        Timestamp updatedAt) {
        this.buyerProfileId = buyerProfileId;
        this.userId = userId;
        this.profilePhoto = profilePhoto;
        this.address = address;
        this.city = city;
        this.district = district;
        this.state = state;
        this.pincode = pincode;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getBuyerProfileId() {
        return buyerProfileId;
    }

    public void setBuyerProfileId(int buyerProfileId) {
        this.buyerProfileId = buyerProfileId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getProfilePhoto() {
        return profilePhoto;
    }

    public void setProfilePhoto(String profilePhoto) {
        this.profilePhoto = profilePhoto;
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
