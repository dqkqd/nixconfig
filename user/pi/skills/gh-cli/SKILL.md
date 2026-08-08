---
name: gh-cli
description: GitHub CLI (gh) — read PR reviews/threads and issues, edit and comment PRs.
---

# GitHub CLI (gh-cli)

Authenticated `gh` CLI. Reads PR reviews/comments and issue threads; may edit PRs and comment on them. Never resolves review threads or replies to them.

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

## Reviews

```bash
gh api /repos/{owner}/{repo}/pulls/<n>/reviews --paginate --jq '.[] | {author: .user.login, state, body}'
# state: APPROVED / CHANGES_REQUESTED / COMMENTED / DISMISSED
```

## Review threads (inline comments & suggestions)

Thread start has `in_reply_to_id: null`; replies carry the parent comment id. Bodies may contain `suggestion` blocks.

```bash
gh api /repos/{owner}/{repo}/pulls/<n>/comments --paginate --jq '.[] | {id, path, line, in_reply_to_id, author: .user.login, body}'
```

Resolved/outdated state — GraphQL (REST `resolved` field is unreliable):

```bash
gh api graphql -f query='
query { repository(owner: "<owner>", name: "<repo>") { pullRequest(number: <n>) {
  reviewThreads(first: 50) { nodes {
    isResolved isOutdated path line
    comments(first: 10) { nodes { author { login } body } }
  } }
} } }'
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

## Rules

- You may edit PR descriptions (`gh pr edit`) and comment on PRs (`gh pr comment`).
- Never resolve review threads and never reply to them (no `gh api pulls/<n>/comments` with `in_reply_to`).
- Everything else stays read-only — never approve/request changes, never create or edit issues.
