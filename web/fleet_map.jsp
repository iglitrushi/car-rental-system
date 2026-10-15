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
    <title>Live Fleet Map</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
    <style>
        #map { height: calc(100vh - 260px); min-height: 380px; border-radius: 12px; }
        @keyframes blink { from{opacity:1} to{opacity:.3} }
        .moving-dot { animation: blink 1.2s ease-in-out infinite; }
    </style>
</head>
<body class="bg-gray-100">
<div class="p-4 max-w-7xl mx-auto">

    <div class="flex items-center justify-between mb-3 flex-wrap gap-2">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">Live Fleet Map</h1>
            <p class="text-gray-500 text-sm">
                Auto-refreshes every 10s &nbsp;|&nbsp;
                Last update: <span id="lastUpdate" class="font-medium text-gray-700">Loading...</span>
                <span id="refreshBadge" class="ml-2 text-xs font-semibold text-green-600"
                      style="opacity:0;transition:opacity .3s">&#10003; Updated</span>
            </p>
        </div>
        <div class="flex gap-2 flex-wrap">
            <button onclick="filterMap('all')"    id="btn-all"
                class="px-3 py-1.5 rounded-full text-sm font-medium bg-gray-700 text-white">All</button>
            <button onclick="filterMap('rental')" id="btn-rental"
                class="px-3 py-1.5 rounded-full text-sm font-medium bg-blue-600 text-white" style="opacity:.6">Rentals</button>
            <button onclick="filterMap('taxi')"   id="btn-taxi"
                class="px-3 py-1.5 rounded-full text-sm font-medium bg-amber-500 text-white" style="opacity:.6">Taxis</button>
            <a href="admin_dashboard.jsp"
               class="px-3 py-1.5 rounded-full text-sm font-medium bg-gray-200 text-gray-700 hover:bg-gray-300">Dashboard</a>
        </div>
    </div>

    <div id="map"></div>

    <div class="mt-2 flex gap-5 text-xs text-gray-400 flex-wrap items-center">
        <span><span style="display:inline-block;width:12px;height:12px;border-radius:50%;background:#2563eb;margin-right:4px;vertical-align:middle"></span>Rental</span>
        <span><span style="display:inline-block;width:12px;height:12px;border-radius:50%;background:#d97706;margin-right:4px;vertical-align:middle"></span>Taxi</span>
        <span><span style="display:inline-block;width:12px;height:12px;border-radius:50%;background:#7c3aed;margin-right:4px;vertical-align:middle"></span>Both</span>
        <span class="ml-auto">Albania time (UTC+2) &nbsp;|&nbsp; Click pin for details</span>
    </div>

    <div class="mt-3 bg-white rounded-xl shadow p-4">
        <h2 class="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-3">GPS Tracked Vehicles</h2>
        <div class="overflow-x-auto">
            <table class="min-w-full text-sm">
                <thead class="bg-gray-50 text-gray-500 text-xs uppercase">
                    <tr>
                        <th class="px-3 py-2 text-left">Vehicle</th>
                        <th class="px-3 py-2 text-left">Status</th>
                        <th class="px-3 py-2 text-left">GPS Device ID</th>
                        <th class="px-3 py-2 text-left">Latitude</th>
                        <th class="px-3 py-2 text-left">Longitude</th>
                        <th class="px-3 py-2 text-left">Speed</th>
                        <!-- Odometer hidden until correct field identified -->
                        <th class="px-3 py-2 text-left">Last Ping (Albania)</th>
                        <th class="px-3 py-2 text-left">Type</th>
                        <th class="px-3 py-2 text-left">Action</th>
                    </tr>
                </thead>
                <tbody id="fleetTableBody">
                    <tr><td colspan="10" class="px-3 py-4 text-center text-gray-400">Loading...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
const map = L.map('map').setView([41.3275, 19.8187], 12);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom: 19
}).addTo(map);

const markers = {};
let currentFilter = 'all';
let firstLoad = true;

