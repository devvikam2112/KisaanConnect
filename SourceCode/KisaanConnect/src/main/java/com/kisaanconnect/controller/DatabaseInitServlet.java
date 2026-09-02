package com.kisaanconnect.controller;

import com.kisaanconnect.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "DatabaseInitServlet", urlPatterns = {"/api/db-init"})
public class DatabaseInitServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        int executedStatements = 0;
        int failedStatements = 0;
        List<String> errors = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            // Disable foreign key checks
            try (Statement s = conn.createStatement()) {
                s.execute("SET FOREIGN_KEY_CHECKS = 0");
            }

            InputStream is = getClass().getClassLoader().getResourceAsStream("db/init.sql");
            if (is == null) {
                out.write("{\"success\":false,\"error\":\"db/init.sql resource not found in classpath\"}");
                return;
            }

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                StringBuilder currentStmt = new StringBuilder();
                String line;

                while ((line = reader.readLine()) != null) {
                    String trimmed = line.trim();
                    if (trimmed.startsWith("--") || trimmed.startsWith("/*") || trimmed.startsWith("#") || trimmed.isEmpty()) {
                        continue;
                    }
                    currentStmt.append(line).append("\n");
                    if (trimmed.endsWith(";")) {
                        String sql = currentStmt.toString().trim();
                        if (sql.endsWith(";")) {
                            sql = sql.substring(0, sql.length() - 1);
                        }
                        if (!sql.isEmpty()) {
                            // Normalize boolean and timestamp literals
                            sql = sql.replace(", true,", ", 1,")
                                     .replace(", false,", ", 0,")
                                     .replaceAll("\\.0'", "'");

                            try (Statement stmt = conn.createStatement()) {
                                stmt.execute(sql);
                                executedStatements++;
                            } catch (Exception e) {
                                failedStatements++;
                                String errSummary = e.getMessage() + " | Stmt: " + (sql.length() > 100 ? sql.substring(0, 100) : sql);
                                if (errors.size() < 10) {
                                    errors.add(errSummary);
                                }
                            }
                        }
                        currentStmt.setLength(0);
                    }
                }
            }

            // Re-enable foreign key checks
            try (Statement s = conn.createStatement()) {
                s.execute("SET FOREIGN_KEY_CHECKS = 1");
            }

            // Query table count
            int tableCount = 0;
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()")) {
                if (rs.next()) {
                    tableCount = rs.getInt(1);
                }
            }

            // Query user count
            int userCount = 0;
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM users")) {
                if (rs.next()) {
                    userCount = rs.getInt(1);
                }
            }

            // Query product count
            int productCount = 0;
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM products")) {
                if (rs.next()) {
                    productCount = rs.getInt(1);
                }
            }

            // Query order count
            int orderCount = 0;
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM orders")) {
                if (rs.next()) {
                    orderCount = rs.getInt(1);
                }
            }

            StringBuilder errJson = new StringBuilder("[");
            for (int i = 0; i < errors.size(); i++) {
                if (i > 0) errJson.append(",");
                errJson.append("\"").append(errors.get(i).replace("\"", "\\\"").replace("\n", " ")).append("\"");
            }
            errJson.append("]");

            out.write(String.format(
                    "{\"success\":true,\"executed\":%d,\"failed\":%d,\"tableCount\":%d,\"userCount\":%d,\"productCount\":%d,\"orderCount\":%d,\"errors\":%s}",
                    executedStatements, failedStatements, tableCount, userCount, productCount, orderCount, errJson.toString()
            ));

        } catch (Exception e) {
            e.printStackTrace();
            out.write(String.format("{\"success\":false,\"error\":\"%s\"}", e.getMessage().replace("\"", "\\\"")));
        }
    }
}
