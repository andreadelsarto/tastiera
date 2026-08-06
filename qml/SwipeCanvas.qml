import QtQuick 2.15

Canvas {
    id: canvas
    anchors.fill: parent
    z: 10
    enabled: false

    property var gestureEngine
    property var currentTheme
    property var pathPoints: []
    property real pathOpacity: 1.0

    Connections {
        target: gestureEngine
        function onStrokeUpdated(points) {
            canvas.pathPoints = points
            canvas.pathOpacity = 1.0
            canvas.requestPaint()
        }
        function onIsSwipingChanged() {
            if (!gestureEngine.isSwiping) {
                fadeTimer.restart()
            }
        }
    }

    Timer {
        id: fadeTimer
        interval: 16
        repeat: true
        onTriggered: {
            canvas.pathOpacity -= 0.1
            canvas.requestPaint()
            if (canvas.pathOpacity <= 0) {
                canvas.pathOpacity = 0
                canvas.pathPoints = []
                fadeTimer.stop()
            }
        }
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        if (!pathPoints || pathPoints.length < 2) return

        ctx.save()
        ctx.globalAlpha = pathOpacity
        ctx.strokeStyle = currentTheme ? currentTheme.accentColor : "#3daee9"
        ctx.lineWidth = 6
        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        ctx.beginPath()
        ctx.moveTo(pathPoints[0].x, pathPoints[0].y)
        for (var i = 1; i < pathPoints.length; ++i) {
            ctx.lineTo(pathPoints[i].x, pathPoints[i].y)
        }
        ctx.stroke()
        ctx.restore()
    }
}
