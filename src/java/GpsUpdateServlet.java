import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.DBUtil;

import java.io.IOException;
import java.sql.*;


@WebServlet("/GpsUpdateServlet")
public class GpsUpdateServlet extends HttpServlet {

    
    private static final String SECRET_TOKEN = "gps_secret_token_changeme";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");


        String deviceId  = request.getParameter("device_id");
        String latStr    = request.getParameter("lat");
        String lngStr    = request.getParameter("lng");
        String speedStr  = request.getParameter("speed");
        String headingStr = request.getParameter("heading");

        
        if (deviceId == null || latStr == null || lngStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing required fields: device_id, lat, lng");
            return;
        }

        try {
            double lat     = Double.parseDouble(latStr.trim());
            double lng     = Double.parseDouble(lngStr.trim());
            float  speed   = speedStr != null ? Float.parseFloat(speedStr.trim()) : 0f;
            Float  heading = null;
            if (headingStr != null && !headingStr.trim().isEmpty()) {
                heading = Float.parseFloat(headingStr.trim());
            }

            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try {
                con = DBUtil.getConnection();

                
                pst = con.prepareStatement(
                    "SELECT id FROM fleet WHERE gps_device_id = ?");
                pst.setString(1, deviceId.trim());
                rs = pst.executeQuery();

                if (!rs.next()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("Unknown device_id: " + deviceId);
                    return;
                }

                int fleetId = rs.getInt("id");
                DBUtil.close(rs, pst);

                
                pst = con.prepareStatement(
                    "INSERT INTO location_logs (fleet_id, latitude, longitude, speed, heading) " +
                    "VALUES (?, ?, ?, ?, ?)");
                pst.setInt(1, fleetId);
                pst.setDouble(2, lat);
                pst.setDouble(3, lng);
                pst.setFloat(4, speed);
                if (heading != null) pst.setFloat(5, heading);
                else pst.setNull(5, Types.FLOAT);
                pst.executeUpdate();

                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");

            } finally {
                DBUtil.close(rs, pst, con);
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid number format: " + e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error: " + e.getMessage());
        }
    }

   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
