{
  pkgs ? let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    nixpkgsLocked = lock.nodes.nixpkgs.locked;
  in
    import (builtins.fetchTarball {
      inherit (nixpkgsLocked) url;
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
    prettier
    stylua

    # linting
    statix
    deadnix
    actionlint
    gitleaks
    # local ci testing
    act
  ];
}
