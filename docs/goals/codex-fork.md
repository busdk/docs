# Codex Fork And Go Rewrite Feasibility Goal

## Goal

Evaluate whether BusDK should fork OpenAI Codex as a Bus-owned submodule and,
if so, whether to keep the upstream Rust implementation, wrap it, port only the
Bus-critical surfaces, or rewrite Codex in Go.

This goal started as feasibility and planning work: understand what Codex is,
how it is structured, what language it is written in today, which Bus modules
would be affected, and how much work a single Bus submodule or Go rewrite
would likely require. Implementation is now approved only for the worker-owned
`bus-agent-runtime` slice described below.

## Operator Direction Captured

The operator forked this from the LLM limits discussion and requested:

```text
docs/docs/goals/codex-fork.md
```

The question is:

```text
Codex is open source. Which language is it written in, and how much work would
it be to port it as a single Bus submodule and rewrite it as Go?
```

Product implementation should stay inside the approved worker-owned
`bus-agent-runtime` slice until the remaining compatibility, release, and
provider-proof questions are resolved.

## Upstream Codex Facts

As of 2026-06-06, the upstream repository is:

```text
https://github.com/openai/codex
```

The repository is public and Apache-2.0 licensed. GitHub reports the current
language mix as mostly Rust, with smaller Python, TypeScript, Starlark, Shell,
PowerShell, and other content. At the time of review, the GitHub language
breakdown reported Rust at about 96%.

The repository root contains:

- `codex-rs`: the main Rust workspace;
- `codex-cli`: npm packaging for the `codex` command;
- `sdk`: TypeScript SDK surface;
- `docs`, `scripts`, `patches`, and supporting repository tooling.

The Rust workspace is large. `codex-rs/Cargo.toml` lists many internal crates,
including app-server, app-server protocol/client/transport, CLI, core,
protocol, TUI, model providers, sandboxing, MCP, tools, rollout/session state,
extensions, rate-limit parsing, shell execution, file system, approvals,
skills, memories, image generation, web search, and utility crates.

The current Codex CLI can be installed through shell installers, npm,
Homebrew, or GitHub release binaries. The npm package is a wrapper package that
publishes a `codex` binary entrypoint, not evidence that the main agent is
TypeScript.

## License Safety

OpenAI Codex is Apache-2.0 licensed, so Bus may study, fork, vendor, modify,
and redistribute it if Bus preserves the license obligations. Any Bus submodule
or redistributed binary must keep the upstream Apache-2.0 license text,
preserve upstream copyright notices, carry any upstream NOTICE file content
that applies to redistributed artifacts, mark Bus modifications where
appropriate, and include license/NOTICE review in release packaging. A Go
rewrite that copies structure, protocol types, generated models, tests, or
substantial translated code should still be treated as derivative work until
legal review says otherwise.

## Source Size Review

Measured from upstream commit:

```text
87b808bb570f01f4b6fc8485c5459052fac0e320
```

The shallow review checkout did not expose a release tag; `git describe`
reported `87b808b`.

Tracked repository size at that commit:

```text
tracked files:       4,840
Rust crates:           122
tracked lines:   1,222,411
Rust lines:        960,816
TypeScript/JS:       9,819
Python:             34,096
snapshots:           7,946
JSON:              111,603
Markdown:           16,128
```

The counts were produced from the reviewed checkout using `git ls-files`,
`find codex-rs -name Cargo.toml`, and extension-filtered `wc -l` aggregation.
Largest-crate counts were produced by grouping tracked Rust files under
`codex-rs/<crate>/` and separating obvious test, fixture, and snapshot paths
from production-ish paths. The split is intentionally approximate; the tracked
file, crate, and total line counts are the reproducible anchors.

The Rust line count includes tests and fixtures. A rough path/name split shows
about 648k production-ish Rust lines and about 312k Rust test/test-fixture
lines. This is not a tiny CLI with a thin model wrapper; it is a large agent
runtime, UI, protocol, sandbox, and service system.

Largest Rust areas by line count:

