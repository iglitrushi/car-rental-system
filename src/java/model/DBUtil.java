package model;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;


public class DBUtil {

    private static String dbUrl;
    private static String dbUser;
    private static String dbPass;

    static {
        try (InputStream input = DBUtil.class.getClassLoader().getResourceAsStream("database.properties")) {
            Properties prop = new Properties();
            
            if (input == null) {
                throw new RuntimeException("Sorry, unable to find database.properties");
            }
            
            prop.load(input);
            
            dbUrl = prop.getProperty("db.url");
            dbUser = prop.getProperty("db.user");
            dbPass = prop.getProperty("db.password");

            Class.forName("com.mysql.cj.jdbc.Driver");
            
        } catch (Exception ex) {
            throw new RuntimeException("Error initializing database connection", ex);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(dbUrl, dbUser, dbPass);
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try { r.close(); } catch (Exception ignored) {}
            }
        }
    }
}