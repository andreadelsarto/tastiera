import QtQuick 2.15

QtObject {
    id: theme
    readonly property color backgroundColor: "#0a0a0a"
    readonly property color keyBackgroundColor: "#1a1a1a"
    readonly property color keyActiveColor: "#2a2a2a"
    readonly property color keyBorderColor: "#333333"
    readonly property color textColor: "#ffffff"
    readonly property color accentColor: "#ff2e2e" // Red Glyph
    readonly property color redWarningColor: "#ff2e2e"
    readonly property string fontFamily: "DotGothic16, monospace"
    readonly property int keyRadius: 12
}
