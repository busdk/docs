---
title: Go API and type design review
description: Review typed contracts, exported surface area, explicit dependencies, and interface ownership in BusDK Go code.
---

## Typed Contracts

Prefer typed data over stringly contracts once a shape is known. Boundary code
may decode JSON, CLI flags, CSV rows, or event payloads from loose input, but it
should normalize that input into typed internal values before domain logic runs.
Repeated `map[string]any`, `map[string]string`, raw string switches, or
unstructured option bags inside core logic are review signals that the real
contract is not visible in the type system.

Bad:

```go
func Apply(row map[string]string) error {
	if row["status"] == "posted" && row["amount"] == "" {
		return errors.New("missing amount")
	}
	return nil
}
```

Better:

```go
type Entry struct {
	Status Status
	Amount decimal.Amount
}

func Apply(entry Entry) error {
	if entry.Status == StatusPosted && entry.Amount.IsZero() {
		return errors.New("posted entry amount is required")
	}
	return nil
}
```

The better version makes the contract visible. Parsing code can still accept
CSV or JSON, but core logic receives a value it can reason about.

## Surface Area

Keep exported surface area intentional. Exported identifiers need clear names,
comments, and stable semantics. Internal helpers should stay unexported until
another package truly needs them.

Interfaces are valuable when they express a real boundary such as storage,
clock, process execution, HTTP transport, validation, or event delivery. An
interface that only mirrors one concrete type in the same package usually adds
indirection without ownership clarity.

Constructors and functions should make dependencies explicit. Hidden reads from
environment variables, mutable package globals, implicit default clients, or
background initialization make tests and reviews less reliable. When
process-global behavior is truly required, isolate it at the boundary and pass
explicit values into the rest of the code.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ownership-and-architecture">Ownership and architecture</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./source-transforms-and-evaluators">Source transforms and evaluators</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Shared validation layer](../../architecture/shared-validation-layer)
- [LLM finding patterns](./llm-finding-patterns)
