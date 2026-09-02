package com.kisaanconnect.model;

import java.sql.Timestamp;

public class OrganizationMember {

    private int memberId;
    private int organizationId;
    private int userId;
    private String memberRole;
    private String status;
    private Timestamp joinedAt;

    // Joined user details for UI display
    private String fullName;
    private String email;
    private String phone;

    public OrganizationMember() {
    }

    public OrganizationMember(int memberId, int organizationId, int userId,
                              String memberRole, String status, Timestamp joinedAt) {
        this.memberId = memberId;
        this.organizationId = organizationId;
        this.userId = userId;
        this.memberRole = memberRole;
        this.status = status;
        this.joinedAt = joinedAt;
    }

    public int getMemberId() {
        return memberId;
    }

    public void setMemberId(int memberId) {
        this.memberId = memberId;
    }

    public int getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(int organizationId) {
        this.organizationId = organizationId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getMemberRole() {
        return memberRole;
    }

    public void setMemberRole(String memberRole) {
        this.memberRole = memberRole;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(Timestamp joinedAt) {
        this.joinedAt = joinedAt;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}
