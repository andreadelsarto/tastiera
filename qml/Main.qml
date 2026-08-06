import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.keyboard 1.0

Window {
    id: mainWindow
    visible: false
    title: "Plasma Keyboard"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowDoesNotAcceptFocus

    width: Screen.width
    height: Screen.height

    KeyboardController {
        id: controller
    }

    WaylandVirtualKeyboard {
        id: virtualKeyEngine
    }

    GestureEngine {
        id: gestureEngine
    }

    KlipperIntegration {
        id: klipper
    }

    // Dynamic Theme Loader
    property var activeTheme: teenageTheme
    Loader {
        id: themeLoader
        source: "themes/" + controller.activeTheme + ".qml"
        onLoaded: mainWindow.activeTheme = themeLoader.item
    }

    Component.onCompleted: {
        themeLoader.source = "themes/TeenageOP1.qml"
    }

    Connections {
        target: controller
        function onTriggerBackspace() {
            virtualKeyEngine.sendBackspace()
        }
        function onTriggerWordBackspace() {
            virtualKeyEngine.sendCtrlBackspace()
        }
    }

    // Floating Card Container (Matches Screenshots Floating Design)
    Rectangle {
        id: cardBox
        width: controller.sizeMode === "full" ? (parent.width - 24) :
               (controller.sizeMode === "onehand" ? 480 : 896)
        height: 356

        x: controller.sizeMode === "onehand" ? (parent.width - width - 16) : (parent.width - width) / 2
        y: parent.height - height - 40

        function syncMask() {
            controller.updateInputMask(mainWindow, cardBox.x, cardBox.y, cardBox.width, cardBox.height)
        }

        onXChanged: cardBox.syncMask()
        onYChanged: cardBox.syncMask()
        onWidthChanged: cardBox.syncMask()
        onHeightChanged: cardBox.syncMask()
        Component.onCompleted: cardBox.syncMask()

        color: mainWindow.activeTheme ? mainWindow.activeTheme.backgroundColor : "#0b1329"
        radius: mainWindow.activeTheme ? mainWindow.activeTheme.cardRadius : 24
        border.color: mainWindow.activeTheme ? mainWindow.activeTheme.cardBorderColor : "#1e293b"
        border.width: 1

        SwipeCanvas {
            gestureEngine: gestureEngine
            currentTheme: mainWindow.activeTheme
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            // Pill Header Bar (Draggable handle)
            TouchBarView {
                Layout.fillWidth: true
                currentTheme: mainWindow.activeTheme
                controller: controller
                vk: virtualKeyEngine
                klipper: klipper
                cardBox: cardBox
            }

            // Word Suggestion Bar (Microphone + Predictive Pills)
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: "transparent"
                visible: controller.layoutMode === "abc" || controller.layoutMode === "accenti"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    // Mic button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: mainWindow.activeTheme ? mainWindow.activeTheme.keyBackgroundColor : "#162032"
                        border.color: mainWindow.activeTheme ? mainWindow.activeTheme.accentColor : "#0284c7"

                        Text {
                            anchors.centerIn: parent
                            text: "🎙️"
                            font.pixelSize: 14
                        }
                    }

                    // Primary Word Suggestion Pill (Cyan Highlight)
                    Rectangle {
                        width: Math.max(90, word1Text.width + 24)
                        height: 32
                        radius: 16
                        color: mainWindow.activeTheme ? mainWindow.activeTheme.accentColor : "#0284c7"

                        Text {
                            id: word1Text
                            anchors.centerIn: parent
                            text: "tastiera"
                            color: "#ffffff"
                            font.family: mainWindow.activeTheme ? mainWindow.activeTheme.fontFamily : "sans-serif"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: virtualKeyEngine.sendText("tastiera ")
                        }
                    }

                    // Secondary Suggestion Pill 2
                    Rectangle {
                        width: Math.max(70, word2Text.width + 20)
                        height: 32
                        radius: 16
                        color: mainWindow.activeTheme ? mainWindow.activeTheme.keyBackgroundColor : "#162032"
                        border.color: mainWindow.activeTheme ? mainWindow.activeTheme.keyBorderColor : "#334155"

                        Text {
                            id: word2Text
                            anchors.centerIn: parent
                            text: "plasma"
                            color: mainWindow.activeTheme ? mainWindow.activeTheme.textColor : "#fff"
                            font.family: mainWindow.activeTheme ? mainWindow.activeTheme.fontFamily : "sans-serif"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: virtualKeyEngine.sendText("plasma ")
                        }
                    }

                    // Secondary Suggestion Pill 3
                    Rectangle {
                        width: Math.max(65, word3Text.width + 20)
                        height: 32
                        radius: 16
                        color: mainWindow.activeTheme ? mainWindow.activeTheme.keyBackgroundColor : "#162032"
                        border.color: mainWindow.activeTheme ? mainWindow.activeTheme.keyBorderColor : "#334155"

                        Text {
                            id: word3Text
                            anchors.centerIn: parent
                            text: "linux"
                            color: mainWindow.activeTheme ? mainWindow.activeTheme.textColor : "#fff"
                            font.family: mainWindow.activeTheme ? mainWindow.activeTheme.fontFamily : "sans-serif"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: virtualKeyEngine.sendText("linux ")
                        }
                    }
                }

                Connections {
                    target: gestureEngine
                    function onWordPredicted(word) {
                        word1Text.text = word
                    }
                }
            }

            // Main Keyboard Views Container
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                StackLayout {
                    id: layoutStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: controller.layoutMode === "abc" ? 0 :
                                  (controller.layoutMode === "accenti" ? 1 :
                                  (controller.layoutMode === "symbols" ? 2 :
                                  (controller.layoutMode === "numpad" ? 3 :
                                  (controller.layoutMode === "emoji" ? 4 :
                                  (controller.layoutMode === "klipper" ? 5 : 0)))))

                    // View 0: ABC QWERTY Standard (Matching Screenshot)
                    ColumnLayout {
                        spacing: 6

                        // Row 1: q w e^è r t y u^ù i^ì o^ò p
                        RowLayout {
                            spacing: controller.isSplit ? 36 : 6
                            Repeater {
                                model: [
                                    { k: "q", h: "" }, { k: "w", h: "" }, { k: "e", h: "è", a: ["è", "é", "€"] },
                                    { k: "r", h: "" }, { k: "t", h: "" }, { k: "y", h: "" },
                                    { k: "u", h: "ù", a: ["ù", "ú"] }, { k: "i", h: "ì", a: ["ì", "í"] },
                                    { k: "o", h: "ò", a: ["ò", "ó"] }, { k: "p", h: "" }
                                ]
                                delegate: KeyButton {
                                    label: modelData.k
                                    hintAccent: modelData.h
                                    accents: modelData.a ? modelData.a : []
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    gestureEngine: gestureEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }

                        // Row 2: a^à s d f g h j k l
                        RowLayout {
                            spacing: controller.isSplit ? 36 : 6
                            Repeater {
                                model: [
                                    { k: "a", h: "à", a: ["à", "á"] }, { k: "s", h: "" }, { k: "d", h: "" },
                                    { k: "f", h: "" }, { k: "g", h: "" }, { k: "h", h: "" },
                                    { k: "j", h: "" }, { k: "k", h: "" }, { k: "l", h: "" }
                                ]
                                delegate: KeyButton {
                                    label: modelData.k
                                    hintAccent: modelData.h
                                    accents: modelData.a ? modelData.a : []
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    gestureEngine: gestureEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }

                        // Row 3: Shift z x c v b n m Backspace
                        RowLayout {
                            spacing: 6
                            KeyButton {
                                label: "⇧"
                                isSpecial: true
                                implicitWidth: 65
                                currentTheme: mainWindow.activeTheme
                                Layout.fillHeight: true
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: controller.isSplit ? 36 : 6
                                Repeater {
                                    model: ["z", "x", "c", "v", "b", "n", "m"]
                                    delegate: KeyButton {
                                        label: modelData
                                        currentTheme: mainWindow.activeTheme
                                        vk: virtualKeyEngine
                                        gestureEngine: gestureEngine
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                    }
                                }
                            }
                            KeyButton {
                                label: "⌫"
                                isSpecial: true
                                isBackspace: true
                                implicitWidth: 75
                                currentTheme: mainWindow.activeTheme
                                controller: controller
                                vk: virtualKeyEngine
                                Layout.fillHeight: true
                            }
                        }

                        // Row 4: ?123, Emoji, comma, spazio, dot, Cyan Primary Enter
                        RowLayout {
                            spacing: 6
                            KeyButton {
                                label: "?123"
                                isSpecial: true
                                implicitWidth: 65
                                currentTheme: mainWindow.activeTheme
                                onReleased: controller.layoutMode = "symbols"
                                Layout.fillHeight: true
                            }
                            KeyButton {
                                label: "😊"
                                isSpecial: true
                                implicitWidth: 50
                                currentTheme: mainWindow.activeTheme
                                onReleased: controller.layoutMode = "emoji"
                                Layout.fillHeight: true
                            }
                            KeyButton {
                                label: ","
                                implicitWidth: 50
                                currentTheme: mainWindow.activeTheme
                                vk: virtualKeyEngine
                                Layout.fillHeight: true
                            }
                            KeyButton {
                                label: "spazio"
                                textToSend: " "
                                currentTheme: mainWindow.activeTheme
                                vk: virtualKeyEngine
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                            KeyButton {
                                label: "."
                                implicitWidth: 50
                                currentTheme: mainWindow.activeTheme
                                vk: virtualKeyEngine
                                Layout.fillHeight: true
                            }
                            KeyButton {
                                label: "↵"
                                textToSend: "\n"
                                isSpecial: true
                                isPrimaryAction: true
                                implicitWidth: 75
                                currentTheme: mainWindow.activeTheme
                                vk: virtualKeyEngine
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // View 1: IT Accenti Diretti
                    ColumnLayout {
                        spacing: 6
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: ["à", "è", "é", "ì", "ò", "ù", "€", "§"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }

                    // View 2: ?123 Symbols
                    ColumnLayout {
                        spacing: 6
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: ["-", "_", "=", "+", "[", "]", "{", "}", ";", ":"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }

                    // View 3: Numpad Calcolatrice 3x4
                    GridLayout {
                        columns: 4
                        rowSpacing: 6
                        columnSpacing: 6

                        Repeater {
                            model: ["7", "8", "9", "/",
                                    "4", "5", "6", "*",
                                    "1", "2", "3", "-",
                                    "0", ".", "=", "+"]
                            delegate: KeyButton {
                                label: modelData
                                isSpecial: (modelData === "/" || modelData === "*" || modelData === "-" || modelData === "+" || modelData === "=")
                                currentTheme: mainWindow.activeTheme
                                vk: virtualKeyEngine
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // View 4: Emoji Grid
                    Flickable {
                        contentHeight: emojiGrid.height
                        clip: true

                        GridLayout {
                            id: emojiGrid
                            columns: 8
                            rowSpacing: 6
                            columnSpacing: 6
                            width: parent.width

                            Repeater {
                                model: ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣",
                                        "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰",
                                        "😘", "😗", "😙", "😚", "😋", "😛", "😝", "😜",
                                        "🤪", "🤨", "🧐", "🤓", "😎", "🤩", "🥳", "😏",
                                        "😒", "😞", "😔", "😟", "😕", "🙁", "☹️", "😣",
                                        "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠",
                                        "👍", "👎", "👏", "🙌", "👐", "🤲", "🤝", "🙏"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    Layout.fillWidth: true
                                    implicitHeight: 48
                                }
                            }
                        }
                    }

                    // View 5: Klipper Clipboard View
                    ListView {
                        clip: true
                        model: klipper.history
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 44
                            color: klipperMouse.pressed ? (mainWindow.activeTheme ? mainWindow.activeTheme.keyActiveColor : "#24344d") : (mainWindow.activeTheme ? mainWindow.activeTheme.keyBackgroundColor : "#162032")
                            border.color: mainWindow.activeTheme ? mainWindow.activeTheme.keyBorderColor : "#22334d"
                            radius: 8

                            Text {
                                anchors.centerIn: parent
                                anchors.margins: 8
                                text: modelData
                                elide: Text.ElideRight
                                color: mainWindow.activeTheme ? mainWindow.activeTheme.textColor : "#fff"
                                font.pixelSize: 14
                            }

                            MouseArea {
                                id: klipperMouse
                                anchors.fill: parent
                                onClicked: {
                                    virtualKeyEngine.sendText(modelData)
                                }
                            }
                        }
                    }
                }

                // DPadPanel on the right side - EXCLUSIVE REQUIREMENT: sizeMode === 'full' ONLY
                DPadPanel {
                    visible: controller.sizeMode === "full"
                    currentTheme: mainWindow.activeTheme
                    vk: virtualKeyEngine
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}
