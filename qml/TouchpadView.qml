import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var currentTheme
    property var vk
    property var controller
    property real sensitivity: 1.2

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
            height: 38
            spacing: 6

            // 1. Blue Accent Keyboard Toggle Button (Top-Left)
            Rectangle {
                width: 52
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
                            // Super / Meta key for overview / activities
                            vk.pressAndReleaseKey(125)
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
                            // Super + D (Show Desktop)
                            vk.sendCombo(125, 32)
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
                            // Escape
                            vk.pressAndReleaseKey(1)
                        }
                    }
                }
            }

            // 5. Left Click Quick Button
            Rectangle {
                width: 58
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
                width: 58
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
                width: 52
                Layout.fillHeight: true
                radius: 10
                color: currentTheme ? currentTheme.specialKeyBackgroundColor : "#1e293b"
                border.color: currentTheme ? currentTheme.keyBorderColor : "#22334d"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.sensitivity === 1.0 ? "1.0x" : (root.sensitivity === 1.5 ? "1.5x" : "2.0x")
                    color: currentTheme ? currentTheme.accentTextColor : "#38bdf8"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.sensitivity === 1.0) root.sensitivity = 1.5
                        else if (root.sensitivity === 1.5) root.sensitivity = 2.0
                        else root.sensitivity = 1.0
                    }
                }
            }
        }

        // ── Giant Touchpad Surface (Full Area) ────────────────────────
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
                opacity: touchArea.pressed ? 0.05 : 0.25
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Touchpad"
                    color: currentTheme ? currentTheme.textColor : "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Tap = Left Click  •  2-Finger Tap = Right Click  •  2-Finger Drag = Scroll"
                    color: currentTheme ? currentTheme.textColor : "#aaaaaa"
                    font.pixelSize: 11
                }
            }

            MultiPointTouchArea {
                id: touchArea
                anchors.fill: parent
                minimumTouchPoints: 1
                maximumTouchPoints: 2

                property point lastPoint1: Qt.point(0, 0)
                property point startPoint1: Qt.point(0, 0)
                property point lastPoint2: Qt.point(0, 0)
                property real totalDistanceMoved: 0
                property real pressStartTime: 0

                touchPoints: [
                    TouchPoint { id: tp1 },
                    TouchPoint { id: tp2 }
                ]

                onPressed: (touchPoints) => {
                    pressStartTime = Date.now()
                    totalDistanceMoved = 0

                    if (touchPoints.length >= 1) {
                        lastPoint1 = Qt.point(tp1.x, tp1.y)
                        startPoint1 = Qt.point(tp1.x, tp1.y)

                        touchCursorDot.x = tp1.x - touchCursorDot.width / 2
                        touchCursorDot.y = tp1.y - touchCursorDot.height / 2
                        touchCursorDot.visible = true
                    }
                    if (touchPoints.length >= 2) {
                        lastPoint2 = Qt.point(tp2.x, tp2.y)
                    }
                }

                onUpdated: (touchPoints) => {
                    if (touchPoints.length === 1 && tp1.pressed) {
                        var dx = (tp1.x - lastPoint1.x) * root.sensitivity
                        var dy = (tp1.y - lastPoint1.y) * root.sensitivity

                        totalDistanceMoved += Math.sqrt(dx * dx + dy * dy)

                        if (vk && (Math.abs(dx) > 0.05 || Math.abs(dy) > 0.05)) {
                            vk.sendMouseMove(Math.round(dx), Math.round(dy))
                        }

                        lastPoint1 = Qt.point(tp1.x, tp1.y)

                        touchCursorDot.x = tp1.x - touchCursorDot.width / 2
                        touchCursorDot.y = tp1.y - touchCursorDot.height / 2
                    }
                    else if (touchPoints.length >= 2 && tp1.pressed && tp2.pressed) {
                        // Two-finger scroll
                        var scrollDy = Math.round((tp1.y - lastPoint1.y) / 3.0)
                        var scrollDx = Math.round((tp1.x - lastPoint1.x) / 3.0)

                        if (vk && (scrollDy !== 0 || scrollDx !== 0)) {
                            vk.sendMouseScroll(scrollDx, -scrollDy)
                        }

                        lastPoint1 = Qt.point(tp1.x, tp1.y)
                        lastPoint2 = Qt.point(tp2.x, tp2.y)
                    }
                }

                onReleased: (touchPoints) => {
                    var duration = Date.now() - pressStartTime
                    touchCursorDot.visible = false

                    // Tap-to-click check (short duration + minimal movement)
                    if (totalDistanceMoved < 8 && duration < 280) {
                        if (vk) {
                            if (touchPoints.length >= 2) {
                                // 2-finger tap = Right click
                                vk.sendMouseClick(3, true)
                                vk.sendMouseClick(3, false)
                            } else {
                                // 1-finger tap = Left click
                                vk.sendMouseClick(1, true)
                                vk.sendMouseClick(1, false)
                            }
                        }
                    }
                }
            }
        }
    }
}
