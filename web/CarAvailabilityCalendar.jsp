<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.ReservationCalendar, java.text.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Car Availability</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .reservation-tooltip {
            visibility: hidden;
            width: 280px;
            background-color: #333;
            color: #fff;
            text-align: left;
            border-radius: 6px;
            padding: 8px;
            position: absolute;
            z-index: 100;
            bottom: 125%;
            left: 50%;
            transform: translateX(-50%);
            opacity: 0;
            transition: opacity 0.3s;
            font-size: 0.85rem;
        }
        .reservation-day:hover .reservation-tooltip {
            visibility: visible;
            opacity: 1;
        }
    </style>
</head>
<body class="bg-gray-100">
<div class="container mx-auto p-6">
    <h1 class="text-3xl font-bold mb-6 text-center">Car Availability</h1>

    <div class="bg-white p-6 shadow rounded mb-8">
        <h2 class="text-2xl font-semibold mb-4">Reservation Calendar (Next 3 Months)</h2>

        <%
            Map<Integer, List<ReservationCalendar>> reservations =
                (Map<Integer, List<ReservationCalendar>>) request.getAttribute("carReservations");
            String errorMessage = (String) request.getAttribute("errorMessage");

            if (errorMessage != null) {
        %>
            <div class="text-center p-8">
                <p class="text-red-600 text-lg"><%= errorMessage %></p>
                <a href="dashboard.jsp" class="mt-4 inline-block bg-blue-500 text-white px-4 py-2 rounded">
                    Back to Dashboard
                </a>
            </div>
        <%
            } else if (reservations == null || reservations.isEmpty()) {
        %>
            <div class="text-center p-8">
                <p class="text-gray-500 text-lg">No reservation data available</p>
                <a href="dashboard.jsp" class="mt-4 inline-block bg-blue-500 text-white px-4 py-2 rounded">
                    Back to Dashboard
                </a>
            </div>
        <%
            } else {
                Calendar calendar = Calendar.getInstance();
                SimpleDateFormat monthFormat = new SimpleDateFormat("MMMM yyyy");
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

                for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
                    calendar.setTime(new Date());
                    calendar.add(Calendar.MONTH, monthOffset);
                    calendar.set(Calendar.DAY_OF_MONTH, 1);

                    int year = calendar.get(Calendar.YEAR);
                    int month = calendar.get(Calendar.MONTH);
                    int daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
                    int firstDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        %>
        <div class="mb-10">
            <h3 class="text-xl font-bold mb-4"><%= monthFormat.format(calendar.getTime()) %></h3>
            <div class="grid grid-cols-7 gap-1">
                <!-- Weekday headers -->
                <div class="text-center font-semibold py-2 bg-blue-100">Sun</div>
                <div class="text-center font-semibold py-2 bg-blue-100">Mon</div>
                <div class="text-center font-semibold py-2 bg-blue-100">Tue</div>
                <div class="text-center font-semibold py-2 bg-blue-100">Wed</div>
                <div class="text-center font-semibold py-2 bg-blue-100">Thu</div>
                <div class="text-center font-semibold py-2 bg-blue-100">Fri</div>
                <div class="text-center font-semibold py-2 bg-blue-100">Sat</div>

                
                <%
                    for (int i = 1; i < firstDayOfWeek; i++) {
                %>
                    <div class="h-12 border bg-gray-50"></div>
                <%
                    }

                
                    for (int day = 1; day <= daysInMonth; day++) {
                        calendar.set(Calendar.DAY_OF_MONTH, day);
                        Date currentDate = calendar.getTime();

                     
                        Calendar calNorm = Calendar.getInstance();
                        calNorm.setTime(currentDate);
                        calNorm.set(Calendar.HOUR_OF_DAY, 0);
                        calNorm.set(Calendar.MINUTE, 0);
                        calNorm.set(Calendar.SECOND, 0);
                        calNorm.set(Calendar.MILLISECOND, 0);
                        currentDate = calNorm.getTime();

                        boolean isReserved = false;
                        StringBuilder tooltipContent = new StringBuilder();

                        for (List<ReservationCalendar> resList : reservations.values()) {
                            for (ReservationCalendar res : resList) {
                                if (!currentDate.before(res.getStartDate()) && !currentDate.after(res.getEndDate())) {
                                    isReserved = true;
                                    tooltipContent.append(
                                        "<div class='mb-2'><strong>" + res.getNameOfBrand() + " " + res.getModel() + "</strong><br>" +
                                        "From: " + dateFormat.format(res.getStartDate()) + "<br>" +
                                        "To: " + dateFormat.format(res.getEndDate()) + "</div>"
                                    );
                                }
                            }
                        }
                %>
                <div class="h-12 border relative <%= isReserved ? "bg-red-100 reservation-day" : "bg-white" %>">
                    <div class="absolute top-0 left-0 p-1"><%= day %></div>
                    <% if (isReserved) { %>
                        <div class="reservation-tooltip">
                            <%= tooltipContent.toString() %>
                        </div>
                    <% } %>
                </div>
                <%
                    }
                %>
            </div>
        </div>
        <%
                }
            }
        %>
    </div>

   
    <div class="bg-white p-6 shadow rounded mt-12">
        <h2 class="text-2xl font-bold mb-6 text-gray-800">Reserved Car Details</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <%
                if (reservations != null && !reservations.isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

                    for (Map.Entry<Integer, List<ReservationCalendar>> entry : reservations.entrySet()) {
                        for (ReservationCalendar res : entry.getValue()) {
            %>
            <div class="bg-white border border-gray-200 rounded-2xl shadow hover:shadow-lg transition-all p-5">
                <div class="mb-3">
                    <h3 class="text-xl font-semibold text-blue-700 mb-1">
                        <%= res.getNameOfBrand() %> <%= res.getModel() %>
                    </h3>
                        <p class="text-sm text-gray-500">Car ID: <%=res.getCarId() %>
                </div>
                <div class="flex flex-wrap gap-2 mb-4">
                    <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm">
                        Transmission: <%= res.getTransmission() %>
                    </span>
                    <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm">
                        Fuel: <%= res.getFuel() %>
                    </span>
                    <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm">
                        Price per Day: €<%= res.getPrice() %>/day
                    </span>
                </div>
                    <div class="text-sm text-gray-600 space-y-1"> 
                        <p><span class="font-medium text-gray-700">Start Date:</span> <%= sdf.format(res.getStartDate()) %></p>
                <p><span class="font-medium text-gray-700">End Date:</span> <%= sdf.format(res.getEndDate()) %></p>
                    </div>
                </div>
                <%
                            }
                        }
                    } else {
                %>
                <p class="text-gray-600 col-span-full">No reservation details available.</p>
                <%
                    }
                %>
            </div>
            
            <div class="flex justify-center space-x-6 mt-10 mb-6">
                
                    
               
                    <a href="Home.jsp" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                        ⬅ Back to User Menu
                    </a>
                
                <a href="index.html" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                       ⬅ Back to Home
                </a>
                
            </div>

</div>
</body>
</html>
