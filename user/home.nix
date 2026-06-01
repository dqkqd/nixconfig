{pkgs, ...}: {
  imports = [
    ./firefox.nix
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
    brightnessctl
    just
    git

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
    mako
  ];

  programs.zoxide.enable = true;
  programs.gh.enable = true;
  programs.fzf.enable = true;
  programs.gpg.enable = true;
  programs.jujutsu.enable = true;
  programs.fuzzel.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.discord.enable = true;
  programs.starship = {
    enable = true;
    presets = ["nerd-font-symbols"];
  };
  xdg.enable = true;
  xdg.configFile = {
    "jj/config.toml".source = ./jujutsu.toml;
  };
  home.sessionVariables = {EDITOR = "nvim";};
  # expiring
  services.home-manager = {
    autoExpire = {
      enable = true;
      frequency = "weekly";
      store.cleanup = true;
      timestamp = "-7 days";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
