import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string label: ""
    property string hintAccent: ""
    property var accents: []
    property string textToSend: ""
    property bool isSpecial: false
    property bool isPrimaryAction: false
    property bool isBackspace: false
    property bool isCustomAction: false
    property var currentTheme
    property var vk
    property var controller
    property var gestureEngine

    property int selectedAccentIndex: -1
    property bool isAccentOverlayOpen: false

    signal keyTriggered(string key)
    signal pressed()
    signal released()
    signal longPressed()

    Layout.fillHeight: true

    radius: currentTheme ? currentTheme.keyRadius : 12

    // Dynamic background color based on key type & state
    color: isPrimaryAction ? (currentTheme ? currentTheme.accentColor : "#0284c7") :
           (isSpecial ? (currentTheme && currentTheme.specialKeyBackgroundColor ? currentTheme.specialKeyBackgroundColor : (currentTheme ? currentTheme.keyBackgroundColor : "#1e293b")) :
           (mouseArea.pressed ? (currentTheme ? currentTheme.keyActiveColor : "#334155") :
           (currentTheme ? currentTheme.keyBackgroundColor : "#1e293b")))

    border.color: isPrimaryAction ? (currentTheme ? currentTheme.accentColor : "#0284c7") :
                  (currentTheme ? currentTheme.keyBorderColor : "#334155")
    border.width: currentTheme ? currentTheme.keyBorderWidth : 1

    // Scale animation on press
    scale: mouseArea.pressed ? 0.95 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
    }

    // Feature 1: Visual haptic feedback flash overlay
    Rectangle {
        id: hapticFlash
        anchors.fill: parent
        radius: parent.radius
        color: "#ffffff"
        opacity: 0
        z: 10

        SequentialAnimation {
            id: hapticAnimation
            NumberAnimation { target: hapticFlash; property: "opacity"; to: 0.25; duration: 30 }
            NumberAnimation { target: hapticFlash; property: "opacity"; to: 0; duration: 120; easing.type: Easing.OutQuad }
        }
    }

    // Main Key Label
    Text {
        id: labelText
        text: root.label
        anchors.centerIn: parent
        color: root.isPrimaryAction ? "#ffffff" :
               (root.isSpecial ? (currentTheme ? currentTheme.accentTextColor : "#38bdf8") :
               (currentTheme ? currentTheme.textColor : "#f8fafc"))
        font.family: currentTheme ? currentTheme.fontFamily : "sans-serif"
        font.pixelSize: root.label.length > 8 ? 9 :
                       (root.label.length > 5 ? 11 :
                       (root.label.length > 3 ? 13 : (root.isSpecial ? 15 : 18)))
        font.bold: root.isSpecial || root.isPrimaryAction
    }

    // Superscript Accent Hint (Top Right)
    Text {
        text: root.hintAccent
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 6
        color: currentTheme ? currentTheme.accentTextColor : "#38bdf8"
        font.pixelSize: 10
        font.bold: true
        visible: root.hintAccent !== "" && !root.isSpecial
    }

    // Custom Lightweight Accent Overlay (Does NOT steal touch grab)
    Rectangle {
        id: accentOverlay
        visible: root.isAccentOverlayOpen
        z: 9999
        y: -height - 8
        x: (parent.width - width) / 2
        width: accentRow.width + 8
        height: 44
        radius: 12
        color: currentTheme ? currentTheme.backgroundColor : "#0f172a"
        border.color: currentTheme ? currentTheme.accentColor : "#0284c7"
        border.width: 1

        Row {
            id: accentRow
            anchors.centerIn: parent
            spacing: 4
            Repeater {
                model: root.accents
                delegate: Rectangle {
                    width: 36
                    height: 36
                    radius: 8
                    color: index === root.selectedAccentIndex ?
                           (currentTheme ? currentTheme.accentColor : "#0284c7") :
                           (currentTheme ? currentTheme.keyBackgroundColor : "#1e293b")

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: "#ffffff"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.vk) {
                                root.vk.sendText(modelData)
                            } else if (typeof virtualKeyEngine !== "undefined" && virtualKeyEngine) {
                                virtualKeyEngine.sendText(modelData)
                            }
                            root.isAccentOverlayOpen = false
                            root.selectedAccentIndex = -1
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: longPressTimer
        interval: 300
        repeat: false
        onTriggered: {
            root.longPressed()
            if (root.accents && root.accents.length > 0) {
                root.selectedAccentIndex = 0
                root.isAccentOverlayOpen = true
            } else if (root.isBackspace && controller) {
                controller.startBackspaceTimer()
            }
        }
    }

    // Multitouch-enabled input area — each key handles its own independent touch point
    // so pressing multiple keys simultaneously works correctly
    MultiPointTouchArea {
        id: mouseArea
        anchors.fill: parent
        minimumTouchPoints: 1
        maximumTouchPoints: 1

        // Expose a 'pressed' property for visual feedback (scale, color)
        property bool pressed: false

        touchPoints: [
            TouchPoint { id: tp1 }
        ]

        onPressed: (touchPoints) => {
            mouseArea.pressed = true
            root.pressed()
            hapticAnimation.start()
            longPressTimer.start()
            if (gestureEngine) {
                gestureEngine.startTouch(Qt.point(tp1.x, tp1.y))
            }
        }

        onUpdated: (touchPoints) => {
            if (gestureEngine && mouseArea.pressed) {
                gestureEngine.updateTouch(Qt.point(tp1.x, tp1.y))
            }

            // Slide-to-select accent logic
            if (root.isAccentOverlayOpen && root.accents && root.accents.length > 0) {
                var popupPoint = mouseArea.mapToItem(accentRow, tp1.x, tp1.y)
                var idx = Math.floor(popupPoint.x / 40)
                if (idx >= 0 && idx < root.accents.length) {
                    root.selectedAccentIndex = idx
                }
            }
        }

        onReleased: (touchPoints) => {
            mouseArea.pressed = false
            longPressTimer.stop()

            if (gestureEngine) {
                gestureEngine.endTouch()
            }

            root.released()

            if (root.isAccentOverlayOpen) {
                var selIdx = (root.selectedAccentIndex >= 0 && root.selectedAccentIndex < root.accents.length) ? root.selectedAccentIndex : 0
                var selChar = root.accents[selIdx]
                if (root.vk) {
                    root.vk.sendText(selChar)
                } else if (typeof virtualKeyEngine !== "undefined" && virtualKeyEngine) {
                    virtualKeyEngine.sendText(selChar)
                }
                root.isAccentOverlayOpen = false
                root.selectedAccentIndex = -1
            } else if (root.isBackspace) {
                if (controller) controller.stopBackspaceTimer()
                if (root.vk) {
                    root.vk.sendBackspace()
                } else if (typeof virtualKeyEngine !== "undefined" && virtualKeyEngine) {
                    virtualKeyEngine.sendBackspace()
                }
            } else if (!root.isCustomAction) {
                var send = root.textToSend !== "" ? root.textToSend : root.label
                if (send !== "") {
                    if (root.vk) {
                        root.vk.sendText(send)
                    } else if (typeof virtualKeyEngine !== "undefined" && virtualKeyEngine) {
                        virtualKeyEngine.sendText(send)
                    }
                }
                root.keyTriggered(send)
            }
        }

        onCanceled: (touchPoints) => {
            mouseArea.pressed = false
            longPressTimer.stop()
            if (root.isAccentOverlayOpen) {
                var selIdx = (root.selectedAccentIndex >= 0 && root.selectedAccentIndex < root.accents.length) ? root.selectedAccentIndex : 0
                var selChar = root.accents[selIdx]
                if (root.vk) {
                    root.vk.sendText(selChar)
                } else if (typeof virtualKeyEngine !== "undefined" && virtualKeyEngine) {
                    virtualKeyEngine.sendText(selChar)
                }
                root.isAccentOverlayOpen = false
                root.selectedAccentIndex = -1
            }
        }
    }
}

