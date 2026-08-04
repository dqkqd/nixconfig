---
name: nix-shell-run
description: Use when a command is not found in a Nix repo (shell.nix or flake.nix). Run missing commands via nix-shell or nix develop.
---

# Nix-shell Run

1. Check `command -v <cmd>` — skip if found.
2. If `shell.nix` exists: `nix-shell shell.nix --run "<command>"`
3. Else if `flake.nix` exposes a devShell: `nix develop --command "<command>"`
4. If both fail, report the error normally.
