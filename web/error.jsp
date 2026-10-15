<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Error</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center h-screen">
    <div class="bg-white p-6 rounded-lg shadow-lg text-center">
        <h1 class="text-2xl font-bold text-red-600 mb-4">Error</h1>
        <p class="text-lg">
            <%= request.getAttribute("errorMessage") != null ? request.getAttribute("errorMessage") : "Unknown error" %>
        </p>
        <a href="admin_dashboard.jsp" class="block mt-4 text-blue-500 hover:underline">Go Back to Dashboard</a>
    </div>
</body>
</html>
