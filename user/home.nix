{
  pkgs,
  lib,
  ...
}: {
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

  # sway configuration
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };
    };
  };
  programs.swaylock.enable = true;

  # packages
  home.packages = with pkgs; [
    brightnessctl
    just

    # fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # wayland
    wl-clipboard
  ];

  programs.gpg.enable = true;
  programs.jujutsu.enable = true;
  programs.zed-editor.enable = true;
  programs.fd.enable = true;
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.firefox.enable = true;

  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  xdg.enable = true;
  xdg.configFile = {
    "zed/settings.json".source = ./zed/settings.json;
    "zed/keymap.json".source = ./zed/keymap.json;
    "jj/config.toml".source = ./jujutsu.toml;
  };
  home.shell.enableBashIntegration = true;
  home.sessionVariables = {EDITOR = "nvim";};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
