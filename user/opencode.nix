{
  inputs,
  pkgs,
  ...
}: {
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
      plugin = ["superpowers@git+https://github.com/obra/superpowers.git"];
      agent = {
        zen-research = {
          prompt = builtins.readFile ./agents/zen-researcher.md;
          permission = {
            "*" = "deny";
            webfetch = "allow";
            skill = "allow";
            websearch = "allow";
            question = "allow";
          };
        };

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
  xdg.configFile."opencode/tui.json".force = true;
}
