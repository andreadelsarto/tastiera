import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: dpad
    width: 220
    height: parent.height
    color: "transparent"

    property var currentTheme
    property var vk

    // Linux evdev input keycodes
    readonly property int keyLeft: 105
    readonly property int keyUp: 103
    readonly property int keyDown: 108
    readonly property int keyRight: 106
    readonly property int keyHome: 102
    readonly property int keyEnd: 107
    readonly property int keyDelete: 111
    readonly property int keyA: 30

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        Text {
            text: "NAV D-PAD"
            color: currentTheme ? currentTheme.accentColor : "#3daee9"
            font.family: currentTheme ? currentTheme.fontFamily : "sans-serif"
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        GridLayout {
            columns: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            rowSpacing: 4
            columnSpacing: 4

            // Row 1: Home, Up, End
            KeyButton {
                label: "Home"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyHome)
            }
            KeyButton {
                label: "▲"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyUp)
            }
            KeyButton {
                label: "End"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyEnd)
            }

            // Row 2: Left, Down, Right
            KeyButton {
                label: "◄"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyLeft)
            }
            KeyButton {
                label: "▼"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyDown)
            }
            KeyButton {
                label: "►"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyRight)
            }

            // Row 3: Canc, Select All (Span 2)
            KeyButton {
                label: "Canc"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyDelete)
            }
            KeyButton {
                label: "Sel. Tutto"
                isSpecial: true
                currentTheme: dpad.currentTheme
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.columnSpan: 2
                onReleased: if (vk) vk.sendCombo(4 /* Ctrl */, keyA)
            }
        }
    }
}
