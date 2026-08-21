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

        // ── Top Header / Toolbar ──────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: currentTheme ? currentTheme.specialKeyBackgroundColor : "#1e293b"

                Text {
                    anchors.centerIn: parent
                    text: "🖱️"
                    font.pixelSize: 14
                }
            }

            Text {
                text: "Touchpad Mode"
                color: currentTheme ? currentTheme.textColor : "#ffffff"
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
            }

            // Sensitivity Selector
            Row {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "Speed:"
                    color: currentTheme ? currentTheme.textColor : "#888888"
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                Repeater {
                    model: [
                        { label: "1x", val: 1.0 },
                        { label: "1.5x", val: 1.5 },
                        { label: "2x", val: 2.2 }
                    ]

                    delegate: Rectangle {
                        width: 32
                        height: 22
                        radius: 6
                        color: root.sensitivity === modelData.val ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#1e293b")

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: "#ffffff"
                            font.pixelSize: 10
                            font.bold: root.sensitivity === modelData.val
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.sensitivity = modelData.val
                        }
                    }
                }
            }

            // Return to Keyboard Button
            Rectangle {
                width: 90
                height: 26
                radius: 13
                color: currentTheme ? currentTheme.accentColor : "#0284c7"
                Layout.alignment: Qt.AlignVCenter

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "⌨️ Keyboard"
                        color: "#ffffff"
                        font.pixelSize: 10
                        font.bold: true
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
        }

        // ── Main Touch Surface (Trackpad Area) ──────────────────────
        Rectangle {
            id: touchSurface
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: Qt.darker(currentTheme ? currentTheme.backgroundColor : "#0b1329", 1.15)
            border.color: currentTheme ? currentTheme.keyBorderColor : "#1e293b"
            border.width: 1
            clip: true

            // Grid lines overlay for tactile visual cue
            Canvas {
                anchors.fill: parent
                opacity: 0.15
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = currentTheme ? currentTheme.textColor : "#ffffff";
                    ctx.lineWidth = 1;

                    // Subtle dashed border
                    ctx.setLineDash([4, 4]);
                    ctx.strokeRect(8, 8, width - 16, height - 16);
                }
            }

            // Touch trail indicator / dot
            Rectangle {
                id: touchCursorDot
                width: 32
                height: 32
                radius: 16
                color: Qt.hsla(0.58, 0.9, 0.6, 0.35)
                border.color: currentTheme ? currentTheme.accentColor : "#00a2ed"
                border.width: 2
                visible: false
                z: 10

                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // Text hint inside touch area
            Column {
                anchors.centerIn: parent
                spacing: 6
                opacity: touchArea.pressed ? 0.2 : 0.4
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "☝️ Drag finger to move mouse pointer"
                    color: currentTheme ? currentTheme.textColor : "#ffffff"
                    font.pixelSize: 12
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Tap = Left Click  •  2-Finger Drag = Scroll"
                    color: currentTheme ? currentTheme.textColor : "#aaaaaa"
                    font.pixelSize: 10
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

                        if (vk && (Math.abs(dx) > 0.1 || Math.abs(dy) > 0.1)) {
                            vk.sendMouseMove(Math.round(dx), Math.round(dy))
                        }

                        lastPoint1 = Qt.point(tp1.x, tp1.y)

                        touchCursorDot.x = tp1.x - touchCursorDot.width / 2
                        touchCursorDot.y = tp1.y - touchCursorDot.height / 2
                    }
                    else if (touchPoints.length >= 2 && tp1.pressed && tp2.pressed) {
                        // Two-finger scroll
                        var scrollDy = Math.round((tp1.y - lastPoint1.y) / 4.0)
                        var scrollDx = Math.round((tp1.x - lastPoint1.x) / 4.0)

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
                    if (totalDistanceMoved < 8 && duration < 250) {
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

        // ── Physical Thumb Buttons (Bottom Row) ──────────────────────
        RowLayout {
            Layout.fillWidth: true
            height: 48
            spacing: 8

            // Left Click Button
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: leftBtnArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.accentColor : "#0284c7")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#1e293b"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "🖱️ L-Click"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MouseArea {
                    id: leftBtnArea
                    anchors.fill: parent
                    onPressed: if (vk) vk.sendMouseClick(1, true)
                    onReleased: if (vk) vk.sendMouseClick(1, false)
                }
            }

            // Middle Click / Scroll Lock Button
            Rectangle {
                width: 90
                Layout.fillHeight: true
                radius: 12
                color: midBtnArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.specialKeyBackgroundColor : "#1e293b")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#1e293b"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "M-Click"
                    color: currentTheme ? currentTheme.textColor : "#ffffff"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: midBtnArea
                    anchors.fill: parent
                    onPressed: if (vk) vk.sendMouseClick(2, true)
                    onReleased: if (vk) vk.sendMouseClick(2, false)
                }
            }

            // Right Click Button
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: rightBtnArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") : (currentTheme ? currentTheme.specialKeyBackgroundColor : "#1e293b")
                border.color: currentTheme ? currentTheme.keyBorderColor : "#1e293b"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "R-Click 🖱️"
                        color: currentTheme ? currentTheme.textColor : "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MouseArea {
                    id: rightBtnArea
                    anchors.fill: parent
                    onPressed: if (vk) vk.sendMouseClick(3, true)
                    onReleased: if (vk) vk.sendMouseClick(3, false)
                }
            }
        }
    }
}
