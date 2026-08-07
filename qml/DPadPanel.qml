import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: dpad
    width: 250
    height: parent.height
    radius: 16
    color: currentTheme && currentTheme.dpadBg ? currentTheme.dpadBg : "#252a34"

    property var currentTheme
    property var vk
    property var controller
    property var mainWindow

    // Linux evdev input keycodes
    readonly property int keyLeft: 105
    readonly property int keyUp: 103
    readonly property int keyDown: 108
    readonly property int keyRight: 106
    readonly property int keyHome: 102
    readonly property int keyEnd: 107
    readonly property int keyDelete: 111
    readonly property int keyA: 30
    readonly property int keyEsc: 1
    readonly property int keyTab: 15

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Text {
            text: "▷ Extended & Modifiers"
            color: currentTheme && currentTheme.dpadHeaderColor ? currentTheme.dpadHeaderColor : "#00a2ed"
            font.family: currentTheme ? currentTheme.fontFamily : "sans-serif"
            font.pixelSize: 11
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        GridLayout {
            columns: 4
            Layout.fillWidth: true
            Layout.fillHeight: true
            rowSpacing: 5
            columnSpacing: 5

            // Row 1: Esc, Tab, Ctrl, Alt
            KeyButton {
                label: "Esc"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyEsc)
            }
            KeyButton {
                label: "Tab"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: if (vk) vk.sendKey(keyTab)
            }
            KeyButton {
                label: "Ctrl"
                isSpecial: true
                isCustomAction: true
                isPrimaryAction: dpad.mainWindow && dpad.mainWindow.ctrlActive
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: {
                    if (dpad.mainWindow) {
                        dpad.mainWindow.ctrlActive = !dpad.mainWindow.ctrlActive
                        if (dpad.mainWindow.ctrlActive) dpad.mainWindow.altActive = false
                    }
                }
            }
            KeyButton {
                label: "Alt"
                isSpecial: true
                isCustomAction: true
                isPrimaryAction: dpad.mainWindow && dpad.mainWindow.altActive
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onReleased: {
                    if (dpad.mainWindow) {
                        dpad.mainWindow.altActive = !dpad.mainWindow.altActive
                        if (dpad.mainWindow.altActive) dpad.mainWindow.ctrlActive = false
                    }
                }
            }

            // Row 2: Home, Up, End, Canc (Accelerating Repeat Timers)
            KeyButton {
                label: "Home"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onPressed: if (controller) controller.startKeyRepeat(keyHome)
                onReleased: if (controller) controller.stopKeyRepeat()
            }
            KeyButton {
                label: "▲"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onPressed: if (controller) controller.startKeyRepeat(keyUp)
                onReleased: if (controller) controller.stopKeyRepeat()
            }
            KeyButton {
                label: "End"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onPressed: if (controller) controller.startKeyRepeat(keyEnd)
                onReleased: if (controller) controller.stopKeyRepeat()
            }
            KeyButton {
                label: "Canc"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onPressed: if (controller) controller.startKeyRepeat(keyDelete)
                onReleased: if (controller) controller.stopKeyRepeat()
            }

            // Row 3: Left, Down, Right, Tutto (Accelerating Repeat Timers)
            KeyButton {
                label: "◄"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onPressed: if (controller) controller.startKeyRepeat(keyLeft)
                onReleased: if (controller) controller.stopKeyRepeat()
            }
            KeyButton {
                label: "▼"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onPressed: if (controller) controller.startKeyRepeat(keyDown)
                onReleased: if (controller) controller.stopKeyRepeat()
            }
            KeyButton {
                label: "►"
                isSpecial: true
                isCustomAction: true
                currentTheme: dpad.currentTheme
                vk: dpad.vk
                Layout.fillWidth: true
                Layout.fillHeight: true
                onPressed: if (controller) controller.startKeyRepeat(keyRight)
                onReleased: if (controller) controller.stopKeyRepeat()
            }
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
        }
    }
}
