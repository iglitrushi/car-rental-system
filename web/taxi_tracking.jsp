<%@ page import="java.sql.*" %>
<%@ page import="model.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Must be logged in as customer
    if (session.getAttribute("user") == null) {
        response.sendRedirect("index.html");
        return;
    }
    Integer userId = (Integer) session.getAttribute("userId");

    // Find the customer's most recent active taxi booking that has an assigned car
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    int    bookingId     = 0;
    int    fleetId       = 0;
    String carBrand      = null;
    String carModel      = null;
    String pickupAddr    = null;
    String dropoffAddr   = null;
    String bookingStatus = null;
    String gpsDeviceId   = null;
    boolean hasBooking   = false;

    try {
        con = DBUtil.getConnection();
        pst = con.prepareStatement(
            "SELECT tb.id, tb.fleet_id, tb.pickup_address, tb.dropoff_address, tb.status, " +
            "f.brand, f.model, f.gps_device_id " +
            "FROM taxi_bookings tb " +
            "LEFT JOIN fleet f ON tb.fleet_id = f.id " +
            "WHERE tb.user_id = ? AND tb.status IN ('Assigned','InProgress') " +
            "ORDER BY tb.created_at DESC LIMIT 1"
        );
        pst.setInt(1, userId);
        rs = pst.executeQuery();

        if (rs.next()) {
            hasBooking   = true;
            bookingId    = rs.getInt("id");
            fleetId      = rs.getInt("fleet_id");
            carBrand     = rs.getString("brand");
            carModel     = rs.getString("model");
            pickupAddr   = rs.getString("pickup_address");
            dropoffAddr  = rs.getString("dropoff_address");
            bookingStatus= rs.getString("status");
            gpsDeviceId  = rs.getString("gps_device_id");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        DBUtil.close(rs, pst, con);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Track Your Taxi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
    <style>
        #map { height: 380px; border-radius: 12px; }
        @keyframes pulse {
            from { opacity: 1; }
            to   { opacity: 0.4; }
        }
        .pulsing { animation: pulse 1.5s ease-in-out infinite alternate; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">
<div class="max-w-2xl mx-auto px-4 py-8">

<% if (!hasBooking) { %>
    <!-- No active booking -->
    <div class="bg-white shadow-xl rounded-2xl p-10 text-center">
        <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
        </div>
        <h2 class="text-xl font-bold text-gray-700 mb-2">No active taxi booking</h2>
        <p class="text-gray-400 mb-6">You don't have an assigned taxi ride right now.</p>
        <a href="taxi_booking.jsp"
           class="bg-teal-600 text-white px-6 py-2 rounded-full hover:bg-teal-700 transition font-semibold">
            Book a Taxi
        </a>
    </div>

<% } else { %>
    <!-- Active booking header -->
    <div class="bg-white shadow-xl rounded-2xl p-6 mb-4">
        <div class="flex items-center justify-between mb-4">
            <div>
                <h2 class="text-xl font-bold text-gray-800">Your Taxi is on the way</h2>
                <p class="text-gray-500 text-sm">Booking #<%= bookingId %></p>
            </div>
            <span class="px-3 py-1 rounded-full text-sm font-semibold
                <%= "InProgress".equals(bookingStatus) ? "bg-green-100 text-green-800" : "bg-amber-100 text-amber-800" %>
                flex items-center gap-1">
                <span class="pulsing inline-block w-2 h-2 rounded-full
                    <%= "InProgress".equals(bookingStatus) ? "bg-green-500" : "bg-amber-500" %>"></span>
                <%= "InProgress".equals(bookingStatus) ? "In progress" : "Driver assigned" %>
            </span>
        </div>

        <!-- Trip info -->
        <div class="space-y-2 text-sm mb-4">
            <div class="flex gap-3 items-start">
                <div class="w-3 h-3 rounded-full bg-green-500 mt-1 flex-shrink-0"></div>
                <div>
                    <p class="text-gray-400 text-xs">Pickup</p>
                    <p class="font-medium text-gray-700"><%= pickupAddr %></p>
                </div>
            </div>
            <div class="ml-1.5 w-0.5 h-4 bg-gray-200 ml-2"></div>
            <div class="flex gap-3 items-start">
                <div class="w-3 h-3 rounded-full bg-red-500 mt-1 flex-shrink-0"></div>
                <div>
                    <p class="text-gray-400 text-xs">Dropoff</p>
                    <p class="font-medium text-gray-700"><%= dropoffAddr %></p>
                </div>
            </div>
        </div>

        <!-- Car info -->
        <div class="bg-amber-50 rounded-xl p-3 flex items-center gap-3">
            <div class="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-amber-600" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z"/>
                    <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1v-1h3a1 1 0 00.894-.553l2-4A1 1 0 0016 8h-1V7a1 1 0 00-1-1h-3.382l-.724-1.447A1 1 0 009 4H3z"/>
                </svg>
            </div>
            <div>
                <p class="font-semibold text-gray-800"><%= carBrand %> <%= carModel %></p>
                <p class="text-xs text-gray-500">GPS ID: <%= gpsDeviceId != null ? gpsDeviceId : "Not configured yet" %></p>
            </div>
            <div class="ml-auto text-right">
                <p class="text-xs text-gray-400">Speed</p>
                <p class="font-bold text-gray-700" id="speedDisplay">— km/h</p>
            </div>
        </div>
    </div>

    <!-- Live map -->
    <div class="bg-white shadow-xl rounded-2xl p-4 mb-4">
        <div class="flex items-center justify-between mb-2">
            <p class="text-sm font-medium text-gray-700">Live location</p>
            <p class="text-xs text-gray-400">
                Updates every 10s &nbsp;|&nbsp; Last: <span id="lastUpdate">—</span>
            </p>
        </div>
        <div id="map"></div>
        <% if (gpsDeviceId == null) { %>
        <div class="mt-3 bg-amber-50 border border-amber-200 rounded-lg px-4 py-2 text-sm text-amber-700">
            GPS tracker not yet configured for this vehicle. Live tracking will appear once the device is set up.
        </div>
        <% } %>
    </div>

    <!-- Back button -->
    <div class="text-center">
        <a href="Home.jsp"
           class="bg-gray-200 text-gray-700 px-6 py-2 rounded-full hover:bg-gray-300 transition text-sm">
            Back to menu
        </a>
    </div>

<% } // end hasBooking %>

</div>

<% if (hasBooking) { %>
<script>
    const FLEET_ID = <%= fleetId %>;
    const HAS_GPS  = <%= gpsDeviceId != null ? "true" : "false" %>;

    // Map centered on Tirana — will jump to car position on first data
    const map = L.map('map').setView([41.3275, 19.8187], 14);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    // Pickup marker (green)
    L.marker([41.3275, 19.8187], {
        icon: L.divIcon({
            className: '',
            html: '<div style="background:#16a34a;width:14px;height:14px;border-radius:50%;border:2px solid white;box-shadow:0 1px 4px rgba(0,0,0,.3)"></div>',
            iconSize: [14,14]
        })
    }).addTo(map).bindPopup('<b>Your pickup point</b><br><%= pickupAddr %>');

    let carMarker   = null;
    let firstUpdate = true;

    function makeCarIcon() {
        return L.divIcon({
            className: '',
            html: `<div style="background:#d97706;width:18px;height:18px;border-radius:50%;
                   border:3px solid white;box-shadow:0 2px 6px rgba(0,0,0,.4)"></div>`,
            iconSize:  [18,18],
            iconAnchor:[9,9]
        });
    }

    function refreshPosition() {
        if (!HAS_GPS) return;

        fetch('GetFleetPositionsServlet')
            .then(r => r.json())
            .then(data => {
                const car = data.find(v => v.fleetId === FLEET_ID);
                if (!car || !car.hasGps) return;

                const latlng = [car.lat, car.lng];

                if (carMarker) {
                    carMarker.setLatLng(latlng);
                } else {
                    carMarker = L.marker(latlng, { icon: makeCarIcon() })
                        .addTo(map)
                        .bindPopup(`<b>Your taxi</b><br>${car.brand} ${car.model}<br>Speed: ${car.speed.toFixed(0)} km/h`);
                }

                if (firstUpdate) {
                    map.setView(latlng, 15);
                    firstUpdate = false;
                }

                document.getElementById('speedDisplay').textContent = car.speed.toFixed(0) + ' km/h';

                const now = new Date();
                document.getElementById('lastUpdate').textContent =
                    now.getHours().toString().padStart(2,'0') + ':' +
                    now.getMinutes().toString().padStart(2,'0') + ':' +
                    now.getSeconds().toString().padStart(2,'0');
            })
            .catch(err => console.error('Tracking error:', err));
    }

    refreshPosition();
    setInterval(refreshPosition, 10000);
</script>
<% } %>
</body>
</html>
