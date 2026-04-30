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
supports opening a full line-details panel on the right. When evidence is
available either from journal path fields or from attachment metadata linked to
the transaction voucher, both the transaction detail and the line-details panel
now use the same shared evidence surface: one common document is shown inline
below the line table with PDF preview plus explicit open and download controls,
and non-previewable files still keep those controls with visible document
metadata. If multiple documents are linked, the transaction detail lists them
directly. Transactions with
evidence are marked with a document icon in the transactions list. The list
surface also supports explicit Day book and General ledger modes. List and
detail tables use explicit toggle controls for open/close transitions, so row
index cells are plain values instead of navigation links and closing follows the
same toggle interaction pattern as opening.
When AI is enabled, the app also exposes a foldable AI Assistant side panel
that uses a local Codex app-server process in the same workspace where
`bus-ledger` started, so assistant actions can run repository-local `bus`
commands with explicit approval prompts. The panel supports sending additional
messages while a turn is active; those inputs are forwarded as turn steering.
The panel also supports multiple threads, archival, restoring persisted thread
history from `.bus/bus-ledger/`, thread rename, and selecting the model from an available
model list without requiring a manual submit action.
The model dropdown is seeded with shared Codex defaults (including `gpt-5.4`)
and is expanded by all model candidates observed from backend payloads, so the
list reflects complete available options instead of only the first discovered model.
The thread list also keeps a stable "AI working" marker on the busy thread, and
reopening another saved thread no longer shows the generic responding
placeholder unless that reopened thread is the one still running.
The shared close guard also blocks browser close while assistant work is still
active, such as a pending approval, so the session is not torn down
accidentally in the middle of an unfinished AI task.
The shared composer also preserves trailing spaces while the AI input is still
focused, even if the panel re-renders, and only normalizes the draft once you
blur or send it.
The same shared `bus-ui` AI surface also renders command-session activity in
place. When the assistant is waiting on approval or has just completed a
verification command, the panel shows the command, output, status, and review
actions through the shared terminal session panel instead of a ledger-local
terminal UI.
The same shared surface now also shows per-thread workspace isolation state.
When another AI thread already owns the workspace lock, the blocked thread
shows the shared conflict card with the owner thread identifier and
deterministic branch/worktree naming instead of silently failing or rendering
ledger-local lock text.

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
Detail-load warnings are shown in the ledger detail panel and are separated
from assistant runtime errors, so AI/action error state does not overwrite
ledger data warnings.

For operations and troubleshooting, browser-side diagnostics from the WASM UI
are forwarded to server logs via `v1/client-log`. This includes explicit UI
logger messages and global browser failures (`window` `error` events and
`unhandledrejection`) so uncaught frontend initialization/auth issues are
visible from server stderr. Repeated identical log lines are collapsed with
summary output (`... and N more`) to reduce noise during high-frequency UI
events such as drag-over.
AI account-state refresh and account/login event handling also log explicit
auth-detection reasons (including unresolved payload diagnostics), so "not
logged in" status changes can be diagnosed from server logs without browser
debugging.
Server log verbosity follows global flags consistently: default output includes
warnings and errors, `-v` enables info logs, `-vv` enables debug logs, and
`-q` suppresses all non-error logs.
Frontend wiring lifecycle is explicit: AI/drop/resize listeners and poll timers
are registered with tracked disposers and can be released deterministically via
app cleanup in reusable host/test scenarios.
The same cleanup path is also wired to browser lifecycle events
(`beforeunload`, `pagehide`) so production teardown releases listeners/timers
deterministically.
The server also exposes accountant-focused read-only projection endpoints under
`v1/projections/*` for trial balance, period comparison, dimensional, VAT,
cash, subledger, audit-trail, and closing-diagnostics views.

This module is intentionally narrow. It does not implement accounting logic and
does not replace existing accounting modules. It provides a local browsing
surface over workspace data.

### Commands

`serve` starts the local web server. By default it binds to `127.0.0.1` and an
auto-selected port. `version` prints tool name and version.

Run `serve` from a Bus workspace that already contains journal data. Journal
source is resolved via `bus-journal` layout APIs unless overridden by
`--journal-file <path>`; use that override when the journal file is outside the
standard workspace location.

Serve supports `--listen <addr>` and `--port <n>` for the local listener,
defaulting to `127.0.0.1` and an auto-selected port. `--token <value>` and
`--token-bytes <n>` control the browser capability token; prefer the generated
token for normal use. `--journal-file <path>` selects a specific journal CSV.
`--ai` and `--no-ai` enable or disable AI panel features. `--webview` opens an
app-style local web shell window, and `--print-url` prints the tokenized URL;
using `--print-url` disables auto-open.

### Examples

```bash
bus ledger serve --print-url
bus ledger -C ./workspace serve --journal-file journal.csv --print-url
bus-ledger version
```

Successful `serve --print-url` prints a local URL containing the generated
capability token. Open that URL in a browser to reach the ledger UI.

### Using from `.bus` files

```bus
ledger serve --print-url
ledger -C ./workspace serve --print-url
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-books">bus-books</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ledger reference](../modules/bus-ledger)
- [Standard global flags](../cli/global-flags)
