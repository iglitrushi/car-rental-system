<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Car Availability</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
<div class="container mx-auto p-6">
    <h1 class="text-3xl font-bold mb-6 text-center">Car Availability</h1>

    <div class="bg-white p-6 shadow rounded">
        <%
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;
            String errorDetails = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost/demo", "root", "");
                pst = con.prepareStatement("SELECT * FROM carsbrand WHERE availability = 1");
                rs = pst.executeQuery();

                boolean found = false;
        %>

        <table class="min-w-full bg-white border">
            <thead class="bg-blue-500 text-white">
                <tr>
                    <th class="py-2 px-4 border">Car ID</th>
                    <th class="py-2 px-4 border">Brand</th>
                    <th class="py-2 px-4 border">Model</th>
                    <th class="py-2 px-4 border">Cubic</th>
                    <th class="py-2 px-4 border">Fuel</th>
                    <th class="py-2 px-4 border">Transmission</th>
                    <th class="py-2 px-4 border">Year</th>
                    <th class="py-2 px-4 border">Price</th>
                </tr>
            </thead>
            <tbody>
            <%
                while (rs.next()) {
                    found = true;
            %>
                <tr class="border-b">
                    <td class="py-2 px-4"><%= rs.getInt("CarId") %></td>
                    <td class="py-2 px-4"><%= rs.getString("NameOfBrand") %></td>
                    <td class="py-2 px-4"><%= rs.getString("Model") %></td>
                    <td class="py-2 px-4"><%= rs.getInt("Cubic") %></td>
                    <td class="py-2 px-4"><%= rs.getString("Fuel") %></td>
                    <td class="py-2 px-4"><%= rs.getString("transmission") %></td>
                    <td class="py-2 px-4"><%= rs.getInt("year") %></td>
                    <td class="py-2 px-4"><%= rs.getDouble("price") %></td>
                </tr>
            <%
                }

                if (!found) {
            %>
                <tr>
                    <td colspan="5" class="text-center py-4 text-gray-500">No available cars found.</td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>

        <%
            } catch (Exception e) {
                errorDetails = e.toString();
        %>
            <p class="text-red-500 mt-4">❌ Error: <%= errorDetails %></p>
        <%
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (pst != null) pst.close(); } catch (Exception e) {}
                try { if (con != null) con.close(); } catch (Exception e) {}
            }
        %>
    </div>
    <div class="flex justify-center space-x-6 mt-8">
                    <a href="admin_dashboard.jsp" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                        ⬅ Back to Dashboard
                    </a>
               
                    <a href="index.html" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                        ⬅ Back to Home
                    </a>
                </div>
</div>
</body>
</html>
