#include "waylandvirtualkeyboard.h"
#include "virtual-keyboard-unstable-v1-client-protocol.h"
#include "securebuffer.h"

#include <QDebug>
#include <QDateTime>
#include <QGuiApplication>
#include <QtGui/qpa/qplatformnativeinterface.h>

#include <sys/mman.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>
#include <cstring>
#include <linux/input.h>
#include <linux/uinput.h>
#include <linux/input-event-codes.h>

static const char KEYMAP_STRING[] =
    "xkb_keymap {\n"
    "  xkb_keycodes { include \"evdev+aliases(qwerty)\" };\n"
    "  xkb_types    { include \"complete\" };\n"
    "  xkb_compat   { include \"complete\" };\n"
    "  xkb_symbols  { include \"pc+us+inet(evdev)\" };\n"
    "  xkb_geometry { include \"pc(pc105)\" };\n"
    "};\n";

WaylandVirtualKeyboard::WaylandVirtualKeyboard(QObject *parent)
    : QObject(parent)
{
    initWayland();
    initUinput();
}

WaylandVirtualKeyboard::~WaylandVirtualKeyboard()
{
    if (m_virtualKeyboard) {
        zwp_virtual_keyboard_v1_destroy(m_virtualKeyboard);
        m_virtualKeyboard = nullptr;
    }
    if (m_keymapFd >= 0) {
        close(m_keymapFd);
        m_keymapFd = -1;
    }
    if (m_uinputFd >= 0) {
        ioctl(m_uinputFd, UI_DEV_DESTROY);
        close(m_uinputFd);
        m_uinputFd = -1;
    }
}

void WaylandVirtualKeyboard::initUinput()
{
    m_uinputFd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (m_uinputFd < 0) {
        qWarning() << "Could not open /dev/uinput";
        return;
    }

    ioctl(m_uinputFd, UI_SET_EVBIT, EV_KEY);
    ioctl(m_uinputFd, UI_SET_EVBIT, EV_REL);
    ioctl(m_uinputFd, UI_SET_EVBIT, EV_SYN);

    ioctl(m_uinputFd, UI_SET_RELBIT, REL_X);
    ioctl(m_uinputFd, UI_SET_RELBIT, REL_Y);
    ioctl(m_uinputFd, UI_SET_RELBIT, REL_WHEEL);
    ioctl(m_uinputFd, UI_SET_RELBIT, REL_HWHEEL);

    ioctl(m_uinputFd, UI_SET_KEYBIT, BTN_LEFT);
    ioctl(m_uinputFd, UI_SET_KEYBIT, BTN_RIGHT);
    ioctl(m_uinputFd, UI_SET_KEYBIT, BTN_MIDDLE);

    for (int i = 1; i < 240; ++i) {
        ioctl(m_uinputFd, UI_SET_KEYBIT, i);
    }

    struct uinput_user_dev udev;
    memset(&udev, 0, sizeof(udev));
    snprintf(udev.name, UINPUT_MAX_NAME_SIZE, "Plasma Virtual Keyboard");
    udev.id.bustype = BUS_USB;
    udev.id.vendor = 0x1234;
    udev.id.product = 0x5678;
    udev.id.version = 1;

    if (write(m_uinputFd, &udev, sizeof(udev)) < 0) {
        qWarning() << "uinput write udev failed";
    }
    if (ioctl(m_uinputFd, UI_DEV_CREATE) < 0) {
        qWarning() << "UI_DEV_CREATE failed";
    }

    usleep(100000); // 100ms pause for kernel & KWin libinput device discovery
    qInfo() << "Successfully created and registered uinput evdev virtual keyboard!";
}

void WaylandVirtualKeyboard::sendUinputKey(uint32_t keycode, bool pressed)
{
    if (m_uinputFd < 0) return;

    struct input_event ev;
    memset(&ev, 0, sizeof(ev));
    gettimeofday(&ev.time, nullptr);
    ev.type = EV_KEY;
    ev.code = keycode;
    ev.value = pressed ? 1 : 0;
    ssize_t r1 = write(m_uinputFd, &ev, sizeof(ev));

    memset(&ev, 0, sizeof(ev));
    gettimeofday(&ev.time, nullptr);
    ev.type = EV_SYN;
    ev.code = SYN_REPORT;
    ev.value = 0;
    ssize_t r2 = write(m_uinputFd, &ev, sizeof(ev));

    Q_UNUSED(r1);
    Q_UNUSED(r2);
}

