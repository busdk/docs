---
title: Go peer review guide
description: Human review criteria for Go source code that complement normal formatters, static analyzers, and linters.
---

## Go peer review guide

Good Go code in BusDK should be easy to understand, easy to test, and hard to misuse. A peer review should therefore look past formatting and obvious static-analysis findings. It should ask whether the code has the right owner, whether behavior is expressed through clear package boundaries, whether failures are deterministic, and whether the tests prove the actual user-visible contract.

This guide is written so the same checks can later become prompts or rules for an LLM-assisted review tool. A finding should name the code location, explain why the current shape is risky, and suggest the smallest design improvement that would make the code clearer or safer.

## Review Order

Start with the intended product boundary before reading individual functions. Identify the module, package, command, service endpoint, or runtime layer that owns the behavior. Then review the public contract, the package design, the implementation details, and finally the tests and documentation. Code that is locally tidy can still be wrong when it puts behavior in the wrong module, duplicates a data contract, or hides domain logic inside a presentation layer.

Prefer concrete findings over taste. A good review comment says what behavior becomes harder to prove, maintain, or extend. Avoid asking for abstraction only because a function is long, or for inlining only because a helper is small. The question is whether the current shape makes the next correct change obvious.

## Ownership and Architecture

Each package should have one clear responsibility. A command entrypoint should parse arguments, wire dependencies, and render output; it should not own validation, domain rules, storage mutation, or business workflow. A service handler should translate HTTP or event input into typed calls; it should not become the only place where invariants are enforced. Library packages should expose structured behavior that can be unit-tested without shelling out, opening the full CLI, or requiring a live external service.

Look for code that crosses ownership boundaries for convenience. BusDK modules integrate through documented datasets, schemas, shared mechanical libraries, and explicit API/provider boundaries. They should not call another `bus-*` CLI for core behavior, hardcode another module's data paths when a path accessor exists, or duplicate business logic owned by another module. A review should flag code whose imports, file access, or runtime calls make a module depend on another module's internals.

Layering should be predictable. Lower layers provide primitives and contracts; higher layers compose them. If two packages both validate the same rule, both choose storage paths, or both translate the same event shape, there is probably a missing owner. Suggest moving the rule to the package that owns the concept and keeping other packages as callers.

## API and Type Design

Prefer typed data over stringly contracts once a shape is known. Boundary code may decode JSON, CLI flags, CSV rows, or event payloads from loose input, but it should normalize that input into typed internal values before domain logic runs. Repeated `map[string]any`, `map[string]string`, raw string switches, or unstructured option bags inside core logic are review signals that the real contract is not visible in the type system.

Keep exported surface area intentional. Exported identifiers need clear names, comments, and stable semantics. Internal helpers should stay unexported until another package truly needs them. Interfaces are valuable when they express a real boundary such as storage, clock, process execution, HTTP transport, validation, or event delivery. An interface that only mirrors one concrete type in the same package usually adds indirection without ownership clarity.

Constructors and functions should make dependencies explicit. Hidden reads from environment variables, mutable package globals, implicit default clients, or background initialization make tests and reviews less reliable. When process-global behavior is truly required, isolate it at the boundary and pass explicit values into the rest of the code.

## Control Flow and Readability

Review whether a reader can follow the main path without holding too much state in memory. Deep nesting, long functions that mix parsing, validation, mutation, and output, boolean parameters whose meaning is unclear at the call site, and helpers named after implementation details are signs that responsibilities are tangled.

Split code when the split names a real concept. Good helper extraction makes invariants, error paths, or side effects easier to see. Bad helper extraction hides simple code behind vague names such as `handle`, `process`, `doThing`, or `runInternal`. A review should prefer small, meaningful units over both giant functions and ornamental abstraction.

Data mutation should be visibly staged. For commands that change repository data, reviewers should be able to see validation before mutation, deterministic ordering before write, and rollback or no-partial-write behavior on failure. If a function writes as it validates, or appends data before all preconditions are known, flag it.

