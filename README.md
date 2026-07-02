# eazybi/homebrew-tap

Public Homebrew tap for eazyBI command-line tools.

## Install

```sh
brew install eazybi/tap/eazybi-cli
```

No GitHub token or `gh` setup is required — the binaries are hosted publicly at
`https://eazybi.com/system/downloads/`.

## Upgrade

```sh
brew update
brew upgrade eazybi/tap/eazybi-cli
```

## Uninstall

```sh
brew uninstall eazybi/tap/eazybi-cli
brew untap eazybi/tap
```

## Layout

- `Formula/` — auto-generated formulas rendered by
  [goreleaser](https://goreleaser.com/) during eazyBI CLI releases. Formula
  download URLs point at `https://eazybi.com/system/downloads/`.

## Publishing

Formulas are committed here by the eazyBI CLI release process
(`scripts/upload.sh` in the CLI repo), which runs from a trusted environment
after uploading the release archives to `eazybi.com`. This tap does not fetch
from any private repository.
