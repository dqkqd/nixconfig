{
  lib,
  pkgsUnstable,
  ...
}: {
  home.packages = [
    pkgsUnstable.codegraph
  ];

  programs.mcp = {
    enable = true;
    servers = {
      context7 = {
        enabled = true;
        url = "https://mcp.context7.com/mcp";
      };
      websearch = {
        enabled = true;
        url = "https://mcp.exa.ai/mcp?tools=web_search_exa";
      };
      grep_app = {
        enabled = true;
        url = "https://mcp.grep.app";
      };
      codegraph = {
        enabled = true;
        command = "${lib.getExe pkgsUnstable.codegraph}";
        args = ["serve" "--mcp"];
      };
      playwright = {
        enabled = true;
        command = "${pkgsUnstable.playwright-mcp}/bin/playwright-mcp";
        args = ["--headless"];
      };
    };
  };
}
