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

    property string currentInputBuffer: ""
    property bool showThemeSelector: false
    property bool isMinimized: false

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
    property var activeTheme
    Loader {
        id: themeLoader
        source: "themes/" + controller.activeTheme + ".qml"
        onLoaded: mainWindow.activeTheme = themeLoader.item
    }

    Connections {
        target: controller
        function onActiveThemeChanged() {
            themeLoader.source = "themes/" + controller.activeTheme + ".qml"
        }
        function onTriggerBackspace() {
            virtualKeyEngine.sendBackspace()
            if (mainWindow.currentInputBuffer.length > 0) {
                mainWindow.currentInputBuffer = mainWindow.currentInputBuffer.substring(0, mainWindow.currentInputBuffer.length - 1)
                gestureEngine.updateCurrentPrefix(mainWindow.currentInputBuffer)
            }
        }
        function onTriggerWordBackspace() {
            virtualKeyEngine.sendCtrlBackspace()
            mainWindow.currentInputBuffer = ""
            gestureEngine.updateCurrentPrefix("")
        }
    }

    // Floating Bubble / Mini-Bar Handle (Appears at margin when user taps Close ✖)
    Rectangle {
        id: minimizedPill
        width: 140
        height: 38
        radius: 19
        x: parent.width - width - 20
        y: parent.height - height - 40
        visible: mainWindow.isMinimized
        color: mainWindow.activeTheme ? mainWindow.activeTheme.accentColor : "#00a2ed"
        border.color: "#ffffff"
        border.width: 1

        function syncMinimizedMask() {
            if (mainWindow.isMinimized) {
                controller.updateInputMask(mainWindow, minimizedPill.x, minimizedPill.y, minimizedPill.width, minimizedPill.height)
            }
        }

        onXChanged: minimizedPill.syncMinimizedMask()
        onYChanged: minimizedPill.syncMinimizedMask()
        onVisibleChanged: if (mainWindow.isMinimized) minimizedPill.syncMinimizedMask()

        Row {
            anchors.centerIn: parent
            spacing: 6
            Text {
                text: "⌨️  Touch Key"
                color: mainWindow.activeTheme ? mainWindow.activeTheme.accentTextColor : "#ffffff"
                font.family: mainWindow.activeTheme ? mainWindow.activeTheme.fontFamily : "sans-serif"
                font.pixelSize: 13
                font.bold: true
            }
        }

        MouseArea {
            id: minPillMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            property point startPos: "0,0"

            onPressed: (mouse) => {
                startPos = Qt.point(mouse.x, mouse.y)
            }

            onPositionChanged: (mouse) => {
                if (pressed) {
                    var deltaX = mouse.x - startPos.x
                    var deltaY = mouse.y - startPos.y
                    minimizedPill.x += deltaX
                    minimizedPill.y += deltaY
                }
            }

            onClicked: {
                mainWindow.isMinimized = false
                cardBox.syncMask()
            }
        }
    }

    // Floating Card Container (Matches Screenshots Floating Design)
    Rectangle {
        id: cardBox
        visible: !mainWindow.isMinimized
        width: controller.sizeMode === "full" ? (parent.width - 24) :
               (controller.sizeMode === "onehand" ? 480 : 896)
        height: 356

        x: controller.sizeMode === "onehand" ? (parent.width - width - 16) : (parent.width - width) / 2
        y: parent.height - height - 40

        function syncMask() {
            if (!mainWindow.isMinimized) {
                controller.updateInputMask(mainWindow, cardBox.x, cardBox.y, cardBox.width, cardBox.height)
            }
        }

        onXChanged: cardBox.syncMask()
        onYChanged: cardBox.syncMask()
        onWidthChanged: cardBox.syncMask()
        onHeightChanged: cardBox.syncMask()
        onVisibleChanged: if (!mainWindow.isMinimized) cardBox.syncMask()
        Component.onCompleted: cardBox.syncMask()

        color: mainWindow.activeTheme ? mainWindow.activeTheme.backgroundColor : "#e3dfd8"
        radius: mainWindow.activeTheme ? mainWindow.activeTheme.cardRadius : 24
        border.color: mainWindow.activeTheme ? mainWindow.activeTheme.cardBorderColor : "#c8c3b9"
        border.width: 1

        SwipeCanvas {
            gestureEngine: gestureEngine
            currentTheme: mainWindow.activeTheme
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Pill Header Bar (Draggable handle)
            TouchBarView {
                Layout.fillWidth: true
                currentTheme: mainWindow.activeTheme
                controller: controller
                vk: virtualKeyEngine
                klipper: klipper
                cardBox: cardBox
                mainWindow: mainWindow
            }

            // Suggestion Bar OR Theme Selector Bar
            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: 18
                color: mainWindow.activeTheme && mainWindow.activeTheme.headerPillBg ? mainWindow.activeTheme.headerPillBg : "#434a56"

                // State 1: Theme Selector Pills Mode (8 Pluggable Themes)
                Flickable {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    contentWidth: themeRow.width
                    clip: true
                    visible: mainWindow.showThemeSelector

                    RowLayout {
                        id: themeRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        // 1. Teenage OP-1
                        Rectangle {
                            width: 100
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "TeenageOP1" ? "#ff4800" : "#e3dfd8"
                            border.color: "#ff4800"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "🎨 OP-1"
                                color: controller.activeTheme === "TeenageOP1" ? "#ffffff" : "#1e1e1e"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "TeenageOP1"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }

                        // 2. Breeze Dark
                        Rectangle {
                            width: 100
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "BreezeDark" ? "#3daee9" : "#232629"
                            border.color: "#3daee9"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "🌙 Breeze"
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "BreezeDark"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }

                        // 3. Nothing Dark
                        Rectangle {
                            width: 110
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "NothingDark" ? "#ff2e2e" : "#0a0a0a"
                            border.color: "#ff2e2e"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "⚫ Nothing Dark"
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "NothingDark"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }

                        // 4. Nothing Light
                        Rectangle {
                            width: 110
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "NothingLight" ? "#0a0a0a" : "#ffffff"
                            border.color: "#0a0a0a"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "⚪ Nothing Light"
                                color: controller.activeTheme === "NothingLight" ? "#ffffff" : "#0a0a0a"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "NothingLight"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }

                        // 5. Hacker / Matrix
                        Rectangle {
                            width: 100
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "HackerMatrix" ? "#00ff41" : "#050a05"
                            border.color: "#00ff41"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "💻 Matrix"
                                color: controller.activeTheme === "HackerMatrix" ? "#050a05" : "#00ff41"
                                font.family: "monospace"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "HackerMatrix"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }

                        // 6. Cyberpunk 2077
                        Rectangle {
                            width: 110
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "Cyberpunk2077" ? "#ff0055" : "#0d0221"
                            border.color: "#00f0ff"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "🌆 Cyberpunk"
                                color: "#00f0ff"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "Cyberpunk2077"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }

                        // 7. Dracula Dark
                        Rectangle {
                            width: 100
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "DraculaDark" ? "#ff79c6" : "#282a36"
                            border.color: "#bd93f9"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "🧛 Dracula"
                                color: controller.activeTheme === "DraculaDark" ? "#ffffff" : "#f8f8f2"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "DraculaDark"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }

                        // 8. Nord Frost
                        Rectangle {
                            width: 100
                            height: 28
                            radius: 14
                            color: controller.activeTheme === "NordFrost" ? "#88c0d0" : "#2e3440"
                            border.color: "#88c0d0"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "❄️ Nord"
                                color: controller.activeTheme === "NordFrost" ? "#2e3440" : "#eceff4"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    controller.activeTheme = "NordFrost"
                                    mainWindow.showThemeSelector = false
                                }
                            }
                        }
                    }
                }

                // State 2: Dynamic Suggestions & Terminal Quick Bar
                Flickable {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    contentWidth: suggRow.width
                    clip: true
                    visible: !mainWindow.showThemeSelector

                    RowLayout {
                        id: suggRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        // Terminal Quick Pills ($ | ~ / -) - Visible ONLY when isTerminalMode is true
                        Repeater {
                            model: controller.isTerminalMode ? ["$", "|", "~", "/", "-", "_", "sudo ", "grep ", "ls -la ", "cd ", "clear\n"] : []
                            delegate: Rectangle {
                                width: Math.max(28, termText.width + 16)
                                height: 26
                                radius: 13
                                color: "#2d333e"
                                border.color: mainWindow.activeTheme ? mainWindow.activeTheme.accentColor : "#00a2ed"
                                border.width: 1

                                Text {
                                    id: termText
                                    anchors.centerIn: parent
                                    text: modelData.trim()
                                    color: "#38bdf8"
                                    font.family: "monospace"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: virtualKeyEngine.sendText(modelData)
                                }
                            }
                        }

                        // Separator (Only if terminal mode is active)
                        Rectangle {
                            width: 1
                            height: 20
                            color: "#555"
                            visible: controller.isTerminalMode
                        }

                        // Dynamic Italian Dictionary Word Suggestion Pills
                        Repeater {
                            model: gestureEngine.currentSuggestions
                            delegate: Rectangle {
                                width: Math.max(60, suggText.width + 20)
                                height: 26
                                radius: 13
                                color: index === 0 ? (mainWindow.activeTheme ? mainWindow.activeTheme.accentColor : "#00a2ed") : "#2d333e"

                                Text {
                                    id: suggText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: "#ffffff"
                                    font.family: mainWindow.activeTheme ? mainWindow.activeTheme.fontFamily : "sans-serif"
                                    font.pixelSize: 12
                                    font.bold: index === 0
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        virtualKeyEngine.sendText(modelData + " ")
                                        mainWindow.currentInputBuffer = ""
                                        gestureEngine.updateCurrentPrefix("")
                                    }
                                }
                            }
                        }
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

                    // View 0: ABC QWERTY Standard / Split Mode (Matching Screenshot)
                    ColumnLayout {
                        spacing: 6

                        // Row 1: q w e^è r t | y u^ù i^ì o^ò p
                        RowLayout {
                            spacing: 6
                            // Left Bank
                            Repeater {
                                model: [
                                    { k: "q", h: "" }, { k: "w", h: "" }, { k: "e", h: "è", a: ["è", "é", "€"] },
                                    { k: "r", h: "" }, { k: "t", h: "" }
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
                                    onKeyTriggered: (key) => {
                                        mainWindow.currentInputBuffer += key
                                        gestureEngine.updateCurrentPrefix(mainWindow.currentInputBuffer)
                                    }
                                }
                            }
                            // Split Gap
                            Item {
                                visible: controller.isSplit
                                Layout.fillWidth: true
                            }
                            // Right Bank
                            Repeater {
                                model: [
                                    { k: "y", h: "" }, { k: "u", h: "ù", a: ["ù", "ú"] },
                                    { k: "i", h: "ì", a: ["ì", "í"] }, { k: "o", h: "ò", a: ["ò", "ó"] }, { k: "p", h: "" }
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
                                    onKeyTriggered: (key) => {
                                        mainWindow.currentInputBuffer += key
                                        gestureEngine.updateCurrentPrefix(mainWindow.currentInputBuffer)
                                    }
                                }
                            }
                        }

                        // Row 2: a^à s d f g | h j k l
                        RowLayout {
                            spacing: 6
                            // Left Bank
                            Repeater {
                                model: [
                                    { k: "a", h: "à", a: ["à", "á"] }, { k: "s", h: "" }, { k: "d", h: "" },
                                    { k: "f", h: "" }, { k: "g", h: "" }
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
                                    onKeyTriggered: (key) => {
                                        mainWindow.currentInputBuffer += key
                                        gestureEngine.updateCurrentPrefix(mainWindow.currentInputBuffer)
                                    }
                                }
                            }
                            // Split Gap
                            Item {
                                visible: controller.isSplit
                                Layout.fillWidth: true
                            }
                            // Right Bank
                            Repeater {
                                model: [
                                    { k: "h", h: "" }, { k: "j", h: "" }, { k: "k", h: "" }, { k: "l", h: "" }
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
                                    onKeyTriggered: (key) => {
                                        mainWindow.currentInputBuffer += key
                                        gestureEngine.updateCurrentPrefix(mainWindow.currentInputBuffer)
                                    }
                                }
                            }
                        }

                        // Row 3: ⇧ z x c v | b n m ⌫
                        RowLayout {
                            spacing: 6
                            KeyButton {
                                label: "⇧"
                                isSpecial: true
                                implicitWidth: controller.isSplit ? 50 : 60
                                currentTheme: mainWindow.activeTheme
                                Layout.fillHeight: true
                            }
                            Repeater {
                                model: ["z", "x", "c", "v"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    gestureEngine: gestureEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    onKeyTriggered: (key) => {
                                        mainWindow.currentInputBuffer += key
                                        gestureEngine.updateCurrentPrefix(mainWindow.currentInputBuffer)
                                    }
                                }
                            }
                            // Split Gap
                            Item {
                                visible: controller.isSplit
                                Layout.fillWidth: true
                            }
                            Repeater {
                                model: ["b", "n", "m"]
                                delegate: KeyButton {
                                    label: modelData
                                    currentTheme: mainWindow.activeTheme
                                    vk: virtualKeyEngine
                                    gestureEngine: gestureEngine
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    onKeyTriggered: (key) => {
                                        mainWindow.currentInputBuffer += key
                                        gestureEngine.updateCurrentPrefix(mainWindow.currentInputBuffer)
                                    }
                                }
                            }
                            KeyButton {
                                label: "⌫"
                                isSpecial: true
                                isBackspace: true
                                implicitWidth: controller.isSplit ? 50 : 70
                                currentTheme: mainWindow.activeTheme
                                controller: controller
                                vk: virtualKeyEngine
                                Layout.fillHeight: true
                            }
                        }

                        // Row 4: ?123/ABC 😊 , spazio | . ↵ Close(✖)
                        RowLayout {
                            spacing: 6
                            KeyButton {
                                label: controller.layoutMode === "abc" ? "?123" : "ABC"
                                isSpecial: true
                                implicitWidth: 55
                                currentTheme: mainWindow.activeTheme
                                onReleased: {
                                    if (controller.layoutMode === "abc") {
                                        controller.layoutMode = "symbols"
                                    } else {
                                        controller.layoutMode = "abc"
                                    }
                                }
                                Layout.fillHeight: true
                            }
                            KeyButton {
                                label: "😊"
                                isSpecial: true
                                implicitWidth: 44
                                currentTheme: mainWindow.activeTheme
                                onReleased: controller.layoutMode = "emoji"
                                Layout.fillHeight: true
                            }
                            KeyButton {
                                label: ","
                                implicitWidth: 44
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
                                onKeyTriggered: {
                                    mainWindow.currentInputBuffer = ""
                                    gestureEngine.updateCurrentPrefix("")
                                }
                            }
                            // Split Gap
                            Item {
                                visible: controller.isSplit
                                Layout.fillWidth: true
                            }
                            KeyButton {
                                label: "."
                                implicitWidth: 44
                                currentTheme: mainWindow.activeTheme
                                vk: virtualKeyEngine
                                Layout.fillHeight: true
                                onKeyTriggered: {
                                    mainWindow.currentInputBuffer = ""
                                    gestureEngine.updateCurrentPrefix("")
                                }
                            }
                            KeyButton {
                                label: "↵"
                                textToSend: "\n"
                                isSpecial: true
                                isPrimaryAction: true
                                implicitWidth: controller.isSplit ? 50 : 65
                                currentTheme: mainWindow.activeTheme
                                vk: virtualKeyEngine
                                Layout.fillHeight: true
                                onKeyTriggered: {
                                    mainWindow.currentInputBuffer = ""
                                    gestureEngine.updateCurrentPrefix("")
                                }
                            }
                            // Close Keyboard Button ✖ (Contracts to Floating Bubble)
                            KeyButton {
                                label: "✖"
                                isSpecial: true
                                isCustomAction: true
                                implicitWidth: 48
                                currentTheme: mainWindow.activeTheme
                                Layout.fillHeight: true
                                onReleased: {
                                    mainWindow.isMinimized = true
                                    minimizedPill.syncMinimizedMask()
                                }
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
                                        "😘", "😗", "😙", "😚", "😋", "😛", "😜", "🤪",
                                        "🤨", "🧐", "🤓", "😎", "🤩", "🥳", "😏", "😒",
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
