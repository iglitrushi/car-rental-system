import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ApproveReservationServlet")
public class ApproveReservation extends HttpServlet {
  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {

    int id = Integer.parseInt(req.getParameter("reservationId"));
    String action = req.getParameter("action");
    String newStatus = action.equals("approve") ? "Approved" : "Rejected";

    try (Connection con = DriverManager.getConnection(
           "jdbc:mysql://localhost:3306/demo","root","")) {

      PreparedStatement ps = con.prepareStatement(
        "UPDATE date_reservation SET status=? WHERE id=?");
      ps.setString(1, newStatus);
      ps.setInt(2, id);
      ps.executeUpdate();
    } catch(SQLException e) {
      throw new ServletException(e);
    }

    res.sendRedirect("adminReservationCheck.jsp");
  }
}