| Area | Production-ish Rust lines | All Rust lines | Notes |
| --- | ---: | ---: | --- |
| `codex-rs/core` | 93k | 238k | Agent loop, turn handling, model/tool orchestration, policies, tests |
| `codex-rs/tui` | 177k | 205k | Terminal UI and interaction layer |
| `codex-rs/app-server` | 34k | 98k | Headless app-server behavior and tests |
| `codex-rs/app-server-protocol` | 24k | 25k | JSON-RPC/app-server protocol types and mappers |
| `codex-rs/protocol` | 18k | 18k | Core protocol/event types |
| `codex-rs/config` | 16k | 18k | Configuration loading and policy |
| `codex-rs/exec-server` | 14k | 19k | Exec server behavior |
| `codex-rs/app-server-transport` | 11k | 13k | App-server transport/auth |
| `codex-rs/codex-api` | 10k | 12k | Codex API client behavior, rate limits |
| `codex-rs/login` | 5k | 10k | Login/auth flows |
| `codex-rs/exec` | 4k | 9k | Command execution support |
| `codex-rs/linux-sandbox` | 6k | 8k | Linux sandboxing |
| `codex-rs/windows-sandbox-rs` | 16k | 16k | Windows sandboxing |
| `codex-rs/apply-patch` | 5k | 5k | Patch application |
| `codex-rs/thread-store` + `state` + `rollout*` | 41k | 47k | Session/state/rollout storage and tracing |

These counts matter because a "Go rewrite" can mean anything from a small Bus
adapter to a full replacement for roughly 650k production-ish Rust lines plus a
large test suite.

## Feasibility Framing

There are four materially different options. They should not be collapsed into
one vague "port Codex" task.

1. Use upstream Codex as an external dependency.
   Bus continues launching the installed `codex` binary through `bus-agent` and
   `bus-integration-worker`. This is the lowest-maintenance path and keeps Bus
   aligned with upstream releases.

2. Add a Bus submodule that tracks upstream Codex source.
   Bus would vendor or mirror `openai/codex` as a dedicated submodule, build or
   package it as part of Bus release workflows, and apply small Bus-owned
   patches only where necessary. This is a packaging/maintenance fork, not a Go
   rewrite.

3. Build a Bus-native Go adapter around Codex protocols.
   Bus would keep upstream Codex as the reference implementation, but implement
   selected App Server protocol clients, rate-limit readers, worker lifecycle
   integrations, and status surfaces in Go. This is already partly aligned
   with `bus-agent` and `bus-integration-worker`.

4. Rewrite Codex in Go.
   Bus would reimplement enough of Codex's agent runtime in Go to replace the
   upstream Rust binary for selected Bus workflows. Full parity would include
   app-server behavior, CLI/TUI, model provider plumbing, sandboxing,
   approvals, tool execution, file/search context, MCP, extensions, session
   storage, rollout tracing, auth, updater/release behavior, and platform
   packaging. This is a large product rewrite, not a small port.

The selected first implementation slice is now a Bus-owned Go runtime module,
`bus-agent-runtime`, that keeps current upstream Codex integrations intact.
This is narrower than a full Codex rewrite: it targets the headless worker
path, local GPU providers, OpenAI API-compatible providers, Bus worker
orchestration, policy, tool execution, and evidence recording. Remaining
decisions should focus on exact compatibility behavior, local-provider proof,
release boundaries, and which App Server extension behaviors must be supported
in the first slice.

## What Would Actually Need Rewriting In Go

For Bus worker operations, we do not need to rewrite all of Codex. The first
Bus-owned Go target should be a headless runtime subset:

1. App Server protocol client/server compatibility.
   Recreate the JSON-RPC methods, event stream, turn lifecycle, thread start,
   turn start, cancellation, approvals, and error surfaces Bus workers use.
   This maps mainly to `app-server`, `app-server-protocol`,
   `app-server-transport`, and `protocol`.

2. Codex API/auth/rate-limit client behavior.
   Support local-provider and official API-key paths that Bus allows, model
   selection, provider-exposed rate-limit snapshots, backend request/response
   streaming, and safe error mapping. Managed ChatGPT subscription login is
   not part of the first Bus-owned rewrite target. This maps mainly to
   `codex-api`, selected config/provider code, and a much smaller auth surface
   than upstream's full `login` crate.

3. Agent turn engine.
   Recreate the loop that sends model input, receives items, interprets tool
   calls, applies policy, resumes after approvals, and emits stable events.
   This is the hardest part because much of it lives in `core`.

