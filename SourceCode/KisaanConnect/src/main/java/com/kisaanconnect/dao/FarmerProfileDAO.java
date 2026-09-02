package com.kisaanconnect.dao;

import com.kisaanconnect.model.FarmerProfile;
import com.kisaanconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class FarmerProfileDAO {

    public boolean saveProfile(FarmerProfile profile) {
        String sql = """
            INSERT INTO farmer_profiles
            (user_id, farm_name, profile_photo, farm_address, village, taluka, district, state, pincode, latitude, longitude)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, profile.getUserId());
            ps.setString(2, profile.getFarmName());
            ps.setString(3, profile.getProfilePhoto());
            ps.setString(4, profile.getFarmAddress());
            ps.setString(5, profile.getVillage());
            ps.setString(6, profile.getTaluka());
            ps.setString(7, profile.getDistrict());
            ps.setString(8, profile.getState());
            ps.setString(9, profile.getPincode());
            if (profile.getLatitude() != null) ps.setDouble(10, profile.getLatitude()); else ps.setNull(10, java.sql.Types.DECIMAL);
            if (profile.getLongitude() != null) ps.setDouble(11, profile.getLongitude()); else ps.setNull(11, java.sql.Types.DECIMAL);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public FarmerProfile getProfileByUserId(int userId) {
        String sql = "SELECT * FROM farmer_profiles WHERE user_id = ?";
        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                FarmerProfile profile = new FarmerProfile();
                profile.setFarmerProfileId(rs.getInt("farmer_profile_id"));
                profile.setUserId(rs.getInt("user_id"));
                profile.setFarmName(rs.getString("farm_name"));
                profile.setProfilePhoto(rs.getString("profile_photo"));
                profile.setFarmAddress(rs.getString("farm_address"));
                profile.setVillage(rs.getString("village"));
                profile.setTaluka(rs.getString("taluka"));
                profile.setDistrict(rs.getString("district"));
                profile.setState(rs.getString("state"));
                profile.setPincode(rs.getString("pincode"));
                java.math.BigDecimal latBd = rs.getBigDecimal("latitude");
                java.math.BigDecimal lonBd = rs.getBigDecimal("longitude");
                profile.setLatitude(latBd != null ? latBd.doubleValue() : null);
                profile.setLongitude(lonBd != null ? lonBd.doubleValue() : null);
                profile.setVerified(rs.getBoolean("is_verified"));
                profile.setVerificationDate(rs.getTimestamp("verification_date"));
                profile.setCreatedAt(rs.getTimestamp("created_at"));
                profile.setUpdatedAt(rs.getTimestamp("updated_at"));
                return profile;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProfile(FarmerProfile profile) {
        String sql = """
            UPDATE farmer_profiles
            SET farm_name = ?, profile_photo = ?, farm_address = ?, village = ?,
                taluka = ?, district = ?, state = ?, pincode = ?, latitude = ?, longitude = ?
            WHERE user_id = ?
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, profile.getFarmName());
            ps.setString(2, profile.getProfilePhoto());
            ps.setString(3, profile.getFarmAddress());
            ps.setString(4, profile.getVillage());
            ps.setString(5, profile.getTaluka());
            ps.setString(6, profile.getDistrict());
            ps.setString(7, profile.getState());
            ps.setString(8, profile.getPincode());
            if (profile.getLatitude() != null) ps.setDouble(9, profile.getLatitude()); else ps.setNull(9, java.sql.Types.DECIMAL);
            if (profile.getLongitude() != null) ps.setDouble(10, profile.getLongitude()); else ps.setNull(10, java.sql.Types.DECIMAL);
            ps.setInt(11, profile.getUserId());

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
        public boolean profileExists(int userId) {
                
        String sql = """
            SELECT farmer_profile_id
            FROM farmer_profiles
            WHERE user_id = ?
            """;
    
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