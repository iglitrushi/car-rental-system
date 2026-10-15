<%@ page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Search User</title>
    </head>
    <body>
    <center>
        <h1>Search Results</h1>
        <table border="1">
            <tr>
                <th>Username</th>
                <th>Password</th>
            </tr>
            <%
                try {
                  
                    Class.forName("com.mysql.jdbc.Driver");

                    
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/demo", "root", "");

                   
                    String user = request.getParameter("user");

                 
                    String sqlStr = "SELECT username, password FROM login WHERE username = ?";
                    PreparedStatement pst = con.prepareStatement(sqlStr);
                    pst.setString(1, user);

                 
                    ResultSet rs = pst.executeQuery();

                 
                    if (!rs.isBeforeFirst()) {
                        out.println("<tr><td colspan='2'>No user found.</td></tr>");
                    } else {
                        while (rs.next()) {
            %>
                            <tr>
                                <td><%= rs.getString("username") %></td>
                                <td><%= rs.getString("password") %></td>
                            </tr>
            <%
                        }
                    }

               
                    rs.close();
                    pst.close();
                    con.close();
                } catch (Exception e) {
                    out.println("<tr><td colspan='2'>Error: " + e.getMessage() + "</td></tr>");
                    e.printStackTrace();
                }
            %>
        </table>
    </center>
    </body>
</html>
