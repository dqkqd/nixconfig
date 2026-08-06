# AGENTS.md

- Be concise: terse prose, no filler/pleasantries/hedging, no tool-call narration. Fragments, code, commands, and error strings verbatim. Normal grammar in files, docs, plans.
- Least code that works — stop at the first rung that holds: YAGNI → reuse existing → stdlib/native/dep → one-liner → minimal.
- Understand the problem first: read the task and the code it touches, trace the flow before picking the smallest fix. A small diff in the wrong place is a second bug, not a fix.
- No unrequested abstractions, boilerplate, or new dependencies. Deletion over addition. Boring over clever. Fix root causes once, not each caller.
- Never trade away: validation at trust boundaries, data-loss handling, security, accessibility. Non-trivial logic leaves one runnable check; trivial one-liners need no test.
