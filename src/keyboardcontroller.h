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
    Q_PROPERTY(bool keyboardVisible READ keyboardVisible WRITE setKeyboardVisible NOTIFY keyboardVisibleChanged)
    Q_PROPERTY(bool isSplit READ isSplit WRITE setSplit NOTIFY isSplitChanged)
    Q_PROPERTY(bool isTerminalMode READ isTerminalMode WRITE setIsTerminalMode NOTIFY isTerminalModeChanged)
    Q_PROPERTY(bool isPasswordMode READ isPasswordMode WRITE setIsPasswordMode NOTIFY isPasswordModeChanged)
    Q_PROPERTY(bool isHardwareKeyboardConnected READ isHardwareKeyboardConnected NOTIFY hardwareKeyboardStatusChanged)
    Q_PROPERTY(bool backspaceDeletingWord READ backspaceDeletingWord NOTIFY backspaceDeletingWordChanged)

public:
    explicit KeyboardController(QObject *parent = nullptr);
    ~KeyboardController() override;

    static KeyboardController *instance();

    bool isPasswordMode() const { return m_isPasswordMode; }
    void setIsPasswordMode(bool passwordMode);
    Q_INVOKABLE void setContentHint(uint32_t flags);

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

    bool isTerminalMode() const { return m_isTerminalMode; }
    void setIsTerminalMode(bool termMode);

    bool keyboardVisible() const { return m_keyboardVisible; }
    void setKeyboardVisible(bool visible);

    Q_INVOKABLE void startBackspaceTimer();
    Q_INVOKABLE void stopBackspaceTimer();
    Q_INVOKABLE void startKeyRepeat(uint32_t keycode);
    Q_INVOKABLE void stopKeyRepeat();
    Q_INVOKABLE void updateInputMask(QObject *windowObj, int x, int y, int width, int height);

public slots:
    Q_SCRIPTABLE Q_INVOKABLE void toggleVisibility();
    Q_SCRIPTABLE Q_INVOKABLE void showKeyboard();
    Q_SCRIPTABLE Q_INVOKABLE void hideKeyboard();

signals:
    void toggleVisibilityRequested();
    void showRequested();
    void hideRequested();
    void sizeModeChanged();
    void layoutModeChanged();
    void isSplitChanged();
    void isTerminalModeChanged();
    void isPasswordModeChanged();
    void activeThemeChanged();
    void keyboardVisibleChanged();
    void hardwareKeyboardStatusChanged();
    void backspaceDeletingWordChanged();
    void triggerBackspace();
    void triggerWordBackspace();
    void triggerKeyRepeat(uint32_t keycode);

private:
    void checkHardwareKeyboard();

    QString m_sizeMode{"normal"}; // "normal", "full", "onehand"
    QString m_layoutMode{"abc"};  // "abc", "accenti", "symbols", "numpad", "emoji", "klipper"
    QString m_activeTheme{"BreezeDark"}; // "BreezeDark", "TeenageOP1", "NothingDark", "NothingLight"
    bool m_isSplit = false;
    bool m_isTerminalMode = true;
    bool m_isPasswordMode = false;
    bool m_isHardwareKeyboardConnected = false;
    bool m_backspaceDeletingWord = false;
    bool m_keyboardVisible = true;
    QTimer m_backspaceHoldTimer;
    QTimer m_backspaceRepeatTimer;
    int m_backspaceRepeatInterval = 100;
    QTimer m_keyRepeatHoldTimer;
    QTimer m_keyRepeatTimer;
    int m_keyRepeatInterval = 100;
    uint32_t m_currentRepeatKeycode = 0;

    static KeyboardController *s_instance;
};

#endif // KEYBOARDCONTROLLER_H
