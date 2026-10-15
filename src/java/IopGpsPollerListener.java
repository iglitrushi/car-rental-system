import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;


@WebListener
public class IopGpsPollerListener implements ServletContextListener {

    private static final Logger log = Logger.getLogger(IopGpsPollerListener.class.getName());
    private ScheduledExecutorService scheduler;
    private ScheduledExecutorService watchdog;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        log.info("IopGpsPollerListener: starting GPS poller...");

        
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "iopgps-poller");
            t.setDaemon(true);
            t.setUncaughtExceptionHandler((thread, ex) ->
                log.severe("IopGpsPoller thread crashed: " + ex.getMessage()));
            return t;
        });

        scheduler.scheduleAtFixedRate(() -> {
            try {
                IopGpsPollerServlet.PollResult result = IopGpsPollerServlet.poll();
                if (!result.success) {
                    log.warning("IopGpsPoller poll failed: " + result.error);
                }
            } catch (Throwable t) {
                
                log.severe("IopGpsPoller unexpected error: " + t.getMessage());
            }
        }, 10, 15, TimeUnit.SECONDS);

        
        watchdog = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "iopgps-watchdog");
            t.setDaemon(true);
            return t;
        });

        watchdog.scheduleAtFixedRate(() -> {
            try {
                if (scheduler.isShutdown() || scheduler.isTerminated()) {
                    log.severe("IopGpsPoller WATCHDOG: scheduler died — restarting!");
                    contextInitialized(sce);
                } else {
                    log.fine("IopGpsPoller watchdog: poller is alive.");
                }
            } catch (Throwable t) {
                log.severe("Watchdog error: " + t.getMessage());
            }
        }, 5, 5, TimeUnit.MINUTES);

        log.info("IopGpsPollerListener: GPS poller running every 15 seconds. Watchdog active.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (watchdog != null)   { watchdog.shutdownNow(); }
        if (scheduler != null)  { scheduler.shutdownNow(); }
        log.info("IopGpsPollerListener: GPS poller stopped.");
    }
}