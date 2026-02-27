---
title: bus-ledger — local daybook and ledger browser UI
description: Local BusDK UI for browsing transactions as a list and opening transaction details with line-level entries plus previous and next navigation.
---

## `bus-ledger` — local daybook and ledger browser UI

### Synopsis

`bus ledger [global flags] [serve | version]`  
`bus-ledger [global flags] [serve | version]`

With no subcommand, `serve` runs.

### Description

`bus-ledger` provides a focused full-stack browsing flow for journal/daybook
transactions. It starts a token-gated local server, serves an embedded WASM
frontend client, and exposes server API endpoints used by the client.
The frontend composes reusable UI primitives from `bus-ui` so shared controls
can be reused consistently across BusDK modules without tight coupling.

The frontend shows a deterministic transactions list view, supports opening a
transaction detail panel, and includes Previous/Next navigation so users can
move transaction-by-transaction without returning to the list. Each transaction
detail also includes one-row-per-entry line summaries (type/amount/from/to) and
supports opening a full line-details panel on the right. When entry lines
contain evidence source paths, the line-details panel can also display the
evidence document inline and provide an open-in-new-tab action. Transactions
with evidence are marked with a document icon in the transactions list. The
list surface also supports explicit Day book and General ledger modes.
When AI is enabled, the app also exposes a foldable AI Assistant side panel
that uses a local Codex app-server process in the same workspace where
`bus-ledger` started, so assistant actions can run repository-local `bus`
commands with explicit approval prompts. The panel supports sending additional
messages while a turn is active; those inputs are forwarded as turn steering.
The panel also supports multiple threads, archival, restoring persisted thread
history from `.bus/bus-ledger/`, thread rename, and selecting the model from an available
model list without requiring a manual submit action.

The AI message surface is conversation-oriented. User and assistant messages
are rendered as separate items, inline markdown code spans are formatted, and
workspace file references can be rendered as clickable links through the
token-gated server route instead of exposing absolute filesystem paths in the
UI. The composer uses Enter-to-send and Shift+Enter for newline, supports drag
and drop over the whole assistant panel, and keeps dropped files as explicit
pending attachments that users can review and remove before sending.
Inline Markdown rendering is deterministic and safe by default: HTML is escaped
and the enabled syntax set is limited to inline code, emphasis, markdown links,
and URL/path autolinks. Rendering features can be toggled with URL query flags
(`ai_md_code`, `ai_md_links`, `ai_md_autolink`, `ai_md_bold`, `ai_md_italic`)
using `0`/`1` values.
When embedded webview drag data does not expose OS file paths, the client uses
browser file-object upload fallback so drop import still works. Imported files
are deduplicated by content hash in `.bus/bus-ledger/drops/` so repeated drops
of the same file reuse the existing stored copy instead of creating duplicate
timestamped files.

Approval requests are shown inline in the message flow with clearer action
labels and command/path presentation optimized for review. Assistant-status and
engine/auth/model metadata are shown in compact form below the composer so the
message area remains focused on conversation content.

For operations and troubleshooting, browser-side diagnostics from the WASM UI
are forwarded to server logs via `v1/client-log`, and repeated identical log
lines are collapsed with summary output (`... and N more`) to reduce noise
during high-frequency UI events such as drag-over.
The server also exposes accountant-focused read-only projection endpoints under
`v1/projections/*` for trial balance, period comparison, dimensional, VAT,
cash, subledger, audit-trail, and closing-diagnostics views.

This module is intentionally narrow. It does not implement accounting logic and
does not replace existing accounting modules. It provides a local browsing
surface over workspace data.

### Commands

`serve` starts the local web server. By default it binds to `127.0.0.1` and an
auto-selected port. `version` prints tool name and version.

Serve supports `--listen`, `--port`, `--token`, `--token-bytes`,
`--journal-file`, `--ai`, `--no-ai`, `--webview`, and `--print-url`. Journal source is resolved
via `bus-journal` layout APIs unless overridden by `--journal-file`.

### Examples

```bash
bus ledger serve --print-url
bus ledger -C ./workspace serve --journal-file journal.csv --print-url
bus-ledger version
```

### Using from `.bus` files

```bus
ledger serve --print-url
ledger -C ./workspace serve --print-url
```

### Development state

**Value promise:** focused daybook browsing UI with transaction list and
prev/next transaction detail navigation.

**Completeness:** 100% for the initial scope.

**Current:** day-book and general-ledger list modes, transaction detail panel
with line summary list, previous/next navigation, unit tests, and e2e coverage.
Current scope also includes the AI assistant side panel with persisted threads,
model selection, drag-and-drop attachments, inline approvals, markdown-style
inline formatting, and server-visible client diagnostics.

**Planned next:** optional filtering and ledger-specific projections can be
added later without changing the base browse flow.

**Blockers:** None known.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-books">bus-books</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ledger SDD](../sdd/bus-ledger)
- [Standard global flags](../cli/global-flags)
