// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: stand-in for Omarchy's qs.Commons Color. Four roles, a fixed dark default, and the
// two loaders ui/Theme.qml calls. See docs/cachyos/commons-inventory.md.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // The fixed dark theme. It applies whenever no palette file is readable, which is every launch
    // until Phase 3 points ui/Theme.qml at a Noctalia-derived colors.toml.
    readonly property var defaults: ({
        background: "#101315",
        foreground: "#cdd6f4",
        accent: "#89b4fa",
        urgent: "#f38ba8"
    })

    property color background: root.defaults.background
    property color foreground: root.defaults.foreground
    property color accent: root.defaults.accent
    property color urgent: root.defaults.urgent

    // Sample input: foreground = "#cdd6f4"   (the colors.toml format Palette.js also reads)
    function loadColors(body) {
        var found = {};
        var lines = String(body || "").split("\n");
        for (var i = 0; i < lines.length; i++) {
            var kv = lines[i].match(/^\s*([A-Za-z0-9_-]+)\s*=\s*["']?(#[0-9A-Fa-f]{6})/);
            if (kv)
                found[kv[1]] = kv[2];
        }
        function pick(keys, fallback) {
            for (var k = 0; k < keys.length; k++) {
                if (found[keys[k]])
                    return found[keys[k]];
            }
            return fallback;
        }
        root.background = pick(["background"], root.defaults.background);
        root.foreground = pick(["foreground"], root.defaults.foreground);
        root.accent = pick(["accent", "color4"], root.defaults.accent);
        root.urgent = pick(["red", "color1"], root.defaults.urgent);
    }

    // Sample input: [font]\nbase-size = 14
    function loadShell(body) {
        Style.loadShell(body);
        root.themeShellValues = root.parseShell(body);
    }

    // shell.toml flattened to "section.key" -> the value's text, which is how ui/Glass.qml asks for
    // flea.background-alpha. Sample input: [flea]\nbackground-alpha = 0.85
    function parseShell(body) {
        var out = {};
        var section = "";
        var lines = String(body || "").split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].replace(/#.*$/, "").trim();
            var head = line.match(/^\[([A-Za-z0-9_.-]+)\]$/);
            if (head) {
                section = head[1];
                continue;
            }
            var kv = line.match(/^([A-Za-z0-9_-]+)\s*=\s*["']?([^"']*)["']?$/);
            if (kv)
                out[(section ? section + "." : "") + kv[1]] = kv[2].trim();
        }
        return out;
    }

    // The theme's shell.toml (rendered next to colors.toml) and the user's own overrides.
    property var themeShellValues: ({})
    property var userShellValues: ({})
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/flea-cachyos/current"
    readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/flea-cachyos"

    property FileView shellFile: FileView {
        path: root.stateDir + "/theme/shell.toml"
        printErrors: false
        onLoaded: root.themeShellValues = root.parseShell(text())
        onLoadFailed: root.themeShellValues = ({})
    }
    property FileView userShellFile: FileView {
        path: root.configDir + "/shell.toml"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.userShellValues = root.parseShell(text())
        onLoadFailed: root.userShellValues = ({})
    }
}
