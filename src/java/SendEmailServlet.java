import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;


@WebServlet("/sendEmail")
public class SendEmailServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String to          = request.getParameter("to");
        String subject     = request.getParameter("subject");
        String messageText = request.getParameter("message");

       
        if (to == null || to.trim().isEmpty() ||
            subject == null || subject.trim().isEmpty() ||
            messageText == null || messageText.trim().isEmpty()) {
            session.setAttribute("status", "❌ Please fill in all fields (to, subject, message).");
            response.sendRedirect("emailform.jsp");
            return;
        }

       
        System.out.println();
        System.out.println("========== EMAIL (DEMO MODE) ==========");
        System.out.println("To:      " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Message: " + messageText);
        System.out.println("=======================================");
        System.out.println();

        session.setAttribute("status",
            "✅ Email queued (demo mode — check the server console to see the message).");

        response.sendRedirect("emailform.jsp");
    }
}