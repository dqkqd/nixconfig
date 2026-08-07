---
name: librarian
description: Cache remote git repos under ~/.cache/checkouts/<host>/<org>/<repo>. Reuse for reading code, inspecting pinned commits/tags, and diffing versions — instead of per-file API calls.
---

# Librarian

Provides a reusable local checkout of remote git repositories (GitHub/GitLab/Bitbucket URLs, `git@...`, or `owner/repo` shorthand).

## When to Use

- A remote git repository (URL, `git@...`, `owner/repo`) is referenced as source material
- Clone the repo and inspect it locally instead of fetching files one by one
- Inspect a file at a pinned commit/tag, or diff the same file across versions — read the checkout locally instead of per-file API calls
- Re-reading the same repo multiple times — reuse the cached checkout

## Cache location

Repositories are stored at `~/.cache/checkouts/<host>/<org>/<repo>`.

Example: `github.com/octocat/Hello-World` → `~/.cache/checkouts/github.com/octocat/Hello-World`

## Usage

```bash
bash checkout.sh <repo> --path-only
```

Examples:

```bash
bash checkout.sh octocat/Hello-World --path-only
bash checkout.sh github.com/octocat/Hello-World --path-only
bash checkout.sh https://github.com/octocat/Hello-World --path-only
```

The script:

1. Parses the repo reference into host/org/repo.
2. Clones if missing (partial clone).
3. Reuses the existing checkout if present.
4. Fetches from `origin` when stale (default: every 1 day).
5. Fast-forwards when the checkout is clean and has an upstream.

## Options

- `--path-only` - Print only the checkout path
- `--force-update` - Always fetch and attempt a fast-forward
- `--update-interval <secs>` - Minimum seconds between updates (default: 1 day)
- `-h` - Show help

## Workflow

1. Resolve the repository path: `bash checkout.sh <repo> --path-only`.
2. Search, read, and analyze using that path.
3. On later references, call `checkout.sh` again — it finds and updates the cached copy.

Prefer not to edit inside the shared cache; copy from the checkout or use a worktree for task-specific changes.

## Notes

- `owner/repo` shorthand defaults to `github.com`.
