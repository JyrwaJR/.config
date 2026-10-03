---
description: Build, refresh, or query the persistent code knowledge graph
agent: build
---

$ARGUMENTS

## Skills

- **graphify** (primary) — owns the full extraction, clustering, labeling, and export pipeline plus its `references/` docs. This command is a **thin dispatcher only**; the skill is the single source of truth for the procedure.

## Dispatch

Resolve the mode from `$ARGUMENTS` before running anything:

| Arguments contain                | Mode    | Action                                                            |
| -------------------------------- | ------- | ----------------------------------------------------------------- |
| `query "<question>"`             | Query   | Graph must exist — run `graphify query`. Skip the build entirely.  |
| `query "<question>" --dfs`      | Query   | Same, depth-first — use to trace one specific chain.                |
| `path "A" "B"`                   | Path    | Shortest path between two symbols or communities.                   |
| `explain "Symbol"`               | Explain | Plain-language explanation of a single node.                         |
| `add <url>`                      | Add     | Fetch the URL into the corpus, then update the graph.               |
| `--update` (plus a path)         | Update  | Incremental — re-extract only new or changed files.                 |
| `--cluster-only`                 | Cluster | Re-run clustering over the existing graph.                          |
| a bare path, a GitHub URL, or nothing | Build | Full pipeline. Default target is `.` — never ask for a path.  |

Export flags (`--wiki`, `--neo4j`, `--falkordb`, `--svg`, `--graphml`, `--mcp`, `--obsidian`, `--no-viz`, `--mode deep`, `--directed`) pass straight through to the skill.

## Process

1. Load the `graphify` skill and follow it exactly.
2. Resolve the mode from the table above.
3. Check for `graphify-out/graph.json` **before** building anything.
4. Run graphify from the project root — or the worktree root when working in a worktree — so node paths match the files being edited.
5. On success, report the output files (`graph.html`, `GRAPH_REPORT.md`, `graph.json`) and paste only the **God Nodes**, **Surprising Connections**, and **Suggested Questions** sections. Never paste the full report.
6. For a query, answer from what the graph returns and cite `source_location` for specific claims.

## Rules

- **Never duplicate the pipeline.** Do not re-implement extraction, clustering, labeling, health checks, or export steps here. Load the skill and follow it.
- **An existing graph wins.** If `graph.json` exists and the request is a question, query it — never rebuild. Rebuilding wastes time and can discard curated community labels.
- **A missing graph is not a dead end.** For `query` / `path` / `explain` with no `graph.json`, build one first (`/graphify .`), then run the query.
- **Never invent an edge.** Mark an uncertain relationship `AMBIGUOUS`. Do not fabricate connectivity to satisfy a question.
- **No API key required.** graphify extracts code structurally (AST) with no key at all; semantic extraction falls back to the host agent. If you are about to prompt for `ANTHROPIC_API_KEY` or any other provider key, that is a misread of the skill — proceed without one.
- **Surface the size guard.** If the corpus exceeds ~500 files or ~2M words, graphify warns and asks which subtree to map. Pick the subtree the task actually touches; a partial map beats no map.
- **Do not commit `graphify-out/`.** It is regenerated output — never hand-edit it.
- **Honest reporting.** If the build reports `ERROR: Graph is empty`, a `GRAPH HEALTH WARNING`, or a refused shrink, surface it verbatim. Do not paper over an integrity problem.
