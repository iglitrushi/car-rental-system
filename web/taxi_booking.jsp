<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book a Taxi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Leaflet for pickup/dropoff map selection -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
    <style>
        #map { height: 280px; border-radius: 8px; }
        .pin-label { font-size: 11px; color: #374151; margin-top: 2px; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen py-8">
<div class="max-w-2xl mx-auto px-4">

    <div class="bg-white shadow-xl rounded-2xl p-8">
        <h2 class="text-2xl font-bold text-center text-teal-700 mb-1">Book a Taxi</h2>
        <p class="text-center text-gray-500 text-sm mb-6">Immediate or scheduled — we will get you there</p>

        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                <%= error %>
            </div>
        <% } %>

        <form action="TaxiBookingServlet" method="post" class="space-y-4">

            <!-- Booking type toggle -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Booking type</label>
                <div class="flex gap-3">
                    <label class="flex items-center gap-2 cursor-pointer">
                        <input type="radio" name="bookingType" value="immediate" checked
                               onchange="toggleScheduled(false)"
                               class="accent-teal-600">
                        <span class="text-sm font-medium">Immediate (now)</span>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer">
                        <input type="radio" name="bookingType" value="scheduled"
                               onchange="toggleScheduled(true)"
                               class="accent-teal-600">
                        <span class="text-sm font-medium">Schedule in advance</span>
                    </label>
                </div>
            </div>

            <!-- Scheduled time (hidden until "scheduled" selected) -->
            <div id="scheduledDiv" class="hidden">
                <label class="block text-sm font-medium text-gray-700 mb-1">Pickup date &amp; time</label>
                <input type="datetime-local" name="scheduledTime" id="scheduledTime"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-teal-400">
            </div>

            <!-- Customer info -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Your name</label>
                    <input type="text" name="customerName" required
                           value="<%= session.getAttribute("firstName") != null ? session.getAttribute("firstName") : "" %>"
                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-teal-400">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Phone number</label>
                    <input type="tel" name="customerPhone" required placeholder="+355..."
                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-teal-400">
                </div>
            </div>

            <!-- Address fields -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Pickup address</label>
                <input type="text" name="pickupAddress" id="pickupAddress" required
                       placeholder="e.g. Rruga Myslym Shyri, Tiranë"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-teal-400">
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Dropoff address</label>
                <input type="text" name="dropoffAddress" id="dropoffAddress" required
                       placeholder="e.g. Aeroporti Nënë Tereza"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-teal-400">
            </div>

            <!-- Hidden GPS coordinates populated by map clicks -->
            <input type="hidden" name="pickupLat"  id="pickupLat">
            <input type="hidden" name="pickupLng"  id="pickupLng">
            <input type="hidden" name="dropoffLat" id="dropoffLat">
            <input type="hidden" name="dropoffLng" id="dropoffLng">

            <!-- Map: click to set pickup (green) and dropoff (red) pins -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Pin locations on map
                    <span class="text-xs text-gray-400 font-normal ml-2">(first click = pickup, second = dropoff)</span>
                </label>
                <div id="map"></div>
                <div class="flex gap-6 mt-2">
                    <span class="pin-label">
                        <span class="inline-block w-3 h-3 rounded-full bg-green-500 mr-1"></span>
                        Pickup: <span id="pickupCoords">not set</span>
                    </span>
                    <span class="pin-label">
                        <span class="inline-block w-3 h-3 rounded-full bg-red-500 mr-1"></span>
                        Dropoff: <span id="dropoffCoords">not set</span>
                    </span>
                </div>
            </div>

            <button type="submit"
                class="w-full bg-teal-600 hover:bg-teal-700 text-white font-semibold py-3 rounded-lg transition text-lg">
                Request Taxi
            </button>
        </form>
    </div>

    <div class="text-center mt-6">
        <a href="Home.jsp" class="text-gray-500 hover:text-gray-700 text-sm">Back to menu</a>
    </div>
</div>

<script>
    // Tirana center as default map view
    const map = L.map('map').setView([41.3275, 19.8187], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    let pickupMarker = null;
    let dropoffMarker = null;
    let clickCount = 0;

    map.on('click', function(e) {
        const lat = e.latlng.lat.toFixed(6);
        const lng = e.latlng.lng.toFixed(6);
        clickCount++;

        if (clickCount % 2 === 1) {
            // Odd click = pickup (green)
            if (pickupMarker) map.removeLayer(pickupMarker);
            pickupMarker = L.marker([lat, lng], {
                icon: L.divIcon({
                    className: '',
                    html: '<div style="background:#16a34a;width:14px;height:14px;border-radius:50%;border:2px solid white;"></div>',
                    iconSize: [14, 14]
                })
            }).addTo(map).bindPopup('Pickup').openPopup();
            document.getElementById('pickupLat').value = lat;
            document.getElementById('pickupLng').value = lng;
            document.getElementById('pickupCoords').textContent = lat + ', ' + lng;
        } else {
            // Even click = dropoff (red)
            if (dropoffMarker) map.removeLayer(dropoffMarker);
            dropoffMarker = L.marker([lat, lng], {
                icon: L.divIcon({
                    className: '',
                    html: '<div style="background:#dc2626;width:14px;height:14px;border-radius:50%;border:2px solid white;"></div>',
                    iconSize: [14, 14]
                })
            }).addTo(map).bindPopup('Dropoff').openPopup();
            document.getElementById('dropoffLat').value = lat;
            document.getElementById('dropoffLng').value = lng;
            document.getElementById('dropoffCoords').textContent = lat + ', ' + lng;
        }
    });

    function toggleScheduled(show) {
        const div = document.getElementById('scheduledDiv');
        const input = document.getElementById('scheduledTime');
        div.classList.toggle('hidden', !show);
        input.required = show;
    }
</script>
</body>
</html>
