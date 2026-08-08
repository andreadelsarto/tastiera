#include "keyboardcontroller.h"
#include <QDebug>
#include <QQuickWindow>
#include <QRegion>
#include <QDir>
#include <QFileInfo>

KeyboardController *KeyboardController::s_instance = nullptr;

KeyboardController* KeyboardController::instance()
{
    return s_instance;
}

KeyboardController::KeyboardController(QObject *parent)
    : QObject(parent),
      m_activeTheme("BreezeDark")
{
    s_instance = this;
    m_backspaceHoldTimer.setSingleShot(true);
    m_backspaceHoldTimer.setInterval(300); // 300ms initial hold delay

    connect(&m_backspaceHoldTimer, &QTimer::timeout, this, [this]() {
        emit triggerBackspace();
        m_backspaceRepeatInterval = 100;
        m_backspaceRepeatTimer.start(m_backspaceRepeatInterval);
    });

    connect(&m_backspaceRepeatTimer, &QTimer::timeout, this, [this]() {
        emit triggerBackspace();
        if (m_backspaceRepeatInterval > 20) {
            m_backspaceRepeatInterval = std::max(20, m_backspaceRepeatInterval - 10);
            m_backspaceRepeatTimer.setInterval(m_backspaceRepeatInterval);
        }
    });

    m_keyRepeatHoldTimer.setSingleShot(true);
    m_keyRepeatHoldTimer.setInterval(250); // 250ms initial hold delay before repeating

    connect(&m_keyRepeatHoldTimer, &QTimer::timeout, this, [this]() {
        emit triggerKeyRepeat(m_currentRepeatKeycode);
        m_keyRepeatInterval = 80;
        m_keyRepeatTimer.start(m_keyRepeatInterval);
    });

    connect(&m_keyRepeatTimer, &QTimer::timeout, this, [this]() {
        emit triggerKeyRepeat(m_currentRepeatKeycode);
        if (m_keyRepeatInterval > 15) {
            m_keyRepeatInterval = std::max(15, m_keyRepeatInterval - 10);
            m_keyRepeatTimer.setInterval(m_keyRepeatInterval);
        }
    });

    // Hardware keyboard detection (touchbar auto-switch disabled per user request)
    checkHardwareKeyboard();
}

void KeyboardController::setSizeMode(const QString &mode)
{
    if (m_sizeMode != mode) {
        m_sizeMode = mode;
        emit sizeModeChanged();
        if (m_sizeMode == "onehand" && m_isSplit) {
            m_isSplit = false;
            emit isSplitChanged();
        }
    }
}

void KeyboardController::setLayoutMode(const QString &mode)
{
    if (m_layoutMode != mode) {
        m_layoutMode = mode;
        emit layoutModeChanged();
    }
}

void KeyboardController::setActiveTheme(const QString &theme)
{
    if (m_activeTheme != theme) {
        m_activeTheme = theme;
        emit activeThemeChanged();
    }
}

void KeyboardController::setKeyboardVisible(bool visible)
{
    if (m_keyboardVisible != visible) {
        m_keyboardVisible = visible;
        emit keyboardVisibleChanged();
    }
}

void KeyboardController::setIsTerminalMode(bool termMode)
{
    if (m_isTerminalMode != termMode) {
        m_isTerminalMode = termMode;
        emit isTerminalModeChanged();
    }
}

void KeyboardController::setIsPasswordMode(bool passwordMode)
{
    if (m_isPasswordMode != passwordMode) {
        m_isPasswordMode = passwordMode;
        emit isPasswordModeChanged();
    }
}

void KeyboardController::setContentHint(uint32_t flags)
{
    // ZWP_TEXT_INPUT_V3_CONTENT_HINT_PASSWORD = 1
    // ZWP_TEXT_INPUT_V3_CONTENT_HINT_SENSITIVE_DATA = 2
    bool isPass = (flags & 0x01) || (flags & 0x02);
    setIsPasswordMode(isPass);
}

void KeyboardController::setSplit(bool split)
{
    if (m_isSplit != split) {
        m_isSplit = split;
        emit isSplitChanged();
    }
}

void KeyboardController::startBackspaceTimer()
{
    m_backspaceDeletingWord = false;
    emit backspaceDeletingWordChanged();

    // Tap action: 1 single character delete
    emit triggerBackspace();

    m_backspaceHoldTimer.start();
}

void KeyboardController::stopBackspaceTimer()
{
    m_backspaceHoldTimer.stop();
    m_backspaceRepeatTimer.stop();
    if (m_backspaceDeletingWord) {
        m_backspaceDeletingWord = false;
        emit backspaceDeletingWordChanged();
    }
}

void KeyboardController::startKeyRepeat(uint32_t keycode)
{
    m_currentRepeatKeycode = keycode;
    m_keyRepeatHoldTimer.start();
}

void KeyboardController::stopKeyRepeat()
{
    m_keyRepeatHoldTimer.stop();
    m_keyRepeatTimer.stop();
}

KeyboardController::~KeyboardController()
{
    if (s_instance == this) {
        s_instance = nullptr;
    }
}

void KeyboardController::toggleVisibility()
{
    qInfo() << "[KeyboardController] toggleVisibility requested via D-Bus / CLI";
    if (s_instance) {
        emit s_instance->toggleVisibilityRequested();
    } else {
        emit toggleVisibilityRequested();
    }
}

void KeyboardController::showKeyboard()
{
    qInfo() << "[KeyboardController] showKeyboard requested";
    emit showRequested();
}

void KeyboardController::hideKeyboard()
{
    qInfo() << "[KeyboardController] hideKeyboard requested";
    emit hideRequested();
}

void KeyboardController::updateInputMask(QObject *windowObj, int x, int y, int width, int height)
{
    QQuickWindow *window = qobject_cast<QQuickWindow*>(windowObj);
    if (!window) return;
    window->setMask(QRegion(x, y, width, height));
}

void KeyboardController::checkHardwareKeyboard()
{
    // Simple libinput / sysfs check for external hardware keyboards
    QDir inputDevices("/sys/class/input");
    bool foundHardwareKb = false;

    for (const QString &entry : inputDevices.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        if (entry.startsWith("event") || entry.startsWith("input")) {
            QString nameFile = QString("/sys/class/input/%1/device/name").arg(entry);
            if (QFile::exists(nameFile)) {
                QFile f(nameFile);
                if (f.open(QIODevice::ReadOnly)) {
                    QString name = QString::fromUtf8(f.readAll()).trimmed().toLower();
                    if (name.contains("keyboard") && !name.contains("virtual") && !name.contains("power")) {
                        foundHardwareKb = true;
                        break;
                    }
                }
            }
        }
    }

    if (m_isHardwareKeyboardConnected != foundHardwareKb) {
        m_isHardwareKeyboardConnected = foundHardwareKb;
        emit hardwareKeyboardStatusChanged();
    }
}
