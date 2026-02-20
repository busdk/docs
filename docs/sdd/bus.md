---
title: bus — dispatcher and `.bus` command-file execution
description: "bus is the root dispatcher that routes to module CLIs and can execute deterministic `.bus` command files with mandatory syntax preflight and configurable workspace-level atomicity."
---

## Overview

`bus` is the single entrypoint for BusDK. It dispatches user commands to independent module CLIs (for example `bus journal ...`, `bus bank ...`). Modules are responsible for their own data resources and domain validation.

This SDD adds direct support for executing `.bus` files:

- `bus 2024-01.bus`
- `bus 2024-02.bus`
- `bus 2024-03.bus`
- `./2024-01.bus` when the file has a `#!/usr/bin/bus` or `#!/usr/bin/env bus` shebang

A `.bus` file (Busfile) is a deterministic list of `bus` commands (one per line). Execution always performs a full syntax preflight of all provided busfiles before running any command. Workspace-level atomicity (all-or-nothing apply) is optional and configurable; Git-based atomicity is supported as one possible provider, but Git is not required.

Notes:

- `bus run` is not special-cased here. If `run` exists, it is treated as a normal dispatch target (a module/subcommand), and this SDD does not redefine its behavior.
- `bus-replay` is expected to export `.bus` files once this format exists.

## Motivation

Month-sized command files are a simple, reviewable, and (when used with Git) auditable way to build bookkeeping periods:

- easy to diff and code-review
- easy to replay in a clean workspace
- easy for agents to generate deterministically
- enables a strong safety property: detect syntax errors across the whole batch before anything runs

Workspace-level atomicity is optional and configurable because Git-based approaches can be slow with large datasets and some workspaces may not use Git at all.

## Goals

- Support `.bus` files as first-class inputs to the `bus` dispatcher:
  - `bus <file>.bus` executes file(s).
  - Shebang execution works (`./file.bus`) without extra flags.
- Mandatory syntax preflight across all provided busfiles before executing any command:
  - tokenizer/quoting correctness
  - non-empty command token
  - optional dispatch target resolution
- Keep default behavior fast:
  - default validation is syntax-only
  - data validation is optional (best-effort/configurable)
- Make workspace-level atomicity configurable:
  - Git is optional
  - alternative providers are allowed
  - provider selection can come from `datapackage.json` and/or `bus-preferences`
- Keep implementation minimal:
  - dispatcher and busfile code paths should remain as small and direct as possible
  - avoid unnecessary abstraction layers, dependencies, and feature surface

## Non-functional requirements

- Performance testing is mandatory and must be extensive for busfile workloads.
- The implementation must be performance-verified for large multi-file runs, long command batches, and preflight-heavy paths.
- Performance regressions in parsing, preflight, dispatch, and apply orchestration are treated as release blockers.
- Code must remain minimal and maintainable:
  - prefer simple, explicit control flow
  - keep moving parts small and deterministic
  - add complexity only when justified by measured behavior

## Non-goals

- Not a general scripting language (no loops, variables, conditionals, pipes).
- Not guaranteed rollback for external side effects (network calls, filings, emails).
- Not requiring modules to implement `--check` or dry-run modes.

## Terminology

- Busfile: a `.bus` command file.
- Syntax preflight: tokenization and command-line structural validation without executing module code.
- Data validation: executing module logic in a non-mutating mode (if supported).
- Workspace atomicity: all-or-nothing apply for workspace state (implementation-dependent and optional).

## CLI behavior

### Normal dispatch (unchanged)

- `bus <module> <args...>` dispatches to module CLI.
- No special handling is required for `run`; it is dispatched like any other target.

### New: busfile mode

If the first non-flag argument is recognized as a busfile, `bus` enters busfile mode.

#### Synopsis

```sh
bus [BUSFILE_OPTS] <file.bus> [<file2.bus> ...]
./file.bus
```

#### Busfile options

Busfile options are parsed only while in busfile mode:

- `--check`
  - executes in check-only mode
  - always performs syntax preflight
  - if `validation.level=data` and supported, run best-effort data validation
  - MUST NOT apply workspace changes
- `--transaction <provider>`
  - overrides configured transaction provider for this invocation
  - allowed values: `none`, `git`, `snapshot`, `copy`