4. Tool execution and filesystem behavior.
   Recreate shell execution, patch application, file read/write/search
   behavior, stdout/stderr truncation, working-directory handling, and
   deterministic diagnostics. This maps to `exec`, `exec-server`,
   `shell-command`, `apply-patch`, file-system, and utility crates.

5. Sandboxing and approval policy.
   Recreate only the policies Bus needs first: read-only, workspace-write,
   network gating, writable roots, approval request/response, and process
   cleanup. Full platform parity would also pull in Linux and Windows sandbox
   crates.

6. Session/evidence storage.
   Persist enough thread/turn/event state that Bus task evidence remains
   inspectable and replayable. This maps to `thread-store`, `state`, `rollout`,
   and `rollout-trace`, but Bus can choose a smaller schema.

The first Bus runtime can defer or avoid:

- full TUI parity;
- desktop app behavior;
- all extension/plugin surfaces;
- all MCP/client/server features beyond what Bus workers use;
- image generation, web search, memories, skills, and connectors unless Bus
  explicitly needs those through Codex rather than native Bus tools;
- Windows sandboxing if first Bus worker targets are macOS/Linux only;
- npm wrapper and upstream release packaging UX;
- exact upstream CLI flags and terminal UI behavior.

In code-size terms, a focused Bus headless rewrite is probably not 650k lines.
It is more plausibly an 80k-200k Go-line equivalent if it includes protocol
types, tests, tool execution, sandbox policy, session storage, and App Server
compatibility. A very narrow prototype that only talks to an upstream Codex App
Server, reads limits, starts a thread, sends one turn, and records events could
be much smaller, around 5k-20k Go lines, because it avoids model execution and
tool runtime parity.

AI changes the labor profile. It can draft translations, protocol structs,
tests, and adapters quickly, and multiple Bus workers can split the rewrite by
module. It does not remove the hard parts: deciding the compatibility contract,
building hermetic tests, proving live local-provider/OpenAI API behavior,
handling secrets, matching sandbox semantics, and chasing upstream protocol
changes.

## Flat Upstream Codex Feature Inventory

This is a feature-family inventory from upstream commit
`87b808bb570f01f4b6fc8485c5459052fac0e320`. It is complete at the level needed
to scope a Bus-compatible rewrite: it names the product/runtime capabilities
present in the codebase, not every function, enum, test helper, or internal
data type.

