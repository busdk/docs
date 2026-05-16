---
title: Go workflow and backend review
description: Review backend parity, storage policy ownership, idempotency, state transitions, delegation, and correlation identifiers.
---

## Backend Parity

When code supports multiple storage or delivery backends, review semantic
parity across every supported mode. Filesystem, PCSV, SQL, memory, Redis,
PostgreSQL, broadcast, and work-queue paths should preserve the same logical
contract unless a difference is explicitly documented. Security filtering,
account isolation, ordering, acknowledgement, retry, dead-letter, schema
validation, and canonical export/import behavior must not exist only on the
easiest backend.

Storage and event backends should keep mechanical concerns separate from domain
policy. A backend may persist deterministic tables, schemas, events, cursors,
and operational state, but domain modules still own business rules,
destructive-change policy, and user-facing invariants. Schema evolution and
migrations should be transparent, versioned, and reviewable rather than hidden
in ad hoc compatibility code.

## Idempotent Workflows

Stateful workflows need idempotency review. Replay logs, import plans, provider
events, and migration steps should have stable operation identifiers, explicit
guards or idempotency keys, deterministic ordering, and clear applied, skipped,
and failed outcomes. Dry-run paths must not mutate state.

A review should flag workflow code that cannot safely retry after partial
failure, treats duplicate external events as new work, or lets inactive,
canceled, or failed states retain privileges such as paid entitlements.

Event-backed and delegated operations need correlation review. When an HTTP
provider or CLI delegates work through events, queues, workers, or runtime
integrations, the request and response should carry stable correlation
identifiers, caller or account identity should be derived from verified
context, and lifecycle ownership should be clear. Reviewers should flag code
that publishes work without a way to match the response, exposes internal
runner controls through end-user routes, or lets provider-specific runtime
details leak into a provider-neutral API layer.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./determinism-and-side-effects">Determinism and side effects</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./http-and-service-boundaries">HTTP and service boundaries</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Storage backends](../../data/storage-backends)
- [Schema evolution and migration](../../data/schema-evolution-and-migration)
- [LLM finding patterns](./llm-finding-patterns)