- `--scope <scope>`
  - overrides how multiple busfiles are applied
  - `file` (default): each file is its own unit (syntax preflight remains global)
  - `batch`: all files are one unit
- `--trace`
  - prints each parsed command (`file:line`) before executing it

## Busfile recognition

A path is treated as a busfile when any of the following is true:

- It ends with `.bus`.
- The file is executable and begins with a shebang line referencing `bus`:
  - `#!/usr/bin/bus`
  - `#!/usr/bin/env bus`

`bus` must not treat arbitrary readable files as busfiles unless they match those rules.

## Busfile format

A busfile is UTF-8 text.

### Lines

- Blank lines are ignored.
- Comment lines are ignored when first non-whitespace char is `#`.
- All other lines are treated as one `bus` command line.

### Tokenization and quoting

Each command line is tokenized using shell-like quoting rules:

- whitespace separates tokens
- single quotes `'...'` preserve literal content
- double quotes `"..."` preserve literal content (no interpolation)
- backslash `\` escapes the next character

Explicitly disallowed:

- `$VAR` expansion
- `$(...)` command substitution
- backticks
- pipes `|`, redirections `>`, `<`
- `;` command separators

If a line cannot be tokenized (for example unterminated quote), it is a busfile syntax error and execution must stop before any command executes.

### Command shape

First token is the dispatcher target, same as normal CLI:

```text
journal add ...
bank import ...
vat report ...
```

## Execution semantics

### Phase 1: Syntax preflight (mandatory; global)

Before executing any command, `bus` must perform syntax preflight across all provided busfiles:

- read all files
- tokenize each executable line
- ensure first token exists
- optional recommended target-resolution check without running targets

If syntax preflight fails, `bus` must:

- print `file:line: <message>`
- exit non-zero
- make no workspace changes

### Phase 2: Data validation (optional; best-effort)

Controlled by `bus.busfile.validation.level`:

- `syntax` (default): no module-level validation before execution
- `data` (optional): best-effort validation pass before apply

Degrade gracefully if module lacks non-mutating validation:

- default: skip validation for that command
- strict mode: fail early if `bus.busfile.validation.strict=true`

Recommended convention (not mandatory):

- module supports `--check` or `--dry-run`, or
- module supports `BUS_MODE=check` no-mutation behavior

### Phase 3: Apply (execution)

After successful preflight (and optional data validation), execute commands in file order, respecting scope and transaction provider.

- fail-fast on first command error
- stdout/stderr pass through
- with `--trace`, echo `file:line: bus <...>` before execution

#### Scope behavior for multiple busfiles

- scope `file` (default): execute files sequentially; each file its own apply unit
- scope `batch`: all files are one apply unit

## Transaction providers (optional)

Workspace atomicity is implemented by a transaction provider. Providers are optional and configurable. Default is `none`.

### Provider `none` (default)

- no workspace-level atomicity
- direct execution in current workspace
- partial changes possible on later failure

### Provider `git` (optional)

- atomicity via isolated Git branch/worktree and merge on success
- if workspace is not Git repo or Git unavailable, provider must fail clearly or fall back to `none` when configured
- may be slow on large datasets

### Provider `snapshot` (optional)

- atomicity via filesystem snapshot/rollback or equivalent platform mechanism
- environment-specific plug-in provider

### Provider `copy` (optional)

- atomicity via temporary copy, execute there, apply on success
- may be slow on large datasets

### Provider interface (internal)

- `Begin(scope) -> context`
- `RunCommand(context, argv, env, cwd) -> exitCode`
- `Commit(context)`
- `Rollback(context)`
- `Cleanup(context)`

## Configuration

Transaction and validation behavior must be configurable via:

1. `bus-preferences`
2. `datapackage.json`

Precedence:

- CLI overrides (`--transaction`, `--scope`, `--check`)
- bus-preferences
- datapackage defaults
- built-in defaults

### Proposed config keys

```json
{
  "bus": {
    "busfile": {
      "validation": {
        "level": "syntax",
        "strict": false
      },
      "transaction": {
        "provider": "none",
        "scope": "file",
        "fallback_to_none": true
      }
    }
  }
}
```

## Error handling and exit codes

### Error format

- syntax/tokenization error:
  - `2024-02.bus:17: syntax error: unterminated quote`
- dispatch failure (if target resolution is enabled):
  - `2024-02.bus:23: dispatch error: unknown target "bnak"`
- command failure:
  - `2024-01.bus:42: command failed (exit 1): journal add --date ...`

### Exit codes

- `0` success
- `1` command execution failed
- `2` usage error (invalid flags, missing file)
- `65` syntax/tokenization error

If a module returns a specific non-zero code, `bus` should return that same code for command-failed cases.

## Environment signals for modules

During busfile execution, `bus` must set:

- `BUS_BATCH=1`
- `BUS_BUSFILE=<path>`
- `BUS_BUSFILE_LINE=<n>`

## Ecosystem integration

### bus-replay export format

Once busfile support exists, `bus-replay` should export deterministic command logs as `.bus` files:

- default output one file per month/period (configurable), for example `YYYY-MM.bus`
- stable replayable `bus <module> ...` command lines
- directly executable via:
  - `bus YYYY-MM.bus`
  - `bus YYYY-MM.bus YYYY-MM+1.bus ...`

## Examples

### Single busfile content

```bus
#!/usr/bin/env bus