- CLI binary entrypoint and argument parsing.
- CLI command dispatch for interactive and headless execution.
- CLI login, logout, auth status, and account selection.
- CLI config inspection and mutation commands.
- CLI resume, replay, and session selection commands.
- CLI sandbox command wrappers.
- CLI apply-patch command behavior.
- CLI MCP server command behavior.
- CLI cloud task and cloud configuration commands.
- CLI debug and internal diagnostic commands.
- NPM package wrapper for the `codex` binary.
- NPM package build and platform binary selection scripts.
- Installer, update, and release artifact support.
- Homebrew, GitHub release, and shell installer integration.
- Runtime install-context detection.
- Terminal detection and terminal capability probing.
- Terminal title and status integration.
- Terminal hyperlink rendering support.
- Clipboard copy and paste integration.
- Audio, bell, and OSC notification support.
- TUI application loop and frame scheduling.
- TUI keyboard mode handling.
- TUI command palette and command dispatch.
- TUI slash command parser and handlers.
- TUI chat transcript rendering.
- TUI streaming response rendering.
- TUI markdown rendering.
- TUI table and syntax highlighting support.
- TUI diff model and diff rendering.
- TUI execution-cell rendering.
- TUI patch-cell rendering.
- TUI approval-cell rendering.
- TUI MCP-cell rendering.
- TUI search-cell rendering.
- TUI plan-cell rendering.
- TUI session-cell rendering.
- TUI request-user-input rendering.
- TUI composer, draft state, paste handling, and history search.
- TUI textarea editing and Vim-style bindings.
- TUI bottom pane, overlays, popups, and pickers.
- TUI model picker, model catalog view, and reasoning shortcuts.
- TUI settings, permissions, and service-tier popups.
- TUI rate-limit and token-usage status views.
- TUI account status view.
- TUI remote connection status view.
- TUI side panel and thread navigation.
- TUI goal menu and goal validation surfaces.
- TUI review mode surfaces.
- TUI plan implementation surfaces.
- TUI realtime mode surfaces.
- TUI hooks browser.
- TUI memories settings view.
- TUI skills toggle and skills popup.
- TUI plugin mentions and plugin UI surfaces.
- TUI file-search popup.
- TUI mention search and mention rendering.
- TUI onboarding screens.
- TUI trust-directory onboarding flow.
- TUI auth onboarding flow.
- TUI session resume picker and transcript preview.
- TUI session archive commands.
- TUI external editor integration.
- TUI IDE context display and IPC integration.
- TUI update prompts and update actions.
- TUI theme and color styling.
- TUI terminal image/pet rendering support.
- App Server process lifecycle.
- App Server daemon lifecycle.
- App Server client library.
- App Server in-process mode.
- App Server stdio and UDS transport.
- App Server request serialization.
- App Server message processor.
- App Server connection RPC gating.
- App Server initialization request handling.
- App Server outgoing message handling.
- App Server tracing and analytics utilities.
- App Server error-code mapping.
- App Server filters and request validation.
- App Server account request processor.
- App Server app catalog request processor.
- App Server command execution request processor.
- App Server config request processor.
- App Server environment request processor.
- App Server external-agent-config request processor.
- App Server feedback request processor.
- App Server filesystem request processor.
- App Server git request processor.
- App Server marketplace request processor.
- App Server MCP request processor.
- App Server plugin request processor.
- App Server process execution request processor.
- App Server remote-control request processor.
- App Server search request processor.
- App Server thread-goal request processor.
- App Server thread-lifecycle request processor.
- App Server thread request processor.
- App Server thread summary request processor.
- App Server token-usage replay processor.
- App Server turn request processor.
- App Server Windows sandbox request processor.
- App Server configuration manager service.
- App Server dynamic tool catalog.
- App Server filesystem watcher.
- App Server fuzzy file search.
- App Server MCP refresh.
- App Server skills watcher.
- App Server thread state and thread status tracking.
- App Server external-agent configuration migration.
- App Server protocol v2 account API.
- App Server protocol v2 apps API.
- App Server protocol v2 attestation API.
- App Server protocol v2 collaboration-mode API.
- App Server protocol v2 command-exec API.
- App Server protocol v2 config API.
- App Server protocol v2 environment API.
- App Server protocol v2 experimental-feature API.
- App Server protocol v2 feedback API.
- App Server protocol v2 filesystem API.
- App Server protocol v2 hook API.
- App Server protocol v2 item and event data model.
- App Server protocol v2 MCP API.
- App Server protocol v2 model API.
- App Server protocol v2 notification API.
- App Server protocol v2 permissions API.
- App Server protocol v2 plugin API.
- App Server protocol v2 process API.
- App Server protocol v2 realtime API.
- App Server protocol v2 remote-control API.
- App Server protocol v2 review API.
- App Server protocol v2 thread API.
- App Server protocol v2 thread-data API.
- App Server protocol v2 turn API.
- App Server protocol v2 Windows sandbox API.
- App Server protocol shared request, response, and error types.
- Python SDK for App Server-backed Codex runs.
- Python SDK streaming API.
- Python SDK approval API.
- Python SDK lifecycle API.
- Python SDK login integration.
- Python SDK contract-generation tests.
- TypeScript SDK for Codex runs.
- TypeScript SDK streamed run API.
- TypeScript SDK thread API.
- TypeScript SDK turn options.
- TypeScript SDK structured output helpers.
- TypeScript SDK exec helpers.
- Core agent session lifecycle.
- Core thread lifecycle.
- Core turn lifecycle.
- Core task lifecycle.
- Core input queue.
- Core event mapping.
- Core streaming event utilities.
- Core model request construction.
- Core model response parsing.
- Core model/tool loop orchestration.
- Core hosted tool orchestration.
- Core parallel tool orchestration.
- Core tool registry and tool routing.
- Core tool-dispatch tracing.
- Core turn timing and metadata tracking.
- Core turn diff tracking.
- Core automatic compaction window logic.
- Core local compaction.
- Core remote compaction.
- Core context history management.
- Core context normalization.
- Core context update generation.
- Core AGENTS.md discovery and instruction layering.
- Core user-instruction injection.
- Core environment-context injection.
- Core permissions-instruction injection.
- Core plugin-instruction injection.
- Core skill-instruction injection.
- Core app-instruction injection.
- Core collaboration-mode instruction injection.
- Core personality and model-switch instruction injection.
- Core realtime instruction injection.
- Core network-rule and approved-command-prefix instruction injection.
- Core hook-context injection.
- Core internal model-context injection.
- Core prompt debug support.
- Core review-format support.
- Core response retry behavior.
- Core safety checks.
- Core metadata protection.
- Core memory-usage tracking.
- Core installation-id tracking.
- Core personality migration.
- Core shell command canonicalization.
- Core shell execution.
- Core unified exec process management.
- Core unified exec async watcher.
- Core unified exec output buffering.
- Core command stdout and stderr truncation.
- Core shell snapshot support.
- Core user shell command support.
- Core exec environment filtering.
- Core exec policy evaluation.
- Core shell escalation support.
- Core sandbox tags.
- Core sandbox policy model.
- Core Linux landlock integration.
- Core Linux bwrap integration.
- Core Windows sandbox integration.
- Core Windows sandbox read grants.
- Core process hardening.
- Core apply-patch integration.
- Standalone apply-patch parser and executor.
- File-system abstraction.
- File search.
- File watcher.
- Git status and diff helpers.
- Git action directive handling.
- Working-directory and path utility handling.
- Network proxy configuration.
- Network proxy loader.
- Network policy decision support.
- Network approval tool support.
- OpenAI/Codex API client.
- Responses API client behavior.
- Responses API proxy behavior.
- Backend client behavior.
- Generated Codex backend OpenAPI model bindings.
- ChatGPT subscription authentication.
- ChatGPT local auth storage.
- Browser/headless ChatGPT login support.
- API-key authentication support.
- Keyring credential storage.
- Secret storage and redaction helpers.
- Account metadata retrieval.
- Rate-limit metadata retrieval and parsing.
- Token usage accounting.
- Service-tier resolution.
- Model-provider abstraction.
- Model-provider metadata.
- Model catalog retrieval.
- Model migration and upgrade handling.
- Models manager.
- OpenAI realtime WebRTC client.
- Realtime conversation state.
- Realtime context construction.
- Realtime prompt handling.
- Ollama model provider support.
- LM Studio model provider support.
- Amazon Bedrock authentication support.
- Cloud configuration client.
- Cloud task client.
- Cloud task mock client.
- Cloud task data model.
- Agent identity model.
- Agent graph store.
- Agent role registry.
- Agent resolver.
- Agent status model.
- External agent sessions.
- External agent migration.
- Multi-agent session support.
- Code mode and delegated Codex behavior.
- Collaboration-mode templates.
- Managed feature flags.
- Experimental feature flags.
- Configuration file loading.
- Configuration schema generation.
- Configuration editing.
- Configuration lock handling.
- Permission profile resolution.
- Approval request and approval response flow.
- Guardian approval review.
- Guardian review session.
- Guardian follow-up review reminders.
- Hooks engine.
- Hook runtime.
- Hook additional context.
- Hook lifecycle events.
- Plugin manifest discovery.
- Plugin catalog and marketplace support.
- Plugin install, render, and injection support.
- Plugin mention support.
- Plugin tool exposure.
- Core plugin bundle.
- Extension API registry.
- Goal extension.
- Goal accounting.
- Goal metrics.
- Goal steering.
- Guardian extension.
- Image generation extension.
- Image generation tool schema and backend.
- Web search extension.
- Web search tool schema and history.
- Memories extension.
- Memories local backend.
- Memory read citations.
- Memory read usage accounting.
- Memory write guard.
- Memory write runtime.
- Memory write storage.
- Memory write workspace filtering.
- Skills extension.
- Skills catalog.
- Skills provider.
- Skills source discovery.
- Skills render and selection support.
- Core skills bundle.
- Skill dependency discovery for MCP.
- MCP client support.
- MCP server support.
- MCP stdio and UDS integration.
- MCP tool calls.
- MCP tool approval templates.
- MCP tool exposure policy.
- MCP OpenAI file support.
- MCP elicitation support.
- MCP startup and refresh behavior.
- Connector metadata support.
- Mention syntax parsing.
- App metadata rendering.
- Attestation support.
- Analytics event support.
- OpenTelemetry initialization.
- Feedback capture.
- Feedback doctor report generation.
- Response debug context.
- Rollout recording.
- Rollout trace recording.
- Rollout reconstruction.
- Rollout truncation handling.
- Thread store.
- Thread manager.
- Thread summary generation.
- Thread data redaction on resume.
- State database bridge.
- Session state service.
- Session prefix generation.
- Session startup prewarm.
- Message history.
- Test backend support.
- App Server test client.
- Thread manager sample.
- Stdio-to-UDS bridge.
- UDS utility crate.
- ANSI escape handling.
- Async utility helpers.
- Shell command parsing helpers.
- Execution policy legacy compatibility.
- V8 proof-of-concept extension runtime.
- Bazel build integration.
- Repository scripts and release tooling.
- Snapshot, fixture, and harness infrastructure.
- Cross-platform Windows sandbox binary and policy support.
- Cross-platform Linux sandbox binary and policy support.
- Cross-platform macOS terminal and keyring behavior.