## Errors and Diagnostics

Expected failures should return errors, not panic. Panic is appropriate only for programmer errors or impossible states where continuing would hide corruption. User input, missing files, validation failures, bad flags, denied permissions, unavailable local services, and malformed external payloads are ordinary errors.

Errors should carry enough context for the caller to produce deterministic diagnostics. Review error messages for stable identifiers: dataset, field, primary key, command, route, event type, or workspace-relative path. Avoid diagnostics that depend only on incidental row numbers, temporary absolute paths, map iteration order, or host-specific wording when a stable domain identifier is available.

CLI behavior is part of the API. Normal results go to stdout or `--output`; diagnostics, warnings, and errors go to stderr. Invalid usage should be distinguishable from runtime failure. Help and version output should be deterministic. A review should flag code that mixes human diagnostics into structured output or hides failure detail behind a generic `failed` message.

## Context, Resources, and Concurrency

Cancelable work should accept and pass `context.Context`. This includes HTTP calls, event listeners, long-running validation, subprocesses, server loops, and work that may block on I/O. Do not store ordinary business values in context; pass them as typed parameters.

Resource ownership must be visible. Files, response bodies, locks, temporary directories, subprocess handles, tickers, and goroutines need clear lifetime management. Reviewers should look for cleanup immediately after successful acquisition, response bodies that are drained and closed when reuse matters, goroutines with cancellation paths, and channels with an obvious owner.

Concurrency should make state ownership explicit. Shared mutable state should have clear synchronization. Background work should report errors or have an intentional failure policy. A goroutine launched from a request, command, or test without a stop path is a review finding unless the surrounding lifecycle proves it cannot leak.

## Determinism and Side Effects

For the same inputs and environment, code should produce the same outputs. Review map iteration used for user-visible ordering, timestamps created without injection in testable logic, random identifiers without deterministic seeds where repeatability matters, and diagnostics that depend on local absolute paths.

Network, Git, Docker, browser, and filesystem side effects should be explicit parts of the command or test contract. Core library code should not unexpectedly shell out, mutate unrelated files, read global configuration, or reach the network. If such behavior is required, it belongs behind a small boundary that tests can replace.

Do not hide portability assumptions. Code that depends on Unix-only syscall shapes, localhost reachability from containers, executable architecture, filesystem case behavior, shell quoting, or platform-specific paths needs a portability review. The improvement is usually to use a standard library abstraction, isolate the platform-specific piece, or add a deterministic capability probe and skip path in tests.

## Validation and Domain Safety

Validation should be centralized around the owned contract. Schema validation checks shape, required fields, types, keys, and referential integrity. Logical validation enforces domain invariants such as balanced entries, allowed period state, idempotency, authorization scope, or append-only audit rules. A review should flag duplicated validators with different behavior, validation that happens only in the CLI but not the library, or mutation paths that bypass validation.

Money and other exact business quantities must not use `float32` or `float64`. Use decimal-safe representations such as scaled integers, exact decimals, or rational values according to the module contract. Reviewers should also watch for lossy string formatting, implicit timezone conversion, and parsing that accepts ambiguous dates or amounts without a documented rule.

Security and access-control checks should be matrix-based, not one happy path. Protected APIs need coverage for no credential, malformed or wrong-audience credential where relevant, valid credential with insufficient scope, and valid credential with the exact required scope. A review should reject code that treats "any valid token" as sufficient for a protected endpoint family.

## Performance Review

Performance review starts with clarity and measurement. Do not request cleverness because code looks simple. Do flag obvious repeated work in measured or likely hot paths: compiling the same regexp inside a row loop, reparsing a whole dataset for every lookup, rebuilding row maps when indexed access would be clearer, creating HTTP clients per request, or allocating temporary structures whose size is known.

