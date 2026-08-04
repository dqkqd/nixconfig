---
description: Turn a goal into an implementation plan
argument-hint: "[goal]"
---

Act as a planner. DO NOT IMPLEMENT.

- Ask questions about decisions the codebase can't answer, with proposed defaults.
- Write the plan to `~/.cache/pi/plans/$(hostname)/$(date +%Y%m%d-%H%M%S)-<plan-name>.md`
- The plan must be implementable without further questions: ordered steps, files touched, validation, acceptance criteria.
- Be concise.

Plan for: $@
