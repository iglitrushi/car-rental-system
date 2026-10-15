import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;


@WebServlet("/GpsTokenUpdateServlet")
public class GpsTokenUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("index.html");
            return;
        }

        String newToken = request.getParameter("token");
        String action   = request.getParameter("action");

        if ("update".equals(action) && newToken != null && !newToken.trim().isEmpty()) {
            String token = newToken.trim();

            
            try {
                String tokenFile = getServletContext().getRealPath("/WEB-INF/gps_token.txt");
                PrintWriter pw = new PrintWriter(new FileWriter(tokenFile));
                pw.println(token);
                pw.close();
                
                IopGpsPollerServlet.tokenFilePath = tokenFile;
            } catch (Exception e) {
                session.setAttribute("gpsMsg",     "Warning: could not save to file: " + e.getMessage());
                session.setAttribute("gpsMsgType", "error");
                response.sendRedirect("update_gps_token.jsp");
                return;
            }

            
            IopGpsPollerServlet.sessionCookie =
                IopGpsPollerServlet.buildCookie(token);
            IopGpsPollerServlet.lastLoginTime    = System.currentTimeMillis();
            IopGpsPollerServlet.consecutiveFails = 0;

            session.setAttribute("gpsMsg",
                "Token updated successfully! GPS poller is now using the new token. " +
                "Token also saved — will survive server restarts.");
            session.setAttribute("gpsMsgType", "success");

        } else if ("test".equals(action)) {
            IopGpsPollerServlet.PollResult r = IopGpsPollerServlet.poll();
            if (r.success) {
                session.setAttribute("gpsMsg",
                    "Poll OK — saved=" + r.saved + " skipped=" + r.skipped);
                session.setAttribute("gpsMsgType", "success");
            } else {
                session.setAttribute("gpsMsg",     "Poll failed: " + r.error);
                session.setAttribute("gpsMsgType", "error");
            }
        } else {
            session.setAttribute("gpsMsg",     "Token cannot be empty.");
            session.setAttribute("gpsMsgType", "error");
        }

        response.sendRedirect("update_gps_token.jsp");
    }
}