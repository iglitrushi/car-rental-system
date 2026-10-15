import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.DBUtil;

import java.io.IOException;
import java.sql.*;


@WebServlet("/AssignTaxiServlet")
public class AssignTaxiServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("index.html");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String fleetIdStr   = request.getParameter("fleetId");

        if (bookingIdStr == null || fleetIdStr == null || fleetIdStr.isEmpty()) {
            response.sendRedirect("admin_taxi.jsp");
            return;
        }

        Connection con = null;
        PreparedStatement pst = null;

        try {
            con = DBUtil.getConnection();

           
            pst = con.prepareStatement(
                "UPDATE taxi_bookings SET fleet_id = ?, status = 'Assigned' WHERE id = ?");
            pst.setInt(1, Integer.parseInt(fleetIdStr));
            pst.setInt(2, Integer.parseInt(bookingIdStr));
            pst.executeUpdate();
            DBUtil.close(pst);

            
            pst = con.prepareStatement(
                "UPDATE fleet SET available = 0 WHERE id = ?");
            pst.setInt(1, Integer.parseInt(fleetIdStr));
            pst.executeUpdate();

            request.setAttribute("successMessage", "Car assigned successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error assigning car: " + e.getMessage());
        } finally {
            DBUtil.close(pst, con);
        }

        request.getRequestDispatcher("admin_taxi.jsp").forward(request, response);
    }
}
