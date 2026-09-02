package com.kisaanconnect.util;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_LENGTH = 16;
    private static final SecureRandom RANDOM = new SecureRandom();

    private PasswordUtil() {
    }

    /**
     * Hashes a plaintext password using PBKDF2 with HMAC-SHA256 and a random salt.
     * Format: PBKDF2:iterations:salt_base64:hash_base64
     */
    public static String hashPassword(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }

        byte[] salt = new byte[SALT_LENGTH];
        RANDOM.nextBytes(salt);

        byte[] hash = pbkdf2(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);

        return "PBKDF2:" + ITERATIONS + ":" + Base64.getEncoder().encodeToString(salt)
                + ":" + Base64.getEncoder().encodeToString(hash);
    }

    /**
     * Verifies a plain password against stored hash.
     * Supports PBKDF2 hashed passwords and legacy plaintext passwords.
     */
    public static boolean verifyPassword(String plainPassword, String storedHash) {
        if (plainPassword == null || storedHash == null) {
            return false;
        }

        // 1. Check if stored hash is formatted as PBKDF2
        if (storedHash.startsWith("PBKDF2:")) {
            String[] parts = storedHash.split(":");
            if (parts.length != 4) {
                return false;
            }

            try {
                int iterations = Integer.parseInt(parts[1]);
                byte[] salt = Base64.getDecoder().decode(parts[2]);
                byte[] expectedHash = Base64.getDecoder().decode(parts[3]);

                byte[] testHash = pbkdf2(plainPassword.toCharArray(), salt, iterations, expectedHash.length * 8);

                return slowEquals(expectedHash, testHash);
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }

        // 2. Fallback for legacy plaintext passwords stored during early development
        return plainPassword.equals(storedHash);
    }

    /**
     * Checks whether a stored hash is legacy plaintext (needs seamless upgrade to PBKDF2).
     */
    public static boolean isLegacyPassword(String storedHash) {
        return storedHash != null && !storedHash.startsWith("PBKDF2:");
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
            SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGORITHM);
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Error hashing password with " + ALGORITHM, e);
        }
    }

    /**
     * Constant-time comparison to prevent timing attacks.
     */
    public static boolean slowEquals(byte[] a, byte[] b) {
        if (a == null || b == null || a.length != b.length) {
            return false;
        }
        int diff = 0;
        for (int i = 0; i < a.length; i++) {
            diff |= a[i] ^ b[i];
        }
        return diff == 0;
    }
}
