# Worker Runner Providers Goal

## Goal

Add worker runner providers beyond the accepted local `direct` /
`codex-direct` runner without refactoring the workers product, API provider,
Events contract, task modules, or scheduler callers.

The accepted `docs/goals/workers.md` goal covers only local native
Services and local sandboxed Codex Spark workers. This goal owns future worker
runtime expansion, especially:

- Codex workers running inside containers through Docker, Podman, or a future
  stable container integration boundary;
- Codex workers running directly inside VMs through the VM platform boundary.

The Bus-owned `bus-agent-runtime` provider is tracked separately in
`docs/goals/codex-fork.md`. That goal covers the Bus-owned Go implementation
of the headless Codex App Server worker-runtime surface for self-hosted and
OpenAI API-compatible environments, not a container or VM runner and not a
Codex product replacement.

## Scope

`bus-integration-workers` remains the worker lifecycle integration owner. It
should select runner providers through the existing runner kind/provider
interface or registry. Public callers should continue to use canonical worker
requests, status snapshots, lifecycle phases, `runner_kind`, `runner_provider`,
and bounded non-secret metadata.

Container-specific mechanics belong behind `bus-integration-containers` or an
equivalent stable container integration interface. Worker callers must not learn
Docker or Podman flags, mount policy, image pull behavior, network details, or
container lifecycle internals.

VM-specific mechanics belong behind `bus-vm`, `bus-api-provider-vm`, or the
future accepted VM integration boundary. Worker callers must not require VM
image, boot, snapshot, or connection fields until a VM runner provider exists
and owns those details.

## Dependencies

The direct local Spark worker path is already accepted and should be treated as
the compatibility baseline. This goal depends on the provider interface and
status contract from `docs/goals/workers.md`, but it should not reopen the
accepted direct-runner MVP.

Container-backed workers depend on a stable container lifecycle boundary with
safe configuration, redaction, and lifecycle evidence. VM-backed workers depend
on a stable VM lifecycle boundary. If either boundary is not ready, this goal
should add that missing work to the owning container or VM goal/module plan
rather than embedding private mechanics in worker callers.

Remote operation is not required for the first container or VM runner proof. If
the runner proof involves multiple environments, Events relay and environment
coordination are owned by
`docs/goals/service-owned-events-relay.md` and
`docs/goals/multi-environment-task-worker-refactor.md`.

## Required Behavior

Runner kind/provider allocation:

| Runner kind | Provider examples | Status |
| --- | --- | --- |
| `direct` | `codex-direct` | Accepted in the local workers MVP. |
| `container` | `docker`, `podman`, future container provider ids | Future scope owned by this goal. |
| `vm` | future VM provider ids | Future scope owned by this goal. |

New provider ids should be stable, lowercase, non-secret identifiers. They
should name the provider boundary, not a private image, host, account, token
source, or deployment-specific path.

A new runner provider should be accepted only when:

- the provider is selected through canonical `runner_kind` and
  `runner_provider` request fields;
- unsupported runner/provider pairs fail with bounded non-secret diagnostics;
- the worker API, Events, task modules, and scheduler callers do not need
  provider-specific fields or code paths;
- provider-private options are read from provider configuration or capability
  metadata, not from every worker caller;
- status snapshots expose provider-neutral lifecycle and runtime evidence plus
  only bounded, non-secret provider metadata;
- logs/attach/status/message behavior remains available through the workers
  product path;
- secret values, token files, container environment values, VM credentials, and
  private host paths are not exposed in Events, CLI text output, logs, or
  README examples.

## Acceptance Criteria

For a container-backed Codex runner, acceptance requires a product-path proof
that creates, observes, guides, and stops a Codex worker through
`bus workers ...`, while the container lifecycle is delegated to the container
integration boundary. The proof must show that worker callers do not construct
Docker/Podman policy directly.

For a VM-backed Codex runner, acceptance requires a product-path proof that
creates, observes, guides, and stops a Codex worker through `bus workers ...`,
while VM lifecycle is delegated to the VM boundary. The proof must show that VM
fields are not required for the direct or container worker paths.

Each provider needs focused unit tests for selection, lifecycle mapping,
failure mapping, redaction, and capability/status metadata, plus an integration
or e2e proof for create/message/status/logs/attach/stop through the existing
workers API and Events contract.
