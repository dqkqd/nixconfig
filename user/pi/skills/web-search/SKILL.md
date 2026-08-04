---
name: web-search
description: Web search for finding current information, documentation, or facts online.
---

# Web Search

Web search with a single dependency-free script. Uses the Exa API when `EXA_API_KEY` is set, otherwise falls back to a zero-config endpoint.

## Setup

No API key required — the fallback works out of the box. For unthrottled search, add an optional key to your shell profile (`~/.profile` or `~/.zprofile` for zsh):

```bash
export EXA_API_KEY="your-api-key-here"
```

## Search

```bash
node web-search.mjs "query"                   # Basic search (5 results)
node web-search.mjs "query" --num-results 10  # More results (max 20)
node web-search.mjs --help                    # Show help
```

### Options

- `--num-results <num>` - Number of results (default: 5, max: 20)
- `-h` - Show help

## Output Format

```text
--- Result 1 ---
Title: Home Manager - Official NixOS Wiki
Link: https://wiki.nixos.org/wiki/Home_Manager
Published: 2026-08-01
Author: NixOS Wiki contributors
Snippet: Home Manager is a system for managing a user environment...

--- Result 2 ---
...
```

## When to Use

- Searching for documentation or API references
- Looking up facts or current information
- Any task requiring web search