## Minimum Bus-Owned Feature Set

Before considering a Go rewrite, define the minimum Codex behavior Bus truly
needs:

- launch a headless App Server or equivalent worker runtime;
- run against local GPU/provider backends where possible;
- authenticate with official API-key credential sources without leaking
  secrets;
- select model, reasoning effort, sandbox, writable roots, and approval policy;
- start or resume a thread;
- send turns and stream events;
- parse rate-limit snapshots and model/account metadata when exposed by an
  officially supported provider API or by an upstream Codex binary already
  configured by the operator;
- handle tool calls, approvals, shell execution, file edits, and patch
  application;
- preserve the App Server extension boundary that current Codex App Server
  sessions may expose, including skills and memories compatibility plus
  explicit capability-gated behavior for web search and image generation;
- preserve session evidence and terminal/status data for Bus tasks;
- expose deterministic status/errors suitable for worker scheduling;
- run on macOS and Linux worker hosts;
- package into Bus releases without requiring a full Node/Rust developer
  toolchain at runtime.

ChatGPT subscription login/logout should not be part of the first Bus-owned
implementation target. Upstream Codex includes browser login, device-code
login, ChatGPT token storage, account/rate-limit reads, plan/service-tier
display, and ChatGPT backend calls, but those are not an official third-party
integration contract for Bus to reimplement. Bus may still launch an upstream
Codex binary that the operator has already authenticated locally, but Bus
should not own or clone the managed ChatGPT subscription login flow unless a
supported integration contract exists and the operator explicitly approves that
scope.