void WaylandVirtualKeyboard::registryHandleGlobal(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version)
{
    auto *self = static_cast<WaylandVirtualKeyboard *>(data);

    if (strcmp(interface, "wl_seat") == 0) {
        self->m_seat = static_cast<struct wl_seat *>(wl_registry_bind(registry, name, &wl_seat_interface, qMin(version, 7u)));
    } else if (strcmp(interface, "zwp_virtual_keyboard_manager_v1") == 0 ||
               (zwp_virtual_keyboard_manager_v1_interface.name && strcmp(interface, zwp_virtual_keyboard_manager_v1_interface.name) == 0)) {
        self->m_manager = static_cast<struct zwp_virtual_keyboard_manager_v1 *>(
            wl_registry_bind(registry, name, &zwp_virtual_keyboard_manager_v1_interface, 1));
    }
}

void WaylandVirtualKeyboard::registryHandleGlobalRemove(void *data, struct wl_registry *registry, uint32_t name)
{
    Q_UNUSED(data);
    Q_UNUSED(registry);
    Q_UNUSED(name);
}

void WaylandVirtualKeyboard::initWayland()
{
    QPlatformNativeInterface *native = QGuiApplication::platformNativeInterface();
    if (!native) return;

    m_display = static_cast<struct wl_display *>(native->nativeResourceForIntegration("wl_display"));
    if (!m_display) return;

    m_registry = wl_display_get_registry(m_display);
    static const struct wl_registry_listener registryListener = {
        WaylandVirtualKeyboard::registryHandleGlobal,
        WaylandVirtualKeyboard::registryHandleGlobalRemove
    };

    wl_registry_add_listener(m_registry, &registryListener, this);
    wl_display_roundtrip(m_display);
    wl_display_roundtrip(m_display);

    if (m_manager && m_seat) {
        m_virtualKeyboard = zwp_virtual_keyboard_manager_v1_create_virtual_keyboard(m_manager, m_seat);
        createKeymap();
        emit connectionChanged();
    }
}

void WaylandVirtualKeyboard::createKeymap()
{
    if (!m_virtualKeyboard) return;

    m_keymapSize = strlen(KEYMAP_STRING) + 1;
    m_keymapFd = memfd_create("plasma-keyboard-keymap", MFD_CLOEXEC);

    if (m_keymapFd < 0) {
        char temp[] = "/tmp/pk-keymap-XXXXXX";
        m_keymapFd = mkstemp(temp);
        if (m_keymapFd >= 0) unlink(temp);
    }

    if (m_keymapFd >= 0) {
        ftruncate(m_keymapFd, m_keymapSize);
        void *ptr = mmap(nullptr, m_keymapSize, PROT_READ | PROT_WRITE, MAP_SHARED, m_keymapFd, 0);
        if (ptr != MAP_FAILED) {
            memcpy(ptr, KEYMAP_STRING, m_keymapSize);
            munmap(ptr, m_keymapSize);
        }
        zwp_virtual_keyboard_v1_keymap(m_virtualKeyboard, 1 /* XKB_KEYMAP_FORMAT_TEXT_V1 */, m_keymapFd, m_keymapSize);
        wl_display_flush(m_display);
    }
}

void WaylandVirtualKeyboard::sendKey(uint32_t keycode, bool pressed)
{
    if (m_virtualKeyboard) {
        uint32_t time = QDateTime::currentMSecsSinceEpoch() & 0xFFFFFFFF;
        zwp_virtual_keyboard_v1_key(m_virtualKeyboard, time, keycode, pressed ? 1 : 0);
        wl_display_flush(m_display);
    }
    if (m_uinputFd >= 0) {
        sendUinputKey(keycode, true);
        usleep(12000);
        sendUinputKey(keycode, false);
    }
}

void WaylandVirtualKeyboard::sendKeySym(uint32_t keysym)
{
    Q_UNUSED(keysym);
}

