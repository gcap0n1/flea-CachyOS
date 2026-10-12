# What Flea needs from Omarchy

Measured on upstream `v0.3.9` (`1de9d97`). Upstream ships `ui/Commons` and `ui/Ui` as symlinks to `/usr/share/omarchy/shell/`, so their source is not in the repository. This inventory is read from how `ui/` uses them. In this fork they are real directories with our own implementations.

## `qs.Commons` (55 files import it)

| Name | Used by | What Flea reads |
|---|---|---|
| `Style` | 33 files | `cornerRadius`, `space(px)`, `font.{family,resolvedFamily,baseSize,body,bodySmall,caption,icon}`, `spacing.{hairline,rowPaddingX,controlPaddingY,rowGap,panelGap}`, `normalFill`, `hoverFill`, `hoverFillAlpha`, `selectionFill`, `selectionFillAlpha`, `selectedFill`, `selectedAccentFill`, `normalBorderWidth`, `hoverBorderColor`, `scheduleRefresh()` |
| `Color` | `ui/Theme.qml` only, as `Commons.Color` | `background`, `foreground`, `accent`, `urgent`, `loadColors(body)`, `loadShell(body)` |
| `Util` | 5 files | `alpha(color, a)`, `fileUrl(path)` |
| `Border` | `ui/NetworkDialog.qml` | `flat(color, width)` |

`Motion`, `Icons`, `Settings` and `Palette` look like Commons names in a grep but are aliases of Flea's own `ui/js/*.js` modules. They need nothing from us.

`ui/Theme.qml` is the only consumer of `Color`. It reads `<stateDir>/theme/colors.toml` and `shell.toml`, hands the text to `Commons.Color.loadColors()` and `loadShell()`, and derives every other colour itself. `stateDir` is `~/.local/state/omarchy/current`; without that file our `Color` keeps its fixed dark default.

## `qs.Ui` (2 files import it)

| Type | Used in | Contract |
|---|---|---|
| `BorderSurface` | `NetworkDialog.qml` | `color`, `radius`, `padding`, `borderSpec`, and `contentLeftInset`, `contentRightInset`, `contentTopInset`, `contentBottomInset` |
| `PanelSectionHeader` | `Header.qml` (5), `NetworkDialog.qml` | A `Text`: `text`, `elide`, `horizontalAlignment`, `width` |
| `PanelSeparator` | `NetworkDialog.qml` | A hairline across its parent |

## Token contract

`tools/flea-metrics-gate` holds the numbers the tokens must produce at base size 14: `bodySmall` 13, `caption` 12, `rowPaddingX` 14, `rowPaddingY` 7, `gap` 9, `hairline` 1, `menuWidth` 257, `chromeMarkSize` 16. `space(px)` is `round(px x baseSize / 12)`. Our `Style.qml` follows it. `cornerRadius` mirrors Hyprland's `decoration:rounding`.

## Values inferred, not measured

These have no reference number upstream and need an eye on the real window:

- `spacing.panelGap` (Sidebar group headings).
- The washes: `normalFill`, `hoverFill`, `selectionFill`, `selectedFill`, `selectedAccentFill`, `hoverBorderColor`.
- `PanelSectionHeader` weight and colour, `PanelSeparator` strength.
- `BorderSurface` insets (padding plus edge width).

## Qt 6.12

Qt 6.12 added a `Color` singleton to `QtQuick`, which shadows an unqualified `Color` from `qs.Commons`. Upstream `v0.3.9` qualifies it as `Commons.Color`. Inside our own `Commons` files we refer to it through `import "." as C`. Do not add an unqualified `Color` anywhere.

## Omarchy coupling outside the libraries (Phase 2 and later)

Commands called from code: `omarchy update`, `omarchy-theme-set`, `omarchy-tailscale-send`, `omarchy-launch-terminal`, `omarchy-cmd-terminal-cwd`, `omarchy-shell`, `omarchy-pkg-add`. Files with the most references: `src/shelfplugin.rs` and the `shelf/` directory (the Omarchy bar, out of scope for v1), `src/hyprkeys.rs` (writes Omarchy's `bindings.lua`), `src/qsregistry.rs`, `src/update.rs`, `src/defaults.rs`, `ui/js/TextSize.js`, `ui/js/Settings.js`, `ui/ViewState.qml`.

## Running it

The backend has no Rust dependencies. From the repository root:

```sh
cargo build --release
FLEA_UI="$PWD/ui" ./target/release/flea --gui
```

Runtime needs `quickshell`, Qt 6 (`qt6-declarative`, `qt6-multimedia`), `gvfs` and the packages listed in `PKGBUILD`.
