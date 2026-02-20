---
title: "bus-shell — interactive shell wrapper for bus (SDD)"
description: "Software design document for bus-shell, the interactive and one-shot shell wrapper that executes BusDK commands through bus."
---

## bus-shell — interactive shell wrapper for bus

### Introduction and Overview

`bus-shell` provides `bus shell`, which starts an interactive prompt for BusDK commands or runs one command and exits. It is a thin wrapper around the `bus` dispatcher and does not own domain logic.

The module exists to improve operator flow for command-heavy sessions. Users can type `accounts list` or `run sync-all` without repeating the `bus` prefix, while keeping command execution deterministic.

### Requirements

`bus-shell` must support two modes. Interactive mode starts when no command tokens are provided, and one-shot mode starts when a command is provided after global flags. In both modes, commands are executed through `bus` and use the effective working directory.

Global flag handling follows BusDK global semantics. Help and version must short-circuit with exit code `0`. Quiet and verbose must be mutually exclusive and invalid combinations must return exit code `2`. `--chdir` must resolve the execution directory before any command runs.

Interactive mode must provide `help`, `exit`, and `quit` built-ins. Other lines are tokenized with shell-like quoting and then dispatched to `bus`. Empty lines and comment lines that start with `#` are ignored.

One-shot mode must run a single command and return that command’s exit code when the command executes and fails. Usage errors must return `2`, and runtime failures such as missing `bus` must return `1`.

### System Architecture

The architecture is intentionally small. `cmd/bus-shell/main.go` is a thin process entrypoint that calls an internal application runner.

`internal/app/run.go` owns argument parsing, mode selection, interactive loop behavior, tokenization, and process execution. It invokes `bus` as a child process and forwards command output streams according to flags.

### Component Design and Interfaces

The main interface is `Run(args, cwd, stdin, stdout, stderr, env) int`, which returns process exit status for both CLI and tests. Parsing is deterministic and stops global flag parsing at the first command token or `--`.

Interactive dispatch uses a line scanner and a tokenizer that supports single quotes, double quotes, and backslash escapes. Tokenization rejects shell control tokens such as `|`, `;`, `<`, and `>` to keep behavior simple and predictable.

Command execution uses `exec.Command("bus", ...)` with inherited environment and resolved working directory. One-shot mode optionally writes stdout to `--output`, while interactive mode writes command output directly to stdout.

### Data Design

This module does not define workspace datasets and does not write accounting data files. It may write a user-requested output file in one-shot mode when `--output` is set.

The module does not introduce `.bus` ownership. It only executes commands that may operate on workspace data through other modules.

### Assumptions and Dependencies

`bus-shell` assumes the `bus` executable is available on `PATH` when commands are executed. It depends on the operating system process model for child command execution and standard input/output streams.

The module assumes command lines in interactive mode are short enough for scanner defaults. If longer command input becomes a requirement, scanner buffer sizing may need revision.

### Glossary and Terminology

Interactive mode means a prompt loop that reads command lines until `exit`, `quit`, or EOF. One-shot mode means invoking `bus shell` with a command so exactly one command is executed.

A shell command line in this module means a single `bus` command expression with basic quoting rules, not full shell scripting.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-agent">bus-agent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference: bus-shell](../modules/bus-shell)
- [Module SDD: bus](./bus)
- [Module repository structure and dependency rules](../implementation/module-repository-structure)

### Document control

Title: bus-shell module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-SHELL`  
Version: 2026-02-20  
Status: Draft  
Last updated: 2026-02-20  
Owner: BusDK development team
