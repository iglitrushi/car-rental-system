import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.DBUtil;

import java.io.IOException;
import java.sql.*;

/**
 * TaxiBookingServlet — handles taxi booking form submission.
 *
 * BRAND NEW — did not exist in original project.
 *
 * Handles two booking types:
 *  - "immediate": client needs a taxi right now
 *  - "scheduled": client books in advance with a specific pickup time
 *
 * Flow:
 *  1. Client fills taxi_booking.jsp form
 *  2. This servlet saves to taxi_bookings table
 *  3. Admin sees it in admin_taxi.jsp and assigns a driver/car
 *  4. Status updates: Pending → Assigned → InProgress → Completed
 */
@WebServlet("/TaxiBookingServlet")
public class TaxiBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerName  = request.getParameter("customerName");
        String customerPhone = request.getParameter("customerPhone");
        String pickupAddress = request.getParameter("pickupAddress");
        String dropoffAddress= request.getParameter("dropoffAddress");
        String bookingType   = request.getParameter("bookingType");   // immediate or scheduled
        String scheduledTime = request.getParameter("scheduledTime"); // only for scheduled
        String pickupLatStr  = request.getParameter("pickupLat");
        String pickupLngStr  = request.getParameter("pickupLng");
        String dropoffLatStr = request.getParameter("dropoffLat");
        String dropoffLngStr = request.getParameter("dropoffLng");

        // Validation
        if (customerName == null || customerPhone == null ||
            pickupAddress == null || dropoffAddress == null ||
            customerName.isEmpty() || customerPhone.isEmpty() ||
            pickupAddress.isEmpty() || dropoffAddress.isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("taxi_booking.jsp").forward(request, response);
            return;
        }

        if ("scheduled".equals(bookingType) &&
            (scheduledTime == null || scheduledTime.isEmpty())) {
            request.setAttribute("error", "Please provide a scheduled pickup time.");
            request.getRequestDispatcher("taxi_booking.jsp").forward(request, response);
            return;
        }

        // Get user_id from session if logged in
        HttpSession session = request.getSession(false);
        Integer userId = null;
        if (session != null && session.getAttribute("userId") != null) {
            userId = (Integer) session.getAttribute("userId");
        }

        Connection con = null;
        PreparedStatement pst = null;

        try {
            con = DBUtil.getConnection();

            String sql = "INSERT INTO taxi_bookings " +
                "(user_id, customer_name, customer_phone, booking_type, " +
                "pickup_address, dropoff_address, pickup_lat, pickup_lng, " +
                "dropoff_lat, dropoff_lng, scheduled_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            if (userId != null) pst.setInt(1, userId); else pst.setNull(1, Types.INTEGER);
            pst.setString(2, customerName);
            pst.setString(3, customerPhone);
            pst.setString(4, bookingType != null ? bookingType : "immediate");
            pst.setString(5, pickupAddress);
            pst.setString(6, dropoffAddress);

            // GPS coordinates of pickup/dropoff (from map widget, if available)
            if (pickupLatStr != null && !pickupLatStr.isEmpty()) {
                pst.setDouble(7, Double.parseDouble(pickupLatStr));
                pst.setDouble(8, Double.parseDouble(pickupLngStr));
            } else {
                pst.setNull(7, Types.DECIMAL);
                pst.setNull(8, Types.DECIMAL);
            }
            if (dropoffLatStr != null && !dropoffLatStr.isEmpty()) {
                pst.setDouble(9, Double.parseDouble(dropoffLatStr));
                pst.setDouble(10, Double.parseDouble(dropoffLngStr));
            } else {
                pst.setNull(9, Types.DECIMAL);
                pst.setNull(10, Types.DECIMAL);
            }

            if ("scheduled".equals(bookingType) && scheduledTime != null) {
                pst.setTimestamp(11, Timestamp.valueOf(scheduledTime.replace("T", " ") + ":00"));
            } else {
                pst.setNull(11, Types.TIMESTAMP);
            }

            pst.executeUpdate();

            // Pass info to confirmation JSP
            request.setAttribute("customerName",  customerName);
            request.setAttribute("pickupAddress", pickupAddress);
            request.setAttribute("dropoffAddress",dropoffAddress);
            request.setAttribute("bookingType",   bookingType);
            request.setAttribute("scheduledTime", scheduledTime);
            request.getRequestDispatcher("taxi_confirmation.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error submitting taxi request: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            DBUtil.close(pst, con);
        }
    }
}
