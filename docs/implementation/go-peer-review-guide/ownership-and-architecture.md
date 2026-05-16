---
title: Go ownership and architecture review
description: Review package responsibility, command boundaries, module ownership, process exits, and layering in BusDK Go code.
---

## Package Ownership

Each package should have one clear responsibility. A command entrypoint should
parse arguments, wire dependencies, and render output; it should not own
validation, domain rules, storage mutation, or business workflow. A service
handler should translate HTTP or event input into typed calls; it should not
become the only place where invariants are enforced. Library packages should
expose structured behavior that can be unit-tested without shelling out,
opening the full CLI, or requiring a live external service.

For Go CLIs, `main()` should be the only place that calls `os.Exit`. Prefer a
testable run function that accepts arguments, working directory, streams, and
explicit dependencies, then returns an exit code. This keeps command behavior
reviewable without spawning a process and prevents package logic from
terminating tests or callers.

Bad:

```go
func SaveInvoice(path string) {
	if err := writeInvoice(path); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
```

Better:

```go
func SaveInvoice(path string) error {
	if err := writeInvoice(path); err != nil {
		return fmt.Errorf("save invoice %q: %w", path, err)
	}
	return nil
}

func run(args []string) int {
	if len(args) != 1 {
		fmt.Fprintln(os.Stderr, "usage: invoice-save PATH")
		return 2
	}
	if err := SaveInvoice(args[0]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	return 0
}

func main() {
	os.Exit(run(os.Args[1:]))
}
```

The better version lets tests call `SaveInvoice` or `run` directly, validates
arguments before indexing, and leaves process termination at the command
boundary.

## Module Boundaries

Look for code that crosses ownership boundaries for convenience. BusDK modules
integrate through documented datasets, schemas, shared mechanical libraries,
and explicit API/provider boundaries. They should not call another `bus-*` CLI
for core behavior, hardcode another module's data paths when a path accessor
exists, or duplicate business logic owned by another module. A review should
flag code whose imports, file access, or runtime calls make a module depend on
another module's internals.

Layering should be predictable. Lower layers provide primitives and contracts;
higher layers compose them. If two packages both validate the same rule, both
choose storage paths, or both translate the same event shape, there is probably
a missing owner. Suggest moving the rule to the package that owns the concept
and keeping other packages as callers.

Bad:

```go
func handleCreate(w http.ResponseWriter, r *http.Request) {
	req := decodeCreate(r)
	if req.AmountCents <= 0 {
		http.Error(w, "amount must be positive", http.StatusBadRequest)
		return
	}
	// Store directly from the handler.
}
```

Better:

```go
func handleCreate(w http.ResponseWriter, r *http.Request) {
	req := decodeCreate(r)
	invoice, err := invoice.New(req.CustomerID, req.AmountCents)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// Store the validated invoice value.
	_ = invoice
}
```

The handler still owns HTTP translation, but the invoice package owns invoice
rules.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./review-order">Review order</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./api-and-type-design">API and type design</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Independent modules](../../architecture/independent-modules)
- [Shared validation layer](../../architecture/shared-validation-layer)
- [LLM finding patterns](./llm-finding-patterns)
