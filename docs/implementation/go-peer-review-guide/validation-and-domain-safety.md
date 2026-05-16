---
title: Go validation and domain safety review
description: Review schema validation, logical invariants, audit identity, exact quantities, and authorization coverage.
---

## Validation Ownership

Validation should be centralized around the owned contract. Schema validation
checks shape, required fields, types, keys, and referential integrity. Logical
validation enforces domain invariants such as balanced entries, allowed period
state, idempotency, authorization scope, or append-only audit rules.

A review should flag duplicated validators with different behavior, validation
that happens only in the CLI but not the library, or mutation paths that bypass
validation.

Audit, evidence, and other durable records need stable identity. Prefer stable
IDs, canonical path forms, content hashes where integrity matters, immutable
metadata for captured artifacts, and append-only or soft-delete workflows when
history is part of the contract. Reviewers should flag code that links durable
records by incidental filenames, rewrites audit metadata casually, or removes
historical evidence instead of recording an explicit state change.

## Exact Quantities and Authorization Matrices

Money and other exact business quantities must not use `float32` or `float64`.
Use decimal-safe representations such as scaled integers, exact decimals, or
rational values according to the module contract. Reviewers should also watch
for lossy string formatting, implicit timezone conversion, and parsing that
accepts ambiguous dates or amounts without a documented rule.

Bad:

```go
total := 0.0
for _, line := range lines {
	total += line.Price * float64(line.Quantity)
}
```

Better:

```go
var total cents.Amount
for _, line := range lines {
	total = total.Add(line.Price.Mul(line.Quantity))
}
```

The better version uses an exact domain type, so rounding rules are explicit.

Security and access-control checks should be matrix-based, not one happy path.
Protected APIs need coverage for no credential, malformed or wrong-audience
credential where relevant, valid credential with insufficient scope, and valid
credential with the exact required scope. A review should reject code that
treats "any valid token" as sufficient for a protected endpoint family.

Example test shape:

```go
tests := []struct {
	name  string
	token string
	want  int
}{
	{"no token", "", http.StatusUnauthorized},
	{"wrong scope", tokenWith("events:read"), http.StatusForbidden},
	{"required scope", tokenWith("billing:write"), http.StatusAccepted},
}
```

The important part is the matrix. A single happy-path token does not prove
authorization.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./browser-and-ui-boundaries">Browser and UI boundaries</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./authentication-and-credentials">Authentication and credentials</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Shared validation layer](../../architecture/shared-validation-layer)
- [Append-only and security](../../architecture/append-only-and-security)
- [LLM finding patterns](./llm-finding-patterns)
