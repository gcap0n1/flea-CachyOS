// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: the CachyOS logo replaces the Omarchy spiral. The logo artwork is by ptr1337 for
// CachyOS (GPL, https://commons.wikimedia.org/wiki/File:CachyOS_Logo.svg); see NOTICE.md.
import QtQuick
import QtQuick.Shapes

// The empty state's mark. It plays in three beats and then holds: the outline of the C draws
// itself, the facets fill in the brand's teal and cyan, then the three dots arrive one by one.
// The caller drives the repeat, so the mark and its caption share one beat; the loading crawl
// (ui/Spinner.qml) stays a separate gesture, continuous where this one arrives and rests.
Item {
    id: root

    property color color: Theme.color.muted
    // The logo's own viewBox, scaled to the slot.
    readonly property real grid: 17.921
    readonly property real markScale: Math.min(root.width, root.height) / root.grid
    readonly property real brandStroke: 0.7
    // The outline's perimeter is 62.938 logo units; dash units are strokeWidth multiples.
    readonly property real markDashes: 62.938 / root.brandStroke

    readonly property color teal: "#00aa88"
    readonly property color cyan: "#00ccff"
    property real facets: 1
    property real dotA: 1
    property real dotB: 1
    property real dotC: 1

    readonly property bool settled: !draw.running && outline.dashOffset === 0 && root.opacity === 1

    // Repaints the mark from blank. EmptyState calls this off the caption's own timer.
    function replay() {
        if (Theme.reducedMotion)
            root.settle()
        else
            draw.restart()
    }

    // A data-held folder lands whole.
    function settle() {
        draw.stop()
        outline.dashOffset = 0
        root.facets = 1
        root.dotA = 1
        root.dotB = 1
        root.dotC = 1
        root.opacity = 1
    }

    // The logo's coordinate space: everything below is in logo units, scaled to the slot.
    Item {
        width: root.grid
        height: root.grid
        x: (root.width - root.grid * root.markScale) / 2
        y: (root.height - root.grid * root.markScale) / 2
        transform: Scale { xScale: root.markScale; yScale: root.markScale }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // The facets, flat, in the logo's own paint order (its gradient highlights are left out).
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.teal, root.facets); PathSvg { path: "m3.973 1.8893 6.5887 3.6879 2.1127-3.6528z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.teal, root.facets); PathSvg { path: "m6.0619 12.144-1.9125 3.7456h8.5747l2.1664-3.7456z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.cyan, root.facets); PathSvg { path: "m3.973 1.8893 6.5887 3.6879h-4.526l-1.8859 3.2605 1.9121 3.306-1.9125 3.7456-4.1369-7.1525 3.9605-6.8475z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.teal, root.facets); PathSvg { path: "m6.0356 5.5772 6.6388-3.6528-2.1127 3.6528z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.teal, root.facets); PathSvg { path: "m0.0125 8.7368 6.0231-3.1596-1.8859 3.2605z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.teal, root.facets); PathSvg { path: "m6.0356 5.5772-2.0626-3.6879 0.17673 6.9484z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.cyan, root.facets); PathSvg { path: "m6.0619 12.144 6.6622 3.7456 2.1664-3.7456z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.teal, root.facets); PathSvg { path: "m4.1498 8.8377-3.1586 1.5811 3.1583 5.4705z" } }
        ShapePath { strokeColor: "transparent"; fillColor: Qt.alpha(root.teal, root.facets); PathSvg { path: "m0.99115 10.419 5.0708 1.7248-1.9121-3.306z" } }

        // The silhouette of the C, drawn on top so the outline frames the facets.
        ShapePath {
            id: outline
            strokeColor: root.color
            fillColor: "transparent"
            strokeWidth: root.brandStroke
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.MiterJoin
            strokeStyle: ShapePath.DashLine
            // One dash and one gap, each the whole outline, so only ever one dash sits on the path.
            dashPattern: [root.markDashes, root.markDashes]
            dashOffset: 0
            PathSvg { path: "m4.3286 1.9244h8.3458l-2.1127 3.6528h-4.526l-1.8859 3.2605 1.9121 3.306h8.8286l-2.1664 3.7456h-8.5747l-4.1369-7.1525 3.9605-6.8475z" }
        }
    }

    // The three dots, smallest first, where the logo places them (centre and radius in logo units).
    Repeater {
        model: [
            { cx: 14.979, cy: 3.585, r: 0.5568 },
            { cx: 13.490, cy: 7.327, r: 1.0812 },
            { cx: 16.490, cy: 10.643, r: 1.4243 }
        ]
        delegate: Rectangle {
            required property var modelData
            required property int index
            x: modelData.cx - modelData.r
            y: modelData.cy - modelData.r
            width: 2 * modelData.r
            height: width
            radius: modelData.r
            antialiasing: true
            color: root.cyan
            opacity: index === 0 ? root.dotA : index === 1 ? root.dotB : root.dotC
        }
    }
    }

    SequentialAnimation {
        id: draw
        // Dissolve the finished mark rather than cut it, then start from blank.
        NumberAnimation { target: root; property: "opacity"; to: 0.0; duration: 180; easing.type: Easing.OutQuad }
        PropertyAction { target: outline; property: "dashOffset"; value: root.markDashes }
        PropertyAction { target: root; property: "facets"; value: 0 }
        PropertyAction { target: root; property: "dotA"; value: 0 }
        PropertyAction { target: root; property: "dotB"; value: 0 }
        PropertyAction { target: root; property: "dotC"; value: 0 }
        PropertyAction { target: root; property: "opacity"; value: 1.0 }
        PauseAnimation { duration: 200 }
        NumberAnimation { target: outline; property: "dashOffset"; from: root.markDashes; to: 0; duration: 1100; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "facets"; to: 1; duration: 340; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "dotA"; to: 1; duration: 110; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "dotB"; to: 1; duration: 110; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "dotC"; to: 1; duration: 110; easing.type: Easing.OutCubic }
    }

    // The draw is the entrance as well as the loop, so it runs on every appearance.
    onVisibleChanged: if (root.visible) root.replay(); else draw.stop()
    Component.onCompleted: if (root.visible) root.replay()
    Connections {
        target: Theme
        function onReducedMotionChanged() { if (Theme.reducedMotion) root.replay() }
    }
}
