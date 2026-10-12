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
3. Build and test (see the build section of the README once it exists).
4. Push: `git push origin cachyos`.

## Why merge

The `cachyos` branch is public. Merging keeps every commit, so a contributor who branched from `cachyos` does not have to rewrite their work.
