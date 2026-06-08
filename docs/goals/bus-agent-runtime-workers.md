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

`bus-agent-runtime` now has a completed local-provider runtime goal and H100
validation proof, including a local GPU provider proof with `gemma4:31b`.

The current `bus workers` service path is still Codex-specific:

- the direct worker profile uses Codex App Server configuration;
- `bus-integration-worker` owns Codex-specific direct lifecycle launch,
  messaging, model/profile fields, and status projection;
- the current `bus-agent-runtime` CLI is a packaged runtime entrypoint, but it
  is not yet a worker-serving entrypoint that `bus workers` can launch and
  supervise as a runtime provider.

This goal owns the bridge between those two completed surfaces.

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
| `direct` | `bus-agent-runtime` | New Bus-owned local worker runtime path. |

The `bus-agent-runtime` provider id is intentionally descriptive of the module
boundary. It must not use `codex` in its name because it is not a Codex
integration, and it must not encode a host name, model name, GPU type, account,
token source, or deployment-specific path.

Future container or VM runners remain owned by
`docs/goals/worker-runner-providers.md`. This goal is about making the
Bus-owned runtime usable by the existing workers product path first.

### Request, Status, And CLI Contract

The explicit provider-selection request contract is:

- `runner_kind=direct`
- `runner_provider=bus-agent-runtime`

`bus workers create` must accept the same fields through CLI flags and API
payloads:

```bash
bus workers create \
  --type agent \
  --profile <profile> \
  --runner-kind direct \
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

- `runner_kind=direct`
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
- [ ] Add or update CLI/API examples for explicit `codex-direct` and
  `bus-agent-runtime` selection after the product path is verified.

### `bus-agent-runtime`

- [ ] Add the worker-serving entrypoint or adapter required by the workers
  lifecycle.
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
- [ ] Add and gate provider-neutral validation and failure mapping for
  `codex-direct` and `bus-agent-runtime`.
- [ ] Add and gate bounded diagnostics/redaction for command flags, token
  sources, service instance ids, worker ids, and runtime metadata.
- [ ] Add and gate `bus-agent-runtime` logging and attach routing with the same
  user-facing semantics as existing direct workers.
- [ ] Add and gate stop behavior for clean runtime quit, timeout fallback, and
  orphan prevention.

### Service Configuration And Defaults

- [ ] Add self-hosted GPU worker service configuration that can select the
  local model provider without embedding secrets or host-private paths in
  public worker requests.
- [ ] Add tests for self-hosted defaulting when valid local model provider
  configuration is present.
- [ ] Add tests for unsupported or incomplete provider configuration with
  bounded non-secret diagnostics.
- [ ] Keep explicit `runner_provider=codex-direct` from inheriting Bus-owned
  runtime defaults.

### Product Proof

- [ ] Add product-path proof for `bus workers create` using
  `runner_provider=bus-agent-runtime`.
- [ ] Add product-path proof for `bus workers status` showing selected runner
  kind/provider and safe runtime metadata.
- [ ] Add product-path proof for `bus workers message` reaching
  `bus-agent-runtime` and returning through the workers path.
- [ ] Add product-path proof for `bus workers logs`.
- [ ] Add product-path proof for `bus workers attach`.
- [ ] Add product-path proof for `bus workers stop`.
- [ ] Add H100 proof on `coding-agent@ai.hg.fi` with a local GPU model provider
  and record sanitized evidence.
- [ ] Keep the existing Codex worker tests and at least one explicit
  `codex-direct` product-path proof passing.

### Documentation And Promotion

- [ ] Update public docs after implementation so the Bus-owned runtime scope,
  defaults, configuration, and non-goals are clear.
- [ ] Promote accepted implementation branches to the relevant module
  `develop` branches.
- [ ] Sync the updated branches to the configured development environments.

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

Automated tests pass in the affected modules, and the H100 product-path proof
demonstrates a local GPU model worker running through `bus-agent-runtime`.
