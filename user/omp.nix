{
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  config,
  ...
}: let
  ompPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
  ompBin = "${ompPackage}/bin/omp";
in {
  home.packages = [
    pkgsUnstable.rtk
    ompPackage
  ];

  home.activation = {
    ompPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgsUnstable.rtk}/bin/rtk init --agent pi --global
      export PATH="${lib.makeBinPath [pkgs.bun pkgs.git]}:$PATH"

      add_plugin() {
        local repo="''$1" plugin="''$2" marketplace="''$3"

        ${ompBin} plugin marketplace list | grep -q "''$repo" \
          || ${ompBin} plugin marketplace add "''$repo"

        ${ompBin} plugin list | grep -q "''$plugin" \
          || ${ompBin} plugin install "''${plugin}@''${marketplace}"
      }

      add_plugin "JuliusBrussee/caveman" "caveman" "caveman"
      add_plugin "DietrichGebert/ponytail" "ponytail" "ponytail"
      add_plugin "obra/superpowers-marketplace" "superpowers" "superpowers-marketplace"
    '';
  };

  sops.secrets.opencode_api_key = {};
  programs.zsh.initContent = ''
    eval "$(omp completions zsh)"
    export OPENCODE_API_KEY="$(cat ${config.sops.secrets.opencode_api_key.path})"
    export PI_NOTIFICATIONS=off
  '';

  home.file.".omp/agent/config.yml" = {
    force = true;
    text = ''
      modelRoles:
        default: opencode-go/deepseek-v4-flash
        advisor: opencode-go/deepseek-v4-flash
      symbolPreset: nerd
      theme:
        dark: catppuccin-macchiato
        light: catppuccin-latte
      setupVersion: 1
      task:
        agentModelOverrides: {}
      hideThinkingBlock: true
      memory:
        backend: mnemopi
      secrets:
        enabled: true
      advisor:
        enabled: true
    '';
  };

  home.file.".omp/agent/AGENTS.md".source = ./agents/use-ponytail-and-caveman.md;
}
