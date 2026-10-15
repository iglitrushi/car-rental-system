<%@ page import="java.sql.*" %>
<%@ page import="model.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Pay for Reservation</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
<div class="bg-white shadow-xl rounded-xl p-8 w-full max-w-2xl">
    <h2 class="text-2xl font-semibold mb-4 text-center text-blue-600">Pay for Your Reservation</h2>

    <form method="post" action="CreatePaymentServlet" class="space-y-4">
        <div>
            <label class="block text-sm font-medium">Your Name</label>
            <input type="text" name="name" required
                   value="<%= session.getAttribute("firstName") != null ? session.getAttribute("firstName") : "" %>"
                   class="mt-1 p-2 border rounded-md w-full">
        </div>
        <div>
            <label class="block text-sm font-medium">Your Email</label>
            <input type="email" name="email" required
                   class="mt-1 p-2 border rounded-md w-full">
        </div>

        <%
            Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
            StringBuilder priceJs = new StringBuilder("const reservationPrices = {");
            try {
                con = DBUtil.getConnection();
                // Updated: queries rental_bookings JOIN fleet (was date_reservation)
                ps = con.prepareStatement(
                    "SELECT rb.id, f.brand, f.model, rb.start_date, rb.end_date, rb.total_price " +
                    "FROM rental_bookings rb " +
                    "JOIN fleet f ON rb.fleet_id = f.id " +
                    "WHERE rb.status = 'Approved'");
                rs = ps.executeQuery();
        %>
        <div>
            <label class="block text-sm font-medium">Select Approved Reservation</label>
            <select id="reservationSelect" name="reservation_id" required
                    class="mt-1 p-2 border rounded-md w-full">
                <option value="">-- Choose a Reservation --</option>
                <%
                    while (rs.next()) {
                        int id     = rs.getInt("id");
                        double price = rs.getDouble("total_price");
                        priceJs.append(id).append(":").append(price).append(",");
                %>
                <option value="<%= id %>">
                    #<%= id %> — <%= rs.getString("brand") %> <%= rs.getString("model") %>
                    | <%= rs.getDate("start_date") %> to <%= rs.getDate("end_date") %>
                    | $<%= price %>
                </option>
                <%  } %>
            </select>
        </div>
        <%
            } catch (Exception e) {
                out.println("<p class='text-red-600'>Error loading reservations: " + e.getMessage() + "</p>");
            } finally {
                DBUtil.close(rs, ps, con);
                if (priceJs.charAt(priceJs.length()-1) == ',')
                    priceJs.deleteCharAt(priceJs.length()-1);
                priceJs.append("};");
            }
        %>

        <input type="hidden" id="totalPrice" name="totalPrice" value="">

        <script>
            <%= priceJs.toString() %>
            document.getElementById('reservationSelect').addEventListener('change', function() {
                const price = reservationPrices[this.value];
                document.getElementById('totalPrice').value = price ? price.toFixed(2) : '';
            });
        </script>

        <div class="text-center">
            <button type="submit"
                class="bg-yellow-400 hover:bg-yellow-500 text-black font-semibold py-2 px-8 rounded-md">
                Pay with PayPal
            </button>
        </div>
    </form>

    <div class="flex justify-center gap-4 mt-8">
        <a href="Home.jsp"
           class="bg-blue-600 text-white px-6 py-2 rounded-full hover:bg-blue-700 transition">
            Back to Menu
        </a>
        <a href="index.html"
           class="bg-gray-500 text-white px-6 py-2 rounded-full hover:bg-gray-600 transition">
            Back to Home
        </a>
    </div>
</div>
</body>
</html>
