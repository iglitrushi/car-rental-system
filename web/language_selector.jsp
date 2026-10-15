<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
    .language-dropdown {
        position: relative;
        display: inline-block;
    }
    
    .lang-btn {
        background-color: #4CAF50;
        color: white;
        padding: 10px 16px;
        font-size: 14px;
        border: none;
        cursor: pointer;
        border-radius: 4px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .lang-btn:hover {
        background-color: #45a049;
    }
    
    .dropdown-content {
        display: none;
        position: absolute;
        background-color: #f9f9f9;
        min-width: 160px;
        box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
        z-index: 1000;
        border-radius: 4px;
    }
    
    .dropdown-content a {
        color: black;
        padding: 12px 16px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
        transition: 0.2s;
    }
    
    .dropdown-content a:hover {
        background-color: #f1f1f1;
    }
    
    .show {
        display: block;
    }
    
    .flag-icon {
        font-size: 20px;
    }
</style>

<script>
    function toggleDropdown() {
        document.getElementById("languageDropdown").classList.toggle("show");
    }
    
    // Close dropdown if clicked outside
    window.onclick = function(event) {
        if (!event.target.matches('.lang-btn') && !event.target.closest('.lang-btn')) {
            var dropdowns = document.getElementsByClassName("dropdown-content");
            for (var i = 0; i < dropdowns.length; i++) {
                var openDropdown = dropdowns[i];
                if (openDropdown.classList.contains('show')) {
                    openDropdown.classList.remove('show');
                }
            }
        }
    }
    
    function changeLanguage(langCode) {
        // Redirect to a servlet that will handle language change
        window.location.href = '${pageContext.request.contextPath}/ChangeLanguage?lang=' + langCode + '&redirect=' + encodeURIComponent(window.location.pathname + window.location.search);
    }
</script>

<div class="language-dropdown">
    <button onclick="toggleDropdown()" class="lang-btn">
        <span class="flag-icon">
            <c:choose>
                <c:when test="${sessionScope.userLocale.language == 'es'}">??</c:when>
                <c:when test="${sessionScope.userLocale.language == 'fr'}">??</c:when>
                <c:otherwise>??</c:otherwise>
            </c:choose>
        </span>
        <fmt:message key="nav.language"/>
        <span>?</span>
    </button>
    <div id="languageDropdown" class="dropdown-content">
        <a href="javascript:void(0)" onclick="changeLanguage('en')">
            <span class="flag-icon">??</span> English
        </a>
        <a href="javascript:void(0)" onclick="changeLanguage('es')">
            <span class="flag-icon">??</span> Español
        </a>
        <a href="javascript:void(0)" onclick="changeLanguage('fr')">
            <span class="flag-icon">??</span> Français
        </a>
    </div>
</div>