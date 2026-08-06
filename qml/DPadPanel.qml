import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: dpad
    width: 210
    height: parent.height
    radius: 16
    color: currentTheme && currentTheme.dpadBg ? currentTheme.dpadBg : "#252a34"

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
        anchors.margins: 10
        spacing: 6

        Text {
            text: "▷ D-Pad (Modalità Estesa)"
            color: currentTheme && currentTheme.dpadHeaderColor ? currentTheme.dpadHeaderColor : "#00a2ed"
            font.family: currentTheme ? currentTheme.fontFamily : "sans-serif"
            font.pixelSize: 11
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        GridLayout {
            columns: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            rowSpacing: 6
            columnSpacing: 6

            // Row 1: Home, Up, End
            KeyButton {
                label: "Home"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyHome)
            }
            KeyButton {
                label: "▲"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyUp)
            }
            KeyButton {
                label: "End"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyEnd)
            }

            // Row 2: Left, Down, Right
            KeyButton {
                label: "◄"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyLeft)
            }
            KeyButton {
                label: "▼"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyDown)
            }
            KeyButton {
                label: "►"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyRight)
            }

            // Row 3: Tutto, Canc
            KeyButton {
                label: "Tutto"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendCombo(4 /* Ctrl */, keyA)
            }
            KeyButton {
                label: "Canc"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.columnSpan: 2
                onReleased: if (vk) vk.sendKey(keyDelete)
            }
        }
    }
}