// Moving car: larger pulsing icon. Static: normal solid icon.
function makeIcon(type, moving) {
    const colors = {rental:'#2563eb', taxi:'#d97706', both:'#7c3aed'};
    const c = colors[type] || '#6b7280';
    const size = moving ? 22 : 18;
    const pulse = moving
        ? 'box-shadow:0 0 0 4px ' + c + '44;animation:blink 1.2s ease-in-out infinite;'
        : 'box-shadow:0 2px 8px rgba(0,0,0,0.4);';
    return L.divIcon({
        className: '',
        html: '<div style="background:' + c + ';width:' + size + 'px;height:' + size + 'px;' +
              'border-radius:50%;border:3px solid white;' + pulse + '"></div>',
        iconSize: [size, size],
        iconAnchor: [size/2, size/2]
    });
}

function safe(v) {
    return (v===null||v===undefined||v==='null'||v===false||v==='') ? '—' : String(v);
}
function flt(v, d) {
    const f = parseFloat(v);
    return isNaN(f) ? '—' : f.toFixed(d);
}

function buildPopup(v) {
    const moving  = parseFloat(v.speed) > 2;
    const statusHtml = moving
        ? '<span style="color:#16a34a;font-weight:700">&#9679; Moving</span>'
        : '<span style="color:#9ca3af;font-weight:600">&#9679; Static</span>';
    const km = (v.odometerKm && v.odometerKm > 0)
        ? Number(v.odometerKm).toLocaleString() + ' km' : '—';
    const sColor = moving ? '#16a34a' : '#9ca3af';

    return '<div style="min-width:220px;font-family:sans-serif;font-size:13px">' +
        '<div style="font-weight:700;font-size:15px;margin-bottom:3px">' +
            v.brand + ' ' + v.model + '</div>' +
        '<div style="margin-bottom:6px">' + statusHtml + '</div>' +
        '<div style="font-size:11px;color:#9ca3af;margin-bottom:6px">GPS ID: ' +
            safe(v.gpsDeviceId) + '</div>' +
        '<hr style="margin:5px 0;border-color:#f3f4f6">' +
        '<table style="width:100%;border-collapse:collapse;font-size:12px">' +
        '<tr><td style="color:#6b7280;padding:3px 0;width:50%">Speed</td>' +
            '<td style="font-weight:700;text-align:right;color:' + sColor + '">' +
            flt(v.speed, 0) + ' km/h</td></tr>' +
        '<tr><td style="color:#6b7280;padding:3px 0">Latitude</td>' +
            '<td style="font-weight:600;text-align:right;font-family:monospace">' +
            flt(v.lat, 6) + '</td></tr>' +
        '<tr><td style="color:#6b7280;padding:3px 0">Longitude</td>' +
            '<td style="font-weight:600;text-align:right;font-family:monospace">' +
            flt(v.lng, 6) + '</td></tr>' +
        /* odometer hidden */ '' +
        '<tr><td style="color:#6b7280;padding:3px 0">Last ping</td>' +
            '<td style="font-weight:600;text-align:right;font-size:11px">' +
            safe(v.recordedAt) + '</td></tr>' +
        '<tr><td style="color:#6b7280;padding:3px 0">Type</td>' +
            '<td style="font-weight:600;text-align:right;text-transform:capitalize">' +
            safe(v.type) + '</td></tr>' +
        '</table></div>';
}

function updateMarkers(data) {
    const ids = new Set(data.map(v => v.fleetId));
    for (const id in markers) {
        if (!ids.has(parseInt(id))) { map.removeLayer(markers[id]); delete markers[id]; }
    }

    if (firstLoad && data.length > 0) {
        firstLoad = false;
        if (data.length === 1) {
            map.setView([data[0].lat, data[0].lng], 15);
        } else {
            map.fitBounds(data.map(v => [v.lat, v.lng]), {padding:[50,50]});
        }
    }

    data.forEach(v => {
        if (!v.lat || !v.lng) return;
        const moving = parseFloat(v.speed) > 2;
        const popup  = buildPopup(v);
        if (markers[v.fleetId]) {
            markers[v.fleetId].setLatLng([v.lat, v.lng]);
            markers[v.fleetId].setPopupContent(popup);
            markers[v.fleetId].setIcon(makeIcon(v.type, moving));
        } else {
            markers[v.fleetId] = L.marker([v.lat, v.lng], {icon: makeIcon(v.type, moving)})
                .addTo(map).bindPopup(popup);
        }
    });
}

