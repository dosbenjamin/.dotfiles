#!/usr/bin/env bash
set -euo pipefail

readonly expected_user="benjamin"
readonly expected_home="/Users/benjamin"
readonly expected_repo="${expected_home}/.dotfiles"

usage() {
  cat <<'EOF'
Usage: macos-update

Apply the pinned Nix configuration, update Homebrew and Mac App Store
applications, then clean obsolete downloads and unreachable Nix store paths.

  -h, --help Show this help
EOF
}

while (( $# > 0 )); do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This command only supports macOS." >&2
  exit 1
fi

if [[ "$(id -un)" != "${expected_user}" || "${HOME}" != "${expected_home}" ]]; then
  echo "Run this command as ${expected_user} with HOME=${expected_home}." >&2
  exit 1
fi

if [[ ! -d "${expected_repo}/.git" ]]; then
  echo "Expected the dotfiles repository at ${expected_repo}." >&2
  exit 1
fi

cd "${expected_repo}"

echo "Applying the pinned macOS configuration..."
sudo -H nix run 'nix-darwin/nix-darwin-26.05#darwin-rebuild' -- \
  switch --flake "path:${expected_repo}/nix#macos"

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Updating and upgrading Homebrew..."
brew update
brew upgrade
brew upgrade --cask --greedy

echo "Upgrading Mac App Store applications..."
mas upgrade

echo "Cleaning Homebrew and the Nix store..."
brew cleanup
nix store gc

echo "macOS maintenance complete."
