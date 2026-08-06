import QtQuick 2.15

QtObject {
    id: theme
    readonly property color backgroundColor: "#0b1329"
    readonly property color cardBorderColor: "#1e293b"
    readonly property color keyBackgroundColor: "#162032"
    readonly property color keyActiveColor: "#24344d"
    readonly property color keyBorderColor: "#22334d"
    readonly property color textColor: "#e2e8f0"
    readonly property color accentColor: "#0284c7"
    readonly property color accentTextColor: "#38bdf8"
    readonly property color redWarningColor: "#ef4444"
    readonly property string fontFamily: "Inter, Noto Sans, sans-serif"
    readonly property int keyRadius: 14
    readonly property int cardRadius: 24
}
