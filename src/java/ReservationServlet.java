import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@WebServlet("/ReservationServlet")
public class ReservationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String carIdStr = request.getParameter("carId");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        if (name == null || email == null || carIdStr == null || startDateStr == null || endDateStr == null ||
            name.isEmpty() || email.isEmpty() || carIdStr.isEmpty() || startDateStr.isEmpty() || endDateStr.isEmpty()) {
            out.println("<html><body><h3 style='color:red;'>Missing data. Please go back and fill all fields.</h3></body></html>");
            return;
        }

        try {
            int carId = Integer.parseInt(carIdStr);
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);

          
            if (endDate.isBefore(startDate)) {
                out.println("<html><body><h3 style='color:red;'>End date must be after start date.</h3></body></html>");
                return;
            }

            
            long daysBetween = ChronoUnit.DAYS.between(startDate, endDate);
            if (daysBetween <= 0) {
                out.println("<html><body><h3 style='color:red;'>Reservation duration must be greater than 0 days.</h3></body></html>");
                return;
            }

          
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/demo", "root", "");
            PreparedStatement pst = con.prepareStatement("SELECT price FROM carsbrand WHERE CarId = ?");
            pst.setInt(1, carId);
            ResultSet rs = pst.executeQuery();

            double pricePerDay = 0;
            if (rs.next()) {
                pricePerDay = rs.getDouble("price");
            }
            rs.close();
            pst.close();

          
            double totalPrice = pricePerDay * daysBetween;

         
            pst = con.prepareStatement("INSERT INTO date_reservation (name, email, car_id, start_date, end_date, total_price) VALUES (?, ?, ?, ?, ?, ?)");
            pst.setString(1, name);
            pst.setString(2, email);
            pst.setInt(3, carId);
            pst.setDate(4, Date.valueOf(startDate));
            pst.setDate(5, Date.valueOf(endDate));
            pst.setDouble(6, totalPrice);

            int rowsInserted = pst.executeUpdate();
            
            
            out.println("<!DOCTYPE html>");
            out.println("<html lang='en>");
            out.println("<head>");
            out.println("<meta charset='UTF-8'>");
            out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
            out.println("<title>Reservation Status</title>");
            out.println("<script src='https://cdn.tailwindcss.com'></script>");
            out.println("</head>");
            out.println("<body class='bg-gray-100 flex items-center justify-center min-h-screen'>");
            out.println("<div class='bg-white p-8 rounded-xl shadow-lg w-full max-w-lg text-center'>");
            

    if (rowsInserted > 0) {
        out.println("<html><head><title>Reservation Success</title>");
        out.println("<script src='https://cdn.tailwindcss.com'></script></head><body class='bg-gray-100 flex items-center justify-center min-h-screen'>");

    
                out.println("<div class='bg-white p-8 rounded-xl shadow-xl max-w-xl w-full text-center'>");
                out.println("<h2 class='text-2xl font-semibold text-green-600 mb-4'>Reservation Successful!</h2>");
                out.println("<p class='text-gray-700 mb-4'>Thank you, <strong>" + name + "</strong>. Your reservation has been recorded.</p>");
                out.println("<p><strong>Email:</strong> " + email + "</p>");
                out.println("<p><strong>Car ID:</strong> " + carId + "</p>");
                out.println("<p><strong>Start Date:</strong> " + startDate + "</p>");
                out.println("<p><strong>End Date:</strong> " + endDate + "</p>");
                out.println("<p><strong>Total Price:</strong> $" + String.format("%.2f", totalPrice) + "</p>");
                out.println("</div>");

                
                out.println("<div class='mt-6 text-center'>");
                out.println("<a href='index.html' class='inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200'>Back to Home</a>");
                out.println("</div>");
                
                out.println("<div class='mt-6 text-center'>");
                out.println("<a href='Home.jsp' class='inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200'>Back to User Menu</a>");
                out.println("</div>");

                out.println("</body></html>");
    } else {
                out.println("<h2 class='text-2xl font-semibold text-red-600 mb-4'>Reservation Failed</h2>");
                out.println("<p class='text-gray-700 mb-4'>Sorry, something went wrong while processing your reservation.</p>");
                out.println("<a href='index.html' class='inline-block bg-gray-600 text-white px-4 rounded hover:bg-gray-700 transition'>Try Again</a>");
            }
            
            out.println("</div>");
            out.println("</body>");
            out.println("</html>");

            pst.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<html><body><h3 style='color:red;'>Error: " + e.getMessage() + "</h3></body></html>");
        }
    }
}