Optimization should preserve behavior first. A good performance finding states the repeated work, the expected scope of a cache or precomputed value, and the invariants that must not change. Avoid global caches across workspaces unless invalidation and ownership are obvious. Prefer per-schema, per-command, per-request, or per-validation-pass state when that matches the data lifetime.

Benchmarks should measure the hot path, not fixture setup. Review benchmark code for timers around setup and teardown, stable inputs, allocation reporting when relevant, and names that explain the compared shapes.

## Tests and Evidence

Every production behavior change needs automated tests. Unit tests should prove the library or package behavior directly. End-to-end tests should prove the command, service, browser, or integration surface that users or automation actually exercise. Bug fixes need a reproducing test for the defect path and a protecting test for the user-visible failure.

Good tests are deterministic, isolated, and specific about the contract. They assert exit codes, stdout, stderr, response bodies, events, generated files, and repository state where those are part of behavior. They should avoid external network services and shared mutable state. When a strictly local host capability is optional, tests should probe it and skip with a precise reason rather than failing with an unrelated low-level error.

A review should flag tests that only check "no error", depend on test execution order, use sleeps instead of synchronization, rely on the developer's machine state, or exercise only the CLI when the core behavior would be easier to prove through a package test. It should also flag code that is hard to test, because that usually means dependencies are hidden or responsibilities are mixed.

## Documentation and Traceability

Behavior changes need matching documentation. Review code comments, help text, README material, module docs, and public reference pages when the change alters user-visible behavior, CLI flags, API responses, validation rules, file formats, or architecture boundaries. Documentation can be concise, but it must not describe a shape the code no longer has.

Comments should preserve intent and invariants. They should explain ownership, safety constraints, non-obvious ordering, compatibility requirements, or why a simpler-looking change would be wrong. Comments that restate syntax should be removed or replaced with a better name.

## Finding Patterns for LLM Review

An automated reviewer should prefer these finding shapes:

- `wrong owner`: behavior lives in a package, module, handler, or CLI layer that does not own the concept.
- `boundary bypass`: code shells out, hardcodes paths, imports internals, or reaches another module through an unstable route.
- `untyped core contract`: known data shapes stay as generic maps, strings, or `any` after boundary parsing.
- `hidden dependency`: code reads environment, globals, time, randomness, network, filesystem, or process state without an explicit boundary.
- `mixed responsibilities`: one function or type combines parsing, validation, mutation, output, and transport concerns.
- `non-deterministic output`: user-visible ordering, diagnostics, IDs, timestamps, or paths can vary without a documented reason.
- `weak error context`: an error loses the dataset, field, operation, identifier, route, or event type needed to act on it.
- `validation bypass`: one mutation path can write data without the same schema and logical checks as the normal path.
- `side-effect leak`: files, response bodies, goroutines, subprocesses, locks, or temporary resources have unclear cleanup.
- `missing contract test`: changed behavior lacks direct unit coverage or user-visible end-to-end coverage.
- `performance trap`: a hot path repeats parsing, regex compilation, dataset scans, allocation-heavy row hydration, or client construction.
- `stale contract docs`: docs, help, examples, or comments describe a different behavior than the implementation.

Each finding should include a concrete improvement. For example, "move this validation into the library and call it from both CLI and API paths", "normalize the decoded map into a typed struct before domain logic", "sort by stable identifier before rendering", or "inject a clock so tests can assert deterministic timestamps".

## Compact Checklist

Before approving Go code, confirm that the owner and layer are right, the public contract is typed and small, errors are explicit and deterministic, side effects are visible, resources have lifetimes, validation happens before mutation, tests prove both package behavior and user-visible behavior, and documentation matches the code. If any of those are unclear, the review is not done.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./developer-module-workflow">Developer module workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./go-optimization-guide">Go optimization guide</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Testing strategy](../testing/testing-strategy)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Independent modules](../architecture/independent-modules)
- [Shared validation layer](../architecture/shared-validation-layer)
- [Module CLI reference index](../modules/)
