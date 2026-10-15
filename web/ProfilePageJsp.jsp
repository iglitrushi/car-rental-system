<%@ page import="java.sql.*" %>
<%@ page import="model.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Find Your Car</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-[url('assets/images/carRent.jpg')] bg-cover bg-center flex items-center justify-center min-h-screen">

    <div class="bg-gray-700 bg-opacity-90 p-8 shadow-lg rounded-lg w-full max-w-md">
        <h2 class="text-2xl font-bold text-center text-white mb-2">Find a Rental Car</h2>
        <p class="text-center text-gray-300 text-sm mb-6">Select a brand to see available vehicles</p>

        <form method="get" action="servlett">
            <label class="block text-white text-sm font-medium mb-2">Select Brand</label>
            <div class="relative">
                <select name="combo"
                    class="block w-full bg-gray-100 p-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">-- Select a Brand --</option>
                    <%
                        Connection con = null;
                        PreparedStatement pst = null;
                        ResultSet rs = null;
                        try {
                            con = DBUtil.getConnection();
                            // Updated: queries fleet table (was carsbrand), only rental/both types
                            pst = con.prepareStatement(
                                "SELECT DISTINCT brand FROM fleet " +
                                "WHERE type IN ('rental','both') ORDER BY brand");
                            rs = pst.executeQuery();
                            while (rs.next()) {
                                String brand = rs.getString("brand");
                    %>
                                <option value="<%= brand %>"><%= brand %></option>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                    %>
                            <option value="">Error loading brands</option>
                    <%
                        } finally {
                            DBUtil.close(rs, pst, con);
                        }
                    %>
                </select>
            </div>
            <button type="submit"
                class="mt-4 w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 transition font-semibold">
                Search
            </button>
        </form>

        <div class="mt-6 text-center">
            <a href="Home.jsp"
               class="inline-block bg-gray-500 text-white px-6 py-2 rounded-full hover:bg-gray-600 transition">
                Back to Menu
            </a>
        </div>
    </div>
</body>
</html>
