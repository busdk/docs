---
title: Module repository structure and dependency rules
description: Each bus-<module> repository contains a library that implements the module’s behavior and a CLI entrypoint that is a thin wrapper over that library.
---

## Module repository structure and dependency rules

Each `bus-<module>` repository contains a library that implements the module’s behavior and a CLI entrypoint that is a thin wrapper over that library. The CLI is a presentation layer that parses arguments and renders outputs; the library is the implementation unit that performs validation, domain rules, and dataset updates and returns structured results to the CLI.

The standard Go layout keeps the CLI thin and the library testable. The entrypoint lives under `cmd/bus-<module>/main.go`, while the module library lives under `internal/<module>/...` and is the primary unit under test. Domain packages belong under `internal/` so other repositories cannot import them, which enforces the architectural boundary at compile time. Tests should target the library package directly and treat the CLI as a small adapter.

Cross-module reuse in Go is allowed only for explicitly shared mechanical libraries such as [`bus-data`](../modules/bus-data) (or a future `bus-core`) that expose packages outside `internal/`. Domain modules may depend on [`bus-data`](../modules/bus-data), but [`bus-data`](../modules/bus-data) MUST NOT depend on any domain modules, and domain modules MUST NOT import each other. Integration between domain modules is through datasets and schemas, not through internal Go APIs.

Modules MUST NOT invoke other `bus-*` CLIs as internal dependencies for core behavior. The `bus` dispatcher provides a unified UX for users, but it does not make module CLIs a dependency mechanism. If a module needs common mechanics such as workspace storage, schema parsing, or CSV I/O, it should import the shared mechanical library or implement the documented storage backend interface.

This layout preserves multi-language module support because the data contract remains the universal integration surface. The Go library is a reference implementation and a convenience for Go modules, while other languages can implement the same module behavior as long as they read and write the same datasets and schemas.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">BusDK Design Spec: Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./development-status">Development status</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
