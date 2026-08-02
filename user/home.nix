{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./firefox.nix
    ./git.nix
    ./keepassxc.nix
    ./mcp.nix
    ./opencode.nix
    ./skills.nix
    ./sway.nix
    ./zsh.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dqk";
  home.homeDirectory = "/home/dqk";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # packages
  home.packages = with pkgs; [
    # secrets
    age
    sops

    brightnessctl
    just
    uv

    kdePackages.okular

    # fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    font-awesome
    source-han-sans
    source-han-serif

    # wayland
    wl-clipboard
    slurp
    grim

    # nvim
    inputs.nvim-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default

    (anki.withAddons [
      ankiAddons.passfail2
      ankiAddons.review-heatmap
      ankiAddons.anki-connect
      ankiAddons.local-audio-yomichan
    ])
    mpv

    xdg-utils

    # agents tools
    tree
    jq
    ast-grep
    python3
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    firefox.enable = false;
  };

  programs.yazi.enable = true;
  programs.tmux.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.zoxide.enable = true;
  programs.gh.enable = true;
  programs.fzf.enable = true;
  programs.gpg.enable = true;
  programs.fuzzel.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
    };
  };
  programs.obsidian = {
    enable = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.discord.enable = true;
  programs.starship = {
    enable = true;
    presets = ["nerd-font-symbols"];
  };
  services.mako.enable = true;
  services.syncthing.enable = true;
  xdg.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
  xdg.autostart.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
    # fcitx5
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
  };
  # expiring
  services.home-manager = {
    autoExpire = {
      enable = true;
      frequency = "weekly";
      store.cleanup = true;
      timestamp = "-7 days";
    };
  };

  sops = {
    age.keyFile = "/home/dqk/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/sercets.yaml;

    secrets.npm_token = {};
    templates."npmrc" = {
      content = ''
        //registry.npmjs.org/:_authToken=${config.sops.placeholder.npm_token}
      '';
      path = "/home/dqk/.npmrc";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
