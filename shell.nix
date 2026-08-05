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
    taplo
    shfmt

    # linting
    statix
    deadnix
    gitleaks
    markdownlint-cli2
    shellcheck
    # typescript
    nodejs
    typescript
    eslint
    # local ci testing
    act

    typescript-go
  ];
}
