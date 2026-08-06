import QtQuick 2.15

QtObject {
    id: theme
    readonly property color backgroundColor: "#e3dfd8"
    readonly property color cardBorderColor: "#c7c2b8"
    readonly property color keyBackgroundColor: "#f5f3ef"
    readonly property color keyActiveColor: "#dcd7cd"
    readonly property color keyBorderColor: "#d3ceb7"
    readonly property color textColor: "#1c1917"
    readonly property color accentColor: "#0284c7"
    readonly property color accentTextColor: "#0284c7"
    readonly property color redWarningColor: "#dc2626"
    readonly property string fontFamily: "JetBrains Mono, monospace"
    readonly property int keyRadius: 10
    readonly property int cardRadius: 24
}
