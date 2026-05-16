---
title: Go peer review guide
description: Human review criteria for Go source code that complement normal formatters, static analyzers, and linters.
---

## Overview

Good Go code in BusDK should be easy to understand, easy to test, and hard to
misuse. A peer review should therefore look past formatting and obvious
static-analysis findings. It should ask whether the code has the right owner,
whether behavior is expressed through clear package boundaries, whether
failures are deterministic, and whether tests prove the actual user-visible
contract.

This guide is organized as small review pages that can also become source
material for LLM-assisted linting. A finding should name the code location,
explain why the current shape is risky, and suggest the smallest design
improvement that would make the code clearer or safer.

## Review Pages

[Review order](./go-peer-review-guide/review-order) explains how to start with
the product boundary, then move through public contracts, package design,
implementation details, tests, and documentation.

[Ownership and architecture](./go-peer-review-guide/ownership-and-architecture)
covers package responsibility, command boundaries, `os.Exit`, module ownership,
and predictable layering.

[API and type design](./go-peer-review-guide/api-and-type-design) covers typed
contracts, intentional exported surfaces, explicit dependencies, and interface
ownership.

[Source transforms and evaluators](./go-peer-review-guide/source-transforms-and-evaluators)
covers parsers, formatters, compilers, generators, linters, expression
evaluators, and safe evaluation limits.

[Data mapping](./go-peer-review-guide/data-mapping) covers import, extraction,
alias, profile, prior-year, and external workspace mapping rules.

[Control flow and mutation](./go-peer-review-guide/control-flow-and-mutation)
covers readable main paths, meaningful helper extraction, staged validation,
deterministic writes, and no-partial-write behavior.

[Destructive and batch operations](./go-peer-review-guide/destructive-and-batch-operations)
covers delete, rename, overwrite, schema changes, batch preflight, trace modes,
and command-file execution.

[Errors and CLI diagnostics](./go-peer-review-guide/errors-and-cli-diagnostics)
covers ordinary errors, panic boundaries, stable diagnostic context, stdout and
stderr separation, fixed text output, and coupled flag surfaces.

[Context, resources, and concurrency](./go-peer-review-guide/context-resources-and-concurrency)
covers `context.Context`, resource lifetimes, post-response obligations,
goroutine ownership, queues, timers, and tickers.

[Determinism and side effects](./go-peer-review-guide/determinism-and-side-effects)
covers stable output, reproducible build settings, subprocess argument lists,
localized environment reads, portability assumptions, and side-effect
boundaries.

[Workflows and backends](./go-peer-review-guide/workflows-and-backends) covers
backend parity, storage policy ownership, workflow idempotency, state
transitions, delegation, and correlation identifiers.

[HTTP and service boundaries](./go-peer-review-guide/http-and-service-boundaries)
covers bounded request decoding, explicit servers and clients, workspace path
boundaries, capability endpoints, TLS shortcuts, and sensitive logging.

[Browser and UI boundaries](./go-peer-review-guide/browser-and-ui-boundaries)
covers browser-adjacent Go, renderer safety, safe URLs, escaped markup,
projected view models, and accessible rendered output.

[Validation and domain safety](./go-peer-review-guide/validation-and-domain-safety)
covers schema and logical validation, durable audit identity, exact business
quantities, and authorization test matrices.

[Authentication and credentials](./go-peer-review-guide/authentication-and-credentials)
covers OTPs, refresh tokens, account identity, credential clients, replaceable
security primitives, and internal-token boundaries.

[External runners](./go-peer-review-guide/external-runners) covers runtime
selection, model choice, timeouts, sandbox policy, prompt rendering, and typed
runner outcomes.

[Performance review](./go-peer-review-guide/performance-review) covers measured
hot paths, repeated work, cache scope, streaming, pooling, `unsafe`, and
benchmark shape.

[Tests and evidence](./go-peer-review-guide/tests-and-evidence) covers unit
tests, end-to-end tests, regression coverage, deterministic harnesses, and
quality evidence.

[Documentation and traceability](./go-peer-review-guide/documentation-and-traceability)
covers code comments, help text, README material, module docs, public
references, and invariant comments.

[LLM finding patterns](./go-peer-review-guide/llm-finding-patterns) preserves
the compact rule names and finding shape for future automated Go review.

[Compact checklist](./go-peer-review-guide/compact-checklist) gives the final
approval checklist for reviewers.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./developer-module-workflow">Developer module workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./go-peer-review-guide/review-order">Review order</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Testing strategy](../testing/testing-strategy)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Independent modules](../architecture/independent-modules)
- [Shared validation layer](../architecture/shared-validation-layer)
- [Module CLI reference index](../modules/)
