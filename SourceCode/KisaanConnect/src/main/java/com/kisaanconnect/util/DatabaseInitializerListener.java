package com.kisaanconnect.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@WebListener
public class DatabaseInitializerListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[DatabaseInitializerListener] Checking database status on startup...");
        try (Connection conn = DBConnection.getConnection()) {
            boolean hasTables = false;
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()")) {
                if (rs.next() && rs.getInt(1) > 0) {
                    hasTables = true;
                    System.out.println("[DatabaseInitializerListener] Database already contains " + rs.getInt(1) + " tables. Skipping schema initialization.");
                }
            }

            if (!hasTables) {
                System.out.println("[DatabaseInitializerListener] No tables detected. Initializing database schema and seed data from db/init.sql...");
                try (InputStream is = getClass().getClassLoader().getResourceAsStream("db/init.sql")) {
                    if (is != null) {
                        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                            StringBuilder sql = new StringBuilder();
                            String line;
                            try (Statement stmt = conn.createStatement()) {
                                while ((line = reader.readLine()) != null) {
                                    String trimmed = line.trim();
                                    if (trimmed.startsWith("--") || trimmed.startsWith("/*") || trimmed.isEmpty()) {
                                        continue;
                                    }
                                    sql.append(line).append("\n");
                                    if (trimmed.endsWith(";")) {
                                        String statementStr = sql.toString().trim();
                                        if (statementStr.endsWith(";")) {
                                            statementStr = statementStr.substring(0, statementStr.length() - 1);
                                        }
                                        if (!statementStr.isEmpty()) {
                                            try {
                                                stmt.execute(statementStr);
                                            } catch (Exception e) {
                                                System.err.println("[DatabaseInitializerListener] Warning executing statement: " + e.getMessage());
                                            }
                                        }
                                        sql.setLength(0);
                                    }
                                }
                            }
                        }
                        System.out.println("[DatabaseInitializerListener] Database initialization completed successfully!");
                    } else {
                        System.err.println("[DatabaseInitializerListener] db/init.sql resource not found in classpath!");
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[DatabaseInitializerListener] Database check/initialization error: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
}
