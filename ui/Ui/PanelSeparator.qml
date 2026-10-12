// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: stand-in for Omarchy's qs.Ui PanelSeparator. One hairline across its parent.
import QtQuick
import qs.Commons as Commons

Rectangle {
    width: parent ? parent.width : 0
    height: Commons.Style.spacing.hairline
    color: Qt.alpha(Commons.Color.foreground, 0.2)
}
