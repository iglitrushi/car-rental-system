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
    <title>Admin Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<div class="container mx-auto p-6 max-w-6xl">

    <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-800">Admin Dashboard</h1>
        <p class="text-gray-500 text-sm mt-1">Logged in as: <%= session.getAttribute("user") %></p>
    </div>

    <!-- Quick nav buttons -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <a href="adminReservationCheck.jsp"
           class="bg-green-500 hover:bg-green-600 text-white font-semibold py-3 px-4 rounded-lg text-center transition">
            Rental Approvals
        </a>
        <a href="admin_taxi.jsp"
           class="bg-teal-500 hover:bg-teal-600 text-white font-semibold py-3 px-4 rounded-lg text-center transition">
            Taxi Bookings
        </a>
        <a href="ReservationHistory"
           class="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-3 px-4 rounded-lg text-center transition">
            Booking History
        </a>
        <a href="fleet_map.jsp"
           class="bg-purple-500 hover:bg-purple-600 text-white font-semibold py-3 px-4 rounded-lg text-center transition">
            Live Fleet Map
        </a>
        <a href="CarAvailability"
           class="bg-gray-500 hover:bg-gray-600 text-white font-semibold py-3 px-4 rounded-lg text-center transition">
            Calendar View
        </a>
        <a href="emailform.jsp"
           class="bg-orange-500 hover:bg-orange-600 text-white font-semibold py-3 px-4 rounded-lg text-center transition">
            Send Email
        </a>
        <a href="LogOutServlet"
           class="bg-red-500 hover:bg-red-600 text-white font-semibold py-3 px-4 rounded-lg text-center transition">
            Logout
        </a>
    </div>

    <!-- Status messages -->
    <% String ok = (String)request.getAttribute("successMessage");
       String err= (String)request.getAttribute("errorMessage");
       if (ok  != null) { %><div class="bg-green-100 border border-green-400 text-green-800 p-3 rounded mb-4"><%= ok %></div><% } %>
    <% if (err != null) { %><div class="bg-red-100 border border-red-400 text-red-800 p-3 rounded mb-4"><%= err %></div><% } %>

    <!-- Fleet table -->
    <div class="bg-white p-6 shadow-md rounded-lg mb-8">
        <h2 class="text-xl font-semibold mb-4 text-gray-700">Current Fleet</h2>
        <div class="overflow-x-auto">
        <table class="min-w-full text-sm">
            <thead class="bg-gray-100 text-gray-600 uppercase">
                <tr>
                    <th class="px-4 py-3 text-left">ID</th>
                    <th class="px-4 py-3 text-left">Brand</th>
                    <th class="px-4 py-3 text-left">Model</th>
                    <th class="px-4 py-3 text-left">Year</th>
                    <th class="px-4 py-3 text-left">Price/day</th>
                    <th class="px-4 py-3 text-left">Type</th>
                    <th class="px-4 py-3 text-left">Status</th>
                    <th class="px-4 py-3 text-left">GPS Device ID</th>
                    <th class="px-4 py-3 text-left">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
            <%
                Connection con = null; PreparedStatement pst = null; ResultSet rs = null;
                try {
                    con = DBUtil.getConnection();
                    pst = con.prepareStatement(
                        "SELECT id, brand, model, year, price_per_day, type, available, gps_device_id FROM fleet ORDER BY id");
                    rs = pst.executeQuery();
                    while (rs.next()) {
                        int    fid   = rs.getInt("id");
                        String gpsId = rs.getString("gps_device_id");
                        boolean avail= rs.getInt("available") == 1;
            %>
                <tr class="hover:bg-gray-50">
                    <td class="px-4 py-2"><%= fid %></td>
                    <td class="px-4 py-2 font-medium"><%= rs.getString("brand") %></td>
                    <td class="px-4 py-2"><%= rs.getString("model") %></td>
                    <td class="px-4 py-2"><%= rs.getInt("year") %></td>
                    <td class="px-4 py-2 text-blue-700 font-semibold">$<%= rs.getDouble("price_per_day") %></td>
                    <td class="px-4 py-2">
                        <span class="px-2 py-1 rounded-full text-xs font-medium
                            <%= "taxi".equals(rs.getString("type")) ? "bg-teal-100 text-teal-800" :
                               "both".equals(rs.getString("type")) ? "bg-purple-100 text-purple-800" :
                               "bg-blue-100 text-blue-800" %>">
                            <%= rs.getString("type") %>
                        </span>
                    </td>
                    <td class="px-4 py-2">
                        <span class="px-2 py-1 rounded-full text-xs font-medium
                            <%= avail ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800" %>">
                            <%= avail ? "Available" : "Unavailable" %>
                        </span>
                    </td>
                    <td class="px-4 py-2 font-mono text-xs">
                        <%= gpsId != null ? gpsId : "<span class='text-gray-400 italic'>not set</span>" %>
                    </td>
                    <td class="px-4 py-2">
                        <!-- Set GPS device ID inline form -->
                        <form action="AdminServlet" method="post" class="flex gap-1 items-center">
                            <input type="hidden" name="action" value="updateGps">
                            <input type="hidden" name="fleetId" value="<%= fid %>">
                            <input type="text" name="gpsDeviceId"
                                   placeholder="e.g. CAR00<%= fid %>"
                                   class="border rounded px-2 py-1 text-xs w-28">
                            <button type="submit"
                                class="bg-amber-500 text-white px-2 py-1 rounded text-xs hover:bg-amber-600">
                                Set GPS
                            </button>
                        </form>
                    </td>
                </tr>
            <%
                    }
                } catch(Exception e) { e.printStackTrace(); }
                finally { DBUtil.close(rs, pst, con); }
            %>
            </tbody>
        </table>
        </div>
    </div>

    <!-- Add new vehicle form -->
    <div class="bg-white p-6 shadow-md rounded-lg">
        <h2 class="text-xl font-semibold mb-4 text-gray-700">Add New Vehicle</h2>
        <form action="AdminServlet" method="post" class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input type="hidden" name="action" value="addCar">

            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Brand</label>
                <input type="text" name="brand" required class="w-full px-3 py-2 border rounded-md">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Model</label>
                <input type="text" name="model" required class="w-full px-3 py-2 border rounded-md">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Cubic (cc)</label>
                <input type="number" name="cubic" class="w-full px-3 py-2 border rounded-md">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Year</label>
                <input type="number" name="year" required class="w-full px-3 py-2 border rounded-md">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Fuel</label>
                <select name="fuel" class="w-full px-3 py-2 border rounded-md">
                    <option>Petrol</option><option>Diesel</option>
                    <option>Electric</option><option>Hybrid</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Transmission</label>
                <select name="transmission" class="w-full px-3 py-2 border rounded-md">
                    <option>Automatic</option><option>Manual</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Vehicle Type</label>
                <select name="type" class="w-full px-3 py-2 border rounded-md">
                    <option value="rental">Rental only</option>
                    <option value="taxi">Taxi only</option>
                    <option value="both">Both</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Availability</label>
                <select name="availability" class="w-full px-3 py-2 border rounded-md">
                    <option value="1">Available</option>
                    <option value="0">Not Available</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">Price per day ($)</label>
                <input type="number" step="0.01" name="price" required class="w-full px-3 py-2 border rounded-md">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">GPS Device ID (optional)</label>
                <input type="text" name="gpsDeviceId" placeholder="e.g. CAR013"
                       class="w-full px-3 py-2 border rounded-md">
            </div>

            <div class="md:col-span-2">
                <button type="submit"
                    class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-semibold transition">
                    Add Vehicle to Fleet
                </button>
            </div>
        </form>
    </div>

</div>
</body>
</html>
