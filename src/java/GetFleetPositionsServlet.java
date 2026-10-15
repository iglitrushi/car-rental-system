import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.DBUtil;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;


@WebServlet("/GetFleetPositionsServlet")
public class GetFleetPositionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache");

        String typeFilter = request.getParameter("type");
        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        PrintWriter out = response.getWriter();

        try {
            con = DBUtil.getConnection();

           
            
            StringBuilder sql = new StringBuilder(
                "SELECT f.id AS fleet_id, f.brand, f.model, " +
                "f.gps_device_id, f.type AS vehicle_type, " +
                "ll.latitude, ll.longitude, ll.speed, " +
                "ll.odometer_km, ll.recorded_at " +
                "FROM fleet f " +
                "INNER JOIN location_logs ll " +
                "  ON ll.id = (" +
                "    SELECT id FROM location_logs " +
                "    WHERE fleet_id = f.id " +
                "    ORDER BY recorded_at DESC, id DESC LIMIT 1" +
                "  ) " +
                "WHERE f.gps_device_id IS NOT NULL " +
                "AND f.gps_device_id != '' "
            );

            if (typeFilter != null && !typeFilter.isEmpty()) {
                sql.append("AND (f.type = ? OR f.type = 'both') ");
            }
            sql.append("ORDER BY f.brand, f.model");

            pst = con.prepareStatement(sql.toString());
            if (typeFilter != null && !typeFilter.isEmpty()) {
                pst.setString(1, typeFilter);
            }
            rs = pst.executeQuery();

            out.print("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) out.print(",");
                first = false;

                double lat   = rs.getDouble("latitude");
                double lng   = rs.getDouble("longitude");
                float  speed = rs.getFloat("speed");
                int    km    = rs.getInt("odometer_km");
                String recAt = "";
                if (rs.getTimestamp("recorded_at") != null) {
                    recAt = rs.getTimestamp("recorded_at")
                              .toString().substring(0, 19);
                }
                String gpsId = rs.getString("gps_device_id");
                if (gpsId == null) gpsId = "";

                out.print("{");
                out.print("\"fleetId\":"       + rs.getInt("fleet_id")              + ",");
                out.print("\"brand\":\""        + esc(rs.getString("brand"))         + "\",");
                out.print("\"model\":\""        + esc(rs.getString("model"))         + "\",");
                out.print("\"type\":\""         + esc(rs.getString("vehicle_type"))  + "\",");
                out.print("\"gpsDeviceId\":\""  + esc(gpsId)                        + "\",");
                out.print("\"lat\":"            + lat                                + ",");
                out.print("\"lng\":"            + lng                                + ",");
                out.print("\"speed\":"          + speed                              + ",");
                out.print("\"odometerKm\":"     + km                                + ",");
                out.print("\"recordedAt\":\""   + esc(recAt)                        + "\",");
                out.print("\"hasGps\":true");
                out.print("}");
            }
            out.print("]");

        } catch (SQLException e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
        } finally {
            DBUtil.close(rs, pst, con);
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"");
    }
}