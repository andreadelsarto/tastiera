import QtQuick 2.15
import QtQuick.Controls 2.15
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

    signal keyTriggered(string key)
    signal released()
    signal longPressed()

    radius: currentTheme ? currentTheme.keyRadius : 12

    // Dynamic background color based on key type & state
    color: isPrimaryAction ? (currentTheme ? currentTheme.accentColor : "#0284c7") :
           (isSpecial ? (currentTheme ? currentTheme.specialKeyBackgroundColor : "#1e293b") :
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

    // Main Key Label
    Text {
        id: labelText
        text: root.label
        anchors.centerIn: parent
        color: root.isPrimaryAction ? "#ffffff" :
               (root.isSpecial ? (currentTheme ? currentTheme.accentTextColor : "#38bdf8") :
               (currentTheme ? currentTheme.textColor : "#f8fafc"))
        font.family: currentTheme ? currentTheme.fontFamily : "sans-serif"
        font.pixelSize: root.isSpecial ? 16 : 18
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

    // Popup for Long-Press Accents (e.g. è, é, €) with Slide & Tap selection
    Popup {
        id: accentPopup
        y: -height - 8
        x: (parent.width - width) / 2
        padding: 4
        modal: false
        focus: false
        closePolicy: Popup.CloseOnPressOutside

        background: Rectangle {
            color: currentTheme ? currentTheme.backgroundColor : "#0f172a"
            border.color: currentTheme ? currentTheme.accentColor : "#0284c7"
            radius: 12
        }

        contentItem: Row {
            id: accentRow
            spacing: 4
            Repeater {
                model: root.accents
                delegate: Rectangle {
                    width: 36
                    height: 36
                    radius: 8
                    color: index === root.selectedAccentIndex || accentMouse.pressed ?
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
                        id: accentMouse
                        anchors.fill: parent
                        onClicked: {
                            if (root.vk) {
                                root.vk.sendText(modelData)
                            } else if (typeof virtualKeyEngine !== "undefined" && virtualKeyEngine) {
                                virtualKeyEngine.sendText(modelData)
                            }
                            accentPopup.close()
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: longPressTimer
        interval: 350
        repeat: false
        onTriggered: {
            root.longPressed()
            if (root.accents.length > 0) {
                root.selectedAccentIndex = 0
                accentPopup.open()
            } else if (root.isBackspace && controller) {
                controller.startBackspaceTimer()
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onPressed: {
            longPressTimer.start()
            if (gestureEngine) {
                gestureEngine.startTouch(Qt.point(mouse.x, mouse.y))
            }
        }

        onPositionChanged: {
            if (gestureEngine && pressed) {
                gestureEngine.updateTouch(Qt.point(mouse.x, mouse.y))
            }

            // Slide-to-select accent logic
            if (accentPopup.opened && root.accents.length > 0) {
                var popupPoint = mouseArea.mapToItem(accentPopup.contentItem, mouse.x, mouse.y)
                var idx = Math.floor(popupPoint.x / 40)
                if (idx >= 0 && idx < root.accents.length) {
                    root.selectedAccentIndex = idx
                }
            }
        }

        onReleased: {
            longPressTimer.stop()

            if (gestureEngine) {
                gestureEngine.endTouch()
            }

            root.released()

            if (accentPopup.opened) {
                if (root.selectedAccentIndex >= 0 && root.selectedAccentIndex < root.accents.length) {
                    var selChar = root.accents[root.selectedAccentIndex]
                    if (root.vk) {
                        root.vk.sendText(selChar)
                    } else if (typeof virtualKeyEngine !== "undefined" && virtualKeyEngine) {
                        virtualKeyEngine.sendText(selChar)
                    }
                }
                accentPopup.close()
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
    }
}
