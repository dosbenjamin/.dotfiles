#!/usr/bin/env bash
set -euo pipefail

readonly expected_user="benjamin"
readonly expected_home="/Users/benjamin"
readonly expected_repo="${expected_home}/.dotfiles"

assume_yes=false

usage() {
  cat <<'EOF'
Usage: macos-update [--yes]

Update and upgrade Nix from a temporary flake copy, Homebrew, and Mac App Store
applications, then clean obsolete downloads and unreachable Nix store paths.

  -y, --yes  Apply the updated Nix configuration without prompting
  -h, --help Show this help
EOF
}

while (( $# > 0 )); do
  case "$1" in
    -y | --yes)
      assume_yes=true
      ;;
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

update_dir="$(mktemp -d)"
cleanup() {
  rm -rf -- "${update_dir}"
}
trap cleanup EXIT

cp -R "${expected_repo}/nix/." "${update_dir}/"

echo "Updating Nix flake inputs..."
nix --extra-experimental-features 'nix-command flakes' flake update \
  --flake "path:${update_dir}"

if ! cmp -s "${expected_repo}/nix/flake.lock" "${update_dir}/flake.lock"; then
  diff -u \
    --label nix/flake.lock \
    --label nix/flake.lock.updated \
    "${expected_repo}/nix/flake.lock" "${update_dir}/flake.lock" || true

  if [[ "${assume_yes}" == false ]]; then
    read -r -p "Apply this Nix update? [y/N] " reply
    if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
      echo "Stopped before activation; the repository was not changed."
      exit 0
    fi
  fi
else
  echo "Nix flake inputs are already current."
fi

echo "Applying the macOS configuration..."
sudo -H nix run 'nix-darwin/nix-darwin-26.05#darwin-rebuild' -- \
  switch --flake "path:${update_dir}#macos"

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