# 2024-02-29 Bank erp-bank-26246
bank add transactions --set bank_txn_id=erp-bank-26246 --set import_id=erp-bank-2024 --set booked_date=2024-02-29 --set value_date=2024-02-29 --set amount=-861.6800000000 --set currency=EUR --set counterparty_name='Qred Visa' --set counterparty_iban='' --set reference='411050319' --set message='700 / TILISIIRTO / 240229593619234599' --set end_to_end_id=erp-e2e-26246 --set source_id='bank_row:26246'

journal add --date 2024-02-29 --desc 'Bank erp-bank-26246 Qred Visa lyhennys' --debit 2949=861.68 --credit 1910=861.68 --source-id bank_row:26246:journal:1
```

### Multi-file busfile orchestration

```bus
#!/usr/bin/env bus

2024-01.bus
2024-02.bus
2024-03.bus
```

## Implementation design

### Dispatcher entrypoint changes

1. Parse existing global flags.
2. Identify first non-flag argument.
3. If recognized as busfile, enter busfile mode.
4. Else dispatch as normal module invocation.

No special-case dispatch is required for `run`.

### Busfile parsing

Implement a small tokenizer (or vetted shellwords parser) that:

- supports whitespace splitting, single/double quotes, backslash escapes
- performs no expansions
- preserves token order/content

Track:

- file path
- line number
- raw line
- `argv []string`

### Provider implementations

- `none`: direct execution
- `git`: isolated branch/worktree
- `snapshot`: external/specialized provider
- `copy`: temp copy + apply

## Testing

### Unit tests

- tokenizer:
  - quotes, escapes, whitespace, comments, blank lines
  - failure case: unterminated quotes
- busfile recognition:
  - `.bus` extension and shebang detection
  - collision avoidance with module names
- configuration precedence:
  - defaults vs datapackage vs preferences vs CLI override

### Integration tests

- syntax preflight across multiple files:
  - three files, one syntax error, verify no command executed
- provider `none`:
  - verify preflight then fail-fast execution
- provider `git` (when Git available):
  - verify all-or-nothing semantics for `file` and `batch` scopes

### Performance tests (required)

- benchmark tokenizer and preflight on large `.bus` files
- benchmark multi-file global preflight (`N` files, mixed command sizes)
- benchmark end-to-end apply orchestration in `none` provider mode
- where enabled, benchmark `git` provider overhead for `file` and `batch` scopes
- enforce regression thresholds in CI for key hot paths

## Documentation updates

- Update `docs/modules/bus`:
  - running `.bus` command files
  - month-based workflow examples
  - syntax preflight and optional atomicity providers
- Mention configurable atomicity via datapackage/bus-preferences and that Git is optional.
- Reference `bus-replay` as exporter of `.bus` files once available.

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
- [Repository](https://github.com/busdk/bus)

### Document control

Title: bus dispatcher and busfile execution SDD  
Project: BusDK  
Document ID: `BUSDK-DISPATCHER`  
Version: 2026-02-20  
Status: Draft  
Last updated: 2026-02-20  
Owner: BusDK development team
