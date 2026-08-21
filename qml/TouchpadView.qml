import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var currentTheme
    property var vk
    property var controller
    property real sensitivity: 1.3

    color: currentTheme ? currentTheme.backgroundColor : "#0b1329"
    radius: currentTheme ? currentTheme.cardRadius : 24
    border.color: currentTheme ? currentTheme.cardBorderColor : "#1e293b"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // ── Top Slim Control Bar (Matching Screenshot Header) ─────────
        RowLayout {
            Layout.fillWidth: true
            height: 40
            spacing: 6

            // 1. Blue Accent Keyboard Toggle Button (Top-Left)
            Rectangle {
                width: 54
                Layout.fillHeight: true
                radius: 10
                color: currentTheme ? currentTheme.accentColor : "#0284c7"

                // Mini keyboard 3x3 dot matrix grid icon
                Grid {
                    anchors.centerIn: parent
                    columns: 3
                    spacing: 3

                    Repeater {
                        model: 9
                        delegate: Rectangle {
                            width: 5
                            height: 4
                            radius: 1.5
                            color: "#ffffff"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (controller) {
                            controller.sizeMode = "normal"
                        }
                    }
                }
            }

            // 2. Multitask / Overview (|||)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: multiTaskArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#22334d"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            width: 3
                            height: 14
                            radius: 1.5
                            color: currentTheme ? currentTheme.textColor : "#e2e8f0"
                        }
                    }
                }

                MouseArea {
                    id: multiTaskArea
                    anchors.fill: parent
                    onClicked: {
                        if (vk) {
                            vk.pressAndReleaseKey(125) // Super / Meta key
                        }
                    }
                }
            }

            // 3. Home / Desktop (⌂ / O)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: homeArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#22334d"
                border.width: 1

                Rectangle {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    radius: 7
                    color: "transparent"
                    border.color: currentTheme ? currentTheme.textColor : "#e2e8f0"
                    border.width: 2
                }

                MouseArea {
                    id: homeArea
                    anchors.fill: parent
                    onClicked: {
                        if (vk) {
                            vk.sendCombo(125, 32) // Super + D
                        }
                    }
                }
            }

            // 4. Back / ESC (←)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: backArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#22334d"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    color: currentTheme ? currentTheme.textColor : "#e2e8f0"
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    onClicked: {
                        if (vk) {
                            vk.pressAndReleaseKey(1) // ESC
                        }
                    }
                }
            }

            // 5. Left Click Quick Button
            Rectangle {
                width: 64
                Layout.fillHeight: true
                radius: 10
                color: lClickArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#22334d"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "L-Click"
                    color: currentTheme ? currentTheme.textColor : "#e2e8f0"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: lClickArea
                    anchors.fill: parent
                    onPressed: if (vk) vk.sendMouseClick(1, true)
                    onReleased: if (vk) vk.sendMouseClick(1, false)
                }
            }

            // 6. Right Click Quick Button
            Rectangle {
                width: 64
                Layout.fillHeight: true
                radius: 10
                color: rClickArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#22334d"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "R-Click"
                    color: currentTheme ? currentTheme.textColor : "#e2e8f0"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: rClickArea
                    anchors.fill: parent
                    onPressed: if (vk) vk.sendMouseClick(3, true)
                    onReleased: if (vk) vk.sendMouseClick(3, false)
                }
            }

            // 7. Sensitivity Toggle Pill
            Rectangle {
                width: 56
                Layout.fillHeight: true
                radius: 10
                color: (currentTheme && currentTheme.keyBackgroundColor) ? currentTheme.keyBackgroundColor : "#1e293b"
                border.color: currentTheme ? currentTheme.keyBorderColor : "#22334d"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.sensitivity === 1.0 ? "1.0x" : (root.sensitivity === 1.3 ? "1.3x" : "2.0x")
                    color: currentTheme ? currentTheme.accentTextColor : "#38bdf8"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.sensitivity === 1.0) root.sensitivity = 1.3
                        else if (root.sensitivity === 1.3) root.sensitivity = 2.0
                        else root.sensitivity = 1.0
                    }
                }
            }
        }

        // ── Main Touchpad Area with Right Scroll Strip ────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // Giant Trackpad Surface
            Rectangle {
                id: touchSurface
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 16
                color: Qt.darker(currentTheme ? currentTheme.backgroundColor : "#0b1329", 1.25)
                border.color: currentTheme ? currentTheme.keyBorderColor : "#1e293b"
                border.width: 1
                clip: true

                // Interactive Touch Dot
                Rectangle {
                    id: touchCursorDot
                    width: 36
                    height: 36
                    radius: 18
                    color: Qt.hsla(0.58, 0.9, 0.6, 0.35)
                    border.color: currentTheme ? currentTheme.accentColor : "#0284c7"
                    border.width: 2
                    visible: false
                    z: 10

                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                // Subtle Central Hint
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    opacity: padMouseArea.pressed ? 0.05 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Touchpad Surface"
                        color: currentTheme ? currentTheme.textColor : "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Drag finger to move mouse  •  Tap to click"
                        color: currentTheme ? currentTheme.textColor : "#aaaaaa"
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    id: padMouseArea
                    anchors.fill: parent
                    hoverEnabled: false
                    preventStealing: true

                    property point lastPos: Qt.point(0, 0)
                    property point startPos: Qt.point(0, 0)
                    property real pressTime: 0
                    property bool hasMoved: false

                    onPressed: (mouse) => {
                        pressTime = Date.now()
                        lastPos = Qt.point(mouse.x, mouse.y)
                        startPos = Qt.point(mouse.x, mouse.y)
                        hasMoved = false
                        touchCursorDot.x = mouse.x - touchCursorDot.width / 2
                        touchCursorDot.y = mouse.y - touchCursorDot.height / 2
                        touchCursorDot.visible = true
                    }

                    onPositionChanged: (mouse) => {
                        if (pressed) {
                            var dx = (mouse.x - lastPos.x) * root.sensitivity
                            var dy = (mouse.y - lastPos.y) * root.sensitivity

                            if (Math.abs(dx) > 0.05 || Math.abs(dy) > 0.05) {
                                hasMoved = true
                                if (vk) {
                                    vk.sendMouseMove(Math.round(dx), Math.round(dy))
                                }
                            }

                            lastPos = Qt.point(mouse.x, mouse.y)
                            touchCursorDot.x = mouse.x - touchCursorDot.width / 2
                            touchCursorDot.y = mouse.y - touchCursorDot.height / 2
                        }
                    }

                    onReleased: (mouse) => {
                        touchCursorDot.visible = false
                        var duration = Date.now() - pressTime
                        var dist = Math.hypot(mouse.x - startPos.x, mouse.y - startPos.y)

                        if (!hasMoved && dist < 10 && duration < 300) {
                            if (vk) {
                                vk.sendMouseClick(1, true)
                                vk.sendMouseClick(1, false)
                            }
                        }
                    }

                    onWheel: (wheel) => {
                        if (vk) {
                            var delta = wheel.angleDelta.y / 120
                            vk.sendMouseScroll(0, delta)
                        }
                    }
                }
            }

            // Right-side Vertical Scroll Bar Strip
            Rectangle {
                width: 46
                Layout.fillHeight: true
                radius: 14
                color: Qt.darker(currentTheme ? currentTheme.backgroundColor : "#0b1329", 1.15)
                border.color: currentTheme ? currentTheme.keyBorderColor : "#1e293b"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    // Scroll Up Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 8
                        color: scrollUpArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")

                        Text {
                            anchors.centerIn: parent
                            text: "▲"
                            color: currentTheme ? currentTheme.textColor : "#ffffff"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: scrollUpArea
                            anchors.fill: parent
                            onClicked: if (vk) vk.sendMouseScroll(0, 3)
                        }
                    }

                    // Drag Scroll Area
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: scrollDragArea.pressed ? (currentTheme ? currentTheme.accentColor : "#0284c7") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "⇅\nScroll"
                            horizontalAlignment: Text.AlignHCenter
                            color: currentTheme ? currentTheme.textColor : "#888888"
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: scrollDragArea
                            anchors.fill: parent
                            property real lastY: 0

                            onPressed: (mouse) => {
                                lastY = mouse.y
                            }

                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    var dy = mouse.y - lastY
                                    if (Math.abs(dy) > 6) {
                                        if (vk) {
                                            var scrollDelta = Math.round(-dy / 6)
                                            vk.sendMouseScroll(0, scrollDelta)
                                        }
                                        lastY = mouse.y
                                    }
                                }
                            }
                        }
                    }

                    // Scroll Down Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 8
                        color: scrollDownArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")

                        Text {
                            anchors.centerIn: parent
                            text: "▼"
                            color: currentTheme ? currentTheme.textColor : "#ffffff"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: scrollDownArea
                            anchors.fill: parent
                            onClicked: if (vk) vk.sendMouseScroll(0, -3)
                        }
                    }
                }
            }
        }
    }
}
