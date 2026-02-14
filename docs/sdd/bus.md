---
title: bus — single CLI entrypoint for the BusDK toolchain (SDD)
description: "Design document for the bus top-level dispatcher: single entrypoint that invokes bus-<command> executables on PATH."
---

## bus — single CLI entrypoint for the BusDK toolchain

### Introduction and Overview

The bus dispatcher is the single top-level entrypoint for the BusDK CLI. It does not implement domain logic itself. Given arguments `bus <command> [args...]`, it locates the executable `bus-<command>` on PATH and runs it with the remaining arguments, passing through environment, standard input, standard output, and standard error. The exit code of the child process becomes the exit code of bus. This design keeps the dispatcher minimal and leaves all command behavior to the respective module binaries (bus-init, bus-accounts, bus-config, and so on). The intended users are anyone running BusDK from the command line or from scripts; the dispatcher ensures a single, predictable invocation pattern (`bus <module> …`) for every module.

### Requirements

**FR-BUS-001 No arguments.** When the argument list has fewer than two elements (i.e. the program name and no subcommand), the dispatcher MUST write a usage message to stderr and exit with code 2. The usage message MUST include the string `usage: bus <command> [args...]` and MUST include a line `available commands:` followed by a list of available subcommands. Available subcommands MUST be discovered by scanning PATH for executables whose name starts with `bus-` and, on Windows, have an extension in PATHEXT; the resulting command names (the part after `bus-`) MUST be listed in sorted order. Acceptance criteria: running `bus` with no arguments exits 2; stderr contains the usage line and the available-commands header; at least one subcommand appears when at least one `bus-*` executable is on PATH.

**FR-BUS-002 Missing subcommand.** When the first argument names a subcommand for which no corresponding `bus-<subcommand>` executable is found on PATH, the dispatcher MUST write to stderr a message that includes the subcommand name and the expected executable name (`bus-<subcommand>`), MUST append the same usage and available-commands output as in FR-BUS-001, and MUST exit with code 127. Acceptance criteria: running `bus missing` when `bus-missing` is not on PATH exits 127; stderr contains text equivalent to `bus: missing subcommand: missing; expected executable named bus-missing in PATH` and the usage/available-commands block.

**FR-BUS-003 Successful dispatch.** When the first argument names a subcommand and the executable `bus-<subcommand>` is found on PATH, the dispatcher MUST execute it with the remaining arguments (args[2:] passed as the child’s arguments), with the same environment, stdin, stdout, and stderr. The process exit code of the child MUST be returned as the exit code of bus; if the child exits with a non-negative code, that code MUST be returned unchanged. If execution fails (e.g. cannot start the process), the dispatcher MUST write the error to stderr and return 1. Acceptance criteria: `bus accounts --help` runs `bus-accounts --help` and returns its exit code; arguments after the subcommand are passed through; child stdout/stderr are not consumed by the dispatcher.

**FR-BUS-004 PATH and platform.** Subcommand discovery and lookup MUST use the PATH environment variable. On Windows, executables without an extension MUST be resolved using PATHEXT. The first directory in PATH that contains an executable matching `bus-<subcommand>` (with extension on Windows) MUST be used. Acceptance criteria: when two directories on PATH both contain `bus-accounts`, the one earlier in PATH is used; on Windows, `bus-accounts.exe` is found when PATH contains a directory with that file.

**NFR-BUS-001 No configuration files.** The dispatcher MUST NOT read or write any configuration file. It MUST NOT depend on a workspace or datapackage.json. Acceptance criteria: behavior is determined only by argv and env (not by filesystem state other than PATH lookup).

### System Architecture

The dispatcher consists of a main entrypoint that calls a single Run function with os.Args, os.Environ(), and stdio. Run parses the first positional argument as the subcommand, resolves `bus-<subcommand>` on PATH, and execs the child with the remainder of the arguments. Subcommand listing is implemented by iterating over PATH directories and collecting executable names that match the `bus-*` pattern; the stem (after `bus-`) is the command name. No other components or services are involved.

### Component Design and Interfaces

**Interface IF-BUS-001 (dispatch).** The program is invoked as `bus` or `bus <command> [args...]`. There are no flags or options consumed by the dispatcher itself; all tokens after the program name are the subcommand (first token) and the arguments to pass to the child (remaining tokens). Behavior is specified by FR-BUS-001 through FR-BUS-004.

**Planned extension (not yet implemented).** When the first argument is `help` and the executable `bus-help` is not on PATH, the dispatcher SHOULD show usage and available commands and exit 2 (so that `bus help` behaves like `bus` with no args when bus-help is not installed). This is documented in the repository PLAN.md and in the [CLI command structure](../cli/command-structure).

### Data Design

Not Applicable. The dispatcher does not read or write workspace data, configuration, or any persistent state.

### Assumptions and Dependencies

The dispatcher assumes that module binaries are installed and available on PATH (for example via the BusDK superproject `make install`, which places `bus`, `bus-init`, `bus-accounts`, and other `bus-*` binaries in a directory that the user adds to PATH). It has no Go dependencies on other bus-* modules; it only invokes them as separate processes. The behavior of each subcommand is defined by that module’s SDD and CLI reference.

### Glossary and Terminology

**Dispatcher:** the `bus` binary that interprets the first argument as a command name and runs `bus-<command>` with the remaining arguments.

**Subcommand:** the first positional argument to `bus` (e.g. `init`, `accounts`, `config`). It corresponds to the executable name `bus-<subcommand>`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./modules">Modules (SDD)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next">&rarr; <a href="./bus-init">bus-init</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [CLI command structure](../cli/command-structure)
- [Module CLI reference](../modules/index)
- [Development status](../implementation/development-status)
- [Repository](https://github.com/busdk/bus)

### Document control

Title: bus dispatcher SDD  
Project: BusDK  
Document ID: `BUSDK-DISPATCHER`  
Version: 2026-02-14  
Status: Draft  
Last updated: 2026-02-14  
Owner: BusDK development team  
