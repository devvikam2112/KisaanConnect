package com.kisaanconnect.util;

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {

        try (Connection con = DBConnection.getConnection()) {

            if (con != null) {
                System.out.println("================================");
                System.out.println("Database Connected Successfully!");
                System.out.println("================================");
            }

        } catch (Exception e) {
            System.out.println("Connection Failed!");
            e.printStackTrace();
        }

    }
}