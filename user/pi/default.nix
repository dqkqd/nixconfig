{
  inputs,
  pkgs,
  config,
  ...
}: let
  piCodingAgentPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
in {
  home.packages = [
    piCodingAgentPackage

    # require for pi-web-access
    pkgs.ffmpeg
    pkgs.yt-dlp
  ];

  sops.secrets.opencode_api_key = {};
  sops.secrets.exa_api_key = {};
  programs.zsh.initContent = ''
    export OPENCODE_API_KEY="$(cat ${config.sops.secrets.opencode_api_key.path})"
    export EXA_API_KEY="$(cat ${config.sops.secrets.exa_api_key.path})"
    export PI_NOTIFICATIONS=off
  '';

  home.file = {
    # prompts
    ".pi/agent/prompts" = {
      source = ./prompts;
      recursive = true;
    };

    # skills
    ".pi/agent/skills" = {
      source = ./skills;
      recursive = true;
    };

    # extensions
    ".pi/agent/extensions" = {
      source = ./extensions;
      recursive = true;
    };
  };

  sops.secrets."pi/default_provider" = {};
  sops.secrets."pi/default_model" = {};
  sops.templates."pi-settings" = {
    path = "${config.home.homeDirectory}/.pi/agent/settings.json";
    mode = "0400";
    content = builtins.toJSON {
      defaultProvider = config.sops.placeholder."pi/default_provider";
      defaultModel = config.sops.placeholder."pi/default_model";
      defaultThinkingLevel = "high";
      hideThinkingBlock = true;
      theme = "dark";
      enableAnalytics = false;
    };
  };

  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
}
