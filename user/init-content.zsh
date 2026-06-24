nixify() {
  if [ ! -e ./.envrc ]; then
    echo "use nix" > .envrc
    direnv allow
  fi
  if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
    cat > default.nix <<'EOF'
with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    bashInteractive
  ];
}
EOF
''$EDITOR default.nix
  fi
}

flakify() {
  if [ ! -e flake.nix ]; then
    nix flake new -t github:nix-community/nix-direnv .
    direnv allow
  elif [ ! -e .envrc ]; then
    echo "use flake" > .envrc
    direnv allow
  fi
''$EDITOR flake.nix
}

ignore_flakes() {
  if [ ! -e .git]; then
    return
  fi

  if [ ! -e flake.nix]; then
    echo flake.nix > .git/info/exclude
  fi

  if [ ! -e flake.lock]; then
    echo flake.lock > .git/info/exclude
  fi

  if [ ! -e .envrc]; then
    echo .envrc > .git/info/exclude
    echo .direnv > .git/info/exclude
  fi
}
