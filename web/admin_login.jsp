<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // If already logged in as admin, go straight to dashboard
    if (session.getAttribute("role") != null && "admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("admin_dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-200 flex items-center justify-center min-h-screen">

    <div class="bg-white p-8 rounded-xl shadow-lg w-96">
        <h3 class="text-2xl font-bold text-center text-gray-800 mb-2">Admin Login</h3>
        <p class="text-center text-gray-400 text-sm mb-6">Car Rental &amp; Taxi System</p>

        <%-- Show error if login failed --%>
        <% String error = (String) request.getAttribute("errorMsg");
           if (error != null) { %>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4 text-sm">
                <%= error %>
            </div>
        <% } %>

        <%-- Posts to LoginServlet — which checks role and redirects to admin_dashboard.jsp --%>
        <form action="LoginServlet" method="post" class="space-y-4">

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                <input type="text" name="username" required
                       placeholder="Enter admin username"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-400">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <input type="password" name="password" required
                       placeholder="Enter password"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-400">
            </div>

            <button type="submit"
                    class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 rounded-md transition">
                Login
            </button>
        </form>

        <div class="text-center mt-6">
            <a href="index.html" class="text-sm text-gray-400 hover:text-gray-600">
                Back to home page
            </a>
        </div>
    </div>

</body>
</html>
