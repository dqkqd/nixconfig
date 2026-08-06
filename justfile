# List all recipes
default:
    @just --list

fmt:
    treefmt

fmt-check:
    treefmt --ci

lint:
    statix check .
    deadnix .
    gitleaks detect --source . --verbose --redact
    markdownlint-cli2 "**/*.md"
    biome check --error-on-warnings .
    eslint .
    tsc --noEmit
    shellcheck $(git ls-files "*.sh")

check:
    just fmt-check
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
    curl -s "https://addons.mozilla.org/api/v5/addons/addon/{{ name }}/" | jq ".guid"
