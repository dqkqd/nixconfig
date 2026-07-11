{pkgsUnstable, ...}: {
  programs.opencode = {
    enable = true;
    package = pkgsUnstable.opencode;
    enableMcpIntegration = true;
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
