<%@ page import="java.sql.*" %>
<%@ page import="model.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("role") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Taxi Bookings</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<div class="container mx-auto p-6 max-w-7xl">

    <div class="flex items-center justify-between mb-6">
        <h1 class="text-3xl font-bold text-gray-800">Taxi Bookings</h1>
        <a href="admin_dashboard.jsp"
           class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition text-sm">
            Back to Dashboard
        </a>
    </div>

    <%
        String ok  = (String) request.getAttribute("successMessage");
        String err = (String) request.getAttribute("errorMessage");
        if (ok  != null) { %><div class="bg-green-100 border border-green-400 text-green-800 p-3 rounded mb-4"><%= ok %></div><% }
        if (err != null) { %><div class="bg-red-100 border border-red-400 text-red-800 p-3 rounded mb-4"><%= err %></div><% }
    %>

    <!-- Pending / active bookings -->
    <div class="bg-white shadow-md rounded-lg p-6 mb-8">
        <h2 class="text-lg font-semibold text-gray-700 mb-4">Pending &amp; Active</h2>
        <div class="overflow-x-auto">
        <table class="min-w-full text-sm">
            <thead class="bg-teal-600 text-white">
                <tr>
                    <th class="px-4 py-3 text-left">ID</th>
                    <th class="px-4 py-3 text-left">Customer</th>
                    <th class="px-4 py-3 text-left">Phone</th>
                    <th class="px-4 py-3 text-left">Type</th>
                    <th class="px-4 py-3 text-left">Pickup</th>
                    <th class="px-4 py-3 text-left">Dropoff</th>
                    <th class="px-4 py-3 text-left">Scheduled</th>
                    <th class="px-4 py-3 text-left">Status</th>
                    <th class="px-4 py-3 text-left">Assign Car</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
            <%
                Connection con = null; PreparedStatement pst = null; ResultSet rs = null;
                try {
                    con = DBUtil.getConnection();
                    pst = con.prepareStatement(
                        "SELECT tb.id, tb.customer_name, tb.customer_phone, tb.booking_type, " +
                        "tb.pickup_address, tb.dropoff_address, tb.scheduled_time, tb.status, " +
                        "tb.fleet_id, f.brand, f.model " +
                        "FROM taxi_bookings tb " +
                        "LEFT JOIN fleet f ON tb.fleet_id = f.id " +
                        "WHERE tb.status IN ('Pending','Assigned','InProgress') " +
                        "ORDER BY tb.created_at ASC"
                    );
                    rs = pst.executeQuery();

                    // Pre-load available taxi fleet for the assign dropdown
                    PreparedStatement taxiPst = con.prepareStatement(
                        "SELECT id, brand, model FROM fleet WHERE type IN ('taxi','both') AND available = 1");
                    ResultSet taxiRs = taxiPst.executeQuery();
                    StringBuilder taxiOptions = new StringBuilder();
                    taxiOptions.append("<option value=''>-- Select car --</option>");
                    while (taxiRs.next()) {
                        taxiOptions.append("<option value='").append(taxiRs.getInt("id")).append("'>")
                                   .append(taxiRs.getString("brand")).append(" ")
                                   .append(taxiRs.getString("model")).append("</option>");
                    }
                    DBUtil.close(taxiRs, taxiPst);

                    boolean hasRows = false;
                    while (rs.next()) {
                        hasRows = true;
                        int    id      = rs.getInt("id");
                        String status  = rs.getString("status");
                        String sClass  =
                            "Assigned".equals(status)   ? "bg-blue-100 text-blue-800" :
                            "InProgress".equals(status) ? "bg-amber-100 text-amber-800" :
                                                          "bg-yellow-100 text-yellow-800";
            %>
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-2 font-mono">#<%= id %></td>
                    <td class="px-4 py-2 font-medium"><%= rs.getString("customer_name") %></td>
                    <td class="px-4 py-2"><%= rs.getString("customer_phone") %></td>
                    <td class="px-4 py-2 capitalize"><%= rs.getString("booking_type") %></td>
                    <td class="px-4 py-2 text-xs max-w-xs truncate"><%= rs.getString("pickup_address") %></td>
                    <td class="px-4 py-2 text-xs max-w-xs truncate"><%= rs.getString("dropoff_address") %></td>
                    <td class="px-4 py-2 text-xs">
                        <%= rs.getTimestamp("scheduled_time") != null ? rs.getTimestamp("scheduled_time").toString().substring(0,16) : "Now" %>
                    </td>
                    <td class="px-4 py-2">
                        <span class="px-2 py-1 rounded-full text-xs font-medium <%= sClass %>">
                            <%= status %>
                        </span>
                    </td>
                    <td class="px-4 py-2">
                        <form action="AssignTaxiServlet" method="post" class="flex gap-2 items-center">
                            <input type="hidden" name="bookingId" value="<%= id %>">
                            <select name="fleetId" class="border rounded px-2 py-1 text-xs">
                                <%= taxiOptions.toString() %>
                            </select>
                            <button type="submit"
                                class="bg-teal-600 text-white px-3 py-1 rounded text-xs hover:bg-teal-700">
                                Assign
                            </button>
                        </form>
                    </td>
                </tr>
            <%
                    }
                    if (!hasRows) {
            %>
                <tr><td colspan="9" class="px-4 py-6 text-center text-gray-400">No active taxi bookings.</td></tr>
            <%  }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<tr><td colspan='9' class='px-4 py-4 text-red-600'>Error: " + e.getMessage() + "</td></tr>");
                } finally {
                    DBUtil.close(rs, pst, con);
                }
            %>
            </tbody>
        </table>
        </div>
    </div>
</div>
</body>
</html>
