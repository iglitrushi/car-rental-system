<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Available Cars</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-6">
    <h1 class="text-3xl font-bold text-center text-blue-700 mb-8">Available Cars</h1>

    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
        <%
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/demo", "root", "");
                stmt = con.createStatement();
                rs = stmt.executeQuery("SELECT CarId, NameOfBrand, model, cubic, Fuel,transmission, Year, availability, price FROM carsbrand WHERE availability = 1");

                while (rs.next()) {
                    String model = rs.getString("model").trim();
                    String brand = rs.getString("NameOfBrand").trim();
                    double price = rs.getDouble("price");
                    int carId = rs.getInt("CarId");
                    String fuel = rs.getString("Fuel");
                    String transmission = rs.getString("transmission");
                    int year = rs.getInt("Year");

                    String imageFile;
                    if (brand.equalsIgnoreCase("Audi") && model.equalsIgnoreCase("A7")) {
                        imageFile = "audi a7.jpg";
                    } else if (brand.equalsIgnoreCase("Audi") && model.equalsIgnoreCase("Q5")) {
                        imageFile = "audi_q5.jpg";
                    } else if (brand.equalsIgnoreCase("Mercedes") && model.equalsIgnoreCase("S Class")) {
                        imageFile = "mercedes s class.jpg";
                    } else if (brand.equalsIgnoreCase("Mercedes") && model.equalsIgnoreCase("C Class")){
                        imageFile = "mercedes c class.jpg";
                    } else if (brand.equalsIgnoreCase("volvo") && model.equalsIgnoreCase("xps")) {
                        imageFile = "volvo.jpg";
                    } else if (brand.equalsIgnoreCase("mercedes") && model.equalsIgnoreCase("GLA")){
                        imageFile = "mercedes gla.jpg";
                    } else if (brand.equalsIgnoreCase("Volkswagen") && model.equalsIgnoreCase("Golf")) {
                        imageFile = "golf.jpg";
                    }else {
                        imageFile = "default_car.jpg";
                    }

                
                    imageFile = imageFile.replace(" ", "%20");
        %>
        <div class="bg-white rounded-lg shadow-md overflow-hidden">
          
            <div class="w-full h-64 overflow-hidden bg-gray-100">
                <img src="<%= request.getContextPath() %>/assets/images/<%= imageFile %>" 
                     alt="<%= brand %> <%= model %>" 
                     class="w-full h-full object-cover">
            </div>

            <div class="p-4">
                <h2 class="text-xl font-semibold mb-1"><%= brand %> <%= model %></h2>
                <p class="text-gray-600">Fuel: <%= fuel %></p>
                <p class="text-gray-600">Transmission: <%= transmission %></p>
                <p class="text-gray-600">Year: <%= year %></p>
                <p class="text-gray-700 mt-2 mb-4 font-bold">Price per day: $<%= price %></p>

                <form action="index.html" method="get">
    <input type="hidden" name="carId" value="<%= carId %>">
    <input type="hidden" name="model" value="<%= model %>">
    <input type="hidden" name="price" value="<%= price %>">
    <!-- Add this parameter to trigger login message -->
    <input type="hidden" name="requireLogin" value="true">
    <button type="submit"
            class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition duration-200">
        Reserve
    </button>
</form>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<p class='text-red-600'>Error loading cars: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            }
        %>
    </div>
    <div class="flex justify-center space-x-6 mt-8">
                    
               
                   <a href="index.html" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                        ⬅ Back to Home
                    </a>
                </div>
</body>
</html>
