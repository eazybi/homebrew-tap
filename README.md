# eazybi/homebrew-tap

Private Homebrew tap for eazyBI command-line tools.

Formulas here pull binaries from private GitHub releases (currently
[eazybi/eazybi_cli](https://github.com/eazybi/eazybi_cli)), so installing
requires a GitHub token. The tap uses the **GitHub CLI (`gh`)** so you only
authenticate once and never handle a raw PAT.

## One-time setup

```sh
brew install gh
gh auth login                 # browser OAuth, pick HTTPS
gh auth setup-git             # makes git use gh for private HTTPS auth
```

## Install

```sh
brew tap eazybi/tap https://github.com/eazybi/homebrew-tap.git
brew install eazybi/tap/eazybi
```

During `brew install`, the formula's download strategy shells out to
`gh auth token` to fetch a short-lived token and download the release asset.
Nothing is stored in your shell profile.

## Upgrade

```sh
brew update
brew upgrade eazybi/tap/eazybi
```

## Uninstall

```sh
brew uninstall eazybi/tap/eazybi
brew untap eazybi/tap
```

## Power user / CI alternative

If `gh` isn't available (e.g. CI), export a PAT with `repo` scope — the
download strategy will use that instead:

```sh
export HOMEBREW_GITHUB_API_TOKEN=ghp_xxx
```

## Layout

- `Formula/` — auto-generated formulas committed by
  [goreleaser](https://goreleaser.com/) during `eazybi_cli` releases.
- `lib/custom_download_strategy.rb` — authenticates `brew` downloads against
  private GitHub release assets. Tries `gh auth token` first, then falls back
  to `HOMEBREW_GITHUB_API_TOKEN`. Referenced from generated formulas as
  `custom_require "lib/custom_download_strategy"`. Once `eazybi_cli` becomes
  public, both the `custom_require` line and this file can be removed.

## Publishing

Formulas are published automatically when a new tag is pushed to
`eazybi/eazybi_cli`. The release workflow uses the `HOMEBREW_TAP_GITHUB_TOKEN`
secret (a PAT with `repo` scope on this tap) to commit updated formulas here.
