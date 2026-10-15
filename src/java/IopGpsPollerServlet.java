import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.DBUtil;

import java.io.*;
import java.net.*;
import java.sql.*;
import java.util.Properties;
import java.util.logging.Logger;


@WebServlet("/IopGpsPollerServlet")
public class IopGpsPollerServlet extends HttpServlet {

    private static final Logger log = Logger.getLogger(IopGpsPollerServlet.class.getName());

    
    static String BASE_URL;
    static String ACCOUNT_ID;
    static String IOPGPS_USERNAME;
    static String PASS_ENCODED;
    static String APP_NAME;

    static {
        try (InputStream input = IopGpsPollerServlet.class.getClassLoader()
                .getResourceAsStream("gps.properties")) {
            Properties p = new Properties();
            if (input != null) {
                p.load(input);
                BASE_URL        = p.getProperty("gps.base.url", "https://your-gps-provider.example.com");
                ACCOUNT_ID      = p.getProperty("gps.account.id", "");
                IOPGPS_USERNAME = p.getProperty("gps.username", "");
                PASS_ENCODED    = p.getProperty("gps.password", "");
                APP_NAME        = p.getProperty("gps.app.name", "Car_System_App");
            } else {
                throw new RuntimeException("gps.properties not found on classpath");
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to load gps.properties", e);
        }
    }

    private static final int MAX_FAILURES = 5;

    static volatile String sessionCookie    = null;
    static volatile long   lastLoginTime    = 0;
    static volatile int    consecutiveFails = 0;

    @Override
    public void init() throws ServletException {
        super.init();
        loadSavedToken();
    }

    private void loadSavedToken() {
        try {
            String tokenFile = getServletContext().getRealPath("/WEB-INF/gps_token.txt");
            File f = new File(tokenFile);
            if (f.exists()) {
                BufferedReader r = new BufferedReader(new FileReader(f));
                String token = r.readLine();
                r.close();
                if (token != null && !token.trim().isEmpty()) {
                    sessionCookie = buildCookie(token.trim());
                    lastLoginTime = System.currentTimeMillis();
                    log.info("IopGpsPoller: loaded saved token from file.");
                    return;
                }
            }
        } catch (Exception e) {
            log.warning("IopGpsPoller: could not load saved token: " + e.getMessage());
        }
        log.warning("IopGpsPoller: no saved token found. Go to GPS Token page to set one.");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession sess = request.getSession(false);
        boolean isAdmin  = sess != null && "admin".equals(sess.getAttribute("role"));
        boolean isLocal  = "127.0.0.1".equals(request.getRemoteAddr()) ||
                           "0:0:0:0:0:0:0:1".equals(request.getRemoteAddr());
        if (!isAdmin && !isLocal) { response.setStatus(403); return; }

        response.setContentType("application/json;charset=UTF-8");
        PollResult r = poll();
        PrintWriter out = response.getWriter();
        if (r.success) {
            out.print("{\"status\":\"ok\",\"saved\":" + r.saved +
                      ",\"skipped\":" + r.skipped + "}");
        } else {
            out.print("{\"status\":\"error\",\"message\":\"" +
                      r.error.replace("\"","'") + "\"}");
        }
    }

    static PollResult poll() {
        if (sessionCookie == null) {
            return PollResult.error(
                "No token set. Go to Admin Dashboard > GPS Token page. " +
                "Open your GPS provider's portal, press F12, inspect any request, " +
                "copy the USER_TOKEN cookie value, paste and click Update.");
        }

        try {
            String json = fetchVehicleList();

            if (json == null || json.trim().isEmpty()) {
                consecutiveFails++;
                return PollResult.error("Empty response from GPS provider");
            }

            if (isSessionExpired(json)) {
                log.warning("IopGpsPoller: token expired, trying saved token from file...");
                // Try reloading token from file (in case it was updated via web page)
                String savedToken = loadTokenFromFile();
                if (savedToken != null && !savedToken.equals(currentToken())) {
                    sessionCookie = buildCookie(savedToken);
                    lastLoginTime = System.currentTimeMillis();
                    // Retry with new token
                    json = fetchVehicleList();
                    if (json != null && !isSessionExpired(json)) {
                        log.info("IopGpsPoller: recovered using saved token from file.");
                        int[] counts = parseAndSave(json);
                        consecutiveFails = 0;
                        return new PollResult(true, counts[0], counts[1], null);
                    }
                }
                consecutiveFails++;
                if (consecutiveFails >= MAX_FAILURES) {
                    log.severe("CRITICAL: GPS token expired. " +
                        "Go to Admin Dashboard > GPS Token page to update.");
                }
                return PollResult.error(
                    "Token expired. Go to Admin Dashboard > GPS Token page. " +
                    "Takes 30 seconds to update.");
            }

            int[] counts = parseAndSave(json);
            consecutiveFails = 0;
            return new PollResult(true, counts[0], counts[1], null);

        } catch (Exception e) {
            consecutiveFails++;
            log.severe("IopGpsPoller fail #" + consecutiveFails + ": " + e.getMessage());
            return PollResult.error(e.getMessage() != null ? e.getMessage() : "Unknown error");
        }
    }

    private static boolean isSessionExpired(String json) {
        if (json == null) return true;
        return json.contains("\"loginOut\"") ||
               json.contains("\"code\":0,")  ||
               (json.length() < 200 && json.toLowerCase().contains("login"));
    }

    static String fetchVehicleList() throws Exception {
        long ts = System.currentTimeMillis();
        String ep = BASE_URL + "/rest/device/status/list" +
                    "?mapType=0&accountId=" + ACCOUNT_ID +
                    "&v=" + ts + "&lang=en&source=25";
        URL url = new URL(ep);
        HttpURLConnection conn = openConn(url, "GET");
        conn.setRequestProperty("Cookie",  sessionCookie);
        conn.setRequestProperty("Accept",  "application/json; charset=utf-8");
        conn.setRequestProperty("Referer", BASE_URL + "/");
        int status = conn.getResponseCode();
        log.info("IopGpsPoller: HTTP " + status);
        if (status == 302 || status == 401 || status == 403) {
            sessionCookie = null;
            return null;
        }
        return readResp(conn);
    }

    static int[] parseAndSave(String json) throws Exception {
        int saved = 0, skipped = 0;
        Connection con = null;
        try {
            con = DBUtil.getConnection();
            String[] blocks = json.split("\\},\\s*\\{");

            for (String block : blocks) {
                String imei   = extractField(block, "\"1\"");
                String name   = extractField(block, "\"2\"");
                String tsStr  = extractField(block, "\"5\"");
                String latStr = extractField(block, "\"9\"");
                String lngStr = extractField(block, "\"10\"");
                String spdStr = extractField(block, "\"11\"");
                String batStr = extractField(block, "\"49\"");
                String kmStr  = extractField(block, "\"72\"");

                if (imei == null || imei.trim().isEmpty() ||
                    latStr == null || lngStr == null) { skipped++; continue; }

                double lat, lng;
                try {
                    lat = Double.parseDouble(latStr.trim());
                    lng = Double.parseDouble(lngStr.trim());
                } catch (NumberFormatException e) { skipped++; continue; }

                if (lat == 0.0 && lng == 0.0) { skipped++; continue; }
                if (lat < 30.0 || lat > 55.0 || lng < 10.0 || lng > 35.0) {
                    skipped++; continue;
                }

                float speed = 0f, battery = 0f;
                int   km    = 0;
                try { if (spdStr != null) speed   = Float.parseFloat(spdStr.trim()); } catch (NumberFormatException ignored) {}
                try { if (batStr != null) battery = Float.parseFloat(batStr.trim()); } catch (NumberFormatException ignored) {}
                try { if (kmStr  != null) km      = Integer.parseInt(kmStr.trim());  } catch (NumberFormatException ignored) {}

                Timestamp gpsTime = null;
                if (tsStr != null && !tsStr.trim().isEmpty()) {
                    try { gpsTime = new Timestamp(Long.parseLong(tsStr.trim())); }
                    catch (NumberFormatException ignored) {}
                }

                PreparedStatement fp = con.prepareStatement(
                    "SELECT id FROM fleet WHERE gps_device_id = ?");
                fp.setString(1, imei.trim());
                ResultSet fr = fp.executeQuery();
                if (!fr.next()) {
                    fr.close(); fp.close();
                    skipped++; continue;
                }
                int fleetId = fr.getInt("id");
                fr.close(); fp.close();

                PreparedStatement ip;
                if (gpsTime != null) {
                    ip = con.prepareStatement(
                        "INSERT INTO location_logs " +
                        "(fleet_id, latitude, longitude, speed, odometer_km, recorded_at) " +
                        "VALUES (?, ?, ?, ?, ?, ?)");
                    ip.setInt(1, fleetId);
                    ip.setDouble(2, lat);
                    ip.setDouble(3, lng);
                    ip.setFloat(4, speed);
                    ip.setInt(5, km);
                    ip.setTimestamp(6, gpsTime);
                } else {
                    ip = con.prepareStatement(
                        "INSERT INTO location_logs " +
                        "(fleet_id, latitude, longitude, speed, odometer_km) " +
                        "VALUES (?, ?, ?, ?, ?)");
                    ip.setInt(1, fleetId);
                    ip.setDouble(2, lat);
                    ip.setDouble(3, lng);
                    ip.setFloat(4, speed);
                    ip.setInt(5, km);
                }
                ip.executeUpdate();
                ip.close();
                saved++;

                log.info("SAVED: " + name + " lat=" + lat + " lng=" + lng +
                         " speed=" + speed + " km=" + km);
                if (battery > 0 && battery < 11.5)
                    log.warning("LOW BATTERY: " + name + " = " + battery + "V");
            }
        } finally {
            DBUtil.close(con);
        }
        return new int[]{saved, skipped};
    }

    private static String currentToken() {
        if (sessionCookie == null) return "";
        int idx = sessionCookie.indexOf("USER_TOKEN=");
        if (idx < 0) return "";
        int end = sessionCookie.indexOf(";", idx + 11);
        return end < 0 ? sessionCookie.substring(idx + 11)
                       : sessionCookie.substring(idx + 11, end);
    }

    static String loadTokenFromFile() {
        
        try {
            String[] paths = {
                System.getProperty("catalina.home") + "/webapps/" + APP_NAME + "/WEB-INF/gps_token.txt",
                System.getProperty("catalina.base") + "/webapps/" + APP_NAME + "/WEB-INF/gps_token.txt",
            };
            for (String path : paths) {
                java.io.File f = new java.io.File(path);
                if (f.exists()) {
                    java.io.BufferedReader r = new java.io.BufferedReader(new java.io.FileReader(f));
                    String token = r.readLine();
                    r.close();
                    if (token != null && !token.trim().isEmpty()) {
                        log.info("IopGpsPoller: loaded token from " + path);
                        return token.trim();
                    }
                }
            }
        } catch (Exception e) {
            log.warning("IopGpsPoller: could not load token from file: " + e.getMessage());
        }
        return null;
    }

   
    static volatile String tokenFilePath = null;

    static String buildCookie(String token) {
        return "zoneId=Europe/Berlin; lang=en; source=25; " +
               "USER_TOKEN=" + token + "; " +
               "username=" + IOPGPS_USERNAME + "; " +
               "password=" + PASS_ENCODED;
    }

    static HttpURLConnection openConn(URL url, String method) throws Exception {
        HttpURLConnection c = (HttpURLConnection) url.openConnection();
        c.setRequestMethod(method);
        c.setRequestProperty("User-Agent",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/147.0.0.0");
        c.setRequestProperty("Accept-Language", "en-US,en;q=0.9");
        c.setConnectTimeout(12000);
        c.setReadTimeout(12000);
        c.setInstanceFollowRedirects(false);
        return c;
    }

    static String readResp(HttpURLConnection conn) throws Exception {
        InputStream is;
        try { is = conn.getInputStream(); }
        catch (IOException e) { is = conn.getErrorStream(); if (is == null) throw e; }
        if ("gzip".equalsIgnoreCase(conn.getContentEncoding()))
            is = new java.util.zip.GZIPInputStream(is);
        BufferedReader r = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = r.readLine()) != null) sb.append(line);
        r.close();
        return sb.toString();
    }

