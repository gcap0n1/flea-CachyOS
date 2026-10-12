// SPDX-License-Identifier: GPL-3.0-only
// flea-CachyOS: stand-in for Omarchy's qs.Commons Border. Flea calls only Border.flat().
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // A single solid edge. BorderSurface reads color and width from the spec.
    function flat(color, width) {
        return { kind: "flat", color: color, width: width };
    }
}
