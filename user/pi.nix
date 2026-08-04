{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: let
  piCodingAgentPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
  piBin = "${piCodingAgentPackage}/bin/pi";

  piPackages = [
    "npm:pi-web-access"
  ];
in {
  home.packages = [
    piCodingAgentPackage

    # require for pi-web-access
    pkgs.ffmpeg
    pkgs.yt-dlp
  ];

  home.activation = {
    piPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${lib.makeBinPath [pkgs.nodejs pkgs.git]}:$PATH"
      ${piBin} install npm:pi-web-access
      ${lib.concatMapStringsSep "\n" (pkg: "${piBin} install ${pkg}") piPackages}
    '';
  };

  sops.secrets.opencode_api_key = {};
  programs.zsh.initContent = ''
    export OPENCODE_API_KEY="$(cat ${config.sops.secrets.opencode_api_key.path})"
    export PI_NOTIFICATIONS=off
  '';

  # prompts
  home.file = {
    ".pi/agent/prompts/plan.md".source = ./agents/prompts/plan.md;
    # skills
    ".agents/skills/nix-shell-run/SKILL.md".source = ./agents/skills/nix-shell-run/SKILL.md;
    # extensions
    ".pi/agent/extensions/questions.ts".source = ./agents/extensions/questions.ts;
  };

  home.file.".pi/agent/settings.json" = {
    force = true;
    text = builtins.toJSON {
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-flash";
      defaultThinkingLevel = "high";
      hideThinkingBlock = true;
      theme = "dark";
      enableAnalytics = false;
      packages = piPackages;
    };
  };

  home.file.".pi/agent/AGENTS.md" = {
    text = builtins.readFile ./agents/AGENTS.md;
  };
}
