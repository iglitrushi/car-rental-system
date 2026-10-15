<%@ page import="java.sql.*" %>
<%
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");

    if (startDate == null || endDate == null) {
        response.sendRedirect("selectDates.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Enter Personal Info</title>
    <script>
        const prices = {
            <% 
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/demo", "root", "");
                Statement stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                ResultSet rs = stmt.executeQuery("SELECT CarId, Model, price FROM carsbrand");
                while (rs.next()) { 
            %>
                "<%= rs.getInt("CarId") %>": <%= rs.getDouble("price") %>,
            <% } 
                rs.close();
                stmt.close();
                con.close(); 
            %>
        };

        function showPrice(select) {
            const carId = select.value;
            const price = prices[carId] || 0;
            document.getElementById("priceDisplay").innerText = "Price per day: $" + price;
        }
    </script>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
    <div class="bg-white shadow-xl rounded-lg p-8 w-full max-w-md">
        <h2 class="text-2xl font-bold text-center text-blue-700 mb-6">Enter Personal Info and Select Car</h2>
        <form action="ReservationServlet" method="post">
            <input type="hidden" name="startDate" value="<%= startDate %>">
            <input type="hidden" name="endDate" value="<%= endDate %>">

            <div> 
                <label for="name" class="block text-sm font-medium text-gray-700">Full Name:</label>
                <input type="text" name="name" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"><br><br>
            </div>

            <div> 
                <label for="email" class="block text-sm font-medium text-gray-700">Email:</label>
                <input type="email" name="email" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"><br><br>
            </div>

            <div>
                <label for="carId" class="block text-sm font-medium text-gray-700">Car Model:</label>
                <select name="carId" onchange="showPrice(this)" required class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                    <option value="">Select a car</option>
                    <%
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/demo", "root", "");
                        stmt = con.createStatement();
                        rs = stmt.executeQuery("SELECT CarId, Model, price FROM carsbrand");
                        while (rs.next()) {
                            int id = rs.getInt("CarId");
                            String model = rs.getString("Model");
                    %>
                        <option value="<%= id %>"><%= model %></option>
                    <% } 
                        rs.close();
                        stmt.close();
                        con.close(); 
                    %>
                </select><br><br>
            </div>

            <p id="priceDisplay" class="text-sm text-gray-600 italic"><em>Select a car to see the price per day</em></p>

            <div class="text-center"> 
                <button type="submit" class="w-full bg-blue-600 text-white font-semibold py-2 rounded hover:bg-blue-700 transition duration-200">
                    Reserve
                </button>
            </div>
        </form>
                <div class="flex justify-center space-x-6 mt-8">
                   
               
                    <a href="carReservation.jsp" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                        Go Back
                    </a>
                </div>
    </div>
</body>
</html>
