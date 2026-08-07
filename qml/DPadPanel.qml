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

        // VIEW B: KDE Connect Style Multi-Touch Touchpad Canvas View
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: dpad.subMode === "touchpad"
            spacing: 6

            // Main Trackpad Surface
            Rectangle {
                id: padSurface
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: currentTheme && currentTheme.keyBg ? currentTheme.keyBg : "#181b22"
                border.color: multiTouchArea.pressed ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : (currentTheme ? currentTheme.keyBorderColor : "#333b4d")
                border.width: 1

                // Subtle visual grid texture & instructions
                Text {
                    anchors.centerIn: parent
                    text: "1-finger: Move & Tap\n2-fingers: Scroll & Right-Click\nRight bar: Scroll Strip"
                    horizontalAlignment: Text.AlignHCenter
                    color: currentTheme && currentTheme.subTextColor ? currentTheme.subTextColor : "#5a6478"
                    font.pixelSize: 10
                    opacity: multiTouchArea.pressed ? 0.3 : 0.7
                }

                // Dedicated Scroll Bar Strip (Right Edge)
                Rectangle {
                    id: scrollStrip
                    width: 24
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 4
                    radius: 8
                    color: scrollMouseArea.pressed ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "#222733"
                    border.color: "#384152"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "▲\n│\n▼"
                        horizontalAlignment: Text.AlignHCenter
                        color: "#9aa4b8"
                        font.pixelSize: 9
                        font.bold: true
                    }

                    MouseArea {
                        id: scrollMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.SizeVerCursor
                        property real lastY: 0

                        onPressed: (mouse) => {
                            lastY = mouse.y
                        }

                        onPositionChanged: (mouse) => {
                            if (pressed && vk) {
                                var dy = mouse.y - lastY
                                if (Math.abs(dy) >= 4) {
                                    var ticks = dy > 0 ? -1 : 1
                                    vk.sendMouseScroll(0, ticks)
                                    lastY = mouse.y
                                }
                            }
                        }
                    }
                }

                // MultiTouch Area (KDE Connect Gesture Protocol Engine)
                MultiPointTouchArea {
                    id: multiTouchArea
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: scrollStrip.left
                    anchors.margins: 4
                    touchPoints: [
                        TouchPoint { id: p1 },
                        TouchPoint { id: p2 }
                    ]

                    property real startTime: 0
                    property real startP1X: 0
                    property real startP1Y: 0
                    property bool isMultiTouchActive: false

                    onPressed: {
                        startTime = Date.now()
                        startP1X = p1.x
                        startP1Y = p1.y
                        isMultiTouchActive = p1.pressed && p2.pressed
                    }

                    onUpdated: {
                        if (!vk) return

                        if (p1.pressed && p2.pressed) {
                            // 2-Finger Drag -> Scroll (KDE Connect Scroll Protocol)
                            isMultiTouchActive = true
                            var scrollDy = p1.y - p1.previousY
                            var scrollDx = p1.x - p1.previousX

                            if (Math.abs(scrollDy) >= 6) {
                                var ticksY = scrollDy > 0 ? -1 : 1
                                vk.sendMouseScroll(0, ticksY)
                            }
                            if (Math.abs(scrollDx) >= 6) {
                                var ticksX = scrollDx > 0 ? 1 : -1
                                vk.sendMouseScroll(ticksX, 0)
                            }
                        } else if (p1.pressed && !p2.pressed && !isMultiTouchActive) {
                            // 1-Finger Drag -> Cursor Relative Movement with Velocity Acceleration
                            var dx = p1.x - p1.previousX
                            var dy = p1.y - p1.previousY
                            var speed = Math.sqrt(dx * dx + dy * dy)
                            var accel = 1.0 + Math.min(speed * 0.12, 2.5)

                            vk.sendMouseMove(Math.round(dx * accel), Math.round(dy * accel))
                        }
                    }

                    onReleased: {
                        var duration = Date.now() - startTime

                        if (isMultiTouchActive) {
                            // 2-Finger Tap -> Right Click
                            if (duration < 250 && vk) {
                                vk.sendMouseClick(2, true)
                                vk.sendMouseClick(2, false)
                            }
                        } else if (p1.pressed === false && p2.pressed === false) {
                            // 1-Finger Tap -> Left Click
                            var dist = Math.sqrt(Math.pow(p1.x - startP1X, 2) + Math.pow(p1.y - startP1Y, 2))
                            if (duration < 200 && dist < 6 && vk) {
                                vk.sendMouseClick(1, true)
                                vk.sendMouseClick(1, false)
                            }
                        }
                        if (!p1.pressed && !p2.pressed) {
                            isMultiTouchActive = false
                        }
                    }
                }
            }

            // Mouse Buttons Row (Left Click & Right Click)
            RowLayout {
                Layout.fillWidth: true
                height: 36
                spacing: 6

                KeyButton {
                    label: "🖱️ L-Click"
                    isSpecial: true
                    isCustomAction: true
                    currentTheme: dpad.currentTheme
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onPressed: if (vk) vk.sendMouseClick(1, true)
                    onReleased: if (vk) vk.sendMouseClick(1, false)
                }

                KeyButton {
                    label: "🖱️ R-Click"
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
