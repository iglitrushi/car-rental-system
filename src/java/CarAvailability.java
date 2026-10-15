import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import model.ReservationCalendar;
import java.util.Date;

@WebServlet("/CarAvailability")
public class CarAvailability extends HttpServlet {

    private Date truncateTime(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        System.out.println("CarAvailability servlet called.");

        Map<Integer, List<ReservationCalendar>> carReservations = new HashMap<>();

        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost/demo", "root", "");
             PreparedStatement ps = con.prepareStatement(
                 "SELECT r.car_id, c.NameOfBrand, c.Model, c.transmission, c.Fuel, c.price, " +
                 "r.start_date, r.end_date FROM date_reservation r " +
                 "JOIN carsbrand c ON r.car_id = c.CarId " +
                 "WHERE r.status = 'Approved'");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int carId = rs.getInt("car_id");

                Date startDate = truncateTime(rs.getDate("start_date"));
                Date endDate = truncateTime(rs.getDate("end_date"));

                System.out.println("Reservation found: carId=" + carId 
                    + ", brand=" + rs.getString("NameOfBrand") 
                    + ", model=" + rs.getString("Model")
                    + ", start=" + startDate
                    + ", end=" + endDate);

                ReservationCalendar reservation = new ReservationCalendar(
                    carId,
                    rs.getString("NameOfBrand"),
                    rs.getString("Model"),
                    rs.getString("transmission"),
                    rs.getString("Fuel"),
                    rs.getInt("price"),
                    startDate,
                    endDate
                );

                if (!carReservations.containsKey(carId)) {
                    carReservations.put(carId, new ArrayList<ReservationCalendar>());
                }
                carReservations.get(carId).add(reservation);
            }

            System.out.println("Total cars with reservations: " + carReservations.size());

            if (carReservations.isEmpty()) {
                request.setAttribute("message", "No approved reservations found in database.");
            } else {
                request.setAttribute("carReservations", carReservations);
            }

            request.getRequestDispatcher("CarAvailabilityCalendar.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}
