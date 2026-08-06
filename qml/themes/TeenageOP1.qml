import QtQuick 2.15

QtObject {
    id: theme

    property string themeName: "Teenage OP-1"

    // Colors matching Teenage OP-1 synthesizer aesthetics
    property color backgroundColor: "#e3dfd8"
    property color cardBorderColor: "#c8c3b9"
    property int cardRadius: 24

    property color keyBackgroundColor: "#f5f3ef"
    property color keyActiveColor: "#d8d3c8"
    property color keyBorderColor: "#d4cfc5"
    property int keyBorderWidth: 1
    property int keyRadius: 14

    property color specialKeyBackgroundColor: "#eae6de"
    property color textColor: "#1e1e1e"
    property color accentColor: "#00a2ed"       // Safety Cyan
    property color accentTextColor: "#ffffff"

    property color headerPillBg: "#434a56"       // Dark slate pill container
    property color sizeModePillBg: "#21252d"     // Dark slate right container

    property color dpadBg: "#252a34"
    property color dpadHeaderColor: "#00a2ed"

    property string fontFamily: "sans-serif"
}
