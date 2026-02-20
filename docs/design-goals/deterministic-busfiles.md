---
title: "Deterministic `.bus` command files"
description: "`.bus` files are deterministic, reviewable command batches with mandatory syntax preflight before execution."
---

## Deterministic `.bus` command files

BusDK treats `.bus` command files as a first-class operational primitive for repeatable bookkeeping workflows. A `.bus` file is a plain-text list of BusDK commands that can be reviewed, versioned, and replayed with deterministic behavior.

The core principle is safety before mutation: when running one or more `.bus` files, BusDK performs syntax preflight across the whole provided set before executing any command. If any file has a syntax or tokenization error, execution stops without applying commands. This gives users and automation a predictable, auditable batch boundary.

`.bus` files are intentionally constrained. They are command lists, not a general shell scripting language. BusDK parses quoting and escaping, but does not interpret shell expansion, pipes, command substitution, or separators. This keeps execution semantics explicit and stable for humans, scripts, and agents.

The same principle supports portability: monthly or period-based `.bus` files can be checked, reviewed, and replayed in clean workspaces. When needed, workspace-level atomicity can be layered through transaction providers, but the deterministic command-file surface remains the stable contract.

This principle extends CLI-first design: workflows remain explicit command invocations and their effects remain reviewable in repository data. `.bus` files are therefore both an operator tool and an interchange format for automation and replay-oriented tooling.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./double-entry-ledger">Double-entry ledger accounting</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./extensibility">Extensibility as a first-class goal</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Design goals index](./index)
- [Module docs: `bus`](../modules/bus)
- [SDD: `bus`](../sdd/bus)
- [`.bus` script files (writing and execution guide)](../cli/bus-script-files)
