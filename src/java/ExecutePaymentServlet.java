import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import model.PayPal0Auth;

@WebServlet("/execute-payment")
public class ExecutePaymentServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String paymentId = request.getParameter("paymentId");
        String payerId = request.getParameter("PayerID");

        if (paymentId == null || payerId == null) {
            response.getWriter().write("Payment failed or canceled.");
            return;
        }

        try {
            
            String auth = PayPal0Auth.CLIENT_ID + ":" + PayPal0Auth.CLIENT_SECRET;
            String encodedAuth = java.util.Base64.getEncoder().encodeToString(auth.getBytes());

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
            String line;
            while ((line = tokenReader.readLine()) != null) {
                tokenBuilder.append(line);
            }
            tokenReader.close();

            String accessToken = JsonParser.parseString(tokenBuilder.toString())
                    .getAsJsonObject().get("access_token").getAsString();

           
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
            while ((line = executeReader.readLine()) != null) {
                executeBuilder.append(line);
            }
            executeReader.close();

            JsonObject executeResponse = JsonParser.parseString(executeBuilder.toString()).getAsJsonObject();

            
            JsonObject transaction = executeResponse.getAsJsonArray("transactions").get(0).getAsJsonObject();
            JsonObject amount = transaction.getAsJsonObject("amount");
            String total = amount.get("total").getAsString();
            String currency = amount.get("currency").getAsString();

          
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();

            out.println("<html><body>");
            out.println("<h2>Payment successful!</h2>");
            out.println("<p>Amount paid: " + total + " " + currency + "</p>");
            out.println("<p>Thank you for your reservation.</p>");
            out.println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error executing payment: " + e.getMessage());
        }
    }
}
