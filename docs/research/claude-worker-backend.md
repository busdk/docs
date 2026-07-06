# Claude-Backed Bus Workers: Backend Options

Question: Does Anthropic offer something equivalent to OpenAI's Codex App
Server (persistent, supervisor-drivable agent process: create conversations,
stream turns/events, approvals, interrupt/steer/resume) that Bus Workers could
use as a `claude-*` runner provider?

Date: 2026-07-06

Sources:
- Local evidence: `claude` CLI v2.1.201 installed at `~/.local/bin/claude`
  (`claude --help` output captured this date) — flags verified first-hand.
- https://code.claude.com/docs/en/agent-sdk/overview (+ `/typescript`,
  `/python`, `/sessions`, `/permissions`, `/hooks`, `/streaming-output`)
- https://code.claude.com/docs/en/headless
- https://code.claude.com/docs/en/cli-reference
- https://code.claude.com/docs/en/authentication
- https://github.com/anthropics/claude-agent-sdk-typescript ,
  https://github.com/anthropics/claude-agent-sdk-python
- https://github.com/anthropics/claude-code/issues/24594 (stream-json input
  schema undocumented)
- https://support.claude.com/en/articles/15036540 (Agent SDK with Claude plan)

## Findings

### 1. There is no `claude app-server` — but there are two workable analogs

Claude Code has no JSON-RPC app-server subcommand, no `--listen ws://` mode,
and no HTTP driver API. `claude mcp serve` exposes Claude Code *as an MCP
server to other tools*, which is the wrong direction for a worker runner.
The two real options:

**(a) Claude Agent SDK (official, recommended by Anthropic for embedders).**
TypeScript `@anthropic-ai/claude-agent-sdk`, Python `claude-agent-sdk`.
Provides programmatic multi-turn sessions (`ClaudeSDKClient` / `query()`),
real-time streaming (`include_partial_messages`), a `canUseTool` permission
callback (approve/deny/modify each tool call before execution — the direct
analog of Codex `requestApproval`), lifecycle hooks (PreToolUse, PostToolUse,
Stop, SessionStart/End, UserPromptSubmit), `interrupt()` mid-turn (analog of
`turn/interrupt`), session resume + fork (analog of `thread/resume`), MCP
server injection, system-prompt control, model/effort selection.

