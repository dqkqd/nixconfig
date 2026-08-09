---
name: git-commit
description: Write conventional-commits messages. Use when asked to commit changes.
---

# Git commit

Conventional style: `type(scope): subject`.

## Rules

- Check recent commits first (`git log --oneline -15` or `jj log`) and match their type/scope/tone.
- Type: feat, fix, docs, chore, refactor.
- Scope: repo area the change touches; inventing one is fine, ask the user first.
- Subject: imperative, lowercase, <70 chars, no trailing period.
- Body only if the change isn't obvious — what and why, wrapped at 72.

## Commit

```bash
git commit -m "feat(user): add widget"                  # no body
git commit -m "feat(user): add widget" -m "why"         # with body
jj describe -m "feat(user): add widget"                 # jj
jj describe -m "feat(user): add widget" -m "why"        # jj
```
