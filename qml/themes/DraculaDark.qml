import QtQuick 2.15

QtObject {
    id: theme

    property string themeName: "Dracula Dark"

    property color backgroundColor: "#282a36"
    property color cardBorderColor: "#bd93f9"
    property int cardRadius: 24

    property color keyBackgroundColor: "#44475a"
    property color keyActiveColor: "#6272a4"
    property color keyBorderColor: "#6272a4"
    property int keyBorderWidth: 1
    property int keyRadius: 14

    property color specialKeyBackgroundColor: "#383a59"
    property color textColor: "#f8f8f2"
    property color accentColor: "#ff79c6"
    property color accentTextColor: "#ffffff"

    property color headerPillBg: "#21222c"
    property color sizeModePillBg: "#191a21"

    property color dpadBg: "#21222c"
    property color dpadHeaderColor: "#bd93f9"

    property string fontFamily: "sans-serif"
}
