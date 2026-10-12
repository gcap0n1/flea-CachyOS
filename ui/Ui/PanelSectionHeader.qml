// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: stand-in for Omarchy's qs.Ui PanelSectionHeader. A small muted label; ui/Header.qml
// and ui/NetworkDialog.qml set its text, elide, alignment and width, and nothing else.
import QtQuick
import qs.Commons as Commons

Text {
    color: Qt.darker(Commons.Color.foreground, 1.4)
    font.family: Commons.Style.font.family
    font.pixelSize: Commons.Style.font.caption
    font.bold: true
    verticalAlignment: Text.AlignVCenter
}
