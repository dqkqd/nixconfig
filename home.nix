{ config, pkgs, lib, ... }:

{
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

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };
    };
  };

  # packages
  home.packages = with pkgs; [
    brightnessctl
    just

    # fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];


  home.file = { };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Khanh Duong";
        email = "dqkqdlot@gmail.com";
      };
    };
  };

  home.shell.enableBashIntegration = true;

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.firefox.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
