/**
 * Plan tools:
 * - /plan <goal> — plan generation (prompt copied from prompts/plan.md)
 * - /plan-review [path] — open the plan file for in-place editing (Ctrl+G opens
 *   the external editor, :wq returns, Enter submits). Runs diff -U5 against the
 *   base and sends the agent the raw diff so it can apply the changes and
 *   address the user's review feedback.
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const EDITOR_TITLE = "Plan review";

const PLAN_PROMPT = `Act as a planner. DO NOT IMPLEMENT.

- Ask questions about decisions the codebase can't answer, with proposed defaults.
- The plan must be implementable without further questions: ordered steps, files touched, validation, acceptance criteria.
- Be concise.`;

function plansDir(cwd: string): string {
  return path.join(os.homedir(), ".cache", "pi", "plans", path.basename(cwd));
}

function latestPlanFile(cwd: string): string | null {
  const dir = plansDir(cwd);
  if (!fs.existsSync(dir)) return null;
  const files = fs
    .readdirSync(dir)
    .filter((f) => f.endsWith(".md"))
    .sort();
  const latest = files.at(-1);
  return latest !== undefined ? path.join(dir, latest) : null;
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("plan", {
    description: "Turn a goal into an implementation plan",
    handler: async (args, ctx) => {
      const goal = args.trim();
      if (!goal) {
        ctx.ui.notify("Usage: /plan <goal>", "error");
        return;
      }
      pi.sendUserMessage(
        `${PLAN_PROMPT}\n\nWrite the plan to ${plansDir(ctx.cwd)}/$(date +%Y%m%d-%H%M%S)-<plan-name>.md\n\nPlan for: ${goal}`,
      );
    },
  });

  pi.registerCommand("plan-review", {
    description: "Open the plan file for editing; diff sent to agent",
    handler: async (args, ctx) => {
      if (!ctx.hasUI) return;

      const file = args.trim() || latestPlanFile(ctx.cwd);
      if (!file || !fs.existsSync(file)) {
        ctx.ui.notify("No plan file found. Run /plan <goal> first.", "error");
        return;
      }

      const original = fs.readFileSync(file, "utf8");
      const edited = await ctx.ui.editor(EDITOR_TITLE, original);
      if (edited === undefined) {
        ctx.ui.notify("Review cancelled — plan untouched.", "info");
        return;
      }
      if (edited === original) {
        ctx.ui.notify("No changes to the plan.", "info");
        return;
      }
      fs.writeFileSync(file, edited);

      const baseFile = path.join(os.tmpdir(), `plan-review-base-${Date.now()}.md`);
      fs.writeFileSync(baseFile, original);
      const diff = await pi.exec("diff", [
        "-U5",
        "--label",
        "base",
        "--label",
        "edited",
        baseFile,
        file,
      ]);
      fs.rmSync(baseFile, { force: true });

      ctx.ui.notify("Plan updated — agent will handle the review items.", "info");
      pi.sendUserMessage(`User reviewed and edited the plan: ${file}

In the diff, lines starting with "-" are OLD (base plan), lines starting with "+" are NEW (the user's edits).

Example (illustration only, not the actual diff):
old: "- 3. Deploy to prod"
new: "+ 3. Deploy to staging first"

Actual diff:
<diff>
${diff.stdout}
</diff>

Apply the user's changes and address their review feedback.`);
    },
  });
}
