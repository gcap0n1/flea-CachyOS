# Syncing with upstream

## Remotes and branches

| Name | Points to | Rule |
|---|---|---|
| `origin` | `gcap0n1/flea-CachyOS` (this fork) | Where our work is published |
| `upstream` | `thisisgm/flea` | Source of new Flea releases |
| `main` | mirror of `upstream/main` | Fast-forward only. No local commits |
| `cachyos` | our changes on top of an upstream release tag | Default branch of the fork |

## When a new upstream release appears

```sh
git fetch upstream --tags
git checkout main
git merge --ff-only upstream/main
git push origin main

git checkout cachyos
git merge <new-tag>        # merge, not rebase: keeps the history shared with contributors
```

Then:

1. Resolve conflicts. Keep our changes small; if a conflict touches an upstream file we patched, prefer the upstream version and reapply the patch.
2. Read `CHANGELOG.md` for entries that touch Omarchy-specific paths or commands.
3. Since 0.4.0 the window is `flea-gui` (GPUI, `crates/flea-gui`) and the QML frontend no longer runs; `ui/` still ships as data and for `tests/js.sh`. Grep the new code for Omarchy paths and commands (`omarchy/current/theme`, `omarchy/language`, `/usr/share/omarchy`, `"omarchy-`). Colours reach `flea-gui` through `~/.local/state/omarchy/current/theme/colors.toml`, which Noctalia writes (`packaging/noctalia/flea.toml`); the language through `~/.config/flea/language` and the roster under `/usr/share/flea/omarchy` (`src/i18n/mod.rs`).
4. Check what the new code asks of `ui/Commons` and `ui/Ui`: grep `ui/` for `Commons.`, `Style.`, `Util.`, `Border.` and `import qs.Ui`, and add any member our libraries lack (v0.3.10 added `Color.shellFile`, `userShellFile`, `themeShellValues`, `userShellValues` and `Util.clampAlpha` for `ui/Glass.qml`).
5. Compare upstream's root `PKGBUILD` (depends; since 0.4.0 `package()` is `make install`, see the `Makefile`) with `packaging/flea-cachyos/PKGBUILD`.
6. Build and test: `cargo build --release --workspace --bins`, `cargo test --release`, `./tests/js.sh` (the theme-palette checks fail without Omarchy's themes installed), then a real launch with `scripts/flea-dev`.
7. Push: `git push origin cachyos`, then build the package (its version comes from `Cargo.toml`).

## Why merge

The `cachyos` branch is public. Merging keeps every commit, so a contributor who branched from `cachyos` does not have to rewrite their work.

## Automatic sync

`.github/workflows/upstream-check.yml` ("Upstream release sync") runs every day at 06:17 UTC. When `thisisgm/flea` has a `vX.Y.Z` tag that `cachyos` does not contain:

- **Clean merge:** it merges the tag on a `sync/<tag>` branch (keeping our `.github`), builds, runs the Rust tests and `scripts/check-commons`, pushes the branch and opens a pull request with the results.
  - **Every check green:** the workflow fast-forwards `cachyos` to the tested merge itself, which marks the pull request merged, then dispatches `package.yml` (a push made with the workflow token starts no other workflow) and closes older `sync/` pull requests and conflict issues. `pacman -Syu` picks the new version up once the package build finishes.
  - **Held for a person** when the build fails, a Rust test fails other than the known runner-only one below, `scripts/check-commons` finds members missing, the new code adds an Omarchy path or command (step 3), or upstream's runtime `depends` changed (step 5). The pull request says why; follow the steps above, then merge it.
- **Conflict:** it opens an issue listing the conflicting files. Merge by hand with the steps above.
- **Push or pull request refused:** it opens an issue saying why.

The automatic merge skips `./tests/js.sh` and a real launch, which the runner cannot do; run them after the update if something looks off. The fork's Actions setting "Allow GitHub Actions to create and approve pull requests" must stay on. GitHub pauses scheduled workflows after 60 days without repository activity; run it by hand from the Actions tab if it goes quiet.

`backend::flashpipe::tests::a_zip_member_named_with_brackets_streams_itself` fails on GitHub's Ubuntu runner and passes on CachyOS; treat it as an environment difference unless it fails locally too.

## Tags

Upstream's `Release` workflow runs on every `v*` tag and publishes to the AUR, so it is disabled in this fork. Never push the upstream tags to `origin`. Name our own releases with a different prefix, for example `cachyos-v0.3.9.1`.
