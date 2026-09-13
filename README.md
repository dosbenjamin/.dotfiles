# Dotfiles

Personal configuration for Benjamin's remote Linux environment and Apple Silicon Macs.

The Mac is intentionally a lightweight client rather than the primary development workstation. It runs macOS GUI applications, provides a minimal terminal for SSH and occasional local commands, and uses `cloudflared` for SSH access through Cloudflare short-lived certificates and tunnels. The main working environment is a remote VPS, which contains, or will receive, the substantial Linux dotfiles configuration.

The Linux setup remains script-based. macOS uses a flake with nix-darwin and Home Manager, while nix-darwin's Homebrew integration handles graphical applications. Linux can therefore migrate to Home Manager gradually without interrupting the existing setup.

## Layout

```text
.
├── .gitconfig
├── .hushlogin
├── .zshrc
├── AGENTS.md
├── assets/terminal/GitHub Dark.terminal
├── nix
│   ├── flake.lock
│   ├── flake.nix
│   ├── home/benjamin/home.nix
│   └── hosts/macos/darwin.nix
└── scripts
    ├── bootstrap-macos.sh
    ├── install.sh
    └── post-install.sh
```

The macOS Terminal profile lives at `assets/terminal/GitHub Dark.terminal`; the bootstrap imports it through Terminal rather than generating it with Nix.

## macOS

### Assumptions

- Apple Silicon Mac (`aarch64-darwin`)
- macOS user `benjamin`
- Home directory `/Users/benjamin`
- Repository cloned to `/Users/benjamin/.dotfiles`
- Administrator access
- A Mac App Store session for installing MAS applications

The configuration is named `macos` rather than after a specific machine, so the same profile can be reused across compatible Macs.

### First installation

Clone the repository to the expected location, then run:

```bash
~/.dotfiles/scripts/bootstrap-macos.sh
```

The bootstrap is safe to rerun. It:

1. validates macOS, Apple Silicon, the username, and repository path;
2. requests installation of Xcode Command Line Tools if missing;
3. installs Homebrew if missing;
4. installs Lix if missing;
5. imports the `GitHub Dark` Terminal profile when it is not already installed;
6. applies `nix#macos` with nix-darwin.

If Xcode CLT installation is requested, finish it and rerun the bootstrap.

### Applying changes

```bash
sudo nix run 'nix-darwin/nix-darwin-26.05#darwin-rebuild' -- \
  switch --flake ~/.dotfiles/nix#macos
```

Update pinned inputs deliberately with:

```bash
cd ~/.dotfiles/nix
nix flake update
```

Review the lock-file diff and evaluate the configuration before switching.

### Managed macOS configuration

The configuration uses Home Manager for user-scoped packages and files. nix-darwin handles system integration: Lix and Nix settings, GUI and Mac App Store applications, fonts, and macOS defaults. The resulting macOS environment is intentionally minimal rather than a full local development setup.

Home Manager keeps the terminal environment deliberately small:

- Zsh with no framework, theme, or third-party plugins;
- `$HOME/.local/bin` on `PATH`;
- `cloudflared` and the Codex CLI as the current contents of `home.packages`;
- an empty `.hushlogin` generated independently of the legacy file;
- no dependency on the legacy `.zshrc`, `.gitconfig`, or `.hushlogin` files.

`cloudflared` must remain available in the user shell because it participates directly in SSH connections through Cloudflare short-lived certificates and tunnels. Codex is retained for occasional use on the Mac; this does not make macOS a local development workstation. Git, curl, and SSH come from macOS/Xcode Command Line Tools and are sufficient for bootstrap and occasional local use.

nix-darwin manages Lix, flakes, JetBrains Mono, Dock and Finder preferences, dark mode, keyboard repeat, spelling/capitalization preferences, screenshots, and the Terminal profile name.

Homebrew installs `mas` and these casks:

```text
battle-net             chatgpt            discord
figma                  google-chrome      league-of-legends
linearmouse            minecraft          nvidia-geforce-now
rode-connect           steam              teamviewer
visual-studio-code
```

The Mac App Store entries are Numbers, Telegram, and WhatsApp. Homebrew cleanup is disabled, so applications not declared here are not automatically removed.

The screenshot directory is `/Users/benjamin/Pictures/Screenshots`. Home Manager creates it when necessary.

### Terminal profile

The bootstrap imports `assets/terminal/GitHub Dark.terminal` when a profile named `GitHub Dark` is not already installed. Terminal derives that profile name from the filename. The nix-darwin configuration then selects it as Terminal's default and startup profile. Existing profiles are left untouched.

## Linux

The existing workflow is preserved:

```bash
bash ~/.dotfiles/scripts/install.sh
bash ~/.dotfiles/scripts/post-install.sh
```

`install.sh` links the legacy root `.zshrc`, `.gitconfig`, and `.hushlogin` files, installs Oh My Zsh and its existing plugins, and changes the login shell. These files are Linux-only and are not consumed by the macOS configuration. `post-install.sh` is destructive by design: it removes existing Bash configuration, cloud-init marker files, shell history, and `~/.ssh/authorized_keys`. Review it before running it.

Both scripts refuse to run outside Linux. They will remain available until a separate, progressive Home Manager migration replaces their responsibilities.

## Validation

From the repository root:

```bash
bash -n scripts/install.sh scripts/post-install.sh scripts/bootstrap-macos.sh
nix --extra-experimental-features 'nix-command flakes' flake check path:./nix --no-build
nix --extra-experimental-features 'nix-command flakes' eval --raw \
  path:./nix#darwinConfigurations.macos.config.system.build.toplevel.drvPath
git diff --check
```

No deployment or commit is performed automatically from this repository.
