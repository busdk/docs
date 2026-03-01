---
title: "bus-update — module version checking (SDD)"
description: "Software Design Document for bus-update: shared release-index version checks, cache policy, timeout limits, and warning-only startup behavior."
---

## bus-update — module version checking

### Introduction and Overview

`bus-update` provides shared version-check functionality for BusDK modules. It centralizes release-index parsing, version comparison, cache policy, timeout handling, and continuous-failure grace handling.

The module exists to keep version-check behavior in one focused module instead of duplicating logic across `bus-*` modules.

### Requirements

FR-UPD-001 Shared library API. The module MUST expose a reusable Go library for other modules to enforce version checks.

FR-UPD-002 CLI command. The module MUST expose `bus update` to review and selectively update outdated `bus-*` module repositories in a workspace.

FR-UPD-002a Explicit check command. The module MUST also expose `bus update check` for explicit single module/version checks.

FR-UPD-003 Release index format. The default release index source is `https://docs.busdk.com/releases/latest.txt`. Rows are parsed as `{MODULE_NAME} {MODULE_VERSION} {DATE} {HASH}`.

FR-UPD-004 Startup warning mode. When a newer version exists for a module startup check, the check MUST print a deterministic warning to stderr and MUST NOT block command execution.

FR-UPD-004a Explicit check mode. Explicit `bus update check` checks MUST return exit code `1` when a newer version exists.

FR-UPD-005 Cache and refresh. The module MUST cache check state locally and avoid network/index reads on every execution. Default refresh interval is 24 hours.

FR-UPD-006 Failure grace. Check failures caused by index fetch/read failures MUST tolerate transient outages. Startup checks print an error only after continuous failures exceed a configured grace duration (default 24 hours).

FR-UPD-007 Help/version bypass. Embedded startup checks in other modules MUST bypass enforcement for `--help` and `--version` requests.

NFR-UPD-001 Deterministic diagnostics. Error messages and exit code behavior are deterministic for equal inputs.

NFR-UPD-002 Bounded latency. Default timeout for index fetches is short and configurable.

NFR-UPD-003 Minimal dependencies. Implementation uses the Go standard library only.

### System Architecture

`bus-update` has two components.

The library component (`pkg/updatecheck`) implements check enforcement and decision logic. Other `bus-*` modules call this library on startup.

The CLI component (`bus-update`) exposes `check` for explicit module/version checks and uses the same library path.

### Component Design and Interfaces

Primary package API:

- `Enforce(argv []string, stderr io.Writer) int`
- `Check(module, current string, stderr io.Writer) int`
- `CheckWithOptions(module, current string, stderr io.Writer, opts Options) int`

`Enforce` is for startup integration. It derives module name from `argv[0]`, derives the current version from build metadata or environment override, applies help/version bypass, and emits warning-only diagnostics without blocking command execution.

`Check` and `CheckWithOptions` are explicit checks used by the module CLI and tests.

### Data Design

Cache records are JSON files in the local user cache directory by default (`.../busdk/update-check`). Cache keys include module name and release-index source hash.

Cache records include:

- index source
- latest known version
- last successful or attempted check timestamp
- first timestamp of continuous fetch failure window

### Assumptions and Dependencies

Release metadata is published in a flat text file with one module-version row per line.

All module versions compared by this module are release-like semantic numeric versions (`major.minor[.patch]`). Development versions are ignored in startup enforcement.

### Glossary and Terminology

Release index means the flat metadata file listing module versions.

Continuous failure window means the time interval since the first unresolved release-index fetch/read failure without an intervening successful refresh.

### Document control

Title: bus-update module SDD  
Project: BusDK  
Document ID: BUSDK-MOD-UPD  
Version: 2026-02-22  
Status: Draft  
Last updated: 2026-02-22  
Owner: BusDK development team

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-status">bus-status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-update module CLI reference](../modules/bus-update)
- [Module SDD index](./modules)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
