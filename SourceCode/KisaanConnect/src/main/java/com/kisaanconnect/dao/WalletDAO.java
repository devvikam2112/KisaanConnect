package com.kisaanconnect.dao;

import com.kisaanconnect.model.Wallet;
import com.kisaanconnect.model.WalletTransaction;
import com.kisaanconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Random;

public class WalletDAO {

    public Wallet getOrCreateWallet(int userId) {
        String selectSql = "SELECT * FROM wallets WHERE user_id = ?";
        String insertSql = "INSERT INTO wallets (user_id, current_balance, total_credited, total_debited, status) VALUES (?, 0.00, 0.00, 0.00, 'ACTIVE')";

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement psSelect = con.prepareStatement(selectSql)) {
                psSelect.setInt(1, userId);
                ResultSet rs = psSelect.executeQuery();
                if (rs.next()) {
                    return mapResultSetToWallet(rs);
                }
            }

            try (PreparedStatement psInsert = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                psInsert.setInt(1, userId);
                psInsert.executeUpdate();
                ResultSet rs = psInsert.getGeneratedKeys();
                if (rs.next()) {
                    Wallet w = new Wallet();
                    w.setWalletId(rs.getInt(1));
                    w.setUserId(userId);
                    w.setCurrentBalance(BigDecimal.ZERO);
                    w.setTotalCredited(BigDecimal.ZERO);
                    w.setTotalDebited(BigDecimal.ZERO);
                    w.setStatus("ACTIVE");
                    return w;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean creditWallet(int userId, BigDecimal amount, String source, Integer orderId, String remarks) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        String selectLock = "SELECT * FROM wallets WHERE user_id = ? FOR UPDATE";
        String updateWallet = """
            UPDATE wallets
            SET current_balance = current_balance + ?,
                total_credited = total_credited + ?,
                last_transaction_at = CURRENT_TIMESTAMP
            WHERE wallet_id = ?
            """;
        String insertTxn = """
            INSERT INTO user_wallet_transactions (
                wallet_id, order_id, transaction_type, transaction_source,
                amount, balance_after, txn_reference_no, remarks, status
            ) VALUES (?, ?, 'CREDIT', ?, ?, ?, ?, ?, 'SUCCESS')
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            Wallet wallet = null;
            try (PreparedStatement psLock = con.prepareStatement(selectLock)) {
                psLock.setInt(1, userId);
                ResultSet rs = psLock.executeQuery();
                if (rs.next()) {
                    wallet = mapResultSetToWallet(rs);
                }
            }

            if (wallet == null) {
                con.rollback();
                return false;
            }

            BigDecimal newBalance = wallet.getCurrentBalance().add(amount);

            // Update Wallet
            try (PreparedStatement psUp = con.prepareStatement(updateWallet)) {
                psUp.setBigDecimal(1, amount);
                psUp.setBigDecimal(2, amount);
                psUp.setInt(3, wallet.getWalletId());
                psUp.executeUpdate();
            }

            // Insert Transaction Ledger
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
            String refNo = "TXN-" + sdf.format(new Date()) + "-" + (1000 + new Random().nextInt(9000));

            try (PreparedStatement psTxn = con.prepareStatement(insertTxn)) {
                psTxn.setInt(1, wallet.getWalletId());
                if (orderId != null) {
                    psTxn.setInt(2, orderId);
                } else {
                    psTxn.setNull(2, Types.INTEGER);
                }
                psTxn.setString(3, source != null ? source : "TOP_UP");
                psTxn.setBigDecimal(4, amount);
                psTxn.setBigDecimal(5, newBalance);
                psTxn.setString(6, refNo);
                psTxn.setString(7, remarks);
                psTxn.executeUpdate();
            }

            con.commit();
            return true;
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

    public boolean debitWallet(int userId, BigDecimal amount, String source, Integer orderId, String remarks) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        String selectLock = "SELECT * FROM wallets WHERE user_id = ? FOR UPDATE";
        String updateWallet = """
            UPDATE wallets
            SET current_balance = current_balance - ?,
                total_debited = total_debited + ?,
                last_transaction_at = CURRENT_TIMESTAMP
            WHERE wallet_id = ?
            """;
        String insertTxn = """
            INSERT INTO user_wallet_transactions (
                wallet_id, order_id, transaction_type, transaction_source,
                amount, balance_after, txn_reference_no, remarks, status
            ) VALUES (?, ?, 'DEBIT', ?, ?, ?, ?, ?, 'SUCCESS')
            """;

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            Wallet wallet = null;
            try (PreparedStatement psLock = con.prepareStatement(selectLock)) {
                psLock.setInt(1, userId);
                ResultSet rs = psLock.executeQuery();
                if (rs.next()) {
                    wallet = mapResultSetToWallet(rs);
                }
            }

            if (wallet == null || wallet.getCurrentBalance().compareTo(amount) < 0) {
                // Insufficient funds
                con.rollback();
                return false;
            }

            BigDecimal newBalance = wallet.getCurrentBalance().subtract(amount);

            // Update Wallet
            try (PreparedStatement psUp = con.prepareStatement(updateWallet)) {
                psUp.setBigDecimal(1, amount);
                psUp.setBigDecimal(2, amount);
                psUp.setInt(3, wallet.getWalletId());
                psUp.executeUpdate();
            }

            // Insert Transaction Ledger
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
            String refNo = "TXN-" + sdf.format(new Date()) + "-" + (1000 + new Random().nextInt(9000));

            try (PreparedStatement psTxn = con.prepareStatement(insertTxn)) {
                psTxn.setInt(1, wallet.getWalletId());
                if (orderId != null) {
                    psTxn.setInt(2, orderId);
                } else {
                    psTxn.setNull(2, Types.INTEGER);
                }
                psTxn.setString(3, source != null ? source : "ORDER_PAYMENT");
                psTxn.setBigDecimal(4, amount);
                psTxn.setBigDecimal(5, newBalance);
                psTxn.setString(6, refNo);
                psTxn.setString(7, remarks);
                psTxn.executeUpdate();
            }

            con.commit();
            return true;
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

    public List<WalletTransaction> getTransactionsByWalletId(int walletId) {
        List<WalletTransaction> list = new ArrayList<>();
        String sql = "SELECT * FROM user_wallet_transactions WHERE wallet_id = ? ORDER BY transaction_date DESC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, walletId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                WalletTransaction txn = new WalletTransaction();
                txn.setTransactionId(rs.getInt("transaction_id"));
                txn.setWalletId(rs.getInt("wallet_id"));

                int orderId = rs.getInt("order_id");
                if (!rs.wasNull()) {
                    txn.setOrderId(orderId);
                }

                txn.setTransactionType(rs.getString("transaction_type"));
                txn.setTransactionSource(rs.getString("transaction_source"));
                txn.setAmount(rs.getBigDecimal("amount"));
                txn.setBalanceAfter(rs.getBigDecimal("balance_after"));
                txn.setTxnReferenceNo(rs.getString("txn_reference_no"));
                txn.setRemarks(rs.getString("remarks"));
                txn.setStatus(rs.getString("status"));
                txn.setTransactionDate(rs.getTimestamp("transaction_date"));

                list.add(txn);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Wallet mapResultSetToWallet(ResultSet rs) throws SQLException {
        Wallet w = new Wallet();
        w.setWalletId(rs.getInt("wallet_id"));
        w.setUserId(rs.getInt("user_id"));
        w.setCurrentBalance(rs.getBigDecimal("current_balance"));
        w.setTotalCredited(rs.getBigDecimal("total_credited"));
        w.setTotalDebited(rs.getBigDecimal("total_debited"));
        w.setLastTransactionAt(rs.getTimestamp("last_transaction_at"));
        w.setStatus(rs.getString("status"));
        w.setCreatedAt(rs.getTimestamp("created_at"));
        w.setUpdatedAt(rs.getTimestamp("updated_at"));
        return w;
    }
}
