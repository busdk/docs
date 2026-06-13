# Bus Agent Runtime Workers Goal

## Goal

Make `bus-agent-runtime` available through the `bus workers` toolset as a
first-class LLM agent runtime provider.

This runtime must sit beside the existing Codex worker integrations. It must
not replace `codex-direct`, Codex App Server workers, or any existing Codex
integration module. On self-hosted GPU environments, this Bus-owned runtime
should become the default worker runtime when the environment advertises a
local model provider such as an Ollama or OpenAI-compatible endpoint.

## Current State

`bus-agent-runtime` now has a completed local-provider runtime goal, a prior
H100 validation proof for the runtime module itself, and a `bus workers`
product-path H100 proof on `coding-agent@ai.hg.fi` with `gemma4:31b`.

The bridge between the completed runtime surface and the worker product path is
implemented on the promoted `develop` branches:

- appserver workers can explicitly select either `codex-direct` or
  `bus-agent-runtime`;
- self-hosted local model configuration can default omitted direct provider
  requests to `bus-agent-runtime`;
- `bus workers` create, status, message, logs, attach, and stop have product
  proof coverage for the Bus-owned runtime, and explicit `codex-direct`
  behavior remains covered.

The remaining closeout work is autonomous create-only real-work execution:
`bus workers create` must start `bus-agent-runtime` work from the task body
alone, without a manual `bus workers message`, and the runtime must complete a
real backlog item with verification evidence and a worker-branch commit.

This does not relax the Codex-compatible steering contract. A
`bus-agent-runtime` worker must remain operator/supervisor steerable through
`bus workers message`, with the same user-facing semantics as existing Codex
App Server workers. Create-only autonomous execution is an additional Bus
product path, not a replacement for interactive worker guidance.

## Unit-First Gate

Do not spend H100 time to rediscover runtime/model-loop failures that can be
modeled locally. Every H100 failure pattern that affects autonomous execution
must first be converted into a local fake-provider or hermetic integration
regression in the owning module.

This thread's current acceptance path is local-only. The final H100 proof is a
deferred infrastructure proof, not a prerequisite for closing the local
runtime/workers implementation review. It is allowed only after these local
gates pass on the promoted branches:

- `bus-agent-runtime` fake-provider regressions cover repeated successful
  mutation tools, malformed or redundant shell calls, missing verification
  after dirty worktrees, missing `lifecycle.complete`, and outside-root context
  artifact access.
- `bus-agent-runtime` full automated tests pass, including the focused
  autonomous-loop regressions for the H100 trace shapes.
- `bus-integration-worker` worker create-to-run tests pass for prompt
  hydration, runner projection, and failure evidence projection.
- The BusDK superproject pins the accepted module tips before any remote or
  paid proof is launched.

## Affected Modules

`bus-agent-runtime` should provide the worker-serving runtime surface needed by
the worker lifecycle. This may be a CLI subcommand, a library adapter, or both,
but it must support the App Server-compatible worker protocol surface required
for create, message, status, logs, attach, and stop flows.

`bus-integration-worker` should add a provider-neutral lifecycle implementation
for the Bus-owned runtime. The existing Codex direct lifecycle should remain in
place. Provider selection, launch, status mapping, log/attach routing, stop
behavior, diagnostics, and redaction should be tested for both providers.

`bus-api-provider-worker` should accept, validate, persist, and project the new
runtime provider fields and defaults without making public callers understand
provider-private launch details.

`bus-worker` should expose provider selection and defaults through the CLI in a
way that keeps existing Codex worker commands working.

Worker service profiles under `profiles/bus/workers` or the accepted services
profile boundary should gain a self-hosted GPU profile that defaults to
`bus-agent-runtime` when local model provider configuration is present.

Documentation and help text should describe the Bus-owned runtime scope,
configuration, and boundaries after the product path is implemented.

## Runner Contract

The first implementation should use the existing runner kind/provider contract:

