---
title: Go optimization guide
description: Default Go build and test optimization profile used in BusDK module Makefiles, with reproducibility-focused flags and practical overrides.
---

## Go optimization guide

Go optimization work is most reliable when each change has one clear intent, one measurable result, and one rollback path. This guide follows that approach and documents the defaults used in BusDK module Makefiles.

### Measure first, then optimize

Optimization without representative measurement is the fastest way to waste engineering time and introduce regressions. In Go services, you should collect CPU, heap, alloc, mutex, block, goroutine, and trace data before changing hot paths. This tells you whether the dominant cost is compute, contention, allocation pressure, or blocking.

For example, if p99 latency is rising but CPU is low, a mutex or channel block issue is usually a better first target than micro-optimizing arithmetic. If CPU is high and alloc profiles show a steep `allocs/op`, reducing allocations often gives both throughput and latency wins because GC work drops with it.

### `-trimpath` for reproducible paths

`-trimpath` removes machine-local source paths from build outputs. This improves build reproducibility and reduces accidental environment leakage in debug metadata.

In practice, this means two developers building the same commit in different directories get more comparable artifacts. It does not make binaries bit-identical by itself, but it removes one common source of non-determinism.

Example:

```bash
go build -trimpath ./cmd/myservice
```

### `-buildvcs=false` for deterministic metadata

`-buildvcs=false` disables embedding VCS metadata in the binary. This avoids differences caused by repository state, detached checkouts, or CI metadata variations.

This is primarily a reproducibility choice. If your release process needs VCS metadata in binaries, keep it as an explicit opt-in override instead of a default.

Example:

```bash
go build -buildvcs=false ./cmd/myservice
```

### `-ldflags "-s -w"` for smaller binaries

`-s -w` strips symbol table and DWARF debug info, which usually reduces binary size noticeably. Smaller binaries improve image transfer and startup I/O behavior in containerized deployments.

This is a release-build optimization. If you need richer debugging with external tools, use a debug target without strip flags.

Example:

```bash
go build -ldflags '-s -w' ./cmd/myservice
```

### `CGO_ENABLED=0` plus `netgo,osusergo`

`CGO_ENABLED=0` pushes builds toward pure-Go portability and simpler runtime dependencies. Combined with `-tags netgo,osusergo`, DNS and user lookup paths prefer pure-Go implementations.

This is useful for consistent behavior across Linux containers and minimal base images. It also pairs well with static-linking strategies. The tradeoff is that environment-specific resolver behavior can differ from cgo-backed paths, so you should validate critical network workloads.

Example:

```bash
CGO_ENABLED=0 go build -tags 'netgo,osusergo' ./cmd/myservice
```

### `-mod=readonly` for dependency safety

`-mod=readonly` prevents silent `go.mod` and `go.sum` edits during normal build and test runs. This keeps CI and local behavior aligned and avoids accidental dependency drift in unrelated changes.

When dependency updates are intended, run `go mod tidy` explicitly, commit the result, and return to readonly mode for normal workflows.

Example:

```bash
go test -mod=readonly ./...
go mod tidy
go test -mod=readonly ./...
```

### Keep optimized and debug builds separate

Production defaults should stay optimized and reproducible. Debug-oriented flags such as escape-analysis or no-inline builds should live in a separate target so day-to-day artifacts remain stable.

In BusDK Makefiles this is expressed as `build` for optimized output and `build-debug` for investigation work. This separation avoids accidental release of debug-heavy binaries.

Example:

```bash
make build
make build-debug DEBUG_GCFLAGS='all=-N -l -m'
```

### Container-aware runtime settings matter

Compile-time optimization and runtime behavior are linked in production. In containerized services, wrong concurrency or memory settings can erase compile-time gains.

Set memory budgets intentionally (`GOMEMLIMIT`) and verify scheduler behavior (`GOMAXPROCS`) under real CPU quota constraints. Use profiles and runtime metrics after rollout to confirm p95/p99 and GC CPU behavior move in the intended direction.

Example:

```bash
GOMEMLIMIT=1GiB GOMAXPROCS=4 ./myservice
```

### Suggested optimization workflow

Start with one bottleneck from profiling data, apply one focused change, and compare before/after with benchmarks and profiles. Promote only changes that improve the target metric without harming correctness, tail latency, or operational stability.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./developer-module-workflow">Developer module workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./development-status">Development status — BusDK modules</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Implementation and development status](./index)
- [Module repository structure and dependency rules](./module-repository-structure)
- [Go command: build](https://pkg.go.dev/cmd/go#hdr-Compile_packages_and_dependencies)
- [Go package: net (name resolution and resolver behavior)](https://pkg.go.dev/net)
- [Go package: net/http/pprof](https://pkg.go.dev/net/http/pprof)
