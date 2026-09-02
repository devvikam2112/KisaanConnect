package com.kisaanconnect.dao;

import com.kisaanconnect.model.BuyerProfile;
import com.kisaanconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class BuyerDAO {

    public boolean saveProfile(BuyerProfile profile) {
        String sql = """
            INSERT INTO buyer_profiles
            (user_id, profile_photo, address, city, district, state, pincode, latitude, longitude)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, profile.getUserId());
            ps.setString(2, profile.getProfilePhoto());
            ps.setString(3, profile.getAddress());
            ps.setString(4, profile.getCity());
            ps.setString(5, profile.getDistrict());
            ps.setString(6, profile.getState());
            ps.setString(7, profile.getPincode());
            if (profile.getLatitude() != null) ps.setDouble(8, profile.getLatitude()); else ps.setNull(8, java.sql.Types.DECIMAL);
            if (profile.getLongitude() != null) ps.setDouble(9, profile.getLongitude()); else ps.setNull(9, java.sql.Types.DECIMAL);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public BuyerProfile getProfileByUserId(int userId) {
        String sql = "SELECT * FROM buyer_profiles WHERE user_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                BuyerProfile profile = new BuyerProfile();
                profile.setBuyerProfileId(rs.getInt("buyer_profile_id"));
                profile.setUserId(rs.getInt("user_id"));
                profile.setProfilePhoto(rs.getString("profile_photo"));
                profile.setAddress(rs.getString("address"));
                profile.setCity(rs.getString("city"));
                profile.setDistrict(rs.getString("district"));
                profile.setState(rs.getString("state"));
                profile.setPincode(rs.getString("pincode"));
                java.math.BigDecimal latBd = rs.getBigDecimal("latitude");
                java.math.BigDecimal lonBd = rs.getBigDecimal("longitude");
                profile.setLatitude(latBd != null ? latBd.doubleValue() : null);
                profile.setLongitude(lonBd != null ? lonBd.doubleValue() : null);
                profile.setCreatedAt(rs.getTimestamp("created_at"));
                profile.setUpdatedAt(rs.getTimestamp("updated_at"));
                return profile;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public BuyerProfile getOrCreateBuyerProfile(int userId) {
        BuyerProfile profile = getProfileByUserId(userId);
        if (profile != null) {
            return profile;
        }
        BuyerProfile newProfile = new BuyerProfile();
        newProfile.setUserId(userId);
        newProfile.setAddress("");
        newProfile.setCity("");
        newProfile.setDistrict("");
        newProfile.setState("Maharashtra");
        newProfile.setPincode("");
        saveProfile(newProfile);
        return getProfileByUserId(userId);
    }

    public boolean updateProfile(BuyerProfile profile) {
        String sql = """
            UPDATE buyer_profiles
            SET profile_photo = ?,
                address = ?,
                city = ?,
                district = ?,
                state = ?,
                pincode = ?,
                latitude = ?,
                longitude = ?
            WHERE user_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, profile.getProfilePhoto());
            ps.setString(2, profile.getAddress());
            ps.setString(3, profile.getCity());
            ps.setString(4, profile.getDistrict());
            ps.setString(5, profile.getState());
            ps.setString(6, profile.getPincode());
            if (profile.getLatitude() != null) ps.setDouble(7, profile.getLatitude()); else ps.setNull(7, java.sql.Types.DECIMAL);
            if (profile.getLongitude() != null) ps.setDouble(8, profile.getLongitude()); else ps.setNull(8, java.sql.Types.DECIMAL);
            ps.setInt(9, profile.getUserId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean profileExists(int userId) {
        String sql = "SELECT buyer_profile_id FROM buyer_profiles WHERE user_id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
