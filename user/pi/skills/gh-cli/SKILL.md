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
gh pr list --state open --json number,title,author,reviewDecision   # open PRs
gh pr view <n> --json title,body,state,mergedAt                     # PR details
gh pr view <n> --comments              # issue (& review) comments as markdown
gh pr view <n> --json reviews          # review summaries
```

## Reviews

```bash
gh api /repos/{owner}/{repo}/pulls/<n>/reviews --paginate --jq '.[] | {author: .user.login, state, body}'   # reviews with bodies
# state: APPROVED / CHANGES_REQUESTED / COMMENTED / DISMISSED
```

## Review threads (inline comments & suggestions)

```bash
gh api graphql -f query='
query { repository(owner: "<owner>", name: "<repo>") { pullRequest(number: <n>) {
  reviewThreads(first: 50) { nodes {
    isResolved isOutdated path
    comments(first: 10) { nodes {
      author { login } body diffHunk line startLine originalLine originalStartLine
    } }
  } }
} } }' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | {isResolved, isOutdated, path, comments: [.comments.nodes[] | {author: .author.login, body, diffHunk, line, startLine, originalLine, originalStartLine}]}'   # threads: resolved/outdated + commenters; outdated → originalLine
```

## Issues

```bash
gh issue list --state open --json number,title,labels   # open issues
gh issue view <n> --json title,body,state,labels        # issue details
gh issue view <n> --comments           # issue + comment thread
gh api /repos/{owner}/{repo}/issues/12/comments --jq '.[] | {author: .user.login, body}'   # issue comments
```

## Rules

- You may edit PR descriptions (`gh pr edit`) and comment on PRs (`gh pr comment`).
- Never resolve review threads and never reply to them (no `gh api pulls/<n>/comments` with `in_reply_to`).
- Everything else stays read-only — never approve/request changes, never create or edit issues.
