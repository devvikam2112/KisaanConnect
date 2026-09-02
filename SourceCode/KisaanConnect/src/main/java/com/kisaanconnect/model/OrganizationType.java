package com.kisaanconnect.model;

import java.sql.Timestamp;

public class OrganizationType {

    private int orgTypeId;
    private String typeName;
    private String description;
    private boolean active;
    private Timestamp createdAt;

    public OrganizationType() {
    }

    public OrganizationType(int orgTypeId, String typeName, String description, boolean active, Timestamp createdAt) {
        this.orgTypeId = orgTypeId;
        this.typeName = typeName;
        this.description = description;
        this.active = active;
        this.createdAt = createdAt;
    }

    public int getOrgTypeId() {
        return orgTypeId;
    }

    public void setOrgTypeId(int orgTypeId) {
        this.orgTypeId = orgTypeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
