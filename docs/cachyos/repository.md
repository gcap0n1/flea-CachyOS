# The flea-cachyos pacman repository

`.github/workflows/package.yml` builds `flea-cachyos` from the `cachyos` branch after every change, signs it, and publishes it with a signed database in this fork's [`repo` release](https://github.com/gcap0n1/flea-CachyOS/releases/tag/repo). With the repository in `pacman.conf`, `sudo pacman -Syu` updates Flea like any other package.

## Use it

Trust the signing key once (fingerprint `3246 42F2 730F 0852 06D7 2AFE 933E 7588 7CEF E703`):

```sh
curl -fsSLO https://raw.githubusercontent.com/gcap0n1/flea-CachyOS/cachyos/packaging/repo/flea-cachyos.asc
sudo pacman-key --add flea-cachyos.asc
sudo pacman-key --lsign-key 324642F2730F085206D72AFE933E75887CEFE703
```

Add the repository at the end of `/etc/pacman.conf`:

```ini
[flea-cachyos]
SigLevel = Required
Server = https://github.com/gcap0n1/flea-CachyOS/releases/download/repo
```

Then `sudo pacman -Syu flea-cachyos`.

The package provides and conflicts with `dolphin`, so installing it replaces Dolphin (which `cachyos-hypr-noctalia` requires) in one transaction. Each user then runs `flea-cachyos-setup` once.

## Maintain it

The workflow needs two repository secrets:

- `PKG_SIGNING_KEY`: the armored private key, `gpg --armor --export-secret-keys <fingerprint>`.
- `PKG_SIGNING_FPR`: its fingerprint.

The key is a dedicated, passphrase-less signing key that expires on 2029-10-12. Before then, extend it or make a new one, update both secrets and `packaging/repo/flea-cachyos.asc`, and have users trust the new key.
