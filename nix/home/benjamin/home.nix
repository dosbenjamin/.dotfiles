{
  config,
  lib,
  pkgs,
  ...
}:

{
  home = {
    username = "benjamin";
    homeDirectory = "/Users/benjamin";
    stateVersion = "26.05";

    packages = with pkgs; [
      codex
      mas
    ];
    sessionPath = [ "$HOME/.local/bin" ];

    file.".hushlogin".text = "";
  };

  programs.zsh = {
    enable = true;
    shellAliases.macos-update = "bash ~/.dotfiles/scripts/update-macos.sh";
  };

  home.activation.createScreenshotsDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
  '';
}
