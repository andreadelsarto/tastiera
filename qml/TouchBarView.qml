import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: touchBar
    height: 44
    color: "transparent"

    property var currentTheme
    property var controller
    property var vk
    property var klipper
    property var cardBox

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // Left section: Title & Protocol Badge (Draggable handle)
        Row {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                width: titleText.width + 16
                height: 28
                color: "transparent"
                radius: 14

                Text {
                    id: titleText
                    text: "⠿  KDE Touch Key"
                    color: currentTheme ? currentTheme.textColor : "#fff"
                    font.family: currentTheme ? currentTheme.fontFamily : "sans-serif"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: dragMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor
                    property point startPos: "0,0"

                    onPressed: {
                        startPos = Qt.point(mouse.x, mouse.y)
                    }

                    onPositionChanged: {
                        if (pressed && cardBox) {
                            var deltaX = mouse.x - startPos.x
                            var deltaY = mouse.y - startPos.y
                            cardBox.x += deltaX
                            cardBox.y += deltaY
                        }
                    }
                }
            }

            Rectangle {
                width: badgeText.width + 12
                height: 24
                radius: 12
                color: currentTheme ? currentTheme.keyBackgroundColor : "#162032"
                border.color: currentTheme ? currentTheme.accentColor : "#0284c7"
                border.width: 1
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: "Wayland Layer-Shell"
                    color: currentTheme ? currentTheme.accentTextColor : "#38bdf8"
                    font.family: currentTheme ? currentTheme.fontFamily : "sans-serif"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }

        // Center section: Mode Pills
        Flickable {
            Layout.fillWidth: true
            height: 36
            contentWidth: pillRow.width
            clip: true
            Layout.alignment: Qt.AlignVCenter

            Row {
                id: pillRow
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                // ABC Pill
                Rectangle {
                    width: 50
                    height: 28
                    radius: 14
                    color: controller && controller.layoutMode === "abc" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "ABC"
                        color: controller && controller.layoutMode === "abc" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.layoutMode = "abc"
                    }
                }

                // IT Pill
                Rectangle {
                    width: 50
                    height: 28
                    radius: 14
                    color: controller && controller.layoutMode === "accenti" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "🇮🇹 IT"
                        color: controller && controller.layoutMode === "accenti" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.layoutMode = "accenti"
                    }
                }

                // ?123 Pill
                Rectangle {
                    width: 54
                    height: 28
                    radius: 14
                    color: controller && controller.layoutMode === "symbols" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "?123"
                        color: controller && controller.layoutMode === "symbols" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.layoutMode = "symbols"
                    }
                }

                // 1234 Numpad Pill
                Rectangle {
                    width: 58
                    height: 28
                    radius: 14
                    color: controller && controller.layoutMode === "numpad" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "🔢 1234"
                        color: controller && controller.layoutMode === "numpad" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.layoutMode = "numpad"
                    }
                }

                // Emoji Pill
                Rectangle {
                    width: 40
                    height: 28
                    radius: 14
                    color: controller && controller.layoutMode === "emoji" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "😊"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.layoutMode = "emoji"
                    }
                }

                // Split Pill
                Rectangle {
                    width: 58
                    height: 28
                    radius: 14
                    color: controller && controller.isSplit ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "✂️ Split"
                        color: controller && controller.isSplit ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.isSplit = !controller.isSplit
                    }
                }

                // Klipper Pill
                Rectangle {
                    width: 68
                    height: 28
                    radius: 14
                    color: controller && controller.layoutMode === "klipper" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : (currentTheme ? currentTheme.keyBackgroundColor : "#162032")
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "📋 Klipper"
                        color: controller && controller.layoutMode === "klipper" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.layoutMode = "klipper"
                    }
                }

                // Theme Pill Switcher
                Rectangle {
                    width: 68
                    height: 28
                    radius: 14
                    color: currentTheme ? currentTheme.keyBackgroundColor : "#162032"
                    border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "🎨 Theme"
                        color: currentTheme ? currentTheme.textColor : "#fff"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (controller) {
                                if (controller.activeTheme === "TeenageOP1") controller.activeTheme = "BreezeDark"
                                else if (controller.activeTheme === "BreezeDark") controller.activeTheme = "NothingDark"
                                else if (controller.activeTheme === "NothingDark") controller.activeTheme = "NothingLight"
                                else controller.activeTheme = "TeenageOP1"
                            }
                        }
                    }
                }
            }
        }

        // Right section: Size Mode Segmented Switcher [ Normale | Estesa | 1-Mano ]
        Rectangle {
            width: 210
            height: 32
            radius: 16
            color: currentTheme ? currentTheme.keyBackgroundColor : "#162032"
            border.color: currentTheme ? currentTheme.keyBorderColor : "#334155"
            Layout.alignment: Qt.AlignVCenter

            Row {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 2

                // Normale
                Rectangle {
                    width: (parent.width - 4) / 3
                    height: parent.height
                    radius: 14
                    color: controller && controller.sizeMode === "normal" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Normale"
                        color: controller && controller.sizeMode === "normal" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 11
                        font.bold: controller && controller.sizeMode === "normal"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.sizeMode = "normal"
                    }
                }

                // Estesa (Full)
                Rectangle {
                    width: (parent.width - 4) / 3
                    height: parent.height
                    radius: 14
                    color: controller && controller.sizeMode === "full" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Estesa"
                        color: controller && controller.sizeMode === "full" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 11
                        font.bold: controller && controller.sizeMode === "full"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.sizeMode = "full"
                    }
                }

                // 1-Mano
                Rectangle {
                    width: (parent.width - 4) / 3
                    height: parent.height
                    radius: 14
                    color: controller && controller.sizeMode === "onehand" ? (currentTheme ? currentTheme.accentColor : "#0284c7") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "📱 1-Mano"
                        color: controller && controller.sizeMode === "onehand" ? "#ffffff" : (currentTheme ? currentTheme.textColor : "#fff")
                        font.pixelSize: 11
                        font.bold: controller && controller.sizeMode === "onehand"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (controller) controller.sizeMode = "onehand"
                    }
                }
            }
        }
    }
}