**(b) Claude Code headless stream-json stdio (the raw mechanism under the
SDK).** Verified first-hand on v2.1.201: `claude -p --input-format
stream-json --output-format stream-json --include-partial-messages
--replay-user-messages` keeps ONE claude process alive; the parent streams
user-message JSON lines in on stdin and receives newline-delimited event JSON
on stdout — this is exactly how the Agent SDK drives the CLI internally.
Session flags verified: `--session-id <uuid>`, `--resume [id]`,
`--fork-session`, `-c/--continue`. Permission flags verified:
`--permission-mode` (acceptEdits, auto, bypassPermissions, manual, dontAsk,
plan), `--allowedTools`/`--disallowedTools`,
`--dangerously-skip-permissions`. Also relevant: `--bare` (minimal mode,
strict `ANTHROPIC_API_KEY` auth, no keychain/OAuth reads — good for isolated
worker homes), `--mcp-config`, `--agents <json>`, `--system-prompt`,
`--append-system-prompt`, `--json-schema`, `--effort`, `--fallback-model`,
`--add-dir`, `-w/--worktree` (built-in git worktree creation). CAVEAT: the
stream-json *input* wire schema is explicitly undocumented (GH issue #24594);
Anthropic's stable contract is the SDK, not the raw wire format. A Go
integration speaking raw stream-json must pin CLI versions and own schema
drift. `--permission-prompt-tool` does NOT exist in v2.1.201; approval
callbacks are SDK-only (`canUseTool`) — headless CLI offers only
pre-approved allowlists + permission modes.

### 2. Concept mapping (Codex App Server -> Claude)

| Codex App Server | Claude equivalent |
|---|---|
| `codex app-server` (stdio JSON-RPC) / `--listen ws://` | one long-lived `claude -p` stream-json process (stdio only; no WS) or SDK host process |
| `thread/start`, `thread/resume` | `--session-id` / `--resume` (SDK: `resume`, `fork_session`) |
| `turn/start` (user input) | write user message JSON line to stdin (SDK: `client.query()`) |
| `turn/steer` (inject mid-turn) | no direct steer; closest: queue next stdin message (delivered next turn) or SDK interrupt+re-query — DESIGN GAP |
| `turn/interrupt` | SDK `interrupt()`; raw CLI: no documented mid-turn interrupt control message — DESIGN GAP for raw-stdio path |
| `requestApproval` server-request | SDK `canUseTool` callback; raw CLI: none (use permission modes/allowlists, or MCP permission tool) |
| event notifications (`item/agentMessage/delta`, plans, goals) | stream-json events (`stream_event` deltas, tool_use blocks, `result`); no plan/goal event family — goals stay Bus-side |
| `account/login/start` (ChatGPT OAuth) | `claude setup-token` -> `CLAUDE_CODE_OAUTH_TOKEN` (subscription) or `ANTHROPIC_API_KEY` |
| `sandbox_mode` / `sandboxPolicy` | `--permission-mode` + allowlists + OS sandboxing; no writable-roots parameter parity |
| per-worker `CODEX_HOME` | per-worker `CLAUDE_CONFIG_DIR` + `--bare` + `--settings` |
| token counts (absent in Codex path too; Bus estimates) | stream-json `result` event carries usage/cost fields |

### 3. Auth for automation

Precedence: Bedrock/Vertex/Foundry env gates > `ANTHROPIC_AUTH_TOKEN` >
`ANTHROPIC_API_KEY` > `apiKeyHelper` > `CLAUDE_CODE_OAUTH_TOKEN` (from
`claude setup-token`, requires subscription) > interactive OAuth. Policy
(reported by research pass, worth re-verifying before productizing):
consumer-subscription OAuth tokens must not power third-party agent products;
API-key (or cloud-provider) auth is the safe route for a shipped
`bus-integration-claude`. `--bare` reads ONLY `ANTHROPIC_API_KEY`/
`apiKeyHelper`.

## How this applies to us

The Bus side is already pluggable: engine choice is the
`(runner_kind, runner_provider)` pair routed through `WorkerRunnerProvider`
registrations in `bus-integration-worker/pkg/workersintegration/
runner_provider.go`; `codex-direct`, `codex-appserver`, and
`bus-agent-runtime` already coexist, and templates in
`.bus/worker/templates.json` select providers per worker. Three integration
shapes, cheapest first:

1. **`bus-agent-runtime` + Anthropic `ModelProvider`** — implement the
   `ModelProvider` interface (`bus-agent-runtime/provider.go`) against the
   Anthropic Messages API (or an OpenAI-compatible gateway). Smallest change;
   reuses the Bus-owned tool loop; but the worker then uses Bus tools, not
   Claude Code's harness.
2. **`claude-appserver` lifecycle provider (recommended target)** — new
   `WorkerLifecycle` + messenger in bus-integration-worker that launches one
   persistent `claude -p --input-format stream-json --output-format
   stream-json` per worker (per-worker `CLAUDE_CONFIG_DIR`, product worktree,
   identity worktree, `--add-dir`s) and adapts thread/turn/steer/interrupt
   semantics. Full Claude Code agent quality; must own the undocumented wire
   schema (pin versions) and fill the steer/interrupt gaps.
3. **SDK sidecar** — a small Node/Python daemon per worker embedding the
   Agent SDK and exposing a stable JSON-RPC (even Codex-app-server-shaped)
   to Go. Most stable contract (SDK is the documented surface, `canUseTool`
   approval callback maps cleanly onto Bus approvals) at the cost of a
   Node/Python runtime dependency in the worker stack.

**Operator decision (2026-07-06):** go with shape 2 — the Go `WorkerLifecycle`
speaking raw stream-json to a persistent `claude` process. Rationale: there is
no official Go Agent SDK (the Agent SDK is TypeScript/Python only; the official
`anthropic-sdk-go` covers only the raw Messages API), and the operator prefers
no Node/Python sidecar dependency; we own the wire schema and fix the
integration whenever a Claude Code release breaks it. Design consequences to
bake in: record the `claude --version` used per worker and probe the protocol
on startup; keep the message-schema handling in one small parsing module so
drift fixes are localized; prefer `--bare` + per-worker `CLAUDE_CONFIG_DIR` for
isolation; degrade gracefully (fail the worker with exact protocol evidence,
never hang) when an unknown event type appears.

**Operator architecture correction (2026-07-06, supersedes the module mapping
above where they conflict):** engine ownership is per-module and event-based.
`bus-integration-claude` (new module) OWNS the Claude process instance(s) and
exposes persistent, steerable sessions over the Bus Events API under
`bus.claude.*`; the stream-json wire client is an internal detail of that
module. `bus-integration-codex` likewise owns the main Codex App Server
instance under `bus.codex.*` — its current `bus.llm.*` one-shot turn shape is
a refactoring target (no one-shot engine turns anywhere), as is the direct
per-worker `codex app-server` spawning inside `bus-integration-worker`.
Consumers (`bus-integration-worker` runner lifecycles, chat, LLM API) reach
engines only through those events. Module <-> namespace naming stays aligned.

**Session-manager design (operator direction, 2026-07-06):**
`bus-integration-claude` must implement multi-session support itself, because
one `claude` process == one session (unlike `codex app-server`, where one
process multiplexes many threads). The module owns a session manager:
- Registry: `session_id -> {process handle, stdin/stdout pipes, state,
  workdir, CLAUDE_CONFIG_DIR, claude --version, last activity}`. We mint the
  session UUID and pass `--session-id` at spawn.
- Lifecycle verbs: create (spawn), message (write stream-json user line),
  interrupt (control request; SIGTERM group fallback like the Codex client's
  process teardown), stop (graceful term -> kill), status snapshot.
- Crash recovery + idle eviction: Claude Code persists sessions on disk, so a
  dead or evicted process can be respawned with `--resume <session-id>` and
  full context restored. Evict idle processes on a timeout to bound memory;
  resume lazily on next message. Crash blast radius is one session (an
  advantage over one shared app-server process).
- Concurrency: cap concurrent processes; queue or reject beyond the cap;
  stamp every emitted event with session_id when fanning stdout onto Bus
  Events.
- Event contract shaped like the existing request/response/snapshot Bus
  patterns, e.g. `bus.claude.session.create.request`,
  `bus.claude.session.message.request/.response`,
  `bus.claude.session.interrupt.request`, `bus.claude.session.stop.request`,
  `bus.claude.session.status.snapshot`, plus streamed
  `bus.claude.session.event` notifications for deltas/tool activity. Design
  the payload schema engine-neutrally so `bus.codex.*` can carry the same
  shape and event-based consumers (workers runner) treat engines uniformly;
  only the namespace and engine-specific metadata differ.

Misapplication warnings:
- Do NOT conclude "one-shot `claude -p` per message" is equivalent — that
  loses in-process session continuity and is the fire-and-forget shape the
  supervisor guidance already rejects for workers (steering requires a live
  process; `--resume` restores context but not a running turn).
- Do NOT treat the absence of `--permission-prompt-tool` as "no approvals
  possible": SDK `canUseTool` and MCP-based permission tools exist; raw-stdio
  designs need one of those or explicit permission modes.
- The research pass's claim that a persistent stdio-driven claude process is
  impossible was WRONG for current CLIs — v2.1.201 documents realtime
  streaming input; the SDK uses it. The correct caution is that the wire
  schema is unstable/undocumented, not nonexistent.
