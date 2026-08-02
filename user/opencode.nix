{
  lib,
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    rtk
  ];
  # https://www.rtk-ai.app/docs/getting-started/supported-agents/#opencode
  home.activation = {
    rtkOpencode = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.rtk}/bin/rtk init --global --opencode
    '';
    cavemanOpencode = lib.hm.dag.entryAfter ["writeBoundary"] ''
      PATH="${lib.makeBinPath [pkgs.nodejs pkgs.git]}:$PATH" ${pkgs.nodejs}/bin/npx -y github:JuliusBrussee/caveman -- --only opencode
    '';
  };

  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    enableMcpIntegration = true;
    web = {
      enable = true;
      extraArgs = [
        "--hostname"
        "0.0.0.0"
        "--port"
        "4096"
        "--mdns"
      ];
    };
    settings = let
      models = {
        thinking = "opencode-go/glm-5.2";
        balance = "opencode-go/kimi-k2.7-code";
        cheap = "opencode-go/mimo-v2.5";
      };
    in {
      plugin = [
        "superpowers@git+https://github.com/obra/superpowers.git"
        "@simonwjackson/opencode-direnv"
        "@tarquinen/opencode-dcp@latest"
        "opencode-mem"
        "@dietrichgebert/ponytail"
      ];
      agent = {
        build = {
          model = models.cheap;
        };
        plan = {
          model = models.balance;
        };
        general = {
          model = models.cheap;
        };
        explore = {
          model = models.cheap;
        };
        scout = {
          model = models.cheap;
        };
      };
    };
  };

  xdg.configFile = {
    "opencode/tui.json".force = true;
    "opencode/opencode.json".force = true;
  };
}
