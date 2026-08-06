import QtQuick 2.15

QtObject {
    id: theme

    property string themeName: "Nord Frost"

    property color backgroundColor: "#2e3440"
    property color cardBorderColor: "#88c0d0"
    property int cardRadius: 24

    property color keyBackgroundColor: "#3b4252"
    property color keyActiveColor: "#434c5e"
    property color keyBorderColor: "#4c566a"
    property int keyBorderWidth: 1
    property int keyRadius: 14

    property color specialKeyBackgroundColor: "#353b49"
    property color textColor: "#eceff4"
    property color accentColor: "#88c0d0"
    property color accentTextColor: "#2e3440"

    property color headerPillBg: "#272c36"
    property color sizeModePillBg: "#1e222a"

    property color dpadBg: "#272c36"
    property color dpadHeaderColor: "#88c0d0"

    property string fontFamily: "sans-serif"
}