function updateTable(data) {
    const tbody = document.getElementById('fleetTableBody');
    if (!data.length) {
        tbody.innerHTML = '<tr><td colspan="10" class="px-3 py-6 text-center text-gray-400">' +
            'No GPS-tracked vehicles found.<br>' +
            '<span class="text-xs">Set gps_device_id in Admin Dashboard and ensure poller is running.</span>' +
            '</td></tr>';
        return;
    }

    const typeBadge = {
        rental: 'bg-blue-100 text-blue-800',
        taxi:   'bg-amber-100 text-amber-800',
        both:   'bg-purple-100 text-purple-800'
    };

    tbody.innerHTML = data.map(v => {
        const moving   = parseFloat(v.speed) > 2;
        const statusEl = moving
            ? '<span class="flex items-center gap-1 text-green-600 font-semibold">' +
              '<span class="moving-dot inline-block w-2 h-2 rounded-full bg-green-500"></span>Moving</span>'
            : '<span class="flex items-center gap-1 text-gray-400">' +
              '<span class="inline-block w-2 h-2 rounded-full bg-gray-300"></span>Static</span>';
        const sCl   = moving ? 'text-green-600 font-bold' : 'text-gray-400';
        const km    = (v.odometerKm && v.odometerKm > 0)
                      ? Number(v.odometerKm).toLocaleString() + ' km' : '—';
        const ping  = (v.recordedAt && v.recordedAt !== '')
                      ? v.recordedAt.substring(0, 19) : '—';
        const bc    = typeBadge[v.type] || 'bg-gray-100 text-gray-600';

        return '<tr class="hover:bg-gray-50 border-b border-gray-50">' +
            '<td class="px-3 py-2 font-semibold text-gray-800">' +
                v.brand + ' ' + v.model + '</td>' +
            '<td class="px-3 py-2">' + statusEl + '</td>' +
            '<td class="px-3 py-2 font-mono text-xs text-gray-500">' +
                safe(v.gpsDeviceId) + '</td>' +
            '<td class="px-3 py-2 font-mono text-xs">' + flt(v.lat, 6) + '</td>' +
            '<td class="px-3 py-2 font-mono text-xs">' + flt(v.lng, 6) + '</td>' +
            '<td class="px-3 py-2 ' + sCl + '">' + flt(v.speed, 0) + ' km/h</td>' +
            /* odometer hidden */ '' +
            '<td class="px-3 py-2 text-xs text-gray-500">' + ping + '</td>' +
            '<td class="px-3 py-2">' +
                '<span class="px-2 py-0.5 rounded-full text-xs font-medium ' + bc + '">' +
                safe(v.type) + '</span></td>' +
            '<td class="px-3 py-2">' +
                '<button onclick="locateCar(' + v.fleetId + ',' + v.lat + ',' + v.lng + ')" ' +
                'class="text-xs bg-blue-600 text-white px-3 py-1 rounded-full ' +
                'hover:bg-blue-700 transition">Locate</button></td>' +
            '</tr>';
    }).join('');
}

function locateCar(id, lat, lng) {
    map.flyTo([lat, lng], 16, {duration:1.2});
    setTimeout(() => { if (markers[id]) markers[id].openPopup(); }, 1300);
}

function filterMap(type) {
    currentFilter = type;
    ['all','rental','taxi'].forEach(t => {
        const b = document.getElementById('btn-' + t);
        if (b) b.style.opacity = (t === type) ? '1' : '0.6';
    });
    refreshMap();
}

function refreshMap() {
    const url = 'GetFleetPositionsServlet' +
                (currentFilter !== 'all' ? '?type=' + currentFilter : '');
    fetch(url)
        .then(r => r.json())
        .then(data => {
            if (!Array.isArray(data)) {
                console.error('GPS error:', data);
                return;
            }
            updateMarkers(data);
            updateTable(data);
            const now = new Date();
            document.getElementById('lastUpdate').textContent =
                now.toTimeString().substring(0, 8);
            const b = document.getElementById('refreshBadge');
            b.style.opacity = '1';
            setTimeout(() => b.style.opacity = '0', 1500);
        })
        .catch(err => {
            document.getElementById('lastUpdate').textContent = 'Error — retrying...';
            console.error('Fleet map error:', err);
        });
}

refreshMap();
setInterval(refreshMap, 10000);
</script>
</body>
</html>
