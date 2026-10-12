// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: stand-in for Omarchy's qs.Commons Style. The values reproduce the metrics contract
// in tools/flea-metrics-gate (base size 14, bodySmall 13, caption 12, space(px) = px x base / 12).
// Fills are inferred from how ui/*.qml uses them and still need a visual check, see
// docs/cachyos/commons-inventory.md.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "." as C

Singleton {
    id: root

    // The OEM's own anchor: space(px) is written against a base size of 12.
    readonly property int spaceAnchor: 12

    // Hyprland's decoration:rounding, read live by scheduleRefresh().
    property int cornerRadius: 8

    function space(px) {
        return Math.round(px * root.font.baseSize / root.spaceAnchor);
    }

    readonly property QtObject font: QtObject {
        property int baseSize: 14
        // The alias until fc-match answers; resolvedFamily is what the metrics gate compares.
        property string family: "monospace"
        property string resolvedFamily: family
        readonly property int body: Math.round(baseSize * 1.0)
        readonly property int bodySmall: Math.round(baseSize * 0.917)
        readonly property int caption: Math.round(baseSize * 0.833)
        readonly property int icon: Math.round(baseSize * 1.167)
    }

    readonly property QtObject spacing: QtObject {
        readonly property int hairline: root.space(1)
        readonly property int rowPaddingX: root.space(12)
        readonly property int controlPaddingY: root.space(6)
        readonly property int rowGap: root.space(8)
        // Inferred: the gap Sidebar leaves around its group headings. Verify against the field.
        readonly property int panelGap: root.space(8)
    }

    // The washes. hoverFillAlpha is also read on its own, to tint accent ink.
    readonly property real hoverFillAlpha: 0.08
    readonly property real selectionFillAlpha: 0.18
    readonly property color normalFill: Qt.alpha(C.Color.foreground, 0.05)
    readonly property color hoverFill: Qt.alpha(C.Color.foreground, root.hoverFillAlpha)
    readonly property color selectionFill: Qt.alpha(C.Color.accent, root.selectionFillAlpha)
    readonly property color selectedFill: Qt.alpha(C.Color.foreground, 0.14)
    // Carries the selected alpha already, so a caller uses it as a colour and never also as an opacity.
    readonly property color selectedAccentFill: Qt.alpha(C.Color.accent, 0.35)
    readonly property int normalBorderWidth: root.space(1)
    readonly property color hoverBorderColor: Qt.alpha(C.Color.foreground, 0.3)

    // Sample input: [font]\nbase-size = 14\nfamily = "JetBrainsMono Nerd Font"
    function loadShell(body) {
        var text = String(body || "");
        var size = text.match(/^\s*base-size\s*=\s*(\d+)/m);
        root.font.baseSize = size ? Number(size[1]) : 14;
        var fam = text.match(/^\s*family\s*=\s*["']([^"']+)["']/m);
        if (fam) {
            root.font.family = fam[1];
            root.font.resolvedFamily = fam[1];
        } else {
            familyQuery.running = true;
        }
    }

    // Re-reads what the compositor and fontconfig own; Theme calls it when the theme name changes.
    function scheduleRefresh() {
        refresh.restart();
    }

    Timer {
        id: refresh
        interval: 50
        onTriggered: {
            rounding.running = true;
            familyQuery.running = true;
        }
    }

    // Sample input: {"option": "decoration:rounding", "int": 10, "set": true}
    Process {
        id: rounding
        running: true
        command: ["hyprctl", "-j", "getoption", "decoration:rounding"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    if (typeof parsed.int === "number")
                        root.cornerRadius = parsed.int;
                } catch (e) {
                    // hyprctl unreachable: the default stays.
                }
            }
        }
    }

    // fc-match answers the face "monospace" stands for, which is what the metrics contract names.
    Process {
        id: familyQuery
        running: true
        command: ["fc-match", "monospace", "-f", "%{family}"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var name = String(text).split(",")[0].trim();
                if (name.length > 0)
                    root.font.resolvedFamily = name;
            }
        }
    }
}
