#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QLocalServer>
#include <QLocalSocket>
#include <QStandardPaths>
#include <QSocketNotifier>
#include <KLocalizedString>

#include "keyboardcontroller.h"
#include "waylandvirtualkeyboard.h"
#include "gestureengine.h"
#include "klipperintegration.h"

#ifdef HAVE_LAYERSHELLQT
#include <LayerShellQt/Window>
#endif

#include <sys/prctl.h>
#include <sys/resource.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <cstdio>
#include <cstring>
#include <cstdlib>

static const char* SOCKET_NAME = "plasma-keyboard-single-instance";
static const QString DBUS_SERVICE = QStringLiteral("org.kde.plasma.keyboard");
static const QString DBUS_PATH    = QStringLiteral("/org/kde/plasma/keyboard");

static void setupProcessSecurity() {
    // Prevent crash dumps containing process RAM
    prctl(PR_SET_DUMPABLE, 0);

    // Set max coredump size to 0
    rlimit rl = {0, 0};
    setrlimit(RLIMIT_CORE, &rl);
}

/**
 * Get the full path of the Unix socket used for single-instance IPC.
 * Uses XDG_RUNTIME_DIR or /tmp as fallback.
 */
static std::string getSocketPath()
{
    const char *runtimeDir = getenv("XDG_RUNTIME_DIR");
    std::string base = runtimeDir ? runtimeDir : "/tmp";
    return base + "/" + SOCKET_NAME;
}

/**
 * Try to connect to an existing instance via raw Unix Domain Socket.
 * This works BEFORE QGuiApplication is created, so it doesn't require
 * a display connection.
 * Returns true if an existing instance was found and toggle was sent.
 */
