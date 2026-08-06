#ifndef KEYBOARDCONTROLLER_H
#define KEYBOARDCONTROLLER_H

#include <QObject>
#include <QString>
#include <QTimer>

class KeyboardController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sizeMode READ sizeMode WRITE setSizeMode NOTIFY sizeModeChanged)
    Q_PROPERTY(QString layoutMode READ layoutMode WRITE setLayoutMode NOTIFY layoutModeChanged)
    Q_PROPERTY(QString activeTheme READ activeTheme WRITE setActiveTheme NOTIFY activeThemeChanged)
    Q_PROPERTY(bool isSplit READ isSplit WRITE setSplit NOTIFY isSplitChanged)
    Q_PROPERTY(bool isHardwareKeyboardConnected READ isHardwareKeyboardConnected NOTIFY hardwareKeyboardStatusChanged)
    Q_PROPERTY(bool backspaceDeletingWord READ backspaceDeletingWord NOTIFY backspaceDeletingWordChanged)

public:
    explicit KeyboardController(QObject *parent = nullptr);

    QString sizeMode() const { return m_sizeMode; }
    void setSizeMode(const QString &mode);

    QString layoutMode() const { return m_layoutMode; }
    void setLayoutMode(const QString &mode);

    QString activeTheme() const { return m_activeTheme; }
    void setActiveTheme(const QString &theme);

    bool isSplit() const { return m_isSplit; }
    void setSplit(bool split);

    bool isHardwareKeyboardConnected() const { return m_isHardwareKeyboardConnected; }
    bool backspaceDeletingWord() const { return m_backspaceDeletingWord; }

    Q_INVOKABLE void startBackspaceTimer();
    Q_INVOKABLE void stopBackspaceTimer();
    Q_INVOKABLE void updateInputMask(QObject *windowObj, int x, int y, int width, int height);

signals:
    void sizeModeChanged();
    void layoutModeChanged();
    void activeThemeChanged();
    void isSplitChanged();
    void hardwareKeyboardStatusChanged();
    void backspaceDeletingWordChanged();
    void triggerBackspace();
    void triggerWordBackspace();

private:
    void checkHardwareKeyboard();

    QString m_sizeMode{"normal"}; // "normal", "full", "onehand"
    QString m_layoutMode{"abc"};  // "abc", "accenti", "symbols", "numpad", "emoji", "klipper"
    QString m_activeTheme{"TeenageOP1"}; // "TeenageOP1", "BreezeDark", "NothingDark", "NothingLight"
    bool m_isSplit{false};
    bool m_isHardwareKeyboardConnected{false};
    bool m_backspaceDeletingWord{false};

    QTimer m_backspaceHoldTimer;
    QTimer m_backspaceRepeatTimer;
};

#endif // KEYBOARDCONTROLLER_H
