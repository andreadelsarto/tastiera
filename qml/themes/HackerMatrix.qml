import QtQuick 2.15

QtObject {
    id: theme

    property string themeName: "Hacker / Matrix"

    property color backgroundColor: "#050a05"
    property color cardBorderColor: "#00ff41"
    property int cardRadius: 24

    property color keyBackgroundColor: "#0d1a0d"
    property color keyActiveColor: "#1a331a"
    property color keyBorderColor: "#008020"
    property int keyBorderWidth: 1
    property int keyRadius: 14

    property color specialKeyBackgroundColor: "#122412"
    property color textColor: "#00ff41"
    property color accentColor: "#00ff41"
    property color accentTextColor: "#050a05"

    property color headerPillBg: "#081408"
    property color sizeModePillBg: "#050d05"

    property color dpadBg: "#081408"
    property color dpadHeaderColor: "#00ff41"

    property string fontFamily: "monospace"
}
