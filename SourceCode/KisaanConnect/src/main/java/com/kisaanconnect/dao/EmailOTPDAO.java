package com.kisaanconnect.dao;

import com.kisaanconnect.util.DBConnection;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class EmailOTPDAO {

    private static final SecureRandom RANDOM = new SecureRandom();

    public String generateAndStoreOTP(String email, String purpose, int expirationMinutes) {
        // Generate 6 digit numeric code
        int codeInt = 100000 + RANDOM.nextInt(900000);
        String otpCode = String.valueOf(codeInt);

        long now = System.currentTimeMillis();
        long expireTime = now + (expirationMinutes * 60L * 1000L);
        Timestamp expiresAt = new Timestamp(expireTime);

        String sql = """
            INSERT INTO email_otps (email, otp_code, otp_purpose, attempts_count, max_attempts, expires_at, is_used)
            VALUES (?, ?, ?, 0, 3, ?, 0)
            """;

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, email);
            ps.setString(2, otpCode);
            ps.setString(3, purpose != null ? purpose : "FORGOT_PASSWORD");
            ps.setTimestamp(4, expiresAt);
            ps.executeUpdate();

            // Print for local server development and logging
            System.out.println("=================================================");
            System.out.println(" [KisaanConnect OTP Service] Email: " + email + " | Code: " + otpCode + " | Expires: " + expiresAt);
            System.out.println("=================================================");

            return otpCode;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean verifyOTP(String email, String otpCode, String purpose) {
        String selectSql = """
            SELECT otp_id, otp_code, attempts_count, max_attempts, expires_at, is_used
            FROM email_otps
            WHERE email = ? AND otp_purpose = ? AND is_used = 0
            ORDER BY created_at DESC
            LIMIT 1
            """;

        String updateAttempts = "UPDATE email_otps SET attempts_count = attempts_count + 1 WHERE otp_id = ?";
        String markUsed = "UPDATE email_otps SET is_used = 1 WHERE otp_id = ?";

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement psSelect = con.prepareStatement(selectSql)) {
                psSelect.setString(1, email);
                psSelect.setString(2, purpose != null ? purpose : "FORGOT_PASSWORD");
                ResultSet rs = psSelect.executeQuery();

                if (rs.next()) {
                    int otpId = rs.getInt("otp_id");
                    String storedCode = rs.getString("otp_code");
                    int attempts = rs.getInt("attempts_count");
                    int maxAttempts = rs.getInt("max_attempts");
                    Timestamp expiresAt = rs.getTimestamp("expires_at");

                    if (attempts >= maxAttempts) {
                        return false; // Max attempts exceeded
                    }

                    if (expiresAt.before(new Timestamp(System.currentTimeMillis()))) {
                        return false; // Expired
                    }

                    if (storedCode.equals(otpCode.trim())) {
                        try (PreparedStatement psUsed = con.prepareStatement(markUsed)) {
                            psUsed.setInt(1, otpId);
                            psUsed.executeUpdate();
                        }
                        return true;
                    } else {
                        try (PreparedStatement psAtt = con.prepareStatement(updateAttempts)) {
                            psAtt.setInt(1, otpId);
                            psAtt.executeUpdate();
                        }
                        return false;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
