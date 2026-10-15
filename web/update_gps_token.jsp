<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Admin only
    if (session.getAttribute("role") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("index.html");
        return;
    }

    // Read flash messages set by GpsTokenUpdateServlet
    String message  = (String) session.getAttribute("gpsMsg");
    String msgType  = (String) session.getAttribute("gpsMsgType");
    session.removeAttribute("gpsMsg");
    session.removeAttribute("gpsMsgType");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GPS Token Manager</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen py-8">
<div class="max-w-2xl mx-auto px-4">
<div class="bg-white shadow-xl rounded-2xl p-8">

    <h2 class="text-2xl font-bold text-gray-800 mb-1">GPS Token Manager</h2>
    <p class="text-gray-500 text-sm mb-6">
        Update the iopgps.com session token — no server restart needed
    </p>

    <!-- Message -->
    <% if (message != null) { %>
    <div class="mb-5 px-4 py-3 rounded-lg text-sm font-medium border
        <%= "success".equals(msgType)
            ? "bg-green-50 text-green-800 border-green-300"
            : "bg-red-50 text-red-800 border-red-300" %>">
        <%= message %>
    </div>
    <% } %>

    <!-- How to get token -->
    <div class="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-6 text-sm">
        <h3 class="font-semibold text-blue-800 mb-2">How to get a fresh token (30 seconds)</h3>
        <ol class="list-decimal list-inside space-y-1 text-blue-700">
            <li>Open <strong>iopgps.com</strong> — make sure you are logged in</li>
            <li>Press <strong>F12</strong> &rarr; Network tab &rarr; Fetch/XHR filter</li>
            <li>Click any request in the list</li>
            <li>Click the <strong>Headers</strong> tab on the right panel</li>
            <li>Find <strong>Cookie:</strong> under Request Headers</li>
            <li>Copy the value after <strong>USER_TOKEN=</strong> up to the next <strong>;</strong></li>
            <li>Paste below and click <strong>Update Token</strong></li>
        </ol>
    </div>

    <!-- Update token form -->
    <form action="GpsTokenUpdateServlet" method="post" class="space-y-4 mb-6">
        <input type="hidden" name="action" value="update">
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                New USER_TOKEN value
            </label>
            <input type="text" name="token" required
                   placeholder="Paste the 32-character token here"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg
                          font-mono text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none">
            <p class="text-xs text-gray-400 mt-1">
                Example: ae5534b7c9b84cea9625923179f1ca7d
            </p>
        </div>
        <button type="submit"
            class="w-full bg-blue-600 hover:bg-blue-700 text-white
                   font-semibold py-2.5 rounded-lg transition">
            Update Token
        </button>
    </form>

    <!-- Test poll button -->
    <form action="GpsTokenUpdateServlet" method="post" class="mb-6">
        <input type="hidden" name="action" value="test">
        <button type="submit"
            class="w-full bg-green-600 hover:bg-green-700 text-white
                   font-semibold py-2.5 rounded-lg transition">
            Test GPS Poller Now
        </button>
        <p class="text-xs text-gray-400 text-center mt-1">
            Should save 2 positions if token is valid
        </p>
    </form>

    <div class="text-center pt-4 border-t border-gray-100">
        <a href="fleet_map.jsp"
           class="text-sm text-blue-600 hover:underline mr-4">
            Open Fleet Map
        </a>
        <a href="admin_dashboard.jsp"
           class="text-sm text-gray-400 hover:text-gray-600">
            Back to Dashboard
        </a>
    </div>

</div>
</div>
</body>
</html>
