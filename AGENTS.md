# Agent instructions

## Project decisions

- Keep the existing Linux setup operational while migrating it gradually to Nix and Home Manager.
- Keep `scripts/install.sh` and `scripts/post-install.sh`; they remain Linux-only until that migration is complete.
- Use flakes, nix-darwin, and Home Manager for macOS.
- Use the stable 26.05 branches and keep their inputs aligned through `nix/flake.lock`.
- Keep the generic macOS flake configuration name `macos`; do not create machine-specific configurations unless requested.
- Target Apple Silicon (`aarch64-darwin`) with user `benjamin`, home `/Users/benjamin`, and repository `/Users/benjamin/.dotfiles`.
- Keep Lix as the configured Nix implementation.
- Prefer user-scoped configuration and packages through Home Manager. Keep system-level management only where macOS integration warrants it: Lix and Nix settings, GUI and Mac App Store applications, fonts used by macOS applications, and system defaults belong in nix-darwin.
- Keep the macOS shell minimal: Zsh without Oh My Zsh, starship, zoxide, fzf, autosuggestions, syntax highlighting, or other plugins.
- Keep `home.packages` limited to `cloudflared` unless explicitly requested otherwise.
- Use macOS/Xcode CLT for Git, curl, and SSH. Do not manage `.gitconfig` on macOS.
- Manage GUI and Mac App Store applications through nix-darwin's Homebrew integration.
- Do not enable destructive Homebrew cleanup; undeclared applications must remain installed.
- Keep `.hushlogin` shared through Home Manager. Keep the root `.zshrc` and `.gitconfig` Linux-only for now.
- Keep the Nix modules small and direct. Extract shared modules only when Linux actually reuses them.

## Working rules

- Read `README.md` for user-facing setup and usage documentation; do not duplicate it here.
- Inspect `git status` and relevant diffs before editing. Preserve unrelated and uncommitted changes.
- Do not delete, rename, or substantially rewrite the legacy Linux scripts as part of unrelated macOS work.
- Preserve the platform guards in all bootstrap and post-install scripts.
- Avoid destructive operations and never commit unless explicitly requested.
- Do not add secrets, credentials, host keys, or machine-specific private data.
- Do not generate or commit the binary Terminal profile. Its future location is `assets/terminal/GitHub Dark.terminal`.
- When changing macOS packages or applications, keep the configuration intentionally minimal and verify identifiers against current upstream sources.
- When changing Nix inputs, update `flake.lock` deliberately and review the resulting diff.
- Validate relevant changes from the repository root with:

  ```bash
  bash -n scripts/install.sh scripts/post-install.sh scripts/bootstrap-macos.sh
  nix --extra-experimental-features 'nix-command flakes' flake check path:./nix --no-build
  nix --extra-experimental-features 'nix-command flakes' eval --raw \
    path:./nix#darwinConfigurations.macos.config.system.build.toplevel.drvPath
  git diff --check
  ```

- Use `path:./nix` for local checks so new, unstaged flake files remain visible to Nix.
