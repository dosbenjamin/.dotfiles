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
      cloudflared
      codex
    ];
    sessionPath = [ "$HOME/.local/bin" ];

    file.".hushlogin".text = "";
  };

  programs.zsh.enable = true;

  home.activation.createScreenshotsDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
  '';
}
