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

    // The same encoding ui/boot/shell.qml writes out for itself.
    function fileUrl(path) {
        return "file://" + encodeURI(path).replace(/#/g, "%23").replace(/\?/g, "%3F");
    }
}
