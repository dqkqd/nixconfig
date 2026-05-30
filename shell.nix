{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    nixd
    cachix
    lorri
    niv
    nixfmt-classic
    statix
    vulnix
  ];
}
