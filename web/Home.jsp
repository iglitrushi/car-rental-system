<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Guard: redirect to login if no session
    if (session.getAttribute("user") == null) {
        response.sendRedirect("index.html");
        return;
    }
    String firstName = (String) session.getAttribute("firstName");
    if (firstName == null) firstName = (String) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Menu</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-[url('assets/images/car1.jpg')] bg-cover bg-center flex justify-center items-center min-h-screen">

    <div class="text-center bg-blue-900 bg-opacity-90 p-10 rounded-2xl shadow-2xl w-96">
        <h1 class="text-3xl font-bold text-white mb-1">Welcome, <%= firstName %>!</h1>
        <p class="text-blue-300 text-sm mb-8">What would you like to do?</p>

        <!-- Rental section -->
        <p class="text-blue-200 text-xs uppercase tracking-widest mb-2 text-left">Car Rental</p>
        <div class="space-y-3 mb-6">
            <a href="ProfilePageJsp.jsp"
               class="block bg-blue-600 hover:bg-blue-500 text-white py-2 rounded-lg transition">
                Search &amp; Book a Car
            </a>
            <a href="carReservation.jsp"
               class="block bg-blue-600 hover:bg-blue-500 text-white py-2 rounded-lg transition">
                Make a Reservation
            </a>
            <a href="CarAvailability"
               class="block bg-gray-700 hover:bg-blue-600 text-white py-2 rounded-lg transition">
                Calendar Availability
            </a>
            <a href="index.jsp"
               class="block bg-yellow-500 hover:bg-yellow-400 text-black py-2 rounded-lg transition font-semibold">
                Pay with PayPal
            </a>
        </div>

        <!-- Taxi section (NEW) -->
        <p class="text-blue-200 text-xs uppercase tracking-widest mb-2 text-left">Taxi</p>
        <div class="space-y-3 mb-6">
            <a href="taxi_booking.jsp"
               class="block bg-green-600 hover:bg-green-500 text-white py-2 rounded-lg transition">
                Book a Taxi
            </a>
            <a href="taxi_tracking.jsp"
               class="block bg-green-700 hover:bg-green-600 text-white py-2 rounded-lg transition">
                Track My Taxi
            </a>
        </div>

        <!-- Account -->
        <p class="text-blue-200 text-xs uppercase tracking-widest mb-2 text-left">Account</p>
        <div class="space-y-3">
            <a href="./ProfileServlet"
               class="block bg-gray-600 hover:bg-gray-500 text-white py-2 rounded-lg transition">
                My Profile
            </a>
            <a href="./LogOutServlet"
               class="block bg-red-600 hover:bg-red-500 text-white py-2 rounded-lg transition">
                Logout
            </a>
        </div>
    </div>

</body>
</html>