| Runner kind | Runner provider | Purpose |
| --- | --- | --- |
| `direct` | `codex-direct` | Existing Codex App Server direct worker path. |
| `appserver` | `bus-agent-runtime` | New Bus-owned local worker runtime path. |

The `bus-agent-runtime` provider id is intentionally descriptive of the module
boundary. It must not use `codex` in its name because it is not a Codex
integration, and it must not encode a host name, model name, GPU type, account,
token source, or deployment-specific path.

Future container or VM runners remain owned by
`docs/goals/worker-runner-providers.md`. This goal is about making the
Bus-owned runtime usable by the existing workers product path first.

### Request, Status, And CLI Contract

The explicit provider-selection request contract is:

- `runner_kind=appserver`
- `runner_provider=bus-agent-runtime`

`bus workers create` must accept the same fields through CLI flags and API
payloads:

```bash
bus workers create \
  --type agent \
  --profile <profile> \
  --runner-kind appserver \
  --runner-provider bus-agent-runtime \
  --model <local-or-openai-compatible-model> \
  --task-ref <task-ref> \
  --environment <environment-id>
```

The canonical worker create Event payload must carry `runner_kind` and
`runner_provider` as public selection fields. It may carry model/profile/task
metadata, but it must not carry provider-private API keys, token file paths,
raw provider URLs with credentials, host-private filesystem paths, or full
environment dumps.

`bus workers status`, status snapshot Events, and API projections must show the
selected public runner fields:

- `runner_kind`
- `runner_provider`
- `runtime_ref`
- `worktree_ref`
- `logs_ref`
- `worktree_path`
- `logs_path`
- `lifecycle_phase`
- `last_error`

Status output may include sanitized provider/runtime metadata such as provider
kind, model id, non-secret capability labels, or credential-source labels. It
must redact or omit secrets and host-private provider details.

`bus workers message`, `logs`, `attach`, and `stop` must route by worker id and
the persisted runner kind/provider. They must not require the caller to resend
provider-private launch configuration after worker creation.

## Defaulting Behavior

Self-hosted GPU environments should default to:

- `runner_kind=appserver`
- `runner_provider=bus-agent-runtime`

when the worker service can discover valid local model provider configuration.
Examples include an environment capability, service profile value, or
provider-specific configuration for an Ollama or OpenAI-compatible endpoint.

Codex must remain explicitly selectable. A user or scheduler request for
`runner_provider=codex-direct` must continue to launch the existing Codex
worker path and must not inherit Bus-owned runtime defaults.

Unsupported or incomplete provider configuration must fail with bounded,
non-secret diagnostics that name the missing configuration and the selected
runner kind/provider.

The defaulting order is:

1. An explicit request value wins. `runner_provider=codex-direct` always stays
   on the Codex direct lifecycle, and `runner_provider=bus-agent-runtime` always
   selects the Bus-owned runtime lifecycle.
2. If the request omits `runner_kind`, the worker service may default it to
   `direct` only for direct-runtime-capable profiles.
3. If the request omits `runner_provider` and the selected environment
   advertises a complete Bus-owned local provider configuration, self-hosted
   profiles should default to `bus-agent-runtime`.
4. If the request omits `runner_provider` and no complete Bus-owned local
   provider configuration is present, existing Codex-capable profiles retain
   their current `codex-direct` behavior.
5. If both Codex and Bus-owned runtime defaults are possible, the environment
   or service profile must choose one explicitly so scheduler behavior is
   deterministic.

## Dependencies

This goal depends on the completed `bus-agent-runtime` local-provider runtime
goal and its H100 validation proof.

This goal also depends on the accepted worker runner contract in
`docs/goals/workers.md` and the provider expansion rules in
`docs/goals/worker-runner-providers.md`.

The self-hosted default proof depends on a host such as `coding-agent@ai.hg.fi`
running Bus services plus a local GPU model provider. The runtime should
consume that provider; it should not own GPU backend installation as part of
normal worker launch.

