# Agent Instructions

NixOS + Home Manager flake (26.05).

## Layout

- `host/` - system config
- `user/` - Home Manager modules
- `shell.nix` - Dev shell with formatters, linters, and CI tooling.

## Commands

```bash
just fmt             # format everything (alejandra, prettier, …)
just lint            # statix, deadnix, gitleaks, markdownlint-cli2
just check           # fmt-check + lint + nix flake check --no-build --show-trace
just build           # USER-ONLY: system rebuild
just update          # nix flake update
```

## Rules

- Run lint, fmt, check before finishing
- **NEVER** run `just build`, `sudo nixos-rebuild switch`
