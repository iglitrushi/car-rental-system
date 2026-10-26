import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;


@WebFilter("/*") 
public class LanguageFilter implements Filter {
    
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession();
        
        
        if (session.getAttribute("userLocale") == null) {
           
            Locale browserLocale = httpRequest.getLocale();
            session.setAttribute("userLocale", browserLocale);
        }
        
        chain.doFilter(request, response);
    }
    
    public void init(FilterConfig fConfig) throws ServletException {}
    public void destroy() {}
}