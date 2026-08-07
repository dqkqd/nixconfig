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

  piSrc = pkgs.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "1dd2354052f7dd9fcdcc3097b87cf4b377853a74";
    hash = "sha256-l/HiMKk83Pr5yDjFe+n0+tb9YvtNFoLTEpCFjEmUXKc=";
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
    export PI_SKIP_VERSION_CHECK=1
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
        "${piSrc}/packages/coding-agent/examples/extensions/questionnaire.ts"
        "${piSrc}/packages/coding-agent/examples/extensions/todo.ts"
      ];
      skills = [
        ./skills
      ];
      themes = [
        ./themes/catppuccin-mocha.json
      ];
      enableAnalytics = false;
    };
  };
}
