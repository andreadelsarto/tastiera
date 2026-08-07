import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: dpad
    width: 260
    height: parent.height
    radius: 16
    color: currentTheme && currentTheme.dpadBg ? currentTheme.dpadBg : "#252a34"

    property var currentTheme
    property var vk
    property var controller
    property var mainWindow

    // Sub-mode: "dpad" vs "touchpad"
    property string subMode: "dpad"

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

        // Segmented Header Switcher: [ 🎯 D-Pad ] | [ 🖱️ Touchpad ]
        Rectangle {
            Layout.fillWidth: true
            height: 28
            radius: 14
            color: currentTheme && currentTheme.headerPillBg ? currentTheme.headerPillBg : "#1a1d24"

            Row {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 2

                // D-Pad Tab
                Rectangle {
                    width: (parent.width - 2) / 2
                    height: parent.height
                    radius: 12
                    color: dpad.subMode === "dpad" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "🎯 D-Pad"
                        color: dpad.subMode === "dpad" ? "#ffffff" : "#a0a5b0"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: dpad.subMode = "dpad"
                    }
                }

                // Touchpad Tab
                Rectangle {
                    width: (parent.width - 2) / 2
                    height: parent.height
                    radius: 12
                    color: dpad.subMode === "touchpad" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "🖱️ Touchpad"
                        color: dpad.subMode === "touchpad" ? "#ffffff" : "#a0a5b0"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: dpad.subMode = "touchpad"
                    }
                }
            }
        }

        // VIEW A: D-Pad Grid View
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: dpad.subMode === "dpad"
            spacing: 5

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
                    onCanceled: if (controller) controller.stopKeyRepeat()
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
                    onCanceled: if (controller) controller.stopKeyRepeat()
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
                    onCanceled: if (controller) controller.stopKeyRepeat()
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
                    onCanceled: if (controller) controller.stopKeyRepeat()
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
                    onCanceled: if (controller) controller.stopKeyRepeat()
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
                    onCanceled: if (controller) controller.stopKeyRepeat()
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
                    onCanceled: if (controller) controller.stopKeyRepeat()
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

        // VIEW B: Touchpad Surface Area View
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: dpad.subMode === "touchpad"
            spacing: 6

            // Interactive Trackpad Canvas Surface
            Rectangle {
                id: trackpadSurface
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: currentTheme && currentTheme.keyBg ? currentTheme.keyBg : "#1e222b"
                border.color: currentTheme && currentTheme.accentColor ? currentTheme.accentColor : "#00a2ed"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "✨ Drag finger to move cursor"
                    color: currentTheme && currentTheme.subTextColor ? currentTheme.subTextColor : "#6b7280"
                    font.pixelSize: 10
                    opacity: padMouseArea.pressed ? 0.3 : 0.8
                }

                MouseArea {
                    id: padMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    property point lastPos: "0,0"

                    onPressed: (mouse) => {
                        lastPos = Qt.point(mouse.x, mouse.y)
                    }

                    onPositionChanged: (mouse) => {
                        if (pressed && vk) {
                            var dx = (mouse.x - lastPos.x) * 2.2
                            var dy = (mouse.y - lastPos.y) * 2.2
                            vk.sendMouseMove(Math.round(dx), Math.round(dy))
                            lastPos = Qt.point(mouse.x, mouse.y)
                        }
                    }

                    onClicked: {
                        if (vk) {
                            vk.sendMouseClick(1, true)
                            vk.sendMouseClick(1, false)
                        }
                    }
                }
            }

            // Mouse Buttons Row (Left Click & Right Click)
            RowLayout {
                Layout.fillWidth: true
                height: 38
                spacing: 6

                KeyButton {
                    label: "🖱️ Left Click"
                    isSpecial: true
                    isCustomAction: true
                    currentTheme: dpad.currentTheme
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onPressed: if (vk) vk.sendMouseClick(1, true)
                    onReleased: if (vk) vk.sendMouseClick(1, false)
                }

                KeyButton {
                    label: "🖱️ Right Click"
                    isSpecial: true
                    isCustomAction: true
                    currentTheme: dpad.currentTheme
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onPressed: if (vk) vk.sendMouseClick(2, true)
                    onReleased: if (vk) vk.sendMouseClick(2, false)
                }
            }
        }
    }
}
