import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/servlett")
public class servlett extends HttpServlet {
    int i;
    Connection con;
    PreparedStatement pst;
    ResultSet rs;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    try {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html");
        String carname = request.getParameter("combo");

        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost/demo", "root", "");
        pst = con.prepareStatement("SELECT CarId, NameOfBrand, Model, Cubic, Fuel, Year FROM carsbrand WHERE NameOfBrand=?", 
    ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

        pst.setString(1, carname);
        rs = pst.executeQuery();

        
        String carImageUrl = "assets/images/rental.jpg"; 

        
        if (rs.next()) {
            String brand = rs.getString("NameOfBrand");

          
            if ("BMW".equalsIgnoreCase(brand)) {
                carImageUrl = "assets/images/bmw.jpeg";
            } else if ("Audi".equalsIgnoreCase(brand)) {
                carImageUrl = "assets/images/audi a7.jpg";
            } else if ("Mercedes".equalsIgnoreCase(brand)) {
                carImageUrl = "assets/images/mercedes.jpeg";
            }
            
            
            rs.beforeFirst();
        }

        
        out.println("<!DOCTYPE html>");
        out.println("<html lang='en'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<script src='https://cdn.tailwindcss.com'></script>");
        out.println("<title>Car Search Results</title>");
        out.println("</head>");
        out.println("<body class='bg-gray-600 flex items-center justify-center min-h-screen p-4'>");

        out.println("<div class='bg-white shadow-lg rounded-lg p-6 w-full max-w-4xl text-center'>");

        
        out.println("<img src='" + carImageUrl + "' alt='Car Image' class='w-full max-h-96 object-cover rounded-lg mb-6'>");

        out.println("<h2 class='text-2xl font-bold text-gray-800 mb-4'>Result of Search Page</h2>");

        out.println("<div class='overflow-x-auto'>");
        out.println("<table class='w-full text-left border-collapse border border-gray-300 bg-grey-600 shadow-md rounded-lg'>");
        out.println("<thead>");
        out.println("<tr class='bg-gray-600 text-black-700'>");
        out.println("<th class='p-3 border'>Car ID</th>");
        out.println("<th class='p-3 border'>Brand</th>");
        out.println("<th class='p-3 border'>Model</th>");
        out.println("<th class='p-3 border'>Cubic</th>");
        out.println("<th class='p-3 border'>Fuel</th>");
        out.println("<th class='p-3 border'>Year</th>");
        out.println("</tr>");
        out.println("</thead>");
        out.println("<tbody>");

        while (rs.next()) {
            out.println("<tr class='bg-gray-600'>");
            out.println("<td class='p-3 border'>" + rs.getString("CarId") + "</td>");
            out.println("<td class='p-3 border'>" + rs.getString("NameOfBrand") + "</td>");
            out.println("<td class='p-3 border'>" + rs.getString("Model") + "</td>");
            out.println("<td class='p-3 border'>" + rs.getString("Cubic") + "</td>");
            out.println("<td class='p-3 border'>" + rs.getString("Fuel") + "</td>");
            out.println("<td class='p-3 border'>" + rs.getString("Year") + "</td>");
            out.println("</tr>");
        }

        out.println("</tbody>");
        out.println("</table>");
        out.println("</div>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");

    } catch (ClassNotFoundException ex) {
        throw new ServletException("Database driver not found", ex);
    } catch (Exception e) {
        throw new ServletException("Error processing request", e);
    }
}

    public void destroy() {
        i = 0;
    }
}
