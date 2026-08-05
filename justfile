# List all recipes
default:
    @just --list

# Bash files, respecting gitignore
BASH_FILES := shell("git ls-files -co --exclude-standard '*.sh'")

# Format all files with one command
fmt:
    treefmt --no-cache
    biome format --write .
    shfmt -w {{BASH_FILES}}

# Check formatting without writing files
fmt-check:
    treefmt --fail-on-change --no-cache
    biome format .
    shfmt -d {{BASH_FILES}}

# Run all linters
lint:
    statix check .
    deadnix .
    gitleaks detect --source . --verbose --redact
    markdownlint-cli2 "**/*.md"
    biome check --error-on-warnings .
    eslint .
    tsc --noEmit
    shellcheck -S warning {{BASH_FILES}}

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
    curl -s "https://addons.mozilla.org/api/v5/addons/addon/{{ name }}/" | jq ".guid"