For the first Bus-compatible runtime, prefer:

- local GPU providers through Codex-compatible/local provider APIs;
- official OpenAI API-key authentication;
- provider-neutral model, usage, and limit metadata where the provider exposes
  it;
- skills and memories compatibility when those features are enabled in the
  active Codex/App Server configuration;
- explicit disabled or unsupported results for web search and image generation
  unless the active provider and Bus policy enable those tools;
- a clean "not supported for this provider" result for ChatGPT subscription
  limit/login surfaces rather than scraping or reverse-engineering private
  ChatGPT behavior.

Anything beyond that, such as full TUI parity, desktop app behavior, all
plugin marketplace behavior, all provider integrations, and all upstream UX
features, should be classified as full-parity work and not mixed into a first
Bus-owned slice. Do not drop skills, memories, or extension-tool compatibility
from the first slice merely because they live under upstream extension crates:
upstream App Server wires those extension registries into normal thread
runtime, and current Bus App Server launch paths do not explicitly disable
them.

## Affected Bus Modules

Primary modules for a feasibility investigation:

- `bus-agent`: owns reusable agent runtime adapters. It should own any stable
  Go interface to App Server-compatible protocols and must remain
  provider/runtime agnostic where possible.
- `bus-integration-codex`: owns provider-specific behavior for the actual
  upstream Codex product behind Bus Events. Keep this module for current and
  future Codex integrations; do not put the Bus-owned Go subset here.
- `bus-integration-worker`: owns worker lifecycle, App Server launch, worker
  profiles, sandbox wiring, writable roots, and worker status. It is the main
  Bus consumer that would feel a Codex fork or Go rewrite.
- `bus-worker`: owns durable worker identity and may need metadata fields for
  runtime identity, upstream Codex version, or compatibility mode.
