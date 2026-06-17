# SDD Source Index

Use this index before changing module boundaries, command ownership,
Events/auth/config behavior, AI-host behavior, provider/runtime architecture,
notes modules, naming, or private/public coupling.

Primary SDD sources live in the BusDK superproject under `sdd/docs/`. Read that
tree for cross-module and product-boundary decisions.

Some modules also own local SDD trees under `<module>/sdd/docs/`. Read a
module-local SDD when the change is confined to that module's public behavior,
runtime contract, or migration plan.

For public documentation changes, also read `docs/AGENTS.md` and
`skills/bus-docs-quality/SKILL.md`. If stable architecture exists only in agent
guidance, record an SDD-recipient follow-up instead of expanding root
`AGENTS.md`.

Before adding cross-cutting platform behavior, prefer the existing lower-level
owner over duplicating platform features in product modules. Check whether Bus
Events, Bus Data, Auth, Bus API, worker/task infrastructure, or another
platform layer already owns the needed primitive. This applies to
synchronization, replication, idempotency, cursoring, storage, credentials,
task routing, audit history, metadata, validation, capability discovery,
transport, retries, and status reporting. Feature modules should stay focused
on domain semantics and projections; for example, Bus Notes should consume and
project `bus.notes.*` operations while Events owns append-only history, origin
metadata, replay, relay, and remote synchronization.

Before creating or renaming `bus-*`, provider, integration, or workers modules,
keep product families consistent. `bus-{name}` owns the user-facing product and
CLI, `bus-api-provider-{name}` owns API/controller integration with `bus-api`,
and `bus-integration-{name}` owns event/integration-provider runtime behavior
for the `bus-integration` runner. For workers-related architecture, prefer the
plural family: `bus-workers`, `bus-api-provider-workers`, and
`bus-integration-workers`.
