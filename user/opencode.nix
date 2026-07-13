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
    settings = {
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
          model = "opencode-go/deepseek-v4-flash";
          variant = "high";
        };
        general = {
          model = "opencode-go/deepseek-v4-flash";
          variant = "high";
        };
        explore = {
          model = "opencode-go/deepseek-v4-flash";
          variant = "high";
        };
        scout = {
          mode = "subagent";
          model = "opencode-go/deepseek-v4-flash";
          hidden = true;
          variant = "high";
        };
      };
    };
  };
  xdg.configFile."opencode/tui.json".force = true;
}
