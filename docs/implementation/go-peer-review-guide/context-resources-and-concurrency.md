---
title: Go context, resource, and concurrency review
description: Review contexts, cleanup, response bodies, post-response work, goroutines, queues, timers, and tickers.
---

## Context and Resources

Cancelable work should accept and pass `context.Context`. This includes HTTP
calls, event listeners, long-running validation, subprocesses, server loops,
and work that may block on I/O. Do not store ordinary business values in
context; pass them as typed parameters.

Resource ownership must be visible. Files, response bodies, locks, temporary
directories, subprocess handles, tickers, and goroutines need clear lifetime
management. Reviewers should look for cleanup immediately after successful
acquisition, response bodies that are drained and closed when reuse matters,
goroutines with cancellation paths, and channels with an obvious owner.

Bad:

```go
resp, err := client.Get(url)
if err != nil {
	return err
}
return decode(resp.Body) // Body is never closed.
```

Better:

```go
resp, err := client.Get(url)
if err != nil {
	return err
}
defer resp.Body.Close()
return decode(resp.Body)
```

When HTTP connection reuse matters, also drain the body according to the
package's transport policy.

## Background Work

Post-response work needs an intentional context. Request context cancellation
should stop request-scoped work, but it must not silently erase billing, audit,
usage, cleanup, or publication records that the system is required to keep
after a response is sent. Use a short, bounded background context or durable
queue for those obligations, and test cancellation behavior explicitly.

Concurrency should make state ownership explicit. Shared mutable state should
have clear synchronization. Background work should report errors or have an
intentional failure policy. A goroutine launched from a request, command, or
test without a stop path is a review finding unless the surrounding lifecycle
proves it cannot leak. Prefer bounded worker pools and bounded queues over
unbounded goroutine creation, and do not hold locks while doing network or disk
I/O.

Bad:

```go
func handle(w http.ResponseWriter, r *http.Request) {
	go publishAudit(r.Context(), eventFrom(r))
	w.WriteHeader(http.StatusAccepted)
}
```

Better:

```go
func handle(w http.ResponseWriter, r *http.Request) {
	event := eventFrom(r)
	if err := auditQueue.Enqueue(r.Context(), event); err != nil {
		http.Error(w, err.Error(), http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusAccepted)
}
```

The better version gives the work an owned queue and a visible error path.

Repeated timers and tickers need review. `time.After` inside loops allocates
repeatedly and can hide lifecycle problems; prefer a reused timer or ticker
with explicit stop behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./errors-and-cli-diagnostics">Errors and CLI diagnostics</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./determinism-and-side-effects">Determinism and side effects</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Testing strategy](../../testing/testing-strategy)
- [LLM finding patterns](./llm-finding-patterns)
