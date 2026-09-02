package com.kisaanconnect.dao;

import com.kisaanconnect.model.Organization;
import com.kisaanconnect.model.OrganizationMember;
import com.kisaanconnect.model.OrganizationType;
import com.kisaanconnect.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrganizationDAO {

    public List<OrganizationType> getActiveOrganizationTypes() {
        List<OrganizationType> list = new ArrayList<>();
        String sql = "SELECT * FROM organization_types ORDER BY org_type_id ASC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                OrganizationType type = new OrganizationType();
                type.setOrgTypeId(rs.getInt("org_type_id"));
                type.setTypeName(rs.getString("type_name"));
                type.setDescription(rs.getString("description"));
                type.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(type);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public OrganizationType getOrganizationTypeById(int orgTypeId) {
        String sql = "SELECT * FROM organization_types WHERE org_type_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orgTypeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                OrganizationType type = new OrganizationType();
                type.setOrgTypeId(rs.getInt("org_type_id"));
                type.setTypeName(rs.getString("type_name"));
                type.setDescription(rs.getString("description"));
                type.setCreatedAt(rs.getTimestamp("created_at"));
                return type;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean saveOrganization(Organization org) {
        String sqlOrg = """
            INSERT INTO organizations
            (owner_user_id, org_type_id, org_name, gstin, pan_number, business_email, business_phone, address, city, district, state, pincode, status, latitude, longitude)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        String sqlMember = """
            INSERT INTO organization_members
            (organization_id, user_id, member_role, status)
            VALUES (?, ?, 'OWNER', 'ACTIVE')
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(sqlOrg, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, org.getOwnerUserId());
                ps.setInt(2, org.getOrgTypeId());
                ps.setString(3, org.getOrgName());
                ps.setString(4, org.getGstin());
                ps.setString(5, org.getPanNumber());
                ps.setString(6, org.getBusinessEmail());
                ps.setString(7, org.getBusinessPhone());
                ps.setString(8, org.getAddress());
                ps.setString(9, org.getCity());
                ps.setString(10, org.getDistrict());
                ps.setString(11, org.getState());
                ps.setString(12, org.getPincode());
                ps.setString(13, org.getStatus() != null ? org.getStatus() : "ACTIVE");
                if (org.getLatitude() != null) ps.setDouble(14, org.getLatitude()); else ps.setNull(14, java.sql.Types.DECIMAL);
                if (org.getLongitude() != null) ps.setDouble(15, org.getLongitude()); else ps.setNull(15, java.sql.Types.DECIMAL);

                int affected = ps.executeUpdate();
                if (affected == 0) {
                    con.rollback();
                    return false;
                }

                int generatedOrgId = 0;
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        generatedOrgId = generatedKeys.getInt(1);
                        org.setOrganizationId(generatedOrgId);
                    } else {
                        con.rollback();
                        return false;
                    }
                }

                // Add owner as member with role 'OWNER'
                try (PreparedStatement psMember = con.prepareStatement(sqlMember)) {
                    psMember.setInt(1, generatedOrgId);
                    psMember.setInt(2, org.getOwnerUserId());
                    psMember.executeUpdate();
                }

                con.commit();
                return true;
            }
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    public Organization getOrganizationByUserId(int userId) {
        Organization org = getOrganizationByOwnerUserId(userId);
        if (org != null) {
            return org;
        }
        return getOrganizationByMemberUserId(userId);
    }

    public Organization getOrganizationByOwnerUserId(int userId) {
        String sql = """
            SELECT o.*, ot.type_name AS org_type_name
            FROM organizations o
            LEFT JOIN organization_types ot ON o.org_type_id = ot.org_type_id
            WHERE o.owner_user_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToOrganization(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Organization getOrganizationById(int orgId) {
        String sql = """
            SELECT o.*, ot.type_name AS org_type_name
            FROM organizations o
            LEFT JOIN organization_types ot ON o.org_type_id = ot.org_type_id
            WHERE o.organization_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orgId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToOrganization(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Organization getOrganizationByMemberUserId(int userId) {
        String sql = """
            SELECT o.*, ot.type_name AS org_type_name
            FROM organizations o
            JOIN organization_members om ON o.organization_id = om.organization_id
            LEFT JOIN organization_types ot ON o.org_type_id = ot.org_type_id
            WHERE om.user_id = ? AND om.status = 'ACTIVE'
            LIMIT 1
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToOrganization(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateOrganization(Organization org) {
        String sql = """
            UPDATE organizations
            SET org_type_id = ?,
                org_name = ?,
                gstin = ?,
                pan_number = ?,
                business_email = ?,
                business_phone = ?,
                address = ?,
                city = ?,
                district = ?,
                state = ?,
                pincode = ?
            WHERE organization_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, org.getOrgTypeId());
            ps.setString(2, org.getOrgName());
            ps.setString(3, org.getGstin());
            ps.setString(4, org.getPanNumber());
            ps.setString(5, org.getBusinessEmail());
            ps.setString(6, org.getBusinessPhone());
            ps.setString(7, org.getAddress());
            ps.setString(8, org.getCity());
            ps.setString(9, org.getDistrict());
            ps.setString(10, org.getState());
            ps.setString(11, org.getPincode());
            ps.setInt(12, org.getOrganizationId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean organizationExists(int userId) {
        String sql = """
            SELECT organization_id
            FROM organizations
            WHERE owner_user_id = ?
            UNION
            SELECT organization_id
            FROM organization_members
            WHERE user_id = ? AND status = 'ACTIVE'
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addMember(OrganizationMember member) {
        String sql = """
            INSERT INTO organization_members
            (organization_id, user_id, member_role, status)
            VALUES (?, ?, ?, ?)
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, member.getOrganizationId());
            ps.setInt(2, member.getUserId());
            ps.setString(3, member.getMemberRole());
            ps.setString(4, member.getStatus() != null ? member.getStatus() : "ACTIVE");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<OrganizationMember> getOrganizationMembers(int orgId) {
        List<OrganizationMember> list = new ArrayList<>();
        String sql = """
            SELECT om.*, u.full_name, u.email, u.phone
            FROM organization_members om
            JOIN users u ON om.user_id = u.user_id
            WHERE om.organization_id = ? AND om.status = 'ACTIVE'
            ORDER BY om.joined_at ASC
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orgId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrganizationMember member = new OrganizationMember();
                member.setMemberId(rs.getInt("member_id"));
                member.setOrganizationId(rs.getInt("organization_id"));
                member.setUserId(rs.getInt("user_id"));
                member.setMemberRole(rs.getString("member_role"));
                member.setStatus(rs.getString("status"));
                member.setJoinedAt(rs.getTimestamp("joined_at"));
                member.setFullName(rs.getString("full_name"));
                member.setEmail(rs.getString("email"));
                member.setPhone(rs.getString("phone"));
                list.add(member);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Organization mapResultSetToOrganization(ResultSet rs) throws SQLException {
        Organization org = new Organization();
        org.setOrganizationId(rs.getInt("organization_id"));
        org.setOwnerUserId(rs.getInt("owner_user_id"));
        org.setOrgTypeId(rs.getInt("org_type_id"));
        try {
            org.setOrgTypeName(rs.getString("org_type_name"));
        } catch (SQLException ignored) {
        }
        org.setOrgName(rs.getString("org_name"));
        org.setGstin(rs.getString("gstin"));
        org.setPanNumber(rs.getString("pan_number"));
        org.setBusinessEmail(rs.getString("business_email"));
        org.setBusinessPhone(rs.getString("business_phone"));
        org.setAddress(rs.getString("address"));
        org.setCity(rs.getString("city"));
        org.setDistrict(rs.getString("district"));
        org.setState(rs.getString("state"));
        org.setPincode(rs.getString("pincode"));
        org.setStatus(rs.getString("status"));
        try {
            java.math.BigDecimal latBd = rs.getBigDecimal("latitude");
            java.math.BigDecimal lonBd = rs.getBigDecimal("longitude");
            org.setLatitude(latBd != null ? latBd.doubleValue() : null);
            org.setLongitude(lonBd != null ? lonBd.doubleValue() : null);
        } catch (SQLException ignored) {}
        org.setCreatedAt(rs.getTimestamp("created_at"));
        org.setUpdatedAt(rs.getTimestamp("updated_at"));
        return org;
    }
}
