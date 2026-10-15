import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.DBUtil;

import java.io.IOException;
import java.sql.*;
import java.util.logging.Logger;

@WebServlet(urlPatterns = {"/ProfileServlet"})
public class ProfileServlet extends HttpServlet {

    private static final Logger log = Logger.getLogger(ProfileServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String username = (String) session.getAttribute("user");

        try (Connection con = DBUtil.getConnection()) {

           
            PreparedStatement up = con.prepareStatement(
                "SELECT id, first_name, last_name, username, email, contact, address, role, created_at " +
                "FROM users WHERE username = ?");
            up.setString(1, username);
            ResultSet ur = up.executeQuery();
            if (!ur.next()) {
                ur.close(); up.close();
                response.sendRedirect("index.html");
                return;
            }
            int userId = ur.getInt("id");
            request.setAttribute("uFirstName", ur.getString("first_name"));
            request.setAttribute("uLastName",  ur.getString("last_name"));
            request.setAttribute("uUsername",  ur.getString("username"));
            request.setAttribute("uEmail",     ur.getString("email"));
            request.setAttribute("uContact",   ur.getString("contact"));
            request.setAttribute("uAddress",   ur.getString("address"));
            request.setAttribute("uRole",      ur.getString("role"));
            request.setAttribute("uCreatedAt", ur.getTimestamp("created_at"));
            ur.close(); up.close();

            
            PreparedStatement rp = con.prepareStatement(
                "SELECT r.start_date, r.end_date, r.pickup_location, r.dropoff_location, " +
                "       r.total_price, r.status, f.brand, f.model " +
                "FROM rental_bookings r " +
                "LEFT JOIN fleet f ON r.fleet_id = f.id " +
                "WHERE r.user_id = ? " +
                "ORDER BY r.created_at DESC LIMIT 1");
            rp.setInt(1, userId);
            ResultSet rr = rp.executeQuery();
            if (rr.next()) {
                request.setAttribute("lastRental", true);
                request.setAttribute("lrBrand",   rr.getString("brand"));
                request.setAttribute("lrModel",   rr.getString("model"));
                request.setAttribute("lrStart",   rr.getDate("start_date"));
                request.setAttribute("lrEnd",     rr.getDate("end_date"));
                request.setAttribute("lrPickup",  rr.getString("pickup_location"));
                request.setAttribute("lrDropoff", rr.getString("dropoff_location"));
                request.setAttribute("lrTotal",   rr.getDouble("total_price"));
                request.setAttribute("lrStatus",  rr.getString("status"));
            } else {
                request.setAttribute("lastRental", false);
            }
            rr.close(); rp.close();

           
            PreparedStatement tp = con.prepareStatement(
                "SELECT pickup_address, dropoff_address, estimated_price, status, created_at " +
                "FROM taxi_bookings WHERE user_id = ? " +
                "ORDER BY created_at DESC LIMIT 1");
            tp.setInt(1, userId);
            ResultSet tr = tp.executeQuery();
            if (tr.next()) {
                request.setAttribute("lastTaxi", true);
                request.setAttribute("ltPickup",  tr.getString("pickup_address"));
                request.setAttribute("ltDropoff", tr.getString("dropoff_address"));
                request.setAttribute("ltPrice",   tr.getDouble("estimated_price"));
                request.setAttribute("ltStatus",  tr.getString("status"));
                request.setAttribute("ltCreated", tr.getTimestamp("created_at"));
            } else {
                request.setAttribute("lastTaxi", false);
            }
            tr.close(); tp.close();

            
            PreparedStatement sp = con.prepareStatement(
                "SELECT COUNT(*) AS c, COALESCE(SUM(total_price), 0) AS s " +
                "FROM rental_bookings WHERE user_id = ?");
            sp.setInt(1, userId);
            ResultSet sr = sp.executeQuery();
            if (sr.next()) {
                request.setAttribute("totalRentals", sr.getInt("c"));
                request.setAttribute("totalSpent",   sr.getDouble("s"));
            } else {
                request.setAttribute("totalRentals", 0);
                request.setAttribute("totalSpent",   0.0);
            }
            sr.close(); sp.close();

        } catch (Exception e) {
            log.severe("ProfileServlet error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}