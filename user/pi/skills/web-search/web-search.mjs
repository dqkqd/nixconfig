#!/usr/bin/env node
// Web search. Uses the Exa API (EXA_API_KEY) with a zero-config MCP fallback.
// Usage: node web-search.mjs "query" [--num-results N]

/**
 * One search result returned by the API.
 * @typedef {Object} SearchResult
 * @property {string} title - Page title
 * @property {string} url - Page URL
 * @property {string | null} publishedDate - ISO date, or null
 * @property {string | null} author - Author name, or null
 * @property {string[]} highlights - Snippet fragments
 */

/**
 * Parsed command-line arguments.
 * @typedef {Object} ParsedArgs
 * @property {boolean} help - true when -h/--help was given
 * @property {string} query - Search query
 * @property {number} numResults - Result count
 */

/**
 * JSON-RPC response from the MCP endpoint.
 * @typedef {Object} McpResponse
 * @property {{content?: Array<{type?: string, text?: string}>, isError?: boolean}} [result]
 * @property {{message?: string}} [error]
 */

const HELP = `Usage: node web-search.mjs "query" [--num-results N]

Search the web and print a numbered list of relevant results.

Flags:
  -h, --help          Show this help
  --num-results N     Number of results (1-20, default 5)
`;

/**
 * Parse CLI args.
 * @param {string[]} argv
 * @returns {ParsedArgs}
 * @throws {Error} when no query is given
 */
function parseArgs(argv) {
  const DEFAULT_RESULTS = 5;
  const MAX_RESULTS = 20;

  const help = argv.includes("-h") || argv.includes("--help");
  if (help) return { help: true, query: "", numResults: DEFAULT_RESULTS };

  const query = argv.find((a) => !a.startsWith("--"));
  if (!query)
    throw new Error('Missing query. Usage: node web-search.mjs "query" [--num-results N]');

  let numResults = DEFAULT_RESULTS;
  const flagIdx = argv.indexOf("--num-results");
  if (flagIdx >= 0) {
    const n = Number(argv[flagIdx + 1]);
    if (Number.isInteger(n) && n >= 1) {
      numResults = Math.min(n, MAX_RESULTS);
    }
    // missing, non-numeric, or out-of-range values fall back to the default
  }

  return { help: false, query, numResults };
}

/**
 * Search the web via the Exa API, reading the key from EXA_API_KEY.
 * @param {string} query - Search query
 * @param {number} numResults - Number of results to request
 * @returns {Promise<SearchResult[]>}
 * @throws {Error} when EXA_API_KEY is not set, or on HTTP/network errors
 */
async function searchExa(query, numResults) {
  const key = process.env.EXA_API_KEY?.trim();
  if (!key)
    throw new Error("EXA_API_KEY is not set. Get a key at https://dashboard.exa.ai/api-keys");

  const res = await fetch("https://api.exa.ai/search", {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json", "x-api-key": key },
    body: JSON.stringify({
      query,
      numResults,
      type: "auto",
      moderation: true,
      contents: { highlights: true },
    }),
  });
  const data = await res.json();
  if (!res.ok) {
    throw new Error(
      `API error (HTTP ${res.status}): ${data.error ?? data.message ?? res.statusText}`,
    );
  }
  return data.results ?? [];
}

/**
 * Search the web via the Exa MCP endpoint. Zero-config: no API key required.
 * @param {string} query - Search query
 * @param {number} numResults - Number of results to request
 * @returns {Promise<SearchResult[]>}
 * @throws {Error} on MCP or parse errors
 */
async function searchExaMcp(query, numResults) {
  const res = await fetch("https://mcp.exa.ai/mcp?tools=web_search_exa", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json, text/event-stream",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "tools/call",
      params: { name: "web_search_exa", arguments: { query, numResults } },
    }),
  });
  if (!res.ok) {
    throw new Error(`Exa MCP error ${res.status}: ${(await res.text()).slice(0, 300)}`);
  }

  const parsed = parseMcpResponse(await res.text());
  if (!parsed) throw new Error("Exa MCP returned an empty response");
  if (parsed.error) throw new Error(`Exa MCP error: ${parsed.error.message ?? "Unknown error"}`);

  const text = extractMcpText(parsed.result);
  if (parsed.result?.isError) throw new Error(text || "Exa MCP returned an error");
  if (!text) throw new Error("Exa MCP returned empty content");

  const results = parseMcpResults(text);
  if (!results.length) throw new Error("Exa MCP returned empty content");
  return results;
}