- `bus-api-provider-llm`: owns LLM API/model execution surfaces and would need
  compatibility decisions if a Go App Server-compatible runtime becomes a
  first-class backend.

Likely supporting modules:

- `bus-operator-deploy` and release scripts: build, package, install, and
  update any forked Codex binary or Bus-owned runtime module.
- `bus-operator-token`, `bus-secrets`, and credential-source modules:
  API-key, local-provider, and externally configured upstream Codex credential
  storage, copying, redaction, and rotation policy. Managed ChatGPT
  subscription login/logout should remain out of scope unless a supported
  integration contract is explicitly adopted.
- `bus-integration-usage` and `bus-api-provider-usage`: usage and limit
  telemetry if the fork changes how model use, rate limits, or token usage are
  observed.
- `bus-services`: supervision only, if a Bus-owned agent runtime daemon or
  collector is added to service profiles.
- `bus-update` and `bus-configure`: installation/update flows if Bus ships its
  own App Server-compatible runtime.
- `docs` and `sdd`: public and design documentation for the chosen strategy.

Candidate new module:

- `bus-agent-runtime`: a possible Bus-owned, open source Go module for the
  headless App Server-compatible subset. The module name intentionally avoids
  `codex`; `codex` remains reserved for modules that integrate with the actual
  upstream Codex product.

Modules that should not own the fork:

- `bus-events` should remain event transport.
- `bus-api` should remain an API host and router.
- Task modules should not own agent runtime protocol or Codex process
  lifecycle.

## Work Estimate Bands

These are planning bands, not commitments.

Low effort: keep upstream Codex external and improve Bus adapters.

- Scope: stronger `bus-agent` App Server client, better worker status,
  rate-limit parsing, and safer launch diagnostics.
- Expected effort: days to a few weeks, depending on test coverage and live
  proof needs.
- Risk: low maintenance burden; still depends on upstream Codex behavior.

Medium effort: single Bus submodule wrapping upstream Rust Codex.

- Scope: add an upstream-Codex tracking submodule only if Bus chooses to vendor
  the actual upstream product. Do not name a Bus-owned Go rewrite with `codex`;
  reserve that term for direct upstream Codex integration.
- Expected effort: several weeks for reliable build/release/update plumbing,
  then continuing maintenance with every upstream change.
- Risk: Rust toolchain, upstream churn, patch rebase work, security updates,
  and cross-platform release packaging.

High effort: Go implementation of Bus-critical headless runtime.

- Scope: reimplement only the App Server worker path needed by Bus: auth
  handoff, model selection, turn/event protocol, tool calls, approvals,
  sandbox policy, shell execution, file edits, session evidence, and
  rate-limit/usage metadata.
- Expected effort: multi-week to multi-month, depending on how much protocol
  and tool behavior must match upstream exactly.
- Risk: high compatibility risk; upstream private service behavior may change;
  partial parity can be useful but must be branded as Bus-compatible, not full
  Codex.

Very high effort: full Go rewrite of Codex.

- Scope: CLI, TUI, app-server, model providers, sandboxing, MCP, plugins,
  skills, memories, image generation, web search, rollout tracing, session
  storage, packaging, auth, updater behavior, and full UX parity.
- Expected effort: multi-quarter for a small team, likely longer if full
  cross-platform parity and upstream tracking are required.
- Risk: high; easy to spend months recreating moving upstream behavior instead
  of delivering Bus-specific value.

## Proposed Investigation Plan

1. Audit upstream Codex module boundaries.
   Record which Rust crates map to Bus needs: App Server protocol, auth,
   sandbox, shell execution, patch application, session store, rate limits,
   model provider, TUI, and extensions.

2. Define the minimum Bus-compatible Codex runtime.
   Decide whether Bus needs a full CLI/TUI, a headless App Server, or only a
   protocol client plus worker launch wrapper.

3. Compare three implementation paths:
   external upstream binary, Bus submodule wrapping upstream Rust, and Go
   reimplementation of the minimum runtime.

4. Build a compatibility matrix.
   For each path, assess auth, rate limits, model selection, approvals,
   sandboxing, tool calls, file edits, event streaming, session persistence,
   packaging, security updates, and worker proof.

5. Produce a recommendation.
   The recommendation should choose one path for the next implementation slice
   and explicitly reject or defer the other paths.

