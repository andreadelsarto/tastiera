import QtQuick 2.15

QtObject {
    id: theme
    readonly property color backgroundColor: "#f2f2f2"
    readonly property color keyBackgroundColor: "#ffffff"
    readonly property color keyActiveColor: "#e6e6e6"
    readonly property color keyBorderColor: "#e0e0e0"
    readonly property color textColor: "#000000"
    readonly property color accentColor: "#ff2e2e" // Red Glyph
    readonly property color redWarningColor: "#ff2e2e"
    readonly property string fontFamily: "DotGothic16, monospace"
    readonly property int keyRadius: 12
}
