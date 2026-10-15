import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.io.IOException;

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("addCar".equals(action)) {
            String brand = request.getParameter("brand");
            String model = request.getParameter("model");
            int cubic = Integer.parseInt(request.getParameter("cubic"));
            String fuel = request.getParameter("fuel");
            int year = Integer.parseInt(request.getParameter("year"));
            String transmission = request.getParameter("transmission");
            int availability = Integer.parseInt(request.getParameter("availability"));
            double price = Double.parseDouble(request.getParameter("price"));

            Connection con = null;
            PreparedStatement pst = null;

            try {
                
                Context context = new InitialContext();
                DataSource dataSource = (DataSource) context.lookup("java:/comp/env/jdbc/demoDB");
                con = dataSource.getConnection();

                
                String query = "INSERT INTO cars (NameOfBrand, model, cubic, fuel, year, transmission, availability, price_per_day) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                pst = con.prepareStatement(query);
                pst.setString(1, brand);
                pst.setString(2, model);
                pst.setInt(3, cubic);
                pst.setString(4, fuel);
                pst.setInt(5, year);
                pst.setString(6, transmission);
                pst.setInt(7, availability);
                pst.setDouble(8, price);
                
                int rowsInserted = pst.executeUpdate();
                if (rowsInserted > 0) {
                    request.setAttribute("successMessage", "Car added successfully!");
                }

            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            } finally {
                try {
                    if (pst != null) pst.close();
                    if (con != null) con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

           
            RequestDispatcher dispatcher = request.getRequestDispatcher("admin_dashboard.jsp");
            dispatcher.forward(request, response);
        }
    }
}
