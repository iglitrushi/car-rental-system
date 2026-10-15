<%@ page import="jakarta.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Email Form</title>
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
 <div class="bg-white p-6 border border-gray-200 rounded-lg shadow-md w-full max-w-md mx-auto">
    <div class="inline-block border border-gray-300 rounded px-2 py-1 mb-4">
        <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">Send Email</h2>
    </div>

    <% 
        String status = (String) session.getAttribute("status");
        if (status != null) {
    %>
    
        <div class="mb-4 p-4 bg-green-100 text-green-800 rounded-lg">
            <%= status %>
        </div>
    <%
        session.removeAttribute("status"); 
        }
    %>

    <form action="sendEmail" method="post" class="space-y-4">
        <div>
            <label class="block text-gray-700 font-medium mb-1">To</label>
            <input type="text" name="to" required placeholder="example1@mail.com, example2@mail.com"
                   class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"/>
        </div>
        
        <div>
            <label class="block text-gray-700 font-medium mb-1">Subject</label>
            <input type="text" name="subject" required
                   class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-blue-500"/>
         </div>
        
        <div>
            <label class="block text-gray-700 font-medium mb-1">Message</label>
            <textarea name="message" rows="5" required
                      class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Type your message here...">
                      
            </textarea>
        </div>
        
        <div>
            <button type="submit"
                    class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition">
                Send Email  
            </button>
        </div>
    </form>
    
    <div class="flex justify-center space-x-6 mt-8">
                    <a href="admin_dashboard.jsp" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                         Back to Dashboard
                    </a>
               
                    <a href="index.html" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-full shadow hover:bg-blue-700 transition duration-200">
                         Back to Home
                    </a>
                </div>
 </div>
    
    
</body>
</html>
