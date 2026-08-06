#include "keyboardcontroller.h"
#include <QDebug>
#include <QQuickWindow>
#include <QRegion>
#include <QDir>
#include <QFileInfo>

KeyboardController::KeyboardController(QObject *parent)
    : QObject(parent),
      m_activeTheme("TeenageOP1")
{
    m_backspaceHoldTimer.setSingleShot(true);
    m_backspaceHoldTimer.setInterval(1800); // 1.8 seconds hold requirement

    connect(&m_backspaceHoldTimer, &QTimer::timeout, this, [this]() {
        m_backspaceDeletingWord = true;
        emit backspaceDeletingWordChanged();
        emit triggerWordBackspace();

        // Start repeat timer for continuous word deletion while held
        m_backspaceRepeatTimer.start(300);
    });

    connect(&m_backspaceRepeatTimer, &QTimer::timeout, this, [this]() {
        if (m_backspaceDeletingWord) {
            emit triggerWordBackspace();
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