If worker infrastructure, token refresh, Events routing, or service launch
bugs are found while implementing this goal, those bugs should be diagnosed to
root cause and fixed or delegated in their owning module. Do not mark this goal
blocked until the failing component, exact error, decisive diagnostic, and
repair path are known.

When a worker-side issue appears only on `bus-agent-runtime`, compare the
exact request, runtime response status, delivery metadata, task reference,
closeout flag, and status snapshot with the existing Codex worker path before
patching integration behavior. If Codex has a compatible runtime feature that
`bus-agent-runtime` lacks, fix the missing runtime feature in
`bus-agent-runtime`; do not hide it with worker-projection special cases.

## Non-Goals

Do not remove, rename, or replace existing Codex worker integrations.

Do not add ChatGPT subscription login, logout, account-limit scraping, or
ChatGPT subscription token handling to this runtime provider.

Do not make `bus-agent-runtime` responsible for starting Ollama, vLLM,
PostgreSQL, Docker, or host GPU services during normal worker launch.

Do not expose API keys, token file paths, full local provider URLs with
credentials, private host paths, or raw environment values in Events, CLI
output, worker status snapshots, logs, docs examples, or proof artifacts.

## Implementation Checklist

### Contract And CLI

- [x] Define the exact `bus workers` request, status, and CLI contract for
  selecting `runner_provider=bus-agent-runtime`.
- [x] Define self-hosted GPU defaulting semantics separately from explicit
  provider selection.
- [x] Update `bus-worker` CLI help, flags, and output so users can explicitly
  select either provider and can see which provider was selected.
- [x] Add or update CLI/API examples for explicit `codex-direct` and
  `bus-agent-runtime` selection after the product path is verified.
  - Evidence, 2026-06-08: `bus-worker` primary `develop` commits `fef9318`
    and `b0a74d8` add README API JSON examples for both providers after the
    local product proofs. The examples use the actual API fields
    `environment_id` and `capability_tags`; help/README grep checks and
    `git diff --check HEAD~2..HEAD` passed in `bus-worker`.

### `bus-agent-runtime`

- [x] Add the worker-serving entrypoint or adapter required by the workers
  lifecycle.
  - Evidence, 2026-06-08: `bus-agent-runtime` primary `develop` commit
    `34d1ec9` passes `make ci` after the lifecycle vet repair; the gate covered
    fmt-check, `go vet`, `go test ./...`, build, e2e, cross-compile, and
    license scan, with Docker integration skipped on this macOS host because
    Docker is not installed. Product proof `runtime-product-proof-20260608e`
    verified the workers lifecycle path for create/status/message/logs/attach
    and stop.
- [x] Gate the adapter with deterministic tests, `git diff --check`, and
  focused `bus lint` on the final promoted `develop` checkout.
- [x] Cover runtime adapter redaction for prompts, metadata, API keys, token
  file labels, provider URLs, and host-private paths.
- [x] Cover runtime storage/checkpoint behavior so snapshots and event streams
  are captured consistently under concurrent updates.
- [x] Cover git helper path handling for normal relative paths, deleted tracked
  paths, path traversal, symlinks, and bounded output.
- [x] Cover shell/process lifecycle behavior for normal completion, timeout,
  cancellation, output drain, and cleanup.

### `bus-integration-worker`

- [x] Add and gate lifecycle session cleanup, replacement, bounded stderr, and
  wait-result safety for `bus-agent-runtime` worker sessions.
- [x] Add and gate command startup hardening so Events replay/hydration and
  scheduler-once paths use bounded contexts and cannot hang indefinitely.
- [x] Add and gate scheduler claim status handling for reopened tasks,
  including `open`, `ready`, and unsupported statuses.
- [x] Add and gate runtime quit goroutine drain/cancel behavior so stop cleanup
  cannot race with late runtime requests.
- [x] Add and gate provider-neutral validation and failure mapping for
  `codex-direct` and `bus-agent-runtime`.
- [x] Add and gate bounded diagnostics/redaction for command flags, token
  sources, service instance ids, worker ids, and runtime metadata.
