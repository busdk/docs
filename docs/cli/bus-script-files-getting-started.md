---
title: `.bus` files — getting started step by step
description: A simple step-by-step guide for first-time users to create, check, and run .bus files with the bus dispatcher.
---

## `.bus` files — first run

Use this guide if you want the simplest path to run bookkeeping commands from a `.bus` file.

## Step 1: Go to your workspace root

Open a terminal in your BusDK workspace (the directory that contains your datasets and `datapackage.json` when present).

```bash
cd /path/to/your/workspace
```

## Step 2: Create your first `.bus` file

Create a file called `first-run.bus`.

```bash
cat > first-run.bus <<'BUS'
# First .bus run
# Add one balanced journal entry
journal add \
  --date 2026-02-20 \
  --desc "First .bus entry" \
  --debit 1910=10.00 \
  --credit 3000=10.00
BUS
```

A `.bus` file is plain UTF-8 text. Each non-comment line is one command.

## Step 3: Run a safe check first

Validate the file before applying any changes.

```bash
bus --check first-run.bus
```

If check passes, continue. If check fails, fix the reported `file:line` and run check again.

## Step 4: Run the file

Apply the commands.

```bash
bus first-run.bus
```

The dispatcher reads the file, validates syntax first, then runs commands in order.

## Step 5: Confirm result

Use a read command from the module you changed. For journal example:

```bash
bus journal list
```

## Step 6: Use monthly files

A common pattern is one file per month.

```bash
bus 2026-01.bus 2026-02.bus 2026-03.bus
```

`bus` does syntax preflight for all provided files before executing any of them.

## Step 7: Add trace when debugging

Print each parsed command with file and line number.

```bash
bus --check --trace first-run.bus
```

## Minimal file rules

- Lines starting with `#` are comments.
- Blank lines are ignored.
- A trailing `\` continues the command on the next physical line.
- Lines ending with `.bus` include another bus file.
- Use quotes when values contain spaces.

## Common first errors

- Unknown module or typo in command name.
- Unbalanced journal posting (debits and credits differ).
- Unterminated quote in a line.

## Next step

After your first run works, move to the full guide for quoting, includes, scope, transactions, and exit codes in [`.bus` script files — writing and execution guide](./bus-script-files).
If you want a practical file that combines several module commands in one run, use [`.bus` getting started — multiple commands together](./bus-script-files-multi-command-getting-started).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./interactive-and-scripting-parity">Non-interactive use and scripting</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-script-files">`.bus` script files (writing and execution guide)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus module reference](../modules/bus)
- [`.bus` getting started — multiple commands together](./bus-script-files-multi-command-getting-started)
- [`.bus` script files — writing and execution guide](./bus-script-files)
- [Module SDD: bus](../sdd/bus)
