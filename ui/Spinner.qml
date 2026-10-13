// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: the activity mark crawls along the CachyOS logo's outline instead of the Omarchy
// spiral. Logo artwork by ptr1337 for CachyOS (GPL); see NOTICE.md.
import QtQuick
import QtQuick.Shapes

// A stroke-dash crawl along the outline of the C, never a rotation. The faint full outline stays
// underneath so the shape reads even where the dash is not. This and EmptyState's FleaMark are the
// only two places the logo appears in the window.
Item {
    id: root

    property color color: Theme.color.mutedFrame
    // The logo's own viewBox, scaled to the slot.
    readonly property real grid: 17.921
    readonly property real markScale: Math.min(root.width, root.height) / root.grid
    readonly property real brandStroke: 0.7
    // The closed outline is 62.938 logo units, so one dash period is the whole loop and the
    // animation's loop point is invisible.
    readonly property real period: 62.938 / root.brandStroke
    readonly property string outlinePath: "m4.3286 1.9244h8.3458l-2.1127 3.6528h-4.526l-1.8859 3.2605 1.9121 3.306h8.8286l-2.1664 3.7456h-8.5747l-4.1369-7.1525 3.9605-6.8475z"

    Shape {
        width: root.grid
        height: root.grid
        x: (root.width - root.grid * root.markScale) / 2
        y: (root.height - root.grid * root.markScale) / 2
        preferredRendererType: Shape.CurveRenderer
        transform: Scale { xScale: root.markScale; yScale: root.markScale }

        ShapePath {
            strokeColor: Qt.alpha(root.color, 0.25)
            fillColor: "transparent"
            strokeWidth: root.brandStroke
            joinStyle: ShapePath.MiterJoin
            PathSvg { path: root.outlinePath }
        }

        ShapePath {
            id: crawl
            strokeColor: root.color
            fillColor: "transparent"
            strokeWidth: root.brandStroke
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.MiterJoin
            strokeStyle: ShapePath.DashLine
            // A third of the outline lit, two thirds dark.
            dashPattern: [root.period / 3, root.period * 2 / 3]
            PathSvg { path: root.outlinePath }
        }
    }

    // Still for its first second on screen, so a load faster than that draws no motion; a hide puts it back to rest.
    readonly property int stillMs: 1000
    property bool crawling: false
    onVisibleChanged: if (!root.visible) { root.crawling = false; crawl.dashOffset = 0 }
    Timer {
        interval: root.stillMs
        running: root.visible && !root.crawling
        onTriggered: root.crawling = true
    }

    NumberAnimation {
        target: crawl
        property: "dashOffset"
        from: 0
        to: -root.period
        duration: 1600
        loops: Animation.Infinite
        // Item.visible reads effective visibility, so a hidden ancestor stops the crawl too.
        running: root.visible && root.crawling
    }
}
