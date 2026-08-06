/**
 * Questions Tool - Ask the user one or more questions.
 *
 * - Multiple questions: Tab / ←→ cycles between questions, Enter confirms, Esc cancels
 * - Options lists with a "Type something" free-text option
 * - Drafts are persisted via pi.appendEntry() so answers survive a pi restart:
 *   on session_start a pending unanswered draft is re-opened automatically.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  Text,
  visibleWidth,
  wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface QuestionOption {
  value: string;
  label: string;
  description?: string;
}

type RenderOption = QuestionOption & { isOther?: boolean };

interface Question {
  id: string;
  label: string;
  prompt: string;
  options: QuestionOption[];
  allowOther: boolean;
}

interface Answer {
  id: string;
  value: string;
  label: string;
  wasCustom: boolean;
  index?: number;
}

interface QuestionnaireResult {
  questions: Question[];
  answers: Answer[];
  cancelled: boolean;
}

interface QADraft {
  questions: Question[];
  answers: Answer[];
  updatedAt: number;
}

const QuestionOptionSchema = Type.Object({
  value: Type.String({ description: "The value returned when selected" }),
  label: Type.String({ description: "Display label for the option" }),
  description: Type.Optional(
    Type.String({ description: "Optional description shown below label" }),
  ),
});

const QuestionSchema = Type.Object({
  id: Type.String({ description: "Unique identifier for this question" }),
  label: Type.Optional(
    Type.String({
      description:
        "Short contextual label for tab bar, e.g. 'Scope', 'Priority' (defaults to Q1, Q2)",
    }),
  ),
  prompt: Type.String({ description: "The full question text to display" }),
  options: Type.Array(QuestionOptionSchema, { description: "Available options to choose from" }),
  allowOther: Type.Optional(
    Type.Boolean({ description: "Allow 'Type something' option (default: true)" }),
  ),
});

const QuestionsParams = Type.Object({
  questions: Type.Array(QuestionSchema, { description: "Questions to ask the user" }),
});

function errorResult(
  message: string,
  questions: Question[] = [],
): { content: { type: "text"; text: string }[]; details: QuestionnaireResult } {
  return {
    content: [{ type: "text", text: message }],
    details: { questions, answers: [], cancelled: true },
  };
}

function runQuestionnaire(
  ctx: Parameters<Parameters<ExtensionAPI["registerTool"]>[0]["execute"]>[4],
  questions: Question[],
  initialAnswers: Answer[] = [],
): Promise<QuestionnaireResult | null> {
  return ctx.ui.custom<QuestionnaireResult>((tui, theme, _kb, done) => {
    const isMulti = questions.length > 1;
    const totalTabs = questions.length + 1; // questions + Submit

    let currentTab = 0;
    let optionIndex = 0;
    let inputMode = false;
    let inputQuestionId: string | null = null;
    let cachedLines: string[] | undefined;
    const answers = new Map<string, Answer>(initialAnswers.map((a) => [a.id, a]));

    const editorTheme: EditorTheme = {
      borderColor: (s) => theme.fg("accent", s),
      selectList: {
        selectedPrefix: (t) => theme.fg("accent", t),
        selectedText: (t) => theme.fg("accent", t),
        description: (t) => theme.fg("muted", t),
        scrollInfo: (t) => theme.fg("dim", t),
        noMatch: (t) => theme.fg("warning", t),
      },
    };
    const editor = new Editor(tui, editorTheme);

    // Start on the first unanswered question when restoring a draft
    if (initialAnswers.length > 0) {
      const firstUnanswered = questions.findIndex((q) => !answers.has(q.id));
      if (firstUnanswered >= 0) currentTab = firstUnanswered;
    }

    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    function submit(cancelled: boolean) {
      done({ questions, answers: Array.from(answers.values()), cancelled });
    }

    function currentQuestion(): Question | undefined {
      return questions[currentTab];
    }

    function currentOptions(): RenderOption[] {
      const q = currentQuestion();
      if (!q) return [];
      const opts: RenderOption[] = [...q.options];
      if (q.allowOther) {
        opts.push({ value: "__other__", label: "Type something.", isOther: true });
      }
      return opts;
    }

    function allAnswered(): boolean {
      return questions.every((q) => answers.has(q.id));
    }

    function advanceAfterAnswer() {
      if (!isMulti) {
        submit(false);
        return;
      }
      if (currentTab < questions.length - 1) {
        currentTab++;
      } else {
        currentTab = questions.length; // Submit tab
      }
      optionIndex = 0;
      refresh();
    }

    function saveAnswer(
      questionId: string,
      value: string,
      label: string,
      wasCustom: boolean,
      index?: number,
    ) {
      answers.set(questionId, { id: questionId, value, label, wasCustom, index });
    }

    editor.onSubmit = (value) => {
      if (!inputQuestionId) return;
      const trimmed = value.trim() || "(no response)";
      saveAnswer(inputQuestionId, trimmed, trimmed, true);
      inputMode = false;
      inputQuestionId = null;
      editor.setText("");
      advanceAfterAnswer();
    };

    function handleInput(data: string) {
      if (inputMode) {
        if (matchesKey(data, Key.escape)) {
          inputMode = false;
          inputQuestionId = null;
          editor.setText("");
          refresh();
          return;
        }
        editor.handleInput(data);
        refresh();
        return;
      }

      const q = currentQuestion();
      const opts = currentOptions();

      if (isMulti) {
        if (matchesKey(data, Key.tab) || matchesKey(data, Key.right)) {
          currentTab = (currentTab + 1) % totalTabs;
          optionIndex = 0;
          refresh();
          return;
        }
        if (matchesKey(data, Key.shift("tab")) || matchesKey(data, Key.left)) {
          currentTab = (currentTab - 1 + totalTabs) % totalTabs;
          optionIndex = 0;
          refresh();
          return;
        }
      }

      if (currentTab === questions.length) {
        if (matchesKey(data, Key.enter) && allAnswered()) {
          submit(false);
        } else if (matchesKey(data, Key.escape)) {
          submit(true);
        }
        return;
      }

      if (matchesKey(data, Key.up)) {
        optionIndex = Math.max(0, optionIndex - 1);
        refresh();
        return;
      }
      if (matchesKey(data, Key.down)) {
        optionIndex = Math.min(opts.length - 1, optionIndex + 1);
        refresh();
        return;
      }

      if (matchesKey(data, Key.enter) && q) {
        const opt = opts[optionIndex];
        if (opt.isOther) {
          inputMode = true;
          inputQuestionId = q.id;
          editor.setText("");
          refresh();
          return;
        }
        saveAnswer(q.id, opt.value, opt.label, false, optionIndex + 1);
        advanceAfterAnswer();
        return;
      }

      if (matchesKey(data, Key.escape)) {
        submit(true);
      }
    }

    function render(width: number): string[] {
      if (cachedLines) return cachedLines;

      const lines: string[] = [];
      const renderWidth = Math.max(1, width);
      const q = currentQuestion();
      const opts = currentOptions();

      function addWrapped(text: string) {
        lines.push(...wrapTextWithAnsi(text, renderWidth));
      }

      function addWrappedWithPrefix(prefix: string, text: string) {
        const prefixWidth = visibleWidth(prefix);
        if (prefixWidth >= renderWidth) {
          addWrapped(prefix + text);
          return;
        }
        const wrapped = wrapTextWithAnsi(text, renderWidth - prefixWidth);
        const continuationPrefix = " ".repeat(prefixWidth);
        for (let i = 0; i < wrapped.length; i++) {
          lines.push(`${i === 0 ? prefix : continuationPrefix}${wrapped[i]}`);
        }
      }

      lines.push(theme.fg("accent", "─".repeat(renderWidth)));

      if (isMulti) {
        const tabs: string[] = ["← "];
        for (let i = 0; i < questions.length; i++) {
          const isActive = i === currentTab;
          const isAnswered = answers.has(questions[i].id);
          const lbl = questions[i].label;
          const box = isAnswered ? "■" : "□";
          const color = isAnswered ? "success" : "muted";
          const text = ` ${box} ${lbl} `;
          const styled = isActive
            ? theme.bg("selectedBg", theme.fg("text", text))
            : theme.fg(color, text);
          tabs.push(`${styled} `);
        }
        const canSubmit = allAnswered();
        const isSubmitTab = currentTab === questions.length;
        const submitText = " ✓ Submit ";
        const submitStyled = isSubmitTab
          ? theme.bg("selectedBg", theme.fg("text", submitText))
          : theme.fg(canSubmit ? "success" : "dim", submitText);
        tabs.push(`${submitStyled} →`);
        addWrappedWithPrefix(" ", tabs.join(""));
        lines.push("");
      }

      function renderOptions() {
        for (let i = 0; i < opts.length; i++) {
          const opt = opts[i];
          const selected = i === optionIndex;
          const isOther = opt.isOther === true;
          const prefix = selected ? theme.fg("accent", "> ") : "  ";
          const label = `${i + 1}. ${opt.label}${isOther && inputMode ? " ✎" : ""}`;
          const color = selected || (isOther && inputMode) ? "accent" : "text";

          addWrappedWithPrefix(prefix, theme.fg(color, label));
          if (opt.description) {
            addWrappedWithPrefix("     ", theme.fg("muted", opt.description));
          }
        }
      }

      if (inputMode && q) {
        addWrappedWithPrefix(" ", theme.fg("text", q.prompt));
        lines.push("");
        renderOptions();
        lines.push("");
        addWrappedWithPrefix(" ", theme.fg("muted", "Your answer:"));
        for (const line of editor.render(Math.max(1, renderWidth - 2))) {
          lines.push(` ${line}`);
        }
        lines.push("");
        addWrappedWithPrefix(" ", theme.fg("dim", "Enter to submit • Esc to cancel"));
      } else if (currentTab === questions.length) {
        addWrappedWithPrefix(" ", theme.fg("accent", theme.bold("Ready to submit")));
        lines.push("");
        for (const question of questions) {
          const answer = answers.get(question.id);
          if (answer) {
            const prefix = answer.wasCustom ? "(wrote) " : "";
            const summary = `${theme.fg("muted", `${question.label}: `)}${theme.fg("text", prefix + answer.label)}`;
            addWrappedWithPrefix(" ", summary);
          }
        }
        lines.push("");
        if (allAnswered()) {
          addWrappedWithPrefix(" ", theme.fg("success", "Press Enter to submit"));
        } else {
          const missing = questions
            .filter((q) => !answers.has(q.id))
            .map((q) => q.label)
            .join(", ");
          addWrappedWithPrefix(" ", theme.fg("warning", `Unanswered: ${missing}`));
        }
      } else if (q) {
        addWrappedWithPrefix(" ", theme.fg("text", q.prompt));
        lines.push("");
        renderOptions();
      }

      lines.push("");
      if (!inputMode) {
        const help = isMulti
          ? "Tab/←→ navigate • ↑↓ select • Enter confirm • Esc cancel"
          : "↑↓ navigate • Enter select • Esc cancel";
        addWrappedWithPrefix(" ", theme.fg("dim", help));
      }
      lines.push(theme.fg("accent", "─".repeat(renderWidth)));

      cachedLines = lines;
      return lines;
    }

    return {
      render,
      invalidate: () => {
        cachedLines = undefined;
      },
      handleInput,
    };
  });
}

export default function questionsExtension(pi: ExtensionAPI) {
  // Restore a pending draft if pi was closed mid-questionnaire.
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    let pending: QADraft | null = null;
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type !== "custom") continue;
      if (entry.customType === "qa-draft") pending = entry.data as QADraft;
      else if (entry.customType === "qa-answered") pending = null;
      else if (entry.customType === "qa-dismissed") pending = null;
    }
    if (!pending) return;

    const unanswered = pending.questions.some((q) => !pending?.answers.some((a) => a.id === q.id));
    if (!unanswered) return;

    // Re-open the questionnaire with the draft's questions and partial answers.
    const result = await runQuestionnaire(ctx, pending.questions, pending.answers);
    if (!result || result.cancelled) {
      // Remember the user aborted, so it doesn't re-open on every reload.
      pi.appendEntry("qa-dismissed", {
        questions: pending.questions,
        updatedAt: Date.now(),
      });
      return;
    }

    pi.appendEntry("qa-answered", {
      questions: result.questions,
      answers: result.answers,
      updatedAt: Date.now(),
    });

    const lines = result.answers.map((a) => {
      const qLabel = result.questions.find((q) => q.id === a.id)?.label || a.id;
      return `${qLabel}: ${a.wasCustom ? a.label : a.label}`;
    });
    pi.sendMessage(
      {
        customType: "qa-answers",
        content: `User answered the pending questions:\n${lines.join("\n")}`,
        display: true,
      },
      { triggerTurn: true },
    );
  });

  pi.registerTool({
    name: "questions",
    label: "Questions",
    description:
      "Ask the user one or more questions. Use when you need clarification, a decision, preferences, or information only the user knows. For multiple questions, shows a tab-based interface (Tab cycles through questions).",
    promptSnippet: "Ask the user for missing information or decisions",
    promptGuidelines: [
      "Use questions when information is missing, ambiguous, or only the user can decide.",
      "Do not guess user preferences, credentials, or approval — use questions instead.",
    ],
    parameters: QuestionsParams,
    executionMode: "sequential",

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (ctx.mode !== "tui") {
        return errorResult("Error: UI not available (running in non-interactive mode)");
      }
      if (params.questions.length === 0) {
        return errorResult("Error: No questions provided");
      }

      const questions: Question[] = params.questions.map((q, i) => ({
        ...q,
        label: q.label || `Q${i + 1}`,
        allowOther: q.allowOther !== false,
      }));

      // Persist the draft immediately so it survives a mid-way pi close.
      pi.appendEntry("qa-draft", {
        questions,
        answers: [],
        updatedAt: Date.now(),
      } satisfies QADraft);

      const result = await runQuestionnaire(ctx, questions);
      if (!result || result.cancelled) {
        // Remember the user aborted, so it doesn't re-open on every reload.
        pi.appendEntry("qa-dismissed", {
          questions,
          updatedAt: Date.now(),
        });
        return {
          content: [{ type: "text", text: "User cancelled the questions" }],
          details: { questions, answers: [], cancelled: true },
        };
      }

      pi.appendEntry("qa-answered", {
        questions: result.questions,
        answers: result.answers,
        updatedAt: Date.now(),
      });

      const answerLines = result.answers.map((a) => {
        const qLabel = questions.find((q) => q.id === a.id)?.label || a.id;
        if (a.wasCustom) {
          return `${qLabel}: user wrote: ${a.label}`;
        }
        return `${qLabel}: user selected: ${a.index}. ${a.label}`;
      });

      return {
        content: [{ type: "text", text: answerLines.join("\n") }],
        details: result,
      };
    },

    renderCall(args, theme) {
      const qs = (args.questions as Question[]) || [];
      const count = qs.length;
      const labels = qs.map((q) => q.label || q.id).join(", ");
      let text = theme.fg("toolTitle", theme.bold("questions "));
      text += theme.fg("muted", `${count} question${count !== 1 ? "s" : ""}`);
      if (labels) {
        text += theme.fg("dim", ` (${labels})`);
      }
      return new Text(text, 0, 0);
    },

    renderResult(result, _options, theme) {
      const details = result.details as QuestionnaireResult | undefined;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "", 0, 0);
      }
      if (details.cancelled) {
        return new Text(theme.fg("warning", "Cancelled"), 0, 0);
      }
      const lines = details.answers.map((a) => {
        const qLabel = details.questions.find((q) => q.id === a.id)?.label || a.id;
        if (a.wasCustom) {
          return `${theme.fg("success", "✓ ")}${theme.fg("accent", qLabel)}: ${theme.fg("muted", "(wrote) ")}${a.label}`;
        }
        const display = a.index ? `${a.index}. ${a.label}` : a.label;
        return `${theme.fg("success", "✓ ")}${theme.fg("accent", qLabel)}: ${display}`;
      });
      return new Text(lines.join("\n"), 0, 0);
    },
  });
}
