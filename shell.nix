{
  pkgs ? let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    nixpkgsLocked = lock.nodes.nixpkgs.locked;
  in
    import (builtins.fetchTarball {
      url = nixpkgsLocked.url;
      sha256 = nixpkgsLocked.narHash;
    }) {},
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    # existing
    tombi
    vscode-langservers-extracted
    prettierd
    jq

    # formatting
    alejandra
    treefmt
    biome
    mdformat
    stylua

    # linting
    statix
    deadnix
    actionlint
    gitleaks
    shellcheck
    shfmt

    # local ci testing
    act
  ];
}
