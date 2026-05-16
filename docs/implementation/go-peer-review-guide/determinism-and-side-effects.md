---
title: Go determinism and side-effect review
description: Review stable outputs, reproducible builds, subprocess arguments, localized configuration reads, portability, and side-effect boundaries.
---

## Deterministic Output

For the same inputs and environment, code should produce the same outputs.
Review map iteration used for user-visible ordering, timestamps created without
injection in testable logic, random identifiers without deterministic seeds
where repeatability matters, and diagnostics that depend on local absolute
paths.

Build and runtime defaults are part of determinism when they affect released
artifacts or CI evidence. Review whether builds use reproducible settings such
as trimmed paths, read-only module resolution in tests, intentional VCS metadata
handling, and documented CGO or runtime tuning choices. Advanced knobs such as
PGO, `GOAMD64`, `GOGC`, `GOMEMLIMIT`, and `GOMAXPROCS` need realistic workload
evidence rather than local guesswork.

## Side-Effect Boundaries

Network, Git, Docker, browser, and filesystem side effects should be explicit
parts of the command or test contract. Core library code should not
unexpectedly shell out, mutate unrelated files, read global configuration, or
reach the network. If such behavior is required, it belongs behind a small
boundary that tests can replace.

Subprocesses should use explicit binaries and argument lists. Shell-based
`exec.Command("sh", "-c", ...)` or equivalent command strings are harder to
quote, audit, and test than direct `exec.CommandContext` calls.

Bad:

```go
cmd := exec.Command("sh", "-c", "bus export "+workspace)
```

Better:

```go
cmd := exec.CommandContext(ctx, "bus", "export", workspace)
```

The better version avoids accidental shell expansion and makes arguments
unambiguous.

Environment and configuration reads should be localized. `os.Getenv` and
`os.LookupEnv` belong in configuration loading or process-boundary code, not
scattered through business logic. Pass the resolved configuration into packages
as typed values.

Bad:

```go
func Send(msg Message) error {
	baseURL := os.Getenv("BUS_API_URL")
	return post(baseURL, msg)
}
```

Better:

```go
type Client struct {
	BaseURL string
	HTTP    *http.Client
}

func (c Client) Send(ctx context.Context, msg Message) error {
	return post(ctx, c.HTTP, c.BaseURL, msg)
}
```

The better version is easier to test and makes the configuration dependency
visible.

Do not hide portability assumptions. Code that depends on Unix-only syscall
shapes, localhost reachability from containers, executable architecture,
filesystem case behavior, shell quoting, or platform-specific paths needs a
portability review. The improvement is usually to use a standard library
abstraction, isolate the platform-specific piece, or add a deterministic
capability probe and skip path in tests.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./context-resources-and-concurrency">Context, resources, and concurrency</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./workflows-and-backends">Workflows and backends</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Git-backed data store](../../architecture/git-backed-data-store)
- [Testing strategy](../../testing/testing-strategy)
- [LLM finding patterns](./llm-finding-patterns)
