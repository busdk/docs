---
title: Non-interactive use and scripting
description: BusDK commands never wait for user input; all input is supplied per invocation and output is produced when ready.
---

## Non-interactive use and scripting

BusDK commands are designed so that an AI agent or automation script never runs a command that waits for user input. Every command is non-interactive: all required input must be supplied to the command via arguments, flags, or standard input, and output is produced as soon as the operation is ready.

There are no interactive prompts. When the user or script omits a required parameter, the command must not prompt for it; it must fail with a concise usage error on standard error and exit with status code 2. Commands must not read from the terminal for confirmation, choices, or missing options. Optional input (for example bulk row data) may be provided via standard input or a file path; the command must not block waiting for a TTY.

This contract ensures scripting parity: the same invocation works the same whether run from a human at a terminal or from a script, CI, or agent. Deterministic output and exit codes allow automation to rely on BusDK without special “non-interactive” or “batch” modes.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./error-handling-dry-run-diagnostics">Error handling, dry-run, and diagnostics</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./reporting-and-queries">Reporting and query commands</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
