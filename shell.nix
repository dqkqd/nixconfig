{pkgs ? import <nixpkgs> {}}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nil
    alejandra
    cachix
    niv
    statix
    vulnix
    tombi
  ];
}