    static String extractField(String json, String key) {
        int ki = json.indexOf(key);
        if (ki < 0) return null;
        int ci = json.indexOf(":", ki + key.length());
        if (ci < 0) return null;
        int s = ci + 1;
        while (s < json.length() &&
               (json.charAt(s)==' '||json.charAt(s)=='\n'||
                json.charAt(s)=='\r'||json.charAt(s)=='\t')) s++;
        if (s >= json.length()) return null;
        char first = json.charAt(s);
        if (first == '"') {
            int e = json.indexOf('"', s + 1);
            return e < 0 ? null : json.substring(s + 1, e);
        } else if (first == 't' || first == 'f') {
            int e = s;
            while (e < json.length() && Character.isLetter(json.charAt(e))) e++;
            return json.substring(s, e);
        } else {
            int e = s;
            while (e < json.length() && (Character.isDigit(json.charAt(e)) ||
                   json.charAt(e)=='.'||json.charAt(e)=='-')) e++;
            return e == s ? null : json.substring(s, e);
        }
    }

    static class PollResult {
        public final boolean success;
        public final int saved, skipped;
        public final String error;
        PollResult(boolean ok, int sv, int sk, String err) {
            success=ok; saved=sv; skipped=sk; error=err;
        }
        static PollResult error(String msg) { return new PollResult(false,0,0,msg); }
    }
}