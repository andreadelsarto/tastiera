#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
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

static void setupProcessSecurity() {
    // Impedisce la creazione di crash dump contenenti la RAM del processo
    prctl(PR_SET_DUMPABLE, 0);

    // Imposta la dimensione massima dei coredump a 0
    rlimit rl = {0, 0};
    setrlimit(RLIMIT_CORE, &rl);
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IONBF, 0);
    setupProcessSecurity();

    QGuiApplication app(argc, argv);
    app.setOrganizationName("KDE");
    app.setOrganizationDomain("kde.org");
    app.setApplicationName("plasma-keyboard");
    app.setDesktopFileName("org.kde.plasma-keyboard");

    qmlRegisterType<KeyboardController>("org.kde.plasma.keyboard", 1, 0, "KeyboardController");
    qmlRegisterType<WaylandVirtualKeyboard>("org.kde.plasma.keyboard", 1, 0, "WaylandVirtualKeyboard");
    qmlRegisterType<GestureEngine>("org.kde.plasma.keyboard", 1, 0, "GestureEngine");
    qmlRegisterType<KlipperIntegration>("org.kde.plasma.keyboard", 1, 0, "KlipperIntegration");

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

    return app.exec();
}
