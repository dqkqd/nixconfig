{pkgsUnstable, ...}: {
  programs.opencode = {
    enable = true;
    package = pkgsUnstable.opencode;
    enableMcpIntegration = true;
    settings = {
      plugin = ["superpowers@git+https://github.com/obra/superpowers.git"];
    };
  };
  xdg.configFile."opencode/tui.json".force = true;
}
