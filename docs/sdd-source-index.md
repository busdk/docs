# SDD Source Index

Use this index before changing module boundaries, command ownership,
Events/auth/config behavior, AI-host behavior, provider/runtime architecture,
notes modules, naming, or private/public coupling.

Primary SDD sources live in the BusDK superproject under `sdd/docs/`. Read that
tree for cross-module and product-boundary decisions.

Cross-module architecture starts at
`sdd/docs/architecture/architecture-decision-register.md` and then continues at
`sdd/docs/modules/<module>.md` for each owning module. These are private SDD
source paths, not public-site links. Public goal pages and historical reports
preserve context and evidence; they do not supersede an accepted SDD decision
or prove current implementation status.

Some modules also own local SDD trees under `<module>/sdd/docs/`. Read a
module-local SDD when the change is confined to that module's public behavior,
runtime contract, or migration plan.

For public documentation changes, also read `docs/AGENTS.md` and
`skills/bus-docs-quality/SKILL.md`. If stable architecture exists only in agent
guidance, record the missing contract in the owning module `PLAN.md` or a Bus
Thread addressed to the owning SDD module, then update the private SDD before
implementation. Do not expand root `AGENTS.md` with a second copy of the
product contract.

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
