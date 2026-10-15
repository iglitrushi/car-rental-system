<%@ page import="java.sql.*" %>
<%@ page import="model.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Admin only check
    if (session.getAttribute("role") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("index.html");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Pending Reservations</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen p-6">
    <div class="max-w-7xl mx-auto bg-white shadow-xl rounded-xl p-8">
        <h1 class="text-3xl font-bold mb-6 text-center text-blue-700">Pending Rental Reservations</h1>

        <%
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;
            try {
                con = DBUtil.getConnection();
                // Updated: queries rental_bookings JOIN fleet (was date_reservation JOIN carsbrand)
                pst = con.prepareStatement(
                    "SELECT rb.id, rb.customer_name, rb.customer_email, " +
                    "rb.start_date, rb.end_date, rb.total_price, rb.pickup_location, rb.dropoff_location, " +
                    "f.brand, f.model " +
                    "FROM rental_bookings rb " +
                    "JOIN fleet f ON rb.fleet_id = f.id " +
                    "WHERE rb.status = 'Pending' " +
                    "ORDER BY rb.created_at ASC"
                );
                rs = pst.executeQuery();

                if (!rs.isBeforeFirst()) {
        %>
            <p class="text-center text-gray-500 text-lg py-8">No pending reservations.</p>
        <%
                } else {
        %>
        <div class="overflow-x-auto">
            <table class="min-w-full text-sm text-left text-gray-600">
                <thead class="bg-blue-600 text-white">
                    <tr>
                        <th class="px-4 py-3">ID</th>
                        <th class="px-4 py-3">Customer</th>
                        <th class="px-4 py-3">Email</th>
                        <th class="px-4 py-3">Vehicle</th>
                        <th class="px-4 py-3">Dates</th>
                        <th class="px-4 py-3">Pickup → Drop</th>
                        <th class="px-4 py-3">Price</th>
                        <th class="px-4 py-3">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                <%
                    while (rs.next()) {
                        int    id      = rs.getInt("id");
                        String name    = rs.getString("customer_name");
                        String email   = rs.getString("customer_email");
                        String vehicle = rs.getString("brand") + " " + rs.getString("model");
                        String pickup  = rs.getString("pickup_location");
                        String dropoff = rs.getString("dropoff_location");
                        double price   = rs.getDouble("total_price");
                %>
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-4 py-3 font-mono">#<%= id %></td>
                    <td class="px-4 py-3 font-medium"><%= name %></td>
                    <td class="px-4 py-3 text-gray-500"><%= email %></td>
                    <td class="px-4 py-3"><%= vehicle %></td>
                    <td class="px-4 py-3">
                        <%= rs.getDate("start_date") %> →<br><%= rs.getDate("end_date") %>
                    </td>
                    <td class="px-4 py-3 text-xs">
                        <%= pickup  != null && !pickup.isEmpty()  ? pickup  : "—" %> →<br>
                        <%= dropoff != null && !dropoff.isEmpty() ? dropoff : "—" %>
                    </td>
                    <td class="px-4 py-3 font-semibold text-green-700">$<%= String.format("%.2f", price) %></td>
                    <td class="px-4 py-3 space-x-2 whitespace-nowrap">
                        <form action="ApproveReservationServlet" method="post" style="display:inline">
                            <input type="hidden" name="reservationId" value="<%= id %>"/>
                            <button name="action" value="approve"
                                class="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700 transition text-xs">
                                Approve
                            </button>
                        </form>
                        <form action="ApproveReservationServlet" method="post" style="display:inline">
                            <input type="hidden" name="reservationId" value="<%= id %>"/>
                            <button name="action" value="reject"
                                class="bg-red-600 text-white px-3 py-1 rounded hover:bg-red-700 transition text-xs">
                                Reject
                            </button>
                        </form>
                    </td>
                </tr>
                <%  } %>
                </tbody>
            </table>
        </div>
        <% } %>

        <div class="flex justify-center gap-4 mt-8">
            <a href="admin_dashboard.jsp"
               class="bg-blue-600 text-white px-6 py-2 rounded-full hover:bg-blue-700 transition">
                Back to Dashboard
            </a>
        </div>
    </div>

<%
        } catch (Exception e) {
            e.printStackTrace();
%>
    <p class="text-red-600 font-semibold text-center mt-4">Error: <%= e.getMessage() %></p>
<%
        } finally {
            DBUtil.close(rs, pst, con);
        }
%>
</body>
</html>