static bool trySendToggleRaw()
{
    std::string socketPath = getSocketPath();

    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) return false;

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socketPath.c_str(), sizeof(addr.sun_path) - 1);

    if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) == 0) {
        // Connected! Send toggle command
        const char *msg = "toggle\n";
        write(fd, msg, strlen(msg));
        close(fd);
        fprintf(stdout, "[Main] Found running instance via Unix socket. Toggle sent. Exiting.\n");
        return true;
    }

    close(fd);
    return false;
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IONBF, 0);
    setupProcessSecurity();

    // ── Early Single Instance Check (BEFORE QGuiApplication) ──────────
    // Parse --toggle manually from argv to avoid needing QApplication
    bool hasToggle = false;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--toggle") == 0 || strcmp(argv[i], "-t") == 0) {
            hasToggle = true;
            break;
        }
    }

    // Try to contact running instance via raw Unix socket (no Qt needed)
    if (trySendToggleRaw()) {
        return 0;  // Toggle sent successfully, exit secondary process
    }

    // If --toggle was passed but no instance is running, start normally
    // (acts as first launch)

    // ── Create QGuiApplication (requires display) ─────────────────────
    QGuiApplication app(argc, argv);
    app.setOrganizationName("KDE");
    app.setOrganizationDomain("kde.org");
    app.setApplicationName("plasma-keyboard");
    app.setDesktopFileName("org.kde.plasma-keyboard");

    QCommandLineParser parser;
    parser.setApplicationDescription("Plasma Virtual Keyboard");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption toggleOption(QStringList() << "t" << "toggle", "Toggle keyboard window visibility (show/hide)");
    parser.addOption(toggleOption);
    parser.process(app);

    fprintf(stdout, "[Main] No running instance found. Starting as primary instance.\n");

    // ── Setup Unix Domain Socket server for IPC ───────────────────────
    std::string socketPath = getSocketPath();
    // Remove any stale socket from a previous crash
    unlink(socketPath.c_str());

    int serverFd = socket(AF_UNIX, SOCK_STREAM, 0);
    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socketPath.c_str(), sizeof(addr.sun_path) - 1);

    bool socketListening = false;
    if (serverFd >= 0 && bind(serverFd, (struct sockaddr*)&addr, sizeof(addr)) == 0 && listen(serverFd, 5) == 0) {
        socketListening = true;
        fprintf(stdout, "[Main] Unix socket server listening on: %s\n", socketPath.c_str());
    } else {
        fprintf(stderr, "[Main] Failed to create Unix socket server at: %s\n", socketPath.c_str());
        if (serverFd >= 0) close(serverFd);
        serverFd = -1;
    }

    // ── Also setup QLocalServer for Qt-based IPC (works alongside) ────
    QLocalServer::removeServer(QString::fromUtf8(SOCKET_NAME));
    // We use the raw socket above, but also set up a QSocketNotifier
    // to integrate the raw socket fd with Qt's event loop.

    // ── Setup D-Bus service (fallback IPC) ─────────────────────────────
    QDBusConnection bus = QDBusConnection::sessionBus();
    if (bus.isConnected()) {
        bool registered = bus.registerService(DBUS_SERVICE);
        fprintf(stdout, "[Main] D-Bus service registration: %s\n", registered ? "OK" : "FAILED");
    } else {
        fprintf(stdout, "[Main] D-Bus session bus not available (will use socket only).\n");
    }

    // ── Register QML types ─────────────────────────────────────────────
    qmlRegisterType<KeyboardController>("org.kde.plasma.keyboard", 1, 0, "KeyboardController");
    qmlRegisterType<WaylandVirtualKeyboard>("org.kde.plasma.keyboard", 1, 0, "WaylandVirtualKeyboard");
    qmlRegisterType<GestureEngine>("org.kde.plasma.keyboard", 1, 0, "GestureEngine");
    qmlRegisterType<KlipperIntegration>("org.kde.plasma.keyboard", 1, 0, "KlipperIntegration");

    KeyboardController controller;

    // Register controller on D-Bus
    if (bus.isConnected()) {
        if (!bus.registerObject(DBUS_PATH, &controller, QDBusConnection::ExportScriptableSlots | QDBusConnection::ExportScriptableSignals)) {
            fprintf(stderr, "[Main] Failed to register KeyboardController on D-Bus path: %s\n", DBUS_PATH.toUtf8().constData());
        }
    }

    // ── QML Engine ─────────────────────────────────────────────────────
    QQmlApplicationEngine engine;

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [](QObject *obj, const QUrl &) {
        if (!obj) {
            QCoreApplication::exit(-1);
            return;
        }

        auto *window = qobject_cast<QQuickWindow *>(obj);
        if (window) {
            // Explicitly set window flags to bypass tiling window managers (Krohnkite, Bspwm, etc.)
            window->setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint | Qt::BypassWindowManagerHint | Qt::WindowDoesNotAcceptFocus);

#ifdef HAVE_LAYERSHELLQT
            auto lWindow = LayerShellQt::Window::get(window);
            if (lWindow) {
                lWindow->setLayer(LayerShellQt::Window::LayerOverlay);
                lWindow->setScope(QStringLiteral("virtual-keyboard"));
                lWindow->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
                lWindow->setAnchors(LayerShellQt::Window::AnchorBottom);
                lWindow->setExclusiveZone(0);
            }
#endif
            window->setVisible(true);
        }
    }, Qt::QueuedConnection);

    engine.loadFromModule("org.kde.plasma.keyboard", "Main");

    // ── Wire Unix socket server to Qt event loop via QSocketNotifier ──
    if (socketListening && serverFd >= 0) {
        auto *notifier = new QSocketNotifier(serverFd, QSocketNotifier::Read, &app);
        QObject::connect(notifier, &QSocketNotifier::activated, [&controller, serverFd]() {
            int clientFd = accept(serverFd, nullptr, nullptr);
            if (clientFd >= 0) {
                fprintf(stdout, "[Main] Received toggle via Unix socket.\n");
                controller.toggleVisibility();
                close(clientFd);
            }
        });
    }

    // Cleanup socket on exit
    auto cleanupSocket = [socketPath]() {
        unlink(socketPath.c_str());
    };
    QObject::connect(&app, &QCoreApplication::aboutToQuit, cleanupSocket);

    return app.exec();
}
