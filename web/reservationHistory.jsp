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
    <title>Reservation History</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<div class="container mx-auto p-6 max-w-7xl">

    <h1 class="text-3xl font-bold text-gray-800 mb-6 text-center">Reservation History</h1>

    <div class="bg-white p-6 shadow-md rounded-lg">
        <div class="overflow-x-auto">
        <table class="min-w-full text-sm">
            <thead class="bg-blue-600 text-white">
                <tr>
                    <th class="px-4 py-3 text-left">ID</th>
                    <th class="px-4 py-3 text-left">Customer</th>
                    <th class="px-4 py-3 text-left">Email</th>
                    <th class="px-4 py-3 text-left">Vehicle</th>
                    <th class="px-4 py-3 text-left">Start</th>
                    <th class="px-4 py-3 text-left">End</th>
                    <th class="px-4 py-3 text-left">Pickup</th>
                    <th class="px-4 py-3 text-left">Dropoff</th>
                    <th class="px-4 py-3 text-left">Total</th>
                    <th class="px-4 py-3 text-left">Status</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
            <%
                Connection con = null; PreparedStatement pst = null; ResultSet rs = null;
                try {
                    con = DBUtil.getConnection();
                    // Uses the view_rental_details view from new schema
                    pst = con.prepareStatement(
                        "SELECT id, customer_name, customer_email, brand, model, " +
                        "start_date, end_date, pickup_location, dropoff_location, " +
                        "total_price, status FROM view_rental_details ORDER BY id DESC");
                    rs = pst.executeQuery();
                    while (rs.next()) {
                        String status = rs.getString("status");
                        String statusClass =
                            "Approved".equals(status)  ? "bg-green-100 text-green-800" :
                            "Rejected".equals(status)  ? "bg-red-100 text-red-800" :
                            "Completed".equals(status) ? "bg-blue-100 text-blue-800" :
                                                         "bg-yellow-100 text-yellow-800";
            %>
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-2 font-mono">#<%= rs.getInt("id") %></td>
                    <td class="px-4 py-2 font-medium"><%= rs.getString("customer_name") %></td>
                    <td class="px-4 py-2 text-gray-500 text-xs"><%= rs.getString("customer_email") %></td>
                    <td class="px-4 py-2"><%= rs.getString("brand") %> <%= rs.getString("model") %></td>
                    <td class="px-4 py-2"><%= rs.getDate("start_date") %></td>
                    <td class="px-4 py-2"><%= rs.getDate("end_date") %></td>
                    <td class="px-4 py-2 text-xs"><%= rs.getString("pickup_location") != null ? rs.getString("pickup_location") : "—" %></td>
                    <td class="px-4 py-2 text-xs"><%= rs.getString("dropoff_location") != null ? rs.getString("dropoff_location") : "—" %></td>
                    <td class="px-4 py-2 font-semibold text-green-700">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
                    <td class="px-4 py-2">
                        <span class="px-2 py-1 rounded-full text-xs font-medium <%= statusClass %>">
                            <%= status %>
                        </span>
                    </td>
                </tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<tr><td colspan='10' class='px-4 py-4 text-red-600 text-center'>Error: " + e.getMessage() + "</td></tr>");
                } finally {
                    DBUtil.close(rs, pst, con);
                }
            %>
            </tbody>
        </table>
        </div>
    </div>

    <div class="flex justify-center gap-4 mt-8">
        <a href="admin_dashboard.jsp"
           class="bg-blue-600 text-white px-6 py-2 rounded-full hover:bg-blue-700 transition">
            Back to Dashboard
        </a>
    </div>

</div>
</body>
</html>
