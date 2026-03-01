---
title: bus-update
description: bus update checks whether newer module versions are available from the BusDK release index and can block stale module execution.
---

## `bus-update` - module version checks

### Synopsis

`bus update [global flags] [--workspace <dir>] [--dry-run] [--index-url <path-or-url>] [--cache-dir <dir>] [--timeout-seconds <n>]`

`bus update [global flags] check --module <module-name> --current <version> [--index-url <path-or-url>] [--cache-dir <dir>] [--timeout-seconds <n>] [--refresh-seconds <n>] [--failure-grace-seconds <n>]`

### Overview

`bus-update` is the shared BusDK module for release-version checks. Other `bus-*` modules use its Go library before command execution to print warning diagnostics when a newer released version exists.

The default release index is `https://docs.busdk.com/releases/latest.txt`. Each row is parsed as `{MODULE_NAME} {MODULE_VERSION} {DATE} {HASH}`.

The module is designed to avoid network calls on every execution. It uses a local cache with refresh and timeout limits, and it only fails closed on index fetch failures after a continuous failure grace window.

### Commands

`bus update` reviews `bus-*` module repositories in the selected workspace and updates only modules that are behind the release index hash. Modules already at the latest hash are left untouched.

Use `--dry-run` to print what would be updated without changing any repository.

Modules with local uncommitted changes are skipped and reported.

`bus update status` reports whether the current `bus-update` version is outdated, and can also check a provided module/version pair by flags.

`bus update check` evaluates one module/version pair against the release index.

A successful check returns exit `0`. If a newer version is listed, the command returns exit `1` and prints a deterministic diagnostic to stderr.

Embedded startup checks are warning-only and do not block tool execution.

### Cache and failure behavior

Default behavior is:

- timeout `2s`
- cache refresh interval `24h`
- continuous failure grace `24h`

Transient failures inside the grace period are tolerated. Once failures continue beyond the grace period, startup checks print an error diagnostic to stderr and still allow command execution.

### Environment variables

`bus-update` and embedded checks in other modules support these variables:

- `BUSDK_DISABLE_UPDATE_CHECK=1`
- `BUSDK_CURRENT_VERSION=<version>`
- `BUSDK_UPDATE_CHECK_URL=<path-or-url>`
- `BUSDK_UPDATE_CHECK_CACHE_DIR=<dir>`
- `BUSDK_UPDATE_CHECK_TIMEOUT_SECONDS=<n>`
- `BUSDK_UPDATE_CHECK_REFRESH_SECONDS=<n>`
- `BUSDK_UPDATE_CHECK_FAILURE_GRACE_SECONDS=<n>`

### Examples

```bash
bus update check --module bus-run --current 0.0.35
bus update check --module bus-api --current 0.1.2 --index-url /tmp/latest.txt --cache-dir /tmp/bus-update-cache
```

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus update check --module bus-run --current 0.0.35
update check --module bus-run --current 0.0.35
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-status">bus-status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-update SDD](../sdd/bus-update)
- [Module SDD index](../sdd/modules)
- [Standard global flags](../cli/global-flags)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
