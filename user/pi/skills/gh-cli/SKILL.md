---
name: gh-cli
description: GitHub CLI (gh) for interacting with GitHub — read PR reviews/comments and issues/comments, plus gh api for anything GitHub.
---

# GitHub CLI (gh-cli)

Authenticated `gh` CLI. **Read-only** — fetches PR reviews/comments and issue threads; never creates or edits.

## When to Use

- Reading open pull requests, their reviews, and review comments
- Viewing issue details and comment threads
- Any GitHub read (state, comments, metadata) via `gh api`

## Pull requests

```bash
gh pr list --state open --json number,title,author,reviewDecision
gh pr view <n> --json title,body,state,mergedAt
gh pr view <n> --comments              # issue (& review) comments as markdown
gh pr view <n> --json reviews          # review summaries (APPROVED / CHANGES_REQUESTED)
```

Inline/line review comments come from the API:

```bash
gh api /repos/{owner}/{repo}/pulls/12/comments --jq '.[] | {url, path, line, author: .user.login}'
gh api "/repos/{owner}/{repo}/pulls/12/reviews" --jq '.[] | {author: .user.login, state}'
```

## Issues

```bash
gh issue list --state open --json number,title,labels
gh issue view <n> --json title,body,state,labels
gh issue view <n> --comments           # issue + comment thread
gh api /repos/{owner}/{repo}/issues/12/comments --jq '.[] | {author: .user.login, body}'
```

## Conventions

- Target another repo with `-R owner/repo`.
- Prefer `--json` + `--jq` for structured output.
- Add `?per_page=100` and `--paginate` to page through API results.