- [x] Add and gate `bus-agent-runtime` logging and attach routing with the same
  user-facing semantics as existing direct workers.
- [x] Add and gate stop behavior for clean runtime quit, timeout fallback, and
  orphan prevention.

### Service Configuration And Defaults

- [x] Add self-hosted GPU worker service configuration that can select
  `runner_provider=bus-agent-runtime` through a bounded service/profile default
  without embedding secrets or host-private paths in public worker requests.
- [x] Add automatic environment/local-provider discovery so valid local model
  provider configuration can select the Bus-owned runtime default without
  hard-coded host names.
  - Evidence, 2026-06-08: `bus-integration-worker` promoted commits
    `66cde4e` and `947e1df` add hermetic direct default-provider discovery.
    Explicit `BUS_WORKERS_DIRECT_DEFAULT_PROVIDER` still wins; otherwise
    `BUS_AGENT_CODEX_LOCAL_MODEL` or canonical Bus preferences
    `bus-agent.codex_local_model` selects `bus-agent-runtime`; empty config
    remains `codex-direct`; invalid local model ids fail closed. Primary
    checkout gates passed: `go test ./pkg/workersintegration`,
    `go test ./cmd/bus-integration-workers`, `git diff --check HEAD~2..HEAD`,
    and a forbidden-import scan for `bus-agent/agent`/`bus-preferences`.
- [x] Add tests for self-hosted defaulting when configured local provider
  metadata is present.
- [x] Add tests for unsupported or incomplete provider configuration with
  bounded non-secret diagnostics.
- [x] Keep explicit `runner_provider=codex-direct` from inheriting Bus-owned
  runtime defaults.

### Product Proof

- [x] Add product-path proof for `bus workers create` using
  `runner_provider=bus-agent-runtime`.
- [x] Add product-path proof for `bus workers status` showing selected runner
  kind/provider and safe runtime metadata.
- [x] Add product-path proof for `bus workers message` reaching
  `bus-agent-runtime` and returning through the workers path.
- [x] Add product-path proof for `bus workers logs`.
- [x] Add product-path proof for `bus workers attach`.
- [x] Add product-path proof for `bus workers stop`.
  - Evidence, 2026-06-08: after promoting `bus-integration-worker` `c12e7d6`
    and BusDK pointer `1b800c9`, local Services ran worker
    `runtime-product-proof-20260608e` through
    `runner_kind=appserver` / `runner_provider=bus-agent-runtime`. Product CLI
    proof covered `create`, `status`, `message`, `messages`, `logs`, `attach`,
    and `stop`; final status was `stopped` with empty `last_error`.
- [x] Add H100 proof on `coding-agent@ai.hg.fi` with a local GPU model provider
  and record sanitized evidence.
  - [x] Implement provider-backed `bus-agent-runtime` worker messaging so the
    `bus workers message` product path invokes the configured local model and
    returns model-generated text instead of only recording operator guidance.
    Evidence must show provider/model metadata without secrets.
  - Evidence, 2026-06-08: reviewed and promoted `bus-agent-runtime` commit
    `71082ec` and `bus-integration-worker` commit `ec9463c`. The runtime
    lifecycle now exposes provider-backed `message`, and the integration
    lifecycle projects safe provider/model/usage metadata from
    `bus.workers.message.response`. Promoted checks passed: `go test ./...` in
    `bus-agent-runtime`, `go test ./pkg/workersintegration
    ./cmd/bus-integration-workers` in `bus-integration-worker`, and
    `git diff --check` for the affected diffs.
  - Evidence, 2026-06-08: `coding-agent@ai.hg.fi` was synced to BusDK
    `develop` `89fb158` with `bus-agent-runtime` `71082ec`,
    `bus-integration-worker` `30d0318`, and docs `e1846a0`. The host reported
    `NVIDIA H100 80GB HBM3` and Ollama model `gemma4:31b`. A temporary
    memory-backed Services proof stack created worker
    `h100-runtime-proof-20260608a` without explicit `runner_provider`; status
    selected `runner_kind=appserver` / `runner_provider=bus-agent-runtime`.
    `bus workers message` returned text through runtime
    `bus-agent-runtime:h100-runtime-proof-20260608a` with metadata
    `delivery=provider_chat_completion`, `operation=chat_completion`,
    `provider_kind=ollama-compatible`, `provider_name=ollama-compatible`,
    model `gemma4:31b`, and usage request count `1`. The worker stopped cleanly
    with empty `last_error`.
