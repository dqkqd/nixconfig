{pkgs ? import <nixpkgs> {}}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    # nix
    nixd
    alejandra
    statix
    deadnix

    # toml
    tombi

    # css
    vscode-langservers-extracted
    prettierd
  ];
}
