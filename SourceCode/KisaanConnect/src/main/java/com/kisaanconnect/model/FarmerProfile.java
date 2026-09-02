package com.kisaanconnect.model;


import java.sql.Timestamp;

public class FarmerProfile {

    private int farmerProfileId;
    private int userId;
    private String farmName;
    private String profilePhoto;
    private String farmAddress;
    private String village;
    private String taluka;
    private String district;
    private String state;
    private String pincode;
    private boolean verified;
    private Timestamp verificationDate;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public FarmerProfile() {
    }

    public FarmerProfile(int farmerProfileId, int userId, String farmName,
            String profilePhoto, String farmAddress, String village,
            String taluka, String district, String state,
            String pincode, boolean verified,
            Timestamp verificationDate,
            Timestamp createdAt,
            Timestamp updatedAt) {

        this.farmerProfileId = farmerProfileId;
        this.userId = userId;
        this.farmName = farmName;
        this.profilePhoto = profilePhoto;
        this.farmAddress = farmAddress;
        this.village = village;
        this.taluka = taluka;
        this.district = district;
        this.state = state;
        this.pincode = pincode;
        this.verified = verified;
        this.verificationDate = verificationDate;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getFarmerProfileId() {
        return farmerProfileId;
    }

    public void setFarmerProfileId(int farmerProfileId) {
        this.farmerProfileId = farmerProfileId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFarmName() {
        return farmName;
    }

    public void setFarmName(String farmName) {
        this.farmName = farmName;
    }

    public String getProfilePhoto() {
        return profilePhoto;
    }

    public void setProfilePhoto(String profilePhoto) {
        this.profilePhoto = profilePhoto;
    }

    public String getFarmAddress() {
        return farmAddress;
    }

    public void setFarmAddress(String farmAddress) {
        this.farmAddress = farmAddress;
    }

    public String getVillage() {
        return village;
    }

    public void setVillage(String village) {
        this.village = village;
    }

    public String getTaluka() {
        return taluka;
    }

    public void setTaluka(String taluka) {
        this.taluka = taluka;
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

    public boolean isVerified() {
        return verified;
    }

    public void setVerified(boolean verified) {
        this.verified = verified;
    }

    public Timestamp getVerificationDate() {
        return verificationDate;
    }

    public void setVerificationDate(Timestamp verificationDate) {
        this.verificationDate = verificationDate;
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