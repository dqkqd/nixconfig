/**
 * Force uv — block bare python/pip; installs/tools must go through uv/uvx.
 */

import { type ExtensionAPI, isToolCallEventType } from "@earendil-works/pi-coding-agent";

// Bare python/pip — except uv-run commands. pip install is never allowed, even under uv.
const BLOCKED = /\b(?:python(?:3|3\.\d+|w)?|pip(?:3|3\.\d+)?)\b/;
const PIP_INSTALL = /\bpip(?:3|3\.\d+)?\s+install\b/;
const UV_RUN = /(?:^|(?:&&|\|\||;|\|)\s*)uvx?\b/;

const REASON =
  "Blocked: `python`/`pip` — use `uv` instead.\n" +
  "  uv run python <script>   run a script\n" +
  "  uv run -m <module>       run a module\n" +
  "  uv add <pkg>             add a dependency\n" +
  "  uvx <tool>               run a tool\n" +
  "Reissue the command with `uv`.";

function findBlocked(line: string): string | null {
  const trimmed = line.trim();
  if (!trimmed) return null;
  if (PIP_INSTALL.test(trimmed)) return REASON;
  if (UV_RUN.test(trimmed)) return null;
  if (BLOCKED.test(trimmed)) return REASON;
  return null;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (!isToolCallEventType("bash", event)) return;

    for (const line of String(event.input.command).split("\n")) {
      const reason = findBlocked(line);
      if (reason) {
        return { block: true, reason };
      }
    }
  });
}
