import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.DBUtil;

import java.io.IOException;
import java.sql.*;


@WebServlet(urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null ||
            username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Username and password are required.");
            request.getRequestDispatcher("index.html").forward(request, response);
            return;
        }

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            con = DBUtil.getConnection();

            
            String sql = "SELECT id, username, password_hash, role, first_name " +
                         "FROM users WHERE username = ?";
            pst = con.prepareStatement(sql);
            pst.setString(1, username.trim());
            rs = pst.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password_hash");

                boolean passwordMatches = password.equals(storedHash);
               
                if (passwordMatches) {
                    HttpSession session = request.getSession();
                    session.setAttribute("userId",    rs.getInt("id"));
                    session.setAttribute("user",      rs.getString("username"));
                    session.setAttribute("firstName", rs.getString("first_name"));
                    session.setAttribute("role",      rs.getString("role"));

                    
                    String role = rs.getString("role");
                    if ("admin".equals(role)) {
                        response.sendRedirect("admin_dashboard.jsp");
                    } else {
                        response.sendRedirect("Home.jsp");
                    }
                    return;
                }
            }

            
            request.setAttribute("errorMsg", "Wrong username or password.");
            String referer = request.getHeader("Referer");
            if (referer != null && referer.contains("admin_login")) {
                request.getRequestDispatcher("admin_login.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("index.html").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            DBUtil.close(rs, pst, con);
        }
    }
}