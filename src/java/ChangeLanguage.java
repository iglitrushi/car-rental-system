import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;

@WebServlet("/ChangeLanguage")
public class ChangeLanguage extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String langCode = request.getParameter("lang");
        String redirectUrl = request.getParameter("redirect");
        
        Locale selectedLocale = null;
        
        
        switch (langCode) {
            case "es":
                selectedLocale = new Locale("es", "ES");
                break;
            case "fr":
                selectedLocale = new Locale("fr", "FR");
                break;
            case "de":
                selectedLocale = new Locale("de", "DE");
                break;
            case "it":
                selectedLocale = new Locale("it", "IT");
                break;
            case "pt":
                selectedLocale = new Locale("pt", "PT");
                break;
            case "zh":
                selectedLocale = new Locale("zh", "CN");
                break;
            case "ja":
                selectedLocale = new Locale("ja", "JP");
                break;
            case "ru":
                selectedLocale = new Locale("ru", "RU");
                break;
            case "ar":
                selectedLocale = new Locale("ar", "SA");
                break;
            default:
                selectedLocale = new Locale("en", "US");
                break;
        }
        
       
        HttpSession session = request.getSession();
        session.setAttribute("userLocale", selectedLocale);
        
        
        if (redirectUrl != null && !redirectUrl.isEmpty()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/index.html");
        }
    }
}