<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Taxi Booked</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
<div class="bg-white shadow-xl rounded-2xl p-10 max-w-md w-full text-center">

    <!-- Success icon -->
    <div class="w-16 h-16 bg-teal-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <svg class="w-8 h-8 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
        </svg>
    </div>

    <h2 class="text-2xl font-bold text-teal-700 mb-2">Taxi Requested!</h2>
    <p class="text-gray-500 mb-6">Your booking has been received. A driver will be assigned shortly.</p>

    <div class="bg-gray-50 rounded-xl p-4 text-left space-y-2 text-sm mb-6">
        <div class="flex justify-between">
            <span class="text-gray-500">Name</span>
            <span class="font-medium"><%= request.getAttribute("customerName") %></span>
        </div>
        <div class="flex justify-between">
            <span class="text-gray-500">Type</span>
            <span class="font-medium capitalize"><%= request.getAttribute("bookingType") %></span>
        </div>
        <div class="flex justify-between">
            <span class="text-gray-500">Pickup</span>
            <span class="font-medium text-right max-w-xs"><%= request.getAttribute("pickupAddress") %></span>
        </div>
        <div class="flex justify-between">
            <span class="text-gray-500">Dropoff</span>
            <span class="font-medium text-right max-w-xs"><%= request.getAttribute("dropoffAddress") %></span>
        </div>
        <% if ("scheduled".equals(request.getAttribute("bookingType"))) { %>
        <div class="flex justify-between">
            <span class="text-gray-500">Scheduled</span>
            <span class="font-medium"><%= request.getAttribute("scheduledTime") %></span>
        </div>
        <% } %>
    </div>

    <div class="space-y-3">
        <a href="Home.jsp"
           class="block w-full bg-teal-600 hover:bg-teal-700 text-white py-2 rounded-lg transition font-semibold">
            Back to Menu
        </a>
        <a href="taxi_booking.jsp"
           class="block w-full bg-gray-200 hover:bg-gray-300 text-gray-700 py-2 rounded-lg transition">
            Book Another Taxi
        </a>
    </div>
</div>
</body>
</html>