/**
 * Parse a JSON-RPC MCP response body (SSE "data:" lines or plain JSON).
 * @param {string} body
 * @returns {McpResponse | null}
 */
function parseMcpResponse(body) {
  for (const line of body.split("\n").filter((l) => l.startsWith("data:"))) {
    const payload = line.slice(5).trim();
    if (!payload) continue;
    try {
      const candidate = JSON.parse(payload);
      if (candidate?.result || candidate?.error) return candidate;
    } catch {
      // not JSON, keep looking
    }
  }
  try {
    const candidate = JSON.parse(body);
    if (candidate?.result || candidate?.error) return candidate;
  } catch {
    // not JSON
  }
  return null;
}

/**
 * Extract the first non-empty text item from an MCP result.
 * @param {{content?: Array<{type?: string, text?: string}>}} [result]
 * @returns {string}
 */
function extractMcpText(result) {
  return (
    result?.content?.find((item) => item.type === "text" && item.text?.trim())?.text?.trim() ?? ""
  );
}

/**
 * Parse Exa MCP search output into results. Handles both raw JSON (advanced
 * tool) and the formatted "Title: ..." text blocks (basic tool).
 * @param {string} text
 * @returns {SearchResult[]}
 */
function parseMcpResults(text) {
  try {
    const jsonResults = JSON.parse(text)?.results;
    if (Array.isArray(jsonResults) && jsonResults.length > 0) {
      return jsonResults.map((r) => ({
        title: r.title ?? "",
        url: r.url,
        publishedDate: r.publishedDate ?? null,
        author: r.author ?? null,
        highlights: Array.isArray(r.highlights) ? r.highlights : [],
      }));
    }
  } catch {
    // not JSON, parse text blocks below
  }

  const results = [];
  for (const block of text.split(/(?=^Title: )/m)) {
    if (!block.trim()) continue;
    const url = block.match(/^URL: (.+)/m)?.[1]?.trim() ?? "";
    if (!url) continue;
    const title = block.match(/^Title: (.+)/m)?.[1]?.trim() ?? "";

    const textStart = block.indexOf("\nText: ");
    let snippet = "";
    if (textStart >= 0) {
      snippet = block.slice(textStart + 7);
    } else {
      const hlMatch = block.match(/\nHighlights:\s*\n/);
      if (hlMatch?.index != null) snippet = block.slice(hlMatch.index + hlMatch[0].length);
    }
    snippet = snippet.replace(/\n---\s*$/, "").trim();

    results.push({
      title,
      url,
      publishedDate: null,
      author: null,
      highlights: snippet ? [snippet] : [],
    });
  }
  return results;
}

/**
 * Format results as numbered output lines.
 * @param {SearchResult[]} results
 * @returns {string}
 */
function formatResults(results) {
  if (!results.length) return "No results found.";

  const blocks = [];
  for (let i = 0; i < results.length; i++) {
    const r = results[i];
    const lines = [`--- Result ${i + 1} ---`];
    lines.push(`Title: ${r.title || r.url}`);
    lines.push(`Link: ${r.url}`);
    if (r.publishedDate) lines.push(`Published: ${r.publishedDate.slice(0, 10)}`);
    if (r.author) lines.push(`Author: ${r.author}`);
    const snippet = r.highlights?.join(" ")?.trim();
    if (snippet) lines.push(`Snippet: ${snippet.slice(0, 600)}`);
    blocks.push(lines.join("\n"));
  }
  return blocks.join("\n\n");
}

/**
 * Entry point. The only place that exits the process.
 */
async function main() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      console.log(HELP);
      return;
    }

    let results;
    try {
      results = await searchExa(args.query, args.numResults);
    } catch {
      // fall back to the zero-config MCP endpoint when the API path fails
      results = await searchExaMcp(args.query, args.numResults);
    }
    console.log(formatResults(results));
  } catch (err) {
    console.error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}

main();
