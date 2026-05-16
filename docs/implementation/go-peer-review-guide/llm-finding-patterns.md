---
title: Go LLM finding patterns
description: Stable finding names and review comment shapes for LLM-assisted BusDK Go review.
---

## Finding Shapes

An automated reviewer should prefer these finding shapes:

- `wrong owner`: behavior lives in a package, module, handler, or CLI layer that does not own the concept.
- `boundary bypass`: code shells out, hardcodes paths, imports internals, or reaches another module through an unstable route.
- `untyped core contract`: known data shapes stay as generic maps, strings, or `any` after boundary parsing.
- `hidden dependency`: code reads environment, globals, time, randomness, network, filesystem, or process data without an explicit boundary.
- `brittle source transform`: parser, formatter, compiler, generator, or linter logic scans text loosely, loses surrounding code shape, writes partial output after diagnostics, or lacks golden and command-surface coverage.
- `unsafe expression evaluator`: user-provided formulas, queries, or rules can perform hidden side effects, panic, run unbounded, overflow silently, or fail without typed source-span diagnostics.
- `implicit data mapping`: import, extract, migration, or carry-forward code guesses column aliases, domain keys, prior-year inputs, or external workspace data instead of requiring explicit mapped configuration.
- `process exit leak`: package or library code calls `os.Exit` instead of returning an error or exit code to `main`.
- `mixed responsibilities`: one function or type combines parsing, validation, mutation, output, and transport concerns.
- `non-deterministic output`: user-visible ordering, diagnostics, IDs, timestamps, or paths can vary without a documented reason.
- `non-reproducible build path`: build flags, module resolution, VCS metadata, or runtime tuning make artifacts or CI evidence vary without justification.
- `non-idempotent workflow`: replay, import, migration, provider-event, or state-transition code lacks stable operation IDs, retry guards, duplicate-event protection, or dry-run no-mutation proof.
- `backend parity gap`: one storage or delivery backend enforces different validation, authorization, ordering, acknowledgement, retry, migration, or export semantics without a documented contract.
- `weak error context`: an error loses the dataset, field, operation, identifier, route, or event type needed to act on it.
- `state transition leak`: canceled, inactive, failed, or unauthorized state can still retain capabilities, entitlements, or publication effects.
- `uncorrelated delegation`: HTTP, CLI, event, queue, or worker code publishes delegated work without stable request/response correlation, caller identity, lifecycle ownership, or provider-neutral boundaries.
- `destructive default`: delete, rename, overwrite, schema removal, or type-change behavior proceeds without explicit policy, compatibility checks, or no-partial-write guarantees.
- `schema clobber`: data or descriptor rewrites drop unknown metadata, reorder fields unexpectedly, or serialize non-canonically.
- `batch preflight gap`: script, replay, migration, or command-file execution starts mutating before validating the full batch, misstates transaction scope, or accidentally interprets shell features.
- `validation bypass`: one mutation path can write data without the same schema and logical checks as the normal path.
- `weak audit identity`: durable records use incidental filenames or mutable metadata instead of stable IDs, canonical paths, hashes, or append-only state changes.
- `auth boundary bypass`: code trusts caller-supplied account identity, boolean admin flags, synthesized tokens, recoverable OTPs, or unrate-limited auth paths.
- `hardcoded security primitive`: signer, verifier, clock, random source, credential store, or rate limiter is baked into core logic instead of sitting behind a replaceable boundary.
- `ambiguous external runner`: runtime or model selection silently chooses a detected tool, renders templates after starting execution, returns untyped failures, or mixes runner mechanics with workflow, Git, provider, or dataset policy.
- `side-effect leak`: files, response bodies, goroutines, subprocesses, locks, or temporary resources have unclear cleanup.
- `request-context write loss`: required billing, audit, usage, cleanup, or publication records depend on a request context that may be canceled after the client response.
- `unsafe service default`: HTTP code uses unbounded JSON decoding, default clients, default muxes, missing server timeouts, or disabled TLS verification.
- `unsafe tool exposure`: generated tools, MCP resources, or metadata endpoints expose write operations, internal topology, sensitive fields, or provider-specific behavior without capability policy, confirmation, and authorization checks.
- `path boundary escape`: workspace, module, artifact, or capability-token path handling can traverse outside its intended root or bypass a read-only, token, or allowlist gate.
- `secret disclosure`: logs, diagnostics, fixtures, examples, or debug output include credentials or security-sensitive payloads.
- `unsafe browser boundary`: rendering or WASM code reaches browser globals directly, accepts unsafe URLs, serializes callbacks/secrets into markup, skips escaping, or exposes unredacted runtime diagnostics.
- `raw provider UI`: renderers consume provider DTOs, raw provider errors, or authorization policy directly instead of receiving a projected safe view model.
- `inaccessible rendered output`: generated or server-rendered UI lacks accessible names, labels, text status, table headers, safe external-link attributes, or sanitizer-backed rich text handling.
- `missing contract test`: changed behavior lacks direct unit coverage or user-visible end-to-end coverage.
- `weak test harness`: tests are noisy on success, locale-sensitive by accident, sleep-based, order-dependent, or repeatedly compile helpers instead of using the normal build path.
- `performance trap`: a hot path repeats parsing, regex compilation, dataset scans, allocation-heavy row hydration, or client construction.
- `stale contract docs`: docs, help, examples, or comments describe a different behavior than the implementation.

Each finding should include a concrete improvement. For example, "move this
validation into the library and call it from both CLI and API paths", "normalize
the decoded map into a typed struct before domain logic", "sort by stable
identifier before rendering", or "inject a clock so tests can assert
deterministic timestamps".

A useful automated finding should read like this:

```text
wrong owner: cmd/bus-invoice/create.go validates invoice balance in the HTTP
handler. Move the balance check into the invoice package and call it from both
CLI and API paths so every mutation path enforces the same invariant.
```

Avoid vague findings such as "make this cleaner" or "refactor this function".
They do not tell the developer what behavior is at risk.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./documentation-and-traceability">Documentation and traceability</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./compact-checklist">Compact checklist</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Go peer review guide](../go-peer-review-guide)
- [Testing strategy](../../testing/testing-strategy)
- [Error handling, dry-run, and diagnostics](../../cli/error-handling-dry-run-diagnostics)
