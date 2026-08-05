#!/usr/bin/env bash
# Caches a remote git repo at ~/.cache/checkouts/<host>/<org>/<repo>.
# Usage: checkout.sh <repo> [--path-only] [--force-update]
set -euo pipefail

cache_root="$HOME/.cache/checkouts"
update_interval=86400
repo=""
path_only=0
force_update=0

# Print help text.
usage() {
  cat <<'EOF'
Usage: checkout.sh <repo> [options]

Caches a remote git repo at ~/.cache/checkouts/<host>/<org>/<repo>.
Accepts owner/repo, host/org/repo, https:// URLs, git@host:..., ssh:// URLs.

Options:
  --path-only                Print only the checkout path
  --force-update             Always fetch and attempt a fast-forward
  --update-interval <secs>   Minimum seconds between updates (default: 1 day)
  -h, --help                 Show this help
EOF
}

# Parse CLI args into repo, path_only, force_update, update_interval. Exits on errors.
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --path-only) path_only=1 ;;
    --force-update) force_update=1 ;;
    --update-interval)
      [[ $# -lt 2 ]] && {
        echo "error: --update-interval expects a value" >&2
        exit 2
      }
      update_interval="$2"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      exit 2
      ;;
    *) [[ -z "$repo" ]] && repo="$1" || {
      echo "error: unexpected argument: $1" >&2
      exit 2
    } ;;
    esac
    shift
  done
  [[ -n "$repo" ]] || {
    usage
    exit 1
  }
}

# Parse the repo reference into host, org, name. Exits on bad format.
parse_repo() {
  local path
  case "$repo" in
  git@*:*)
    host="${repo#git@}"
    host="${host%%:*}"
    path="${repo#*:}"
    ;;
  ssh://*)
    path="${repo#ssh://}"
    host="${path%%/*}"
    host="${host#*@}"
    path="${path#*/}"
    ;;
  http://* | https://*)
    path="${repo#*://}"
    host="${path%%/*}"
    path="${path#*/}"
    ;;
  */*)
    IFS='/' read -r -a parts <<<"$repo"
    if [[ ${#parts[@]} -eq 2 ]]; then
      host="github.com"
      path="$repo"
    else
      host="${parts[0]}"
      path="${repo#*/}"
    fi
    ;;
  *)
    echo "error: unsupported repository format: $repo" >&2
    exit 2
    ;;
  esac
  IFS='/' read -r -a parts <<<"${path%.git}"
  org="${parts[0]}"
  name="${parts[1]}"
  [[ -n "$host" && -n "$org" && -n "$name" ]] || {
    echo "error: cannot parse repository: $repo" >&2
    exit 2
  }
}

# Clone the repo if missing, otherwise reuse the existing checkout.
ensure_checkout() {
  mkdir -p "$cache_root/$host/$org"
  if [[ ! -d "$checkout_path/.git" ]]; then
    git clone --filter=blob:none "$origin_url" "$checkout_path"
    state="cloned"
  else
    state="existing"
  fi
}

# Fetch when stale (or forced), then fast-forward a clean checkout with an upstream.
refresh() {
  local last_fetch_file now last branch upstream dirty
  last_fetch_file="$checkout_path/.git/librarian-last-fetch"
  now="$(date +%s)"
  if [[ -f "$last_fetch_file" && "$force_update" -eq 0 ]]; then
    last="$(cat "$last_fetch_file" 2>/dev/null || echo 0)"
    [[ "$last" =~ ^[0-9]+$ ]] && ((now - last < update_interval)) && return
  fi
  git -C "$checkout_path" fetch --prune --tags origin
  echo "$now" >"$last_fetch_file"
  branch="$(git -C "$checkout_path" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  upstream="$(git -C "$checkout_path" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  dirty="$(git -C "$checkout_path" status --porcelain --untracked-files=no)"
  if [[ -n "$branch" && -n "$upstream" && -z "$dirty" ]]; then
    git -C "$checkout_path" merge --ff-only "$upstream" 2>/dev/null || true
  fi
}

# Orchestrate: parse, checkout, refresh, then report path or summary.
main() {
  parse_args "$@"
  parse_repo
  checkout_path="$cache_root/$host/$org/$name"
  origin_url="https://$host/$org/$name.git"
  ensure_checkout
  refresh
  if ((path_only == 1)); then
    printf '%s\n' "$checkout_path"
  else
    printf 'repo: %s/%s/%s\npath: %s\nstate: %s\n' "$host" "$org" "$name" "$checkout_path" "$state"
  fi
}

main "$@"
