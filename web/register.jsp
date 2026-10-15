<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>

    
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-600 flex items-center justify-center min-h-screen">

    <div class="bg-white p-6 shadow-lg rounded-lg w-full max-w-sm h-[850px]">

        <h2 class="text-3xl font-bold text-center mb-6 text-blue-700">User Registration</h2>

        
        <form method="post" class="space-y-4">
            <div>
                <label class="block text-lg font-medium mb-1">First Name</label>
                <input type="text" name="first_name" class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none" required>
            </div>

            <div>
                <label class="block text-lg font-medium mb-1">Last Name</label>
                <input type="text" name="last_name" class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none" required>
            </div>

            <div>
                <label class="block text-lg font-medium mb-1">Username</label>
                <input type="text" name="username" class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none" required>
            </div>

            <div>
                <label class="block text-lg font-medium mb-1">Password</label>
                <div class="relative">
                    <input type="password" id="password" name="password" class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none pr-10" required>
                    <button type="button" onclick="togglePassword()" class="absolute right-3 top-3 text-gray-500"></button>
                   
                </div>
            </div>

            <div>
                <label class="block text-lg font-medium mb-1">Address</label>
                <input type="text" name="address" class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>

            <div>
                <label class="block text-lg font-medium mb-1">Contact</label>
                <input type="tel" name="contact" class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>

            <button type="submit" class="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 transition-all">
                Register
            </button>
              <div class="flex justify-center space-x-6 mt-10 mb-6">
             
                <a href="index.html" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                        Back to Home
                </a>
                
            </div>
        </form>

        <p class="text-center mt-4 text-gray-600">
            Already have an account? <a href="index.html" class="text-blue-600 hover:underline">Login here</a>
        </p>

        
        <div class="mt-4 text-center text-red-600">
            <% 
                if (request.getMethod().equals("POST")) {
                    String first_name = request.getParameter("first_name");
                    String last_name = request.getParameter("last_name");
                    String username = request.getParameter("username");
                    String password = request.getParameter("password");
                    String address = request.getParameter("address");
                    String contact = request.getParameter("contact");

                    Connection con = null;
                    PreparedStatement ps = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver"); 
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/demo", "root", "");
                        ps = con.prepareStatement("INSERT INTO users (first_name, last_name, username, password, address, contact) VALUES (?, ?, ?, ?, ?, ?)");

                        ps.setString(1, first_name);
                        ps.setString(2, last_name);
                        ps.setString(3, username);
                        ps.setString(4, password); 
                        ps.setString(5, address);
                        ps.setString(6, contact);

                        int x = ps.executeUpdate();
                        if (x > 0) {
                            out.println("<p class='text-green-600'>Registration successful!</p>");
                        } else {
                            out.println("<p class='text-red-600'>Registration failed. Try again.</p>");
                        }

                    } catch (Exception e) {
                        out.println("<p class='text-red-600'>Error: " + e.getMessage() + "</p>");
                    } finally {
                        try {
                            if (ps != null) ps.close();
                            if (con != null) con.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            %>
        </div>
      
    </div>

   
    <script>
        function togglePassword() {
            var passwordField = document.getElementById("password");
            if (passwordField.type === "password") {
                passwordField.type = "text";
            } else {
                passwordField.type = "password";
            }
        }
    </script>

</body>
</html>
