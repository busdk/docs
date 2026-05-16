---
title: Go tests and evidence review
description: Review unit tests, end-to-end tests, regression coverage, deterministic harnesses, and repository quality evidence.
---

## Coverage Shape

Every production behavior change needs automated tests. Unit tests should prove
the library or package behavior directly. End-to-end tests should prove the
command, service, browser, or integration surface that users or automation
actually exercise. Bug fixes need a reproducing test for the defect path and a
protecting test for the user-visible failure.

Example review comment:

> The unit test proves `ParsePlan` rejects duplicate IDs, but the CLI still
> needs an e2e test showing `bus plan apply` exits non-zero and writes the
> diagnostic to stderr. Otherwise the user-visible contract is not protected.

This kind of comment is specific: it says which layer is already covered and
which layer is missing.

Prefer test-first or tight test-and-code lockstep for behavior changes. During
review, a regression fix without a failing test that would have caught the
defect is incomplete even if the patch looks correct.

## Harness Quality

Good tests are deterministic, isolated, and specific about the contract. They
assert exit codes, stdout, stderr, response bodies, events, generated files, and
repository data where those are part of behavior. They should avoid external
network services and shared mutable data. When a strictly local host capability
is optional, tests should probe it and skip with a precise reason rather than
failing with an unrelated low-level error.

End-to-end suites should be quiet on success and detailed on failure.
User-facing formatted output tests should pin locale or be explicitly
locale-tolerant. If an e2e suite needs helper binaries, build them once through
the module's normal build path instead of repeatedly paying `go run`
compilation inside the suite.

A review should flag tests that only check "no error", depend on test execution
order, use sleeps instead of synchronization, rely on the developer's machine
state, or exercise only the CLI when the core behavior would be easier to prove
through a package test. It should also flag code that is hard to test, because
that usually means dependencies are hidden or responsibilities are mixed.

Quality evidence should include the repository's normal gates, not only a local
package run. For Go changes, review whether formatting, vet/lint, security
checks, race tests where relevant, fuzz tests for parsers or security-sensitive
input, benchmarks for measured paths, module e2e, and root integration gates
were run or intentionally scoped.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./performance-review">Performance review</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./documentation-and-traceability">Documentation and traceability</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Testing strategy](../../testing/testing-strategy)
- [Error handling, dry-run, and diagnostics](../../cli/error-handling-dry-run-diagnostics)
- [LLM finding patterns](./llm-finding-patterns)
