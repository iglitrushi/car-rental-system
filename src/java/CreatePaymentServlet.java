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

@WebServlet("/CreatePaymentServlet")
public class CreatePaymentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        String customerName = request.getParameter("name");
        String customerEmail = request.getParameter("email");
        String totalPrice = request.getParameter("totalPrice"); 
        String description = "Payment for reservation by " + customerName + " (" + customerEmail + ")";

        if (totalPrice == null || totalPrice.isEmpty()) {
            totalPrice = "10.00";  
        }

        try {
            
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

            String accessToken = JsonParser.parseString(tokenBuilder.toString())
                    .getAsJsonObject().get("access_token").getAsString();

            
            URL paymentUrl = new URL(PayPal0Auth.BASE_URL + "/v1/payments/payment");
            HttpURLConnection paymentConn = (HttpURLConnection) paymentUrl.openConnection();
            paymentConn.setRequestMethod("POST");
            paymentConn.setRequestProperty("Authorization", "Bearer " + accessToken);
            paymentConn.setRequestProperty("Content-Type", "application/json");
            paymentConn.setDoOutput(true);

            String json = 
                "{\n" +
                "  \"intent\": \"sale\",\n" +
                "  \"redirect_urls\": {\n" +
                "    \"return_url\": \"http://localhost:8080/YourApp/execute-payment\",\n" +
                "    \"cancel_url\": \"http://localhost:8080/YourApp/index.jsp\"\n" +
                "  },\n" +
                "  \"payer\": {\n" +
                "    \"payment_method\": \"paypal\"\n" +
                "  },\n" +
                "  \"transactions\": [\n" +
                "    {\n" +
                "      \"amount\": {\n" +
                "        \"total\": \"" + totalPrice + "\",\n" +
                "        \"currency\": \"USD\"\n" +
                "      },\n" +
                "      \"description\": \"" + description + "\"\n" +
                "    }\n" +
                "  ]\n" +
                "}";

            OutputStream paymentOs = paymentConn.getOutputStream();
            paymentOs.write(json.getBytes());
            paymentOs.flush();
            paymentOs.close();

            BufferedReader paymentReader = new BufferedReader(new InputStreamReader(paymentConn.getInputStream()));
            StringBuilder paymentBuilder = new StringBuilder();
            String paymentLine;
            while ((paymentLine = paymentReader.readLine()) != null) {
                paymentBuilder.append(paymentLine);
            }
            paymentReader.close();

            JsonObject paymentJson = JsonParser.parseString(paymentBuilder.toString()).getAsJsonObject();
            JsonArray links = paymentJson.getAsJsonArray("links");

            for (int i = 0; i < links.size(); i++) {
                JsonObject link = links.get(i).getAsJsonObject();
                if (link.get("rel").getAsString().equals("approval_url")) {
                    response.sendRedirect(link.get("href").getAsString());
                    return;
                }
            }

            response.getWriter().write("Could not find approval_url.");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error creating payment: " + e.getMessage());
        }
    }
}
