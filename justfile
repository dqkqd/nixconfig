# List all recipes
default:
    @just --list

# Format all files with one command
fmt:
    treefmt

# Check formatting without writing files
fmt-check:
    treefmt --fail-on-change --no-cache

# Run all linters
lint:
    statix check .
    deadnix .
    biome lint .
    actionlint -color
    gitleaks detect --source . --verbose --redact

# Run all local checks (format check + lint + flake eval)
check:
    treefmt --fail-on-change --no-cache
    just lint
    nix flake check --no-build --show-trace

build:
    sudo nixos-rebuild switch --flake .#legend

update:
    nix flake update

clean:
    nix-env --delete-generations old
    nix-store --gc
    nix-collect-garbage -d

optimize:
    nix-store --optimise

firefox-ext-guid name:
  curl -s "https://addons.mozilla.org/api/v5/addons/addon/{{name}}/" | jq ".guid"
