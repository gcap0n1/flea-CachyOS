// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: stand-in for Omarchy's qs.Commons Util. Only the two helpers Flea calls.
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // A colour with its alpha replaced, the house idiom for scrims and washes.
    function alpha(color, a) {
        return Qt.alpha(color, a);
    }

    // An alpha held to [0, 1]; ui/Glass.qml reads one from shell.toml.
    function clampAlpha(value) {
        return Math.max(0, Math.min(1, Number(value)));
    }

    // The same encoding ui/boot/shell.qml writes out for itself.
    function fileUrl(path) {
        return "file://" + encodeURI(path).replace(/#/g, "%23").replace(/\?/g, "%3F");
    }
}
