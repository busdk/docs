---
title: Go errors and CLI diagnostics review
description: Review ordinary errors, panic boundaries, stable diagnostics, stdout and stderr separation, fixed text, and flag surfaces.
---

## Error Boundaries

Expected failures should return errors, not panic. Panic is appropriate only for
programmer errors or impossible states where continuing would hide corruption.
User input, missing files, validation failures, bad flags, denied permissions,
unavailable local services, and malformed external payloads are ordinary
errors.

Bad:

```go
func LoadConfig(path string) Config {
	b, err := os.ReadFile(path)
	if err != nil {
		panic(err)
	}
	return mustParseConfig(b)
}
```

Better:

```go
func LoadConfig(path string) (Config, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return Config{}, fmt.Errorf("read config %q: %w", path, err)
	}
	cfg, err := parseConfig(b)
	if err != nil {
		return Config{}, fmt.Errorf("parse config %q: %w", path, err)
	}
	return cfg, nil
}
```

The better version reports the failing operation and keeps the caller in
control.

## Diagnostics and Output

Errors should carry enough context for the caller to produce deterministic
diagnostics. Review error messages for stable identifiers: dataset, field,
primary key, command, route, event type, or workspace-relative path. Avoid
diagnostics that depend only on incidental row numbers, temporary absolute
paths, map iteration order, or host-specific wording when a stable domain
identifier is available.

CLI behavior is part of the API. Normal results go to stdout or `--output`;
diagnostics, warnings, and errors go to stderr. Invalid usage should be
distinguishable from runtime failure. Help and version output should be
deterministic. A review should flag code that mixes human diagnostics into
structured output or hides failure detail behind a generic `failed` message.

When output is fixed text, prefer direct writer methods or `io.WriteString`
over formatting calls. Formatting APIs are appropriate when formatting is
actually needed; otherwise they add noise and can blur whether the code is
producing structured results or diagnostics.

Bad:

```go
fmt.Fprintf(w, "ok\n")
```

Better:

```go
if _, err := io.WriteString(w, "ok\n"); err != nil {
	return err
}
```

Use `fmt.Fprintf` when there is real formatting, such as
`fmt.Fprintf(w, "created %s\n", id)`.

New user-visible flags and modes need coupled-surface review. A flag is not
complete when parsing works; help text, validation, README or docs examples,
OpenAPI/OpenCLI or other machine-readable metadata, unit tests, and e2e
coverage must move together.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./destructive-and-batch-operations">Destructive and batch operations</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./context-resources-and-concurrency">Context, resources, and concurrency</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Error handling, dry-run, and diagnostics](../../cli/error-handling-dry-run-diagnostics)
- [Command structure](../../cli/command-structure)
- [LLM finding patterns](./llm-finding-patterns)
