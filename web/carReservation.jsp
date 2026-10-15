<%@ page import="java.sql.*" %>
<%@ page import="model.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Make a Reservation</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
    <style>
        #map { height: 260px; border-radius: 8px; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen py-8">
<div class="max-w-2xl mx-auto px-4">
<div class="bg-white shadow-xl rounded-2xl p-8">

    <h2 class="text-2xl font-bold text-center text-blue-700 mb-1">Reserve a Car</h2>
    <p class="text-center text-gray-400 text-sm mb-6">Fill in your details and pick-up/drop-off points</p>

    <% String error = (String) request.getAttribute("error");
       if (error != null) { %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4"><%= error %></div>
    <% } %>

    <form action="ReservationServlet" method="post" class="space-y-4">

        <!-- Personal info -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Full name</label>
                <input type="text" name="name" required
                       value="<%= session.getAttribute("firstName") != null ? session.getAttribute("firstName") : "" %>"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input type="email" name="email" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400">
            </div>
        </div>

        <!-- Car selection -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Select vehicle</label>
            <select name="carId" required
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400">
                <option value="">-- Choose a car --</option>
                <%
                    // Pre-select if coming from search results
                    String preselected = request.getParameter("carId");

                    Connection con = null; PreparedStatement pst = null; ResultSet rs = null;
                    try {
                        con = DBUtil.getConnection();
                        pst = con.prepareStatement(
                            "SELECT id, brand, model, year, price_per_day, fuel " +
                            "FROM fleet WHERE available = 1 AND type IN ('rental','both') ORDER BY brand, model");
                        rs = pst.executeQuery();
                        while (rs.next()) {
                            String selected = String.valueOf(rs.getInt("id")).equals(preselected) ? "selected" : "";
                %>
                    <option value="<%= rs.getInt("id") %>" <%= selected %>>
                        <%= rs.getString("brand") %> <%= rs.getString("model") %>
                        (<%= rs.getInt("year") %>) — $<%= rs.getDouble("price_per_day") %>/day — <%= rs.getString("fuel") %>
                    </option>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<option value=''>Error loading cars</option>");
                    } finally {
                        DBUtil.close(rs, pst, con);
                    }
                %>
            </select>
        </div>

        <!-- Dates -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Start date</label>
                <input type="date" name="startDate" id="startDate" required
                       min="<%= java.time.LocalDate.now() %>"
                       onchange="updateMinEnd()"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">End date</label>
                <input type="date" name="endDate" id="endDate" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400">
            </div>
        </div>

        <!-- Pickup / Dropoff addresses (Point A → Point B) -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Pickup location <span class="text-gray-400 font-normal text-xs">(Point A — where you take the car)</span>
            </label>
            <input type="text" name="pickupLocation" id="pickupLocation"
                   placeholder="e.g. Aeroporti Nënë Tereza, Tiranë"
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400">
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Dropoff location <span class="text-gray-400 font-normal text-xs">(Point B — where you leave the car)</span>
            </label>
            <input type="text" name="dropoffLocation" id="dropoffLocation"
                   placeholder="e.g. Hotel Tirana International"
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-400">
        </div>

        <!-- Optional map to pin A and B -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Or pin on map
                <span class="text-xs text-gray-400 font-normal ml-1">(first click = pickup A, second = dropoff B)</span>
            </label>
            <div id="map"></div>
            <div class="flex gap-6 mt-2 text-xs text-gray-500">
                <span><span class="inline-block w-2.5 h-2.5 rounded-full bg-green-500 mr-1"></span>A: <span id="aLabel">not set</span></span>
                <span><span class="inline-block w-2.5 h-2.5 rounded-full bg-red-500 mr-1"></span>B: <span id="bLabel">not set</span></span>
            </div>
        </div>

        <button type="submit"
            class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg transition text-lg">
            Confirm Reservation
        </button>
    </form>
</div>

<div class="text-center mt-4">
    <a href="Home.jsp" class="text-gray-500 hover:text-gray-700 text-sm">Back to menu</a>
</div>
</div>

<script>
    function updateMinEnd() {
        const s = document.getElementById('startDate').value;
        const e = document.getElementById('endDate');
        e.min = s;
        if (e.value && e.value < s) e.value = s;
    }

    const map = L.map('map').setView([41.3275, 19.8187], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    let markerA = null, markerB = null, clicks = 0;

    function pinIcon(color) {
        return L.divIcon({
            className: '',
            html: `<div style="background:${color};width:14px;height:14px;border-radius:50%;border:2.5px solid white;box-shadow:0 1px 4px rgba(0,0,0,.3)"></div>`,
            iconSize: [14,14]
        });
    }

    map.on('click', function(e) {
        const lat = e.latlng.lat.toFixed(6);
        const lng = e.latlng.lng.toFixed(6);
        clicks++;
        if (clicks % 2 === 1) {
            if (markerA) map.removeLayer(markerA);
            markerA = L.marker([lat,lng], { icon: pinIcon('#16a34a') }).addTo(map).bindPopup('Pickup A').openPopup();
            document.getElementById('pickupLocation').value = lat + ', ' + lng;
            document.getElementById('aLabel').textContent = lat + ', ' + lng;
        } else {
            if (markerB) map.removeLayer(markerB);
            markerB = L.marker([lat,lng], { icon: pinIcon('#dc2626') }).addTo(map).bindPopup('Dropoff B').openPopup();
            document.getElementById('dropoffLocation').value = lat + ', ' + lng;
            document.getElementById('bLabel').textContent = lat + ', ' + lng;
        }
    });
</script>
</body>
</html>
