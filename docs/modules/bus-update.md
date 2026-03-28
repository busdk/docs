---
title: bus-update
description: bus update checks released BusDK versions, updates workspace module repositories, and manages machine-local BusDK executable packages.
---

## `bus-update` - release checks and managed packages

### Synopsis

`bus update [global flags] [--workspace <dir>] [--dry-run] [--force] [--index-url <path-or-url>] [--cache-dir <dir>] [--timeout-seconds <n>]`

`bus update [global flags] status [--module <module-name>] [--current <version>] [--index-url <path-or-url>] [--cache-dir <dir>] [--timeout-seconds <n>] [--refresh-seconds <n>] [--failure-grace-seconds <n>]`

`bus update [global flags] check --module <module-name> --current <version> [--index-url <path-or-url>] [--cache-dir <dir>] [--timeout-seconds <n>] [--refresh-seconds <n>] [--failure-grace-seconds <n>]`

`bus update [global flags] package list [--install-root <dir>] [--os <goos>] [--arch <goarch>]`

`bus update [global flags] package status [--module <module-name>] [--index-url <path-or-url>] [--install-root <dir>] [--ca-file <path>] [--os <goos>] [--arch <goarch>]`

`bus update [global flags] package install --module <module-name> [--version <version>] [--index-url <path-or-url>] [--install-root <dir>] [--ca-file <path>] [--force] [--os <goos>] [--arch <goarch>]`

`bus update [global flags] package upgrade [--module <module-name>] [--index-url <path-or-url>] [--install-root <dir>] [--ca-file <path>] [--force] [--os <goos>] [--arch <goarch>]`

`bus update [global flags] package remove --module <module-name> [--install-root <dir>] [--os <goos>] [--arch <goarch>]`

`bus update [global flags] package verify [--module <module-name>] [--install-root <dir>] [--os <goos>] [--arch <goarch>]`

### Overview

`bus-update` now has two clear roles. The original role remains release checking and selective Git-workspace updates for `bus-*` repositories. The new managed-package role installs and maintains machine-local `bus` and `bus-*` executables in one managed install root.

This split matters because the commands answer different operator questions. `bus update` without `package` works against Git repositories in a workspace. `bus update package ...` works against installed executables in a managed `bin` directory.

### Release checks and workspace updates

The default release index is `https://docs.busdk.com/releases/latest.txt`. Each row is parsed as `{MODULE_NAME} {MODULE_VERSION} {DATE} {HASH}`. Embedded startup checks stay warning-only and use a local cache, short timeout defaults, and a failure-grace window so transient release-index fetch problems do not block normal tool execution.

Running `bus update` in a workspace scans `bus-*` directories that contain `.git`, compares each repository head to the latest released hash, and updates only repositories that are behind the release index. `--dry-run` prints what would change without touching the repositories. Repositories with local uncommitted changes are skipped.

### Managed package behavior

The default managed package manifest is `https://pkg.busdk.com/busdk/packages/v1/index.json`. Each package entry identifies at least module name, version, operating system, architecture, checksum, and signing key. If explicit artifact URLs are not listed, `bus-update` derives them from the stable layout `https://pkg.busdk.com/busdk/{os}/{arch}/{module}/{version}/{filename}` and the matching detached signature path `{filename}.sig`.

`bus update package install` downloads one platform-specific executable, verifies its SHA-256 checksum and detached Ed25519 signature, and then installs it into the managed binary directory with atomic replacement semantics. `upgrade` refreshes installed packages to the latest available version. `list`, `status`, and `verify` inspect the local managed package state, while `remove` cleanly uninstalls one package.

`status` reports installed versus latest available version and marks entries as `up-to-date`, `outdated`, `not-installed`, `missing`, or `checksum-mismatch`. `verify` recalculates installed checksums and is the direct operator command for integrity review.

### Install root and bootstrap flow

Install-root precedence is `--install-root`, then `BUSDK_PACKAGE_ROOT`, then `BUSDK_BOOTSTRAP_ROOT`, then the platform default. On Windows the default root is `%LOCALAPPDATA%\BusDK`; on other systems it is `~/.local/share/busdk`. Managed executables live under `<install-root>/bin`.

The intended Windows bootstrap flow is that the bootstrap installer places only `bus.exe` and `bus-update.exe` into that managed `bin` directory and adds it to `PATH`. After that, `bus update package install ...` places additional `bus-*.exe` binaries into the same location so the already-installed `bus` launcher can discover them through the managed path.

### Security and rollback

Managed package downloads are HTTPS-only unless the operator explicitly points the command at a local file path. Before `bus-update` replaces any executable, it verifies the payload checksum and detached signature. Replacement happens through a temporary file and backup rename in the destination directory, and the old executable is restored if state persistence fails after the new binary is moved into place.

### Environment variables

Release-check and workspace-update flow:

- `BUSDK_DISABLE_UPDATE_CHECK=1`
- `BUSDK_CURRENT_VERSION=<version>`
- `BUSDK_UPDATE_CHECK_URL=<path-or-url>`
- `BUSDK_UPDATE_CHECK_CACHE_DIR=<dir>`
- `BUSDK_UPDATE_CHECK_TIMEOUT_SECONDS=<n>`
- `BUSDK_UPDATE_CHECK_REFRESH_SECONDS=<n>`
- `BUSDK_UPDATE_CHECK_FAILURE_GRACE_SECONDS=<n>`

Managed package flow:

- `BUSDK_PACKAGE_INDEX_URL=<path-or-url>`
- `BUSDK_PACKAGE_ROOT=<dir>`
- `BUSDK_BOOTSTRAP_ROOT=<dir>`
- `BUSDK_PACKAGE_CA_FILE=<path>`

### Examples

```bash
bus update check --module bus-run --current 1.2.3
bus update --workspace /srv/busdk --dry-run
BUSDK_BOOTSTRAP_ROOT="$HOME/.local/share/busdk" bus update package install --module bus-ledger
bus update package verify
```

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus update package install --module bus-ledger
update package install --module bus-ledger
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-status">bus-status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-update reference](../modules/bus-update)
- [Module reference index](../modules/index)
- [Standard global flags](../cli/global-flags)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
