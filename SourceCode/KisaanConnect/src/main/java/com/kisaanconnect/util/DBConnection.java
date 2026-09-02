package com.kisaanconnect.util;

import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/kisaanconnect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC Driver Loaded Successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver NOT Found!");
            e.printStackTrace();
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        String dbUrl = null;
        String user = null;
        String password = null;

        // 1. Check MYSQL_URL / DATABASE_URL
        String envUrl = System.getenv("MYSQL_URL");
        if (envUrl == null || envUrl.trim().isEmpty()) {
            envUrl = System.getenv("DATABASE_URL");
        }

        if (envUrl != null && !envUrl.trim().isEmpty()) {
            try {
                if (envUrl.startsWith("mysql://")) {
                    URI uri = new URI(envUrl);
                    String userInfo = uri.getUserInfo();
                    if (userInfo != null && userInfo.contains(":")) {
                        String[] parts = userInfo.split(":", 2);
                        user = parts[0];
                        password = parts[1];
                    }
                    String host = uri.getHost();
                    int port = uri.getPort() != -1 ? uri.getPort() : 3306;
                    String path = uri.getPath();
                    String dbName = (path != null && path.length() > 1) ? path.substring(1) : "railway";
                    dbUrl = String.format("jdbc:mysql://%s:%d/%s?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata", host, port, dbName);
                } else if (envUrl.startsWith("jdbc:mysql://")) {
                    dbUrl = envUrl;
                }
            } catch (Exception e) {
                System.err.println("Failed to parse MYSQL_URL/DATABASE_URL: " + e.getMessage());
            }
        }

        // 2. Check individual variables MYSQLHOST, MYSQLPORT, MYSQLDATABASE, MYSQLUSER, MYSQLPASSWORD
        if (dbUrl == null) {
            String host = System.getenv("MYSQLHOST");
            if (host != null && !host.trim().isEmpty()) {
                String portStr = System.getenv("MYSQLPORT");
                int port = 3306;
                if (portStr != null && !portStr.trim().isEmpty()) {
                    try {
                        port = Integer.parseInt(portStr.trim());
                    } catch (NumberFormatException ignored) {}
                }
                String dbName = System.getenv("MYSQLDATABASE");
                if (dbName == null || dbName.trim().isEmpty()) {
                    dbName = "railway";
                }
                user = System.getenv("MYSQLUSER");
                password = System.getenv("MYSQLPASSWORD");
                dbUrl = String.format("jdbc:mysql://%s:%d/%s?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata", host, port, dbName);
            }
        }

        // 3. Fallback to local configuration if no environment variables are set
        if (dbUrl == null) {
            dbUrl = DEFAULT_URL;
            user = DEFAULT_USER;
            password = DEFAULT_PASS;
        }

        if (user == null) user = DEFAULT_USER;
        if (password == null) password = DEFAULT_PASS;

        return DriverManager.getConnection(dbUrl, user, password);
    }
}