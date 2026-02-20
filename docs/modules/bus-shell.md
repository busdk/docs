---
title: bus-shell
description: "bus shell starts an interactive BusDK command prompt or runs one command and exits."
---

## `bus-shell` — interactive command prompt for `bus`

### Synopsis

```bash
bus shell [global-flags]
bus shell [global-flags] [--] <command> [args...]
```

`bus shell` gives you a prompt where each line is executed as a `bus` command. You can also pass a command directly so the shell runs it once and exits.

### Description

This module is useful when you want to run many commands in one terminal session without repeating the `bus` prefix. Inside the prompt, write command lines like `accounts list` or `run sync-all --profile local`. The shell dispatches them as `bus accounts list` and `bus run sync-all --profile local`.

Interactive mode supports lightweight built-ins. `help` prints a short reminder, and `exit` or `quit` ends the session.

One-shot mode is useful in scripts and aliases. For example, `bus shell dev stage` runs one command and returns its exit code.

### Global flags

The module accepts standard BusDK global flags. Help and version are immediate and exit with code `0`.

`-C` and `--chdir` set the effective working directory before command execution. `-o` and `--output` are supported only in one-shot mode and redirect command stdout to a file. `-q` suppresses normal output, and `-v` enables verbose diagnostics. `-q` and `-v` cannot be combined.

`--color` and `--no-color` are accepted for compatibility. `--format` currently supports only `text`.

### Examples

```bash
# Start interactive mode
bus shell

# Run one command and exit
bus shell accounts list --format tsv

# Run one command in another repository
bus shell -C ../customer-repo run sync-all --profile dry-run

# Write one-shot output to a file
bus shell -o /tmp/bus-shell.out run send-feedback --channel docs
```

### Using from `.bus` files

Inside a `.bus` file, call the `shell` target the same way as any other module target.

```bus
# same as: bus shell accounts list --format tsv
shell accounts list --format tsv

# same as: bus shell run sync-all --profile local
shell run sync-all --profile local
```

Use this form only when you intentionally want shell-mediated dispatch from a busfile. Most workflows should call module targets directly.

### Files

`bus shell` does not create or own workspace accounting datasets. It executes commands in the effective working directory and relies on `bus` being available on `PATH`.

### Exit status and errors

Exit code `0` means success. Exit code `1` means runtime failure, such as when `bus` cannot be executed. Exit code `2` means invalid usage, such as incompatible flags.

When a one-shot command fails, `bus shell` returns that command exit code.

### Development state

**Value promise.** Start an interactive BusDK prompt or run one command through the dispatcher with consistent global-flag behavior.

**Use cases.** [Orphan modules](../implementation/development-status#orphan-modules) — not mapped to a documented use case.

**Completeness.** 30% — Interactive loop, one-shot mode, and global flag handling are implemented and covered by unit and e2e tests.

**Use case readiness.** Orphan (not mapped): 30% — Core prompt flow and one-shot command execution are available.

**Depends on.** [`bus`](./bus).

**Used by.** End users and scripts that want a shell-style `bus` prompt.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bfl">bus-bfl</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-shell](../sdd/bus-shell)
- [Module CLI reference: bus](./bus)
- [`.bus` script files (writing and execution guide)](../cli/bus-script-files)
