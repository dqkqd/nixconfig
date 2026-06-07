{pkgs ? import <nixpkgs> {}}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    # toml
    tombi

    # css
    vscode-langservers-extracted
    prettierd

    jq
  ];
}