void WaylandVirtualKeyboard::sendText(const QString &text)
{
    if (text.isEmpty()) return;

    QByteArray utf8 = text.toUtf8();
    size_t len = static_cast<size_t>(utf8.size());
    if (len == 0) return;

    // Use SecureKeyBuffer (locked in RAM via mlock, erased via explicit_bzero)
    SecureKeyBuffer secBuffer(len + 1);
    memcpy(secBuffer.data(), utf8.constData(), std::min(len, secBuffer.size() - 1));

    // Check if string contains non-ASCII characters (accents, symbols like €, etc.)
    bool hasNonAscii = false;
    for (size_t i = 0; i < len; ++i) {
        if (static_cast<unsigned char>(secBuffer.data()[i]) > 127) {
            hasNonAscii = true;
            break;
        }
    }

    if (hasNonAscii) {
        sendEmoji(text);
        secBuffer.clear();
        explicit_bzero(utf8.data(), utf8.size());
        return;
    }

    for (size_t i = 0; i < len; ++i) {
        char c = secBuffer.data()[i];
        uint32_t keycode = 0;
        bool shift = false;

        if (c >= 'a' && c <= 'z') {
            static const uint32_t letterCodes[] = {
                KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I, KEY_J,
                KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T,
                KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z
            };
            keycode = letterCodes[c - 'a'];
        } else if (c >= 'A' && c <= 'Z') {
            static const uint32_t letterCodes[] = {
                KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I, KEY_J,
                KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T,
                KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z
            };
            keycode = letterCodes[c - 'A'];
            shift = true;
        } else if (c >= '0' && c <= '9') {
            static const uint32_t numCodes[] = {
                KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9
            };
            keycode = numCodes[c - '0'];
        } else if (c == ' ') keycode = KEY_SPACE;
        else if (c == '\n') keycode = KEY_ENTER;
        else if (c == '.') keycode = KEY_DOT;
        else if (c == ',') keycode = KEY_COMMA;
        else if (c == '-') keycode = KEY_MINUS;
        else if (c == '_') { keycode = KEY_MINUS; shift = true; }
        else if (c == '=') keycode = KEY_EQUAL;
        else if (c == '+') { keycode = KEY_EQUAL; shift = true; }
        else if (c == '/') keycode = KEY_SLASH;
        else if (c == '?') { keycode = KEY_SLASH; shift = true; }
        else if (c == '*') { keycode = KEY_8; shift = true; }
        else if (c == '!') { keycode = KEY_1; shift = true; }
        else if (c == '@') { keycode = KEY_2; shift = true; }
        else if (c == '#') { keycode = KEY_3; shift = true; }
        else if (c == '$') { keycode = KEY_4; shift = true; }
        else if (c == '%') { keycode = KEY_5; shift = true; }
        else if (c == '^') { keycode = KEY_6; shift = true; }
        else if (c == '&') { keycode = KEY_7; shift = true; }
        else if (c == '(') { keycode = KEY_9; shift = true; }
        else if (c == ')') { keycode = KEY_0; shift = true; }
        else if (c == '[') keycode = KEY_LEFTBRACE;
        else if (c == ']') keycode = KEY_RIGHTBRACE;
        else if (c == '{') { keycode = KEY_LEFTBRACE; shift = true; }
        else if (c == '}') { keycode = KEY_RIGHTBRACE; shift = true; }
        else if (c == ';') keycode = KEY_SEMICOLON;
        else if (c == ':') { keycode = KEY_SEMICOLON; shift = true; }
        else if (c == '\'') keycode = KEY_APOSTROPHE;
        else if (c == '"') { keycode = KEY_APOSTROPHE; shift = true; }
        else if (c == '<') { keycode = KEY_COMMA; shift = true; }
        else if (c == '>') { keycode = KEY_DOT; shift = true; }
        else if (c == '\\') keycode = KEY_BACKSLASH;
        else if (c == '|') { keycode = KEY_BACKSLASH; shift = true; }
        else if (c == '~') { keycode = KEY_GRAVE; shift = true; }
        else if (c == '`') keycode = KEY_GRAVE;

        if (keycode != 0) {
            if (shift) sendUinputKey(KEY_LEFTSHIFT, true);
            sendUinputKey(keycode, true);
            usleep(12000);
            sendUinputKey(keycode, false);
            if (shift) sendUinputKey(KEY_LEFTSHIFT, false);
            usleep(10000);
        }
    }

    // Immediately erase RAM buffer
    secBuffer.clear();
    explicit_bzero(utf8.data(), utf8.size());
}

