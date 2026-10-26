package model;

import java.io.InputStream;
import java.util.Properties;

public class PayPal0Auth {
    public static String CLIENT_ID;
    public static String CLIENT_SECRET;
    public static String BASE_URL;

    static {
        try (InputStream input = PayPal0Auth.class.getClassLoader().getResourceAsStream("paypal.properties")) {
            Properties prop = new Properties();
            if (input != null) {
                prop.load(input);
                CLIENT_ID = prop.getProperty("paypal.client.id");
                CLIENT_SECRET = prop.getProperty("paypal.client.secret");
                BASE_URL = prop.getProperty("paypal.base.url", "https://api-m.sandbox.paypal.com");
            } else {
                System.out.println("WARNING: paypal.properties not found. Payments will not work.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}