{
  inputs,
  pkgs,
  config,
  ...
}: let
  piReviewSrc = pkgs.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi-review";
    rev = "f1de050504936046c0f85b21fec0e0a93ef394eb";
    hash = "sha256-bvdJjLudTd9YQF8ip30jIvi6MY3MAcw5GXVONx1DLuQ=";
  };
in {
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
  ];

  sops.secrets.opencode_api_key = {};
  sops.secrets.exa_api_key = {};
  programs.zsh.initContent = ''
    export OPENCODE_API_KEY="$(cat ${config.sops.secrets.opencode_api_key.path})"
    export EXA_API_KEY="$(cat ${config.sops.secrets.exa_api_key.path})"
    export PI_NOTIFICATIONS=off
  '';

  home.file = {
    ".pi/agent/AGENTS.md".source = ./AGENTS.md;
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
      theme = "catppuccin-mocha";
      extensions = [
        ./extensions
        "${piReviewSrc}/review.ts"
      ];
      skills = [
        ./skills
      ];
      prompts = [
        ./prompts
      ];
      themes = [
        ./themes/catppuccin-mocha.json
      ];
      enableAnalytics = false;
    };
  };
}
