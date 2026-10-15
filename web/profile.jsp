<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("index.html");
        return;
    }
    SimpleDateFormat df = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat dfFull = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gradient-to-br from-blue-900 to-gray-900 min-h-screen text-white">

<div class="max-w-4xl mx-auto px-4 py-10">

    <h1 class="text-3xl font-bold mb-2">👤 My Profile</h1>
    <p class="text-blue-300 text-sm mb-8">Your account details and recent activity</p>

    <% if (request.getAttribute("error") != null) { %>
        <div class="bg-red-600 bg-opacity-80 p-4 rounded-lg mb-6">
            Error: <%= request.getAttribute("error") %>
        </div>
    <% } %>

    
    <div class="bg-gray-800 rounded-2xl shadow-xl p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-2">Account Information</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
                <p class="text-gray-400">Full Name</p>
                <p class="font-semibold"><%= request.getAttribute("uFirstName") %> <%= request.getAttribute("uLastName") %></p>
            </div>
            <div>
                <p class="text-gray-400">Username</p>
                <p class="font-semibold"><%= request.getAttribute("uUsername") %></p>
            </div>
            <div>
                <p class="text-gray-400">Email</p>
                <p class="font-semibold"><%= request.getAttribute("uEmail") %></p>
            </div>
            <div>
                <p class="text-gray-400">Contact</p>
                <p class="font-semibold"><%= request.getAttribute("uContact") != null ? request.getAttribute("uContact") : "—" %></p>
            </div>
            <div class="md:col-span-2">
                <p class="text-gray-400">Address</p>
                <p class="font-semibold"><%= request.getAttribute("uAddress") != null ? request.getAttribute("uAddress") : "—" %></p>
            </div>
            <div class="md:col-span-2">
                <p class="text-gray-400">Member Since</p>
                <p class="font-semibold"><%= df.format((java.util.Date) request.getAttribute("uCreatedAt")) %></p>
            </div>
        </div>
    </div>

    
    <div class="bg-gray-800 rounded-2xl shadow-xl p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-2">🚗 Last Car Rental</h2>
        <% if (Boolean.TRUE.equals(request.getAttribute("lastRental"))) { %>
            <div class="flex flex-col md:flex-row gap-4">
                <div class="flex-1 text-sm space-y-2">
                    <p><span class="text-gray-400">Car:</span> <span class="font-semibold"><%= request.getAttribute("lrBrand") %> <%= request.getAttribute("lrModel") %></span></p>
                    <p><span class="text-gray-400">From:</span> <%= df.format((java.util.Date) request.getAttribute("lrStart")) %></p>
                    <p><span class="text-gray-400">To:</span> <%= df.format((java.util.Date) request.getAttribute("lrEnd")) %></p>
                    <p><span class="text-gray-400">Pickup:</span> <%= request.getAttribute("lrPickup") != null ? request.getAttribute("lrPickup") : "—" %></p>
                    <p><span class="text-gray-400">Drop-off:</span> <%= request.getAttribute("lrDropoff") != null ? request.getAttribute("lrDropoff") : "—" %></p>
                    <p><span class="text-gray-400">Total:</span> <span class="text-blue-400 font-bold">€<%= String.format("%.2f", request.getAttribute("lrTotal")) %></span></p>
                    <%
                        String rentalStatus = (String) request.getAttribute("lrStatus");
                        String rentalBadge = "bg-gray-600";
                        if ("Approved".equals(rentalStatus)) rentalBadge = "bg-blue-600";
                        else if ("Completed".equals(rentalStatus)) rentalBadge = "bg-green-600";
                        else if ("Rejected".equals(rentalStatus)) rentalBadge = "bg-red-600";
                        else if ("Pending".equals(rentalStatus)) rentalBadge = "bg-yellow-600";
                    %>
                    <p><span class="text-gray-400">Status:</span>
                        <span class="<%= rentalBadge %> px-2 py-1 rounded text-xs font-semibold"><%= rentalStatus %></span>
                    </p>
                </div>
            </div>
        <% } else { %>
            <p class="text-gray-400 text-sm">You haven't made any rental reservations yet.</p>
            <a href="ProfilePageJsp.jsp" class="inline-block mt-3 bg-blue-600 hover:bg-blue-500 px-4 py-2 rounded-lg text-sm font-semibold">Book a Car</a>
        <% } %>
    </div>

    
    <div class="bg-gray-800 rounded-2xl shadow-xl p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-2">🚕 Last Taxi Booking</h2>
        <% if (Boolean.TRUE.equals(request.getAttribute("lastTaxi"))) { %>
            <div class="text-sm space-y-2">
                <p><span class="text-gray-400">Pickup:</span> <%= request.getAttribute("ltPickup") %></p>
                <p><span class="text-gray-400">Drop-off:</span> <%= request.getAttribute("ltDropoff") %></p>
                <p><span class="text-gray-400">Fare:</span> <span class="text-blue-400 font-bold">€<%= String.format("%.2f", request.getAttribute("ltPrice")) %></span></p>
                <p><span class="text-gray-400">Booked on:</span> <%= dfFull.format((java.util.Date) request.getAttribute("ltCreated")) %></p>
                <%
                    String taxiStatus = (String) request.getAttribute("ltStatus");
                    String taxiBadge = "bg-gray-600";
                    if ("Assigned".equals(taxiStatus)) taxiBadge = "bg-blue-600";
                    else if ("InProgress".equals(taxiStatus)) taxiBadge = "bg-yellow-600";
                    else if ("Completed".equals(taxiStatus)) taxiBadge = "bg-green-600";
                    else if ("Cancelled".equals(taxiStatus)) taxiBadge = "bg-red-600";
                %>
                <p><span class="text-gray-400">Status:</span>
                    <span class="<%= taxiBadge %> px-2 py-1 rounded text-xs font-semibold"><%= taxiStatus %></span>
                </p>
            </div>
        <% } else { %>
            <p class="text-gray-400 text-sm">You haven't booked any taxis yet.</p>
            <a href="taxi_booking.jsp" class="inline-block mt-3 bg-green-600 hover:bg-green-500 px-4 py-2 rounded-lg text-sm font-semibold">Book a Taxi</a>
        <% } %>
    </div>

    
    <div class="bg-gray-800 rounded-2xl shadow-xl p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4 border-b border-gray-700 pb-2">📊 Quick Stats</h2>
        <div class="grid grid-cols-2 gap-6 text-center">
            <div>
                <p class="text-4xl font-bold text-blue-400"><%= request.getAttribute("totalRentals") %></p>
                <p class="text-gray-400 text-sm mt-1">Total Rentals</p>
            </div>
            <div>
                <p class="text-4xl font-bold text-green-400">€<%= String.format("%.2f", request.getAttribute("totalSpent")) %></p>
                <p class="text-gray-400 text-sm mt-1">Total Spent</p>
            </div>
        </div>
    </div>

 
    <div class="flex gap-4">
        <a href="user_dashboard.jsp"
           class="flex-1 text-center bg-gray-600 hover:bg-gray-500 py-3 rounded-lg font-semibold transition">
            Back to Menu
        </a>
        
    </div>

</div>
</body>
</html>