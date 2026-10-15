import java.io.IOException;
import java.util.Locale;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

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