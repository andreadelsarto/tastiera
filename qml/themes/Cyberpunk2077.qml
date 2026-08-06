import QtQuick 2.15

QtObject {
    id: theme

    property string themeName: "Cyberpunk 2077"

    property color backgroundColor: "#0d0221"
    property color cardBorderColor: "#00f0ff"
    property int cardRadius: 24

    property color keyBackgroundColor: "#1a0933"
    property color keyActiveColor: "#2d1254"
    property color keyBorderColor: "#ff0055"
    property int keyBorderWidth: 1
    property int keyRadius: 14

    property color specialKeyBackgroundColor: "#260e45"
    property color textColor: "#00f0ff"
    property color accentColor: "#ff0055"
    property color accentTextColor: "#ffffff"

    property color headerPillBg: "#15062b"
    property color sizeModePillBg: "#110424"

    property color dpadBg: "#15062b"
    property color dpadHeaderColor: "#00f0ff"

    property string fontFamily: "sans-serif"
}
