{pkgs ? import <nixpkgs> {}}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nil
    alejandra
    niv
    statix
    vulnix
    tombi
    nodejs
  ];
}
