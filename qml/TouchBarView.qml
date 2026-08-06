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
    property var mainWindow

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // Left section: Title Handle (Draggable)
        Rectangle {
            width: titleText.width + 12
            height: 28
            color: "transparent"
            Layout.alignment: Qt.AlignVCenter

            Text {
                id: titleText
                text: ":::  KDE Touch Key"
                color: currentTheme ? currentTheme.textColor : "#1e1e1e"
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

                onPressed: (mouse) => {
                    startPos = Qt.point(mouse.x, mouse.y)
                }

                onPositionChanged: (mouse) => {
                    if (pressed && cardBox) {
                        var deltaX = mouse.x - startPos.x
                        var deltaY = mouse.y - startPos.y
                        cardBox.x += deltaX
                        cardBox.y += deltaY
                    }
                }
            }
        }

        // Center section: Mode Pills in Dark Container
        Rectangle {
            Layout.fillWidth: true
            height: 34
            radius: 17
            color: currentTheme && currentTheme.headerPillBg ? currentTheme.headerPillBg : "#434a56"
            Layout.alignment: Qt.AlignVCenter

            Flickable {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                contentWidth: pillRow.width
                clip: true

                Row {
                    id: pillRow
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    // ABC Pill
                    Rectangle {
                        width: 48
                        height: 26
                        radius: 13
                        color: controller && controller.layoutMode === "abc" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "ABC"
                            color: controller && controller.layoutMode === "abc" ? "#ffffff" : "#d0d5dd"
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
                        height: 26
                        radius: 13
                        color: controller && controller.layoutMode === "accenti" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🇮🇹 IT"
                            color: controller && controller.layoutMode === "accenti" ? "#ffffff" : "#d0d5dd"
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
                        width: 50
                        height: 26
                        radius: 13
                        color: controller && controller.layoutMode === "symbols" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "?123"
                            color: controller && controller.layoutMode === "symbols" ? "#ffffff" : "#d0d5dd"
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
                        width: 56
                        height: 26
                        radius: 13
                        color: controller && controller.layoutMode === "numpad" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🔢 1234"
                            color: controller && controller.layoutMode === "numpad" ? "#ffffff" : "#d0d5dd"
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
                        width: 36
                        height: 26
                        radius: 13
                        color: controller && controller.layoutMode === "emoji" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "😊"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (controller) controller.layoutMode = "emoji"
                        }
                    }

                    // Split Pill
                    Rectangle {
                        width: 62
                        height: 26
                        radius: 13
                        color: controller && controller.isSplit ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "▯▯ Split"
                            color: controller && controller.isSplit ? "#ffffff" : "#d0d5dd"
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
                        width: 64
                        height: 26
                        radius: 13
                        color: controller && controller.layoutMode === "klipper" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "📋 Klipper"
                            color: controller && controller.layoutMode === "klipper" ? "#ffffff" : "#d0d5dd"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (controller) controller.layoutMode = "klipper"
                        }
                    }

                    // Terminal Mode Pill (>_ Term)
                    Rectangle {
                        width: 64
                        height: 26
                        radius: 13
                        color: controller && controller.isTerminalMode ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: ">_ Term"
                            color: controller && controller.isTerminalMode ? "#ffffff" : "#d0d5dd"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (controller) controller.isTerminalMode = !controller.isTerminalMode
                        }
                    }

                    // Theme Pill Switcher
                    Rectangle {
                        width: 68
                        height: 26
                        radius: 13
                        color: mainWindow && mainWindow.showThemeSelector ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🎨 Theme"
                            color: mainWindow && mainWindow.showThemeSelector ? "#ffffff" : "#d0d5dd"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (mainWindow) {
                                    mainWindow.showThemeSelector = !mainWindow.showThemeSelector
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right section: Size Mode Segmented Switcher in Dark Container
        Rectangle {
            width: 210
            height: 34
            radius: 17
            color: currentTheme && currentTheme.sizeModePillBg ? currentTheme.sizeModePillBg : "#21252d"
            Layout.alignment: Qt.AlignVCenter

            Row {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 2

                // Normale
                Rectangle {
                    width: (parent.width - 6) / 3
                    height: parent.height
                    radius: 14
                    color: controller && controller.sizeMode === "normal" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Normale"
                        color: controller && controller.sizeMode === "normal" ? "#ffffff" : "#d0d5dd"
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
                    width: (parent.width - 6) / 3
                    height: parent.height
                    radius: 14
                    color: controller && controller.sizeMode === "full" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Estesa"
                        color: controller && controller.sizeMode === "full" ? "#ffffff" : "#d0d5dd"
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
                    width: (parent.width - 6) / 3
                    height: parent.height
                    radius: 14
                    color: controller && controller.sizeMode === "onehand" ? (currentTheme ? currentTheme.accentColor : "#00a2ed") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "📱 1-Mano"
                        color: controller && controller.sizeMode === "onehand" ? "#ffffff" : "#d0d5dd"
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
