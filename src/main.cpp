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

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("KDE");
    app.setApplicationName("plasma-keyboard");

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
            window->setFlags(window->flags() | Qt::WindowDoesNotAcceptFocus);
#ifdef HAVE_LAYERSHELLQT
            auto lWindow = LayerShellQt::Window::get(window);
            if (lWindow) {
                lWindow->setLayer(LayerShellQt::Window::LayerOverlay);
                lWindow->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
                lWindow->setExclusiveZone(0);
            }
#endif
            window->setVisible(true);
        }
    }, Qt::QueuedConnection);

    engine.loadFromModule("org.kde.plasma.keyboard", "Main");

    return app.exec();
}
