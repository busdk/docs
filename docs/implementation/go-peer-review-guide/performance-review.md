---
title: Go performance review
description: Review measured hot paths, repeated work, cache scope, streaming, pooling, unsafe, and benchmark shape.
---

## Hot Paths and Repeated Work

Performance review starts with clarity and measurement. Do not request
cleverness because code looks simple. Do flag obvious repeated work in measured
or likely hot paths: compiling the same regexp inside a row loop, reparsing a
whole dataset for every lookup, rebuilding row maps when indexed access would
be clearer, creating HTTP clients per request, or allocating temporary
structures whose size is known.

Bad:

```go
for _, row := range rows {
	if regexp.MustCompile(`^[A-Z0-9]+$`).MatchString(row.Code) {
		out = append(out, row)
	}
}
```

Better:

```go
var codeRE = regexp.MustCompile(`^[A-Z0-9]+$`)

for _, row := range rows {
	if codeRE.MatchString(row.Code) {
		out = append(out, row)
	}
}
```

This is worth flagging when the loop is on a hot path or the input can be
large. For subtle changes, ask for a benchmark instead of guessing.

## Optimization Evidence

Optimization should preserve behavior first. A good performance finding states
the repeated work, the expected scope of a cache or precomputed value, and the
invariants that must not change. Avoid global caches across workspaces unless
invalidation and ownership are obvious. Prefer per-schema, per-command,
per-request, or per-validation-pass state when that matches the data lifetime.

Prefer streaming over full read-all patterns when full materialization is
unnecessary. Buffer small repeated writes, avoid reflection or caller/stack
capture in hot paths, reset pooled objects before reuse, and avoid `unsafe`
unless measurement clearly justifies the risk.

Benchmarks should measure the hot path, not fixture setup. Review benchmark
code for timers around setup and teardown, stable inputs, allocation reporting
when relevant, and names that explain the compared shapes.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./external-runners">External runners</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./tests-and-evidence">Tests and evidence</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Go optimization guide](../go-optimization-guide)
- [Testing strategy](../../testing/testing-strategy)
- [LLM finding patterns](./llm-finding-patterns)
