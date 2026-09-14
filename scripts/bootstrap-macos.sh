#!/usr/bin/env bash

set -euo pipefail

readonly expected_user="benjamin"
readonly expected_home="/Users/benjamin"
readonly expected_repo="${expected_home}/.dotfiles"
readonly screenshots_dir="${expected_home}/Pictures/Screenshots"
readonly terminal_profile_name="GitHub Dark"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap only supports macOS." >&2
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "This configuration requires an Apple Silicon Mac (arm64)." >&2
  exit 1
fi

if [[ "$(id -un)" != "${expected_user}" || "${HOME}" != "${expected_home}" ]]; then
  echo "Run this bootstrap as ${expected_user} with HOME=${expected_home}." >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

if [[ "${repo_root}" != "${expected_repo}" ]]; then
  echo "Expected the repository at ${expected_repo}, found ${repo_root}." >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing the Xcode Command Line Tools..."
  xcode-select --install || true
  echo "Finish the installation, then run this script again." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Administrator access is required to install Homebrew."
  sudo -v
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

if ! command -v nix >/dev/null 2>&1; then
  echo "Installing Lix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix \
    | sh -s -- install --no-confirm

  # The Lix environment script probes optional shell variables such as
  # ZSH_VERSION, which are unset when this Bash script runs with nounset.
  set +u
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  set -u
fi

terminal_profile="${repo_root}/assets/terminal/GitHub Dark.terminal"

# The destination must exist before nix-darwin writes the screencapture
# preference or macOS may keep using the Desktop on the first activation.
mkdir -p "${screenshots_dir}"

if ! defaults read com.apple.Terminal "Window Settings" 2>/dev/null \
  | grep -Fq "\"${terminal_profile_name}\" ="; then
  echo "Importing the ${terminal_profile_name} Terminal profile..."
  open -a Terminal "${terminal_profile}"
fi

echo "Make sure you are signed in to the Mac App Store before continuing."
echo "Applying the macOS configuration..."

cd "${repo_root}"
sudo -H nix run 'nix-darwin/nix-darwin-26.05#darwin-rebuild' -- \
  switch --flake "${repo_root}/nix#macos"

echo "macOS configuration applied. Log out and back in to apply appearance and keyboard settings."
