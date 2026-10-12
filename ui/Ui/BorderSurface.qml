// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: stand-in for Omarchy's qs.Ui BorderSurface. A filled, rounded card with one edge
// and a padding, and the four content insets ui/NetworkDialog.qml reads to place its body.
import QtQuick

Rectangle {
    id: root

    // Border.flat(color, width): { kind, color, width }.
    property var borderSpec: null
    property real padding: 0

    readonly property real edgeWidth: root.borderSpec && root.borderSpec.width ? root.borderSpec.width : 0
    readonly property real contentLeftInset: root.padding + root.edgeWidth
    readonly property real contentRightInset: root.padding + root.edgeWidth
    readonly property real contentTopInset: root.padding + root.edgeWidth
    readonly property real contentBottomInset: root.padding + root.edgeWidth

    border.width: root.edgeWidth
    border.color: root.borderSpec && root.borderSpec.color ? root.borderSpec.color : "transparent"
}