## Verification Requirements

The feasibility result must include:

- upstream commit and release version reviewed, or an explicit note that the
  reviewed checkout had no release tag available;
- current upstream language mix and repository structure;
- license and NOTICE obligations for forking or vendoring;
- list of Codex crates or packages relevant to Bus;
- list of Bus modules affected;
- minimum Bus-owned behavior required;
- comparison of external binary, Rust submodule fork, and Go rewrite;
- rough effort/risk bands;
- security and credential-handling implications;
- release/build implications for macOS and Linux workers;
- a recommendation for the first implementation slice.

Implementation work is now authorized for the selected `bus-agent-runtime`
slice and must be worker-owned and isolated:

- create or use a Bus Worker-owned worktree and feature branch;
- do not import upstream Codex into an existing Bus module casually;
- do not name a Bus-owned subset module with `codex`, because that is not a
  Bus trademark and should identify upstream Codex integration only;
- do not rewrite product code from the supervisor checkout;
- keep early worker tasks small enough to prove concrete behaviors with
  automated unit and integration tests.

## Implementation Direction

The operator approved starting the Bus-owned Go subset as
`bus-agent-runtime`. This module should be open source and Apache-2.0
compatible. It is not a replacement for current upstream Codex integrations;
modules with `codex` in their names remain reserved for the actual OpenAI
Codex product integration.

The initial implementation target is a single Go Bus module that can run as a
worker runtime compatible with the App Server flows Bus uses. It should focus
on local GPU providers and OpenAI API-compatible providers, with no ChatGPT
subscription login/logout or private subscription scraping.

Implementation and proof work should use Bus Workers and worker-owned
worktrees/branches. The supervisor may maintain this goal, project guidance,
and coordination artifacts, but product code should be assigned to workers.

Current implementation dependency:

- Bus direct worker Git preparation in `bus-integration-worker` must become
  non-interactive for local worker dispatch. During the first
  `bus-agent-runtime` follow-up dispatch, direct lifecycle Git commands dropped
  process-level `GIT_TERMINAL_PROMPT`, `GIT_ASKPASS`, `SSH_ASKPASS`, and Git
  URL rewrite environment, then hung on the operator SSH key passphrase before
  publishing worker status. This must be fixed before local Bus Workers can
  reliably materialize the `bus-agent-runtime` implementation worktrees.
- The default local Workers API must publish status through Events with a valid
  service token or refreshed process state. As of 2026-06-07, `bus workers
  list --api-url http://127.0.0.1:8090/local/v1 --environment local-dev`
  returns `publish_failed: publish worker event: events API status 401`, even
  when the CLI uses the local Events token file. This must be repaired before
  the normal `8090` worker path can be used for further runtime dispatch.

Testing environments:

- local supervisor checkout for goal, plan, and narrow coordination updates;
- existing remote Docker/workload host `coding-agent@dev.hg.fi` when the task
  specifically needs that environment;
- Upcloud host `dev@ai.hg.fi` for runtime/provider proof of the actual
  `bus-agent-runtime` codebase against local GPU providers after Bus tools and
  the local services setup are updated there. This host is not the target for
  proving Bus worker orchestration, worker creation, or worker-infrastructure
  repairs.

## Open Questions

- Which App Server request and event surfaces must be byte-for-byte compatible
  in the first `bus-agent-runtime` slice?
- Which local GPU provider stack should be the first required proof on
  `dev@ai.hg.fi`?
- Which skills, memories, web, image, and connector behaviors are currently
  exercised by Bus App Server launch paths and therefore need first-pass
  compatibility?
- How close should `bus-agent-runtime` release cadence stay to upstream Codex
  protocol changes?
- Which Windows sandbox behaviors can remain compile-only stubs in the first
  implementation without blocking Bus worker use?

## Current State At Handoff

The feasibility goal is defined and the first implementation direction is now
`bus-agent-runtime`.

The current evidence says upstream Codex is open source, Apache-2.0 licensed,
and overwhelmingly Rust. A single Bus submodule that wraps upstream Codex is
plausible but creates ongoing fork/build maintenance. A full Go rewrite is a
large product effort. The selected next step is a Bus-owned Go subset in
`bus-agent-runtime`, with current upstream Codex integrations preserved in
Codex-named integration modules.