- [x] Keep the existing Codex worker tests and at least one explicit
  `codex-direct` product-path proof passing.
  - Evidence, 2026-06-08: `go test ./...` passed in
    `bus-integration-worker`, and local Services proof worker
    `runtime-codex-direct-proof-20260608a` ran explicitly through
    `runner_kind=direct` / `runner_provider=codex-direct`. Product CLI proof
    covered `create`, `status`, `message`, `messages`, `logs`, `attach`, and
    `stop`; the worker replied `Acknowledged.` and final status was `stopped`
    with empty `last_error`.

### Documentation And Promotion

- [x] Update public docs after implementation so the Bus-owned runtime scope,
  defaults, configuration, and non-goals are clear.
  - Evidence, 2026-06-09: public module docs now cover the Bus-owned runtime
    scope and non-goals in `bus-agent-runtime/README.md`, user-facing
    explicit/defaulted provider workflows in `bus-worker/README.md`, and
    service-level defaulting/configuration knobs in
    `bus-integration-worker/README.md`.
- [x] Promote accepted implementation branches to the relevant module
  `develop` branches.
  - Evidence, 2026-06-08: pushed `develop` for `bus-agent-runtime` at
    `71082ec`, `bus-integration-worker` at `6237595`, docs at `eed7406`,
    and BusDK superproject at `2ba8f4a`.
- [x] Sync the updated branches to the configured development environments.
  - Evidence, 2026-06-09: `coding-agent@ai.hg.fi` is synced to the accepted
    implementation and proof commits, including `bus-agent-runtime` `71082ec`
    and `bus-integration-worker` `6401968`. `coding-agent@dev.hg.fi` became
    reachable again through the configured SSH alias route, was fast-forwarded
    from stale BusDK/module tips to the same accepted `develop` implementation
    commits, and its checked-out submodules were cleaned to the superproject
    pins. The dev host rebuilt and installed the refreshed `bus`,
    `bus-services`, `bus-integration-services`, `bus-worker`,
    `bus-integration-worker`, and `bus-agent-runtime` binaries under
    `/home/coding-agent/coding-agent/.local/bin`; `bus-agent-runtime --version`
    reported commit `71082ec`. The dev Bus Services stack was restarted with
    those binaries and `bus services ps --file services.yml` reported
    `postgres`, `events`, `tasks`, `repos`, `workers`, `api`, and
    `events-relay` running.

## Acceptance Criteria

On a self-hosted GPU environment with valid local model provider configuration,
`bus workers` can create a worker without explicitly selecting Codex and the
resulting worker runs through `bus-agent-runtime`.

The same environment can explicitly request `runner_provider=codex-direct` and
still receive the existing Codex worker behavior.

`bus workers status` exposes provider-neutral lifecycle state plus bounded
runtime metadata, including the selected runner kind/provider and safe model
identity. Secrets and private paths are redacted or omitted.

`bus workers message` can send a task prompt to the Bus-owned runtime and
receive a model response through the workers product path.

`bus workers logs`, `attach`, and `stop` work for the Bus-owned runtime with
the same user-facing semantics as other accepted direct workers.

Automated tests pass in the affected modules, and local fake-provider or
hermetic integration tests demonstrate the `bus-agent-runtime` worker path
without a real H100 system. A later H100 run may be used as an infrastructure
confidence proof, but it must not be used to discover basic runtime/model-loop
bugs that should have local regressions first.
