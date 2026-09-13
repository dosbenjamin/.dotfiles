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
      mas
    ];
    sessionPath = [ "$HOME/.local/bin" ];

    file.".hushlogin".text = "";
  };

  programs.zsh.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "workspace.benjamindossantos.dev" = {
        HostName = "workspace.benjamindossantos.dev";
        User = "benjamin";
      };

      "cloudflare-access" = lib.hm.dag.entryAfter [ "workspace.benjamindossantos.dev" ] {
        header = ''Match host workspace.benjamindossantos.dev exec "${pkgs.cloudflared}/bin/cloudflared access ssh-gen --hostname %h"'';
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        IdentityFile = "~/.cloudflared/%h-cf_key";
        CertificateFile = "~/.cloudflared/%h-cf_key-cert.pub";
      };

      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };

  home.activation.createScreenshotsDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
  '';
}
