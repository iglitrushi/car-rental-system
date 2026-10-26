import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonArray;

import model.PayPal0Auth;

@WebServlet("/ExecutePaymentServlet")
public class ExecutePaymentServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String paymentId = request.getParameter("paymentId");
        String payerId = request.getParameter("PayerID");

        if (paymentId == null || payerId == null) {
            response.sendRedirect("cancel.jsp");
            return;
        }

        try {
            // 1. Get Access Token
            String auth = PayPal0Auth.CLIENT_ID + ":" + PayPal0Auth.CLIENT_SECRET;
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes());

            URL tokenUrl = new URL(PayPal0Auth.BASE_URL + "/v1/oauth2/token");
            HttpURLConnection tokenConn = (HttpURLConnection) tokenUrl.openConnection();
            tokenConn.setRequestMethod("POST");
            tokenConn.setRequestProperty("Authorization", "Basic " + encodedAuth);
            tokenConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            tokenConn.setDoOutput(true);

            OutputStream os = tokenConn.getOutputStream();
            os.write("grant_type=client_credentials".getBytes());
            os.flush();
            os.close();

            BufferedReader tokenReader = new BufferedReader(new InputStreamReader(tokenConn.getInputStream()));
            StringBuilder tokenBuilder = new StringBuilder();
            String tokenLine;
            while ((tokenLine = tokenReader.readLine()) != null) {
                tokenBuilder.append(tokenLine);
            }
            tokenReader.close();

            // Parse Token using the modern Gson method
            JsonObject tokenJson = JsonParser.parseString(tokenBuilder.toString()).getAsJsonObject();
            String accessToken = tokenJson.get("access_token").getAsString();

            // 2. Execute Payment
            URL executeUrl = new URL(PayPal0Auth.BASE_URL + "/v1/payments/payment/" + paymentId + "/execute");
            HttpURLConnection executeConn = (HttpURLConnection) executeUrl.openConnection();
            executeConn.setRequestMethod("POST");
            executeConn.setRequestProperty("Authorization", "Bearer " + accessToken);
            executeConn.setRequestProperty("Content-Type", "application/json");
            executeConn.setDoOutput(true);

            String json = "{\"payer_id\": \"" + payerId + "\"}";

            OutputStream os2 = executeConn.getOutputStream();
            os2.write(json.getBytes());
            os2.flush();
            os2.close();

            BufferedReader executeReader = new BufferedReader(new InputStreamReader(executeConn.getInputStream()));
            StringBuilder executeBuilder = new StringBuilder();
            String executeLine;
            while ((executeLine = executeReader.readLine()) != null) {
                executeBuilder.append(executeLine);
            }
            executeReader.close();

            // Parse Execute Response
            JsonObject executeResponse = JsonParser.parseString(executeBuilder.toString()).getAsJsonObject();
            String state = executeResponse.get("state").getAsString();

            if ("approved".equals(state)) {
                JsonArray transactions = executeResponse.getAsJsonArray("transactions");
                JsonObject transaction = transactions.get(0).getAsJsonObject();
                JsonObject amount = transaction.getAsJsonObject("amount");
                String total = amount.get("total").getAsString();

                request.getSession().setAttribute("paymentSuccess", true);
                request.getSession().setAttribute("paymentAmount", total);
                response.sendRedirect("success.jsp");
            } else {
                response.sendRedirect("cancel.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error executing payment: " + e.getMessage());
        }
    }
}