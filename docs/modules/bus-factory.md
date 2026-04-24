---
title: bus-factory
description: Local development assistant UI for BusDK modules.
---

## `bus-factory` - module development assistant

### Synopsis

`bus factory [global flags] [serve] [--root <dir>] [--listen <addr>] [--port <n>] [--token <value>] [--enable-ai=<true|false>] [--webview|--print-url]`

`bus-factory [serve] [--root <dir>] [--listen <addr>] [--port <n>] [--token <value>] [--enable-ai=<true|false>] [--webview|--print-url]`

### Overview

`bus-factory` serves a local token-gated web UI intended for software development workflows in BusDK module repositories.

Initial features:

- read-only list of exported Go units
- toggleable AI assistant panel using the same shared `bus-ui` AI panel renderer (`RenderAIPanel`) used by `bus-ledger`
- AI model dropdown seeded with shared Codex defaults (including `gpt-5.4`) and expanded from complete backend model candidates
- shared `bus-ui` root shell layout and shared `bus-ui` light/dark theme tokens with automatic OS theme detection
- shared `bus-ui` panel/button/AI classes so AI visuals (icons, typography, panel layout) match `bus-ledger`
- superproject module-first view: if root contains `bus` / `bus-*` modules,
  modules are listed first and unit listing is loaded per selected module
- default action integration from `.bus/dev` and `.bus/run`

`bus-factory` now enforces module ownership locks for concurrent AI threads.
When one thread is actively running work for a module, conflicting app-server
approval requests from another thread targeting that same module are declined
until the owner turn completes (or lock lease expires).
The AI panel also exposes the same shared `bus-ui` isolation card used by
other modules, so each thread can show whether it currently owns the selected
module scope or is blocked by another thread, along with deterministic
branch/worktree naming derived from that thread and module.

### Commands

`serve` starts a local HTTP server. By default it opens the capability URL in an app-style local web shell window and prints the URL to stderr. Use `--print-url` to disable auto-open and print URL to stdout.

Global flags:

- `-h`, `--help`
- `-V`, `--version`
- `-v`, `--verbose` (`-vv` enables debug logs)
- `-q`, `--quiet` (suppresses non-error logs/output)
- `-C`, `--chdir <dir>`
- `-o`, `--output <file>`
- `-f`, `--format text`
- `--color <auto|always|never>` / `--no-color`

Defaults:

- `--root .`
- `--listen 127.0.0.1`
- `--port 0` (ephemeral)
- `--token` auto-generated when omitted
- `--enable-ai=true`
- `--webview=true` (opens app-style web shell window)
- `--print-url=false`

### APIs

Under `/{token}/`:

- `GET v1/modules` returns detected BusDK modules under root
- `GET v1/public-units` returns exported Go declarations from workspace root
  or from selected module (`?module=<name>`)
- `GET v1/actions` returns user-defined actions from `.bus/dev` and `.bus/run`
- `POST v1/actions/run` runs non-prompt actions via `bus dev <action>` or
  `bus run <action>`
- `GET v1/ai/status` returns AI panel enable status
- `GET v1/ai/poll` returns AI status, incremental events, and `pending_approvals`
- `POST v1/ai/approval/respond` resolves a pending approval request with a decision
- `POST v1/client-log` forwards browser UI logs to server logs

Prompt action behavior:

- `.txt` actions are routed to AI input (prefill + open AI panel)
- Prompt actions are not executed via `bus dev` / `bus run`

Approval behavior is request/response mediated. When the AI app-server requests
approval, `bus-factory` emits an `approval/requested` event containing
`request_id`, `method`, and `params`, and includes the pending request in
`v1/ai/poll` under `pending_approvals`. The UI responds through
`POST v1/ai/approval/respond` using `request_id` plus one decision:
`accept`, `accept_for_session`, `decline`, or `cancel`.

`GET v1/ai/poll` also returns `acp_status` for review-first coding flows. That
status keeps the current diff blocked while only a narrow Go check has passed,
then switches to ready-to-apply only after the verification pipeline has
escalated to a broad `go test ./...` pass. The same payload includes ordered
tool calls, verification results, and a deterministic diff summary so the UI
does not need to infer readiness from raw terminal text.

Shared AI event handling also recognizes Codex warning, plan-update,
exec-approval, and terminal-interaction event families so the server and UI can
process current backend lifecycle traffic without falling back to unknown-event
warnings.
The shared AI panel also keeps per-thread "AI working" markers stable in the
thread list and avoids showing the generic responding placeholder when you
reopen a different thread while another thread is still waiting on work or
approval.
The shared composer also preserves trailing spaces in the AI text area while
the field is still focused, so background panel refreshes do not collapse draft
text mid-edit; the draft is only normalized when you blur or send it.
The same shared browser AI client now exposes the shared close-guard bindings
used by `bus-ui`, so `bus-factory` blocks browser close while assistant work
is active or a local AI draft is still unfinished instead of maintaining a
separate module-local unload handler. Opening the shared AI shell also triggers
an immediate poll reconciliation, so approvals that were already pending before
the panel opened are reflected in close-guard state without waiting for the
next polling interval.
The shared AI panel also renders the current command session through the same
`bus-ui` terminal surface used by other modules. When approval or verification
work is in progress, the panel can show the current command, streamed output,
session state, and approval prompt from one deterministic `terminal_session`
snapshot in `v1/ai/poll` instead of requiring module-local terminal widgets.

If the pending approval is not resolved, `RequestApproval` cancels on context
cancellation or after a fixed 10-minute timeout.

### Using from `.bus` files

Inside a `.bus` file, write the module command without the `bus` prefix.

```bus
factory serve --print-url
```

### Exit behavior

- `0` success
- `2` invalid usage
- `1` runtime failure

### Sources

- [Module reference: bus-factory](../modules/bus-factory)
- [Request approval implementation](../../../bus-factory/internal/serve/ai.go)
