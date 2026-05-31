build:
    sudo nixos-rebuild switch --flake .#legend

clean:
    nix-env --delete-generations old
    nix-store --gc
    nix-collect-garbage -d

optimize:
    nix-store --optimise
