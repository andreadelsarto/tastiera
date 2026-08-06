#ifndef WAYLANDVIRTUALKEYBOARD_H
#define WAYLANDVIRTUALKEYBOARD_H

#include <QObject>
#include <QString>
#include <wayland-client.h>

struct zwp_virtual_keyboard_manager_v1;
struct zwp_virtual_keyboard_v1;

class WaylandVirtualKeyboard : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)

public:
    explicit WaylandVirtualKeyboard(QObject *parent = nullptr);
    ~WaylandVirtualKeyboard();

    bool isConnected() const { return m_virtualKeyboard != nullptr; }

    Q_INVOKABLE void sendKey(uint32_t keycode, bool pressed = true);
    Q_INVOKABLE void sendKeySym(uint32_t keysym);
    Q_INVOKABLE void sendText(const QString &text);
    Q_INVOKABLE void sendCombo(uint32_t modifier, uint32_t keycode);
    Q_INVOKABLE void sendBackspace();
    Q_INVOKABLE void sendCtrlBackspace();

signals:
    void connectionChanged();

private:
    void initWayland();
    void createKeymap();
    static void registryHandleGlobal(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version);
    static void registryHandleGlobalRemove(void *data, struct wl_registry *registry, uint32_t name);

    struct wl_display *m_display{nullptr};
    struct wl_registry *m_registry{nullptr};
    struct wl_seat *m_seat{nullptr};
    struct zwp_virtual_keyboard_manager_v1 *m_manager{nullptr};
    struct zwp_virtual_keyboard_v1 *m_virtualKeyboard{nullptr};
    int m_keymapFd{-1};
    size_t m_keymapSize{0};
    int m_uinputFd{-1};
    void initUinput();
    void sendUinputKey(uint32_t keycode, bool pressed);
};

#endif // WAYLANDVIRTUALKEYBOARD_H