#include <QClipboard>

void WaylandVirtualKeyboard::sendEmoji(const QString &emoji)
{
    if (emoji.isEmpty()) return;

    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard) {
        clipboard->setText(emoji);
    }
    sendCombo(4, KEY_V);
}

void WaylandVirtualKeyboard::sendCombo(uint32_t modifier, uint32_t keycode)
{
    uint32_t modKey = 0;
    if (modifier == 4) modKey = KEY_LEFTCTRL;
    else if (modifier == 1) modKey = KEY_LEFTSHIFT;
    else if (modifier == 8) modKey = KEY_LEFTALT;

    if (modKey != 0) sendUinputKey(modKey, true);
    sendUinputKey(keycode, true);
    usleep(12000);
    sendUinputKey(keycode, false);
    if (modKey != 0) sendUinputKey(modKey, false);
}

void WaylandVirtualKeyboard::sendBackspace()
{
    sendKey(KEY_BACKSPACE, true);
}

void WaylandVirtualKeyboard::sendCtrlBackspace()
{
    sendCombo(4, KEY_BACKSPACE);
}

void WaylandVirtualKeyboard::sendMouseMove(int dx, int dy)
{
    if (m_uinputFd < 0 || (dx == 0 && dy == 0)) return;

    struct input_event ev[3];
    memset(ev, 0, sizeof(ev));
    gettimeofday(&ev[0].time, nullptr);
    ev[0].type = EV_REL;
    ev[0].code = REL_X;
    ev[0].value = dx;

    gettimeofday(&ev[1].time, nullptr);
    ev[1].type = EV_REL;
    ev[1].code = REL_Y;
    ev[1].value = dy;

    gettimeofday(&ev[2].time, nullptr);
    ev[2].type = EV_SYN;
    ev[2].code = SYN_REPORT;
    ev[2].value = 0;

    ssize_t r = write(m_uinputFd, ev, sizeof(ev));
    Q_UNUSED(r);
}

void WaylandVirtualKeyboard::sendMouseClick(int button, bool pressed)
{
    if (m_uinputFd < 0) return;

    uint32_t btn = BTN_LEFT;
    if (button == 2) btn = BTN_RIGHT;
    else if (button == 3) btn = BTN_MIDDLE;

    struct input_event ev[2];
    memset(ev, 0, sizeof(ev));
    gettimeofday(&ev[0].time, nullptr);
    ev[0].type = EV_KEY;
    ev[0].code = btn;
    ev[0].value = pressed ? 1 : 0;

    gettimeofday(&ev[1].time, nullptr);
    ev[1].type = EV_SYN;
    ev[1].code = SYN_REPORT;
    ev[1].value = 0;

    ssize_t r = write(m_uinputFd, ev, sizeof(ev));
    Q_UNUSED(r);
}

void WaylandVirtualKeyboard::sendMouseScroll(int deltaX, int deltaY)
{
    if (m_uinputFd < 0 || (deltaX == 0 && deltaY == 0)) return;

    struct input_event ev[3];
    int count = 0;
    memset(ev, 0, sizeof(ev));

    if (deltaY != 0) {
        gettimeofday(&ev[count].time, nullptr);
        ev[count].type = EV_REL;
        ev[count].code = REL_WHEEL;
        ev[count].value = deltaY;
        count++;
    }

    if (deltaX != 0) {
        gettimeofday(&ev[count].time, nullptr);
        ev[count].type = EV_REL;
        ev[count].code = REL_HWHEEL;
        ev[count].value = deltaX;
        count++;
    }

    gettimeofday(&ev[count].time, nullptr);
    ev[count].type = EV_SYN;
    ev[count].code = SYN_REPORT;
    ev[count].value = 0;
    count++;

    ssize_t r = write(m_uinputFd, ev, sizeof(struct input_event) * count);
    Q_UNUSED(r);
}
