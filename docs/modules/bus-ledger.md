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
The panel also supports multiple threads so users can open a new issue-focused
thread and switch between existing threads.
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
