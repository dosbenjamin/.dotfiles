{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "benjamin";
  users.users.benjamin = {
    name = "benjamin";
    home = "/Users/benjamin";
  };

  nix = {
    package = pkgs.lix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  programs.zsh.enable = true;

  fonts.packages = [ pkgs.jetbrains-mono ];

  homebrew = {
    enable = true;
    enableZshIntegration = true;

    brews = [ "mole" ];

    casks = [
      "battle-net"
      "chatgpt"
      "cloudflare-warp"
      "discord"
      "figma"
      "google-chrome"
      "league-of-legends"
      "linearmouse"
      "minecraft"
      "nvidia-geforce-now"
      "rode-connect"
      "steam"
      "teamviewer"
      "visual-studio-code"
    ];

    masApps = {
      Numbers = 361304891;
      Telegram = 747648890;
      WhatsApp = 310633997;
    };

    global = {
      autoUpdate = false;
      brewfile = true;
    };

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };
  };

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
      minimize-to-application = true;
      tilesize = 32;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      CreateDesktop = false;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    screencapture = {
      location = "/Users/benjamin/Pictures/Screenshots";
      type = "png";
    };

    CustomUserPreferences = {
      "com.apple.dock"."size-immutable" = true;

      # The bootstrap imports this custom profile before nix-darwin selects it.
      "com.apple.Terminal" = {
        "Default Window Settings" = "GitHub Dark";
        "Startup Window Settings" = "GitHub Dark";
      };
    };
  };

  system.activationScripts.postActivation.text = ''
    echo >&2 "reloading user interface services..."
    killall -qu benjamin Finder || true
    killall -qu benjamin SystemUIServer || true
  '';

  system.stateVersion = 6;
}
