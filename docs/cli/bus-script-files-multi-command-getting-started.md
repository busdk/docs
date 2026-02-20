---
title: "`.bus` getting started — multiple commands together"
description: "Step-by-step guide to run multiple BusDK module commands in one .bus file, including a starter flow for bus-dev, bus-agent, and bus-run."
---

## `.bus` getting started with multiple commands

This guide shows how to run several module commands in one `.bus` file. It includes two practical starter flows:

1. bookkeeping commands together in one run
2. developer and agent tooling commands (`dev`, `agent`, `run`) in one run
3. focused GUI handoff with `books` for end-user form input

## Flow A: bookkeeping starter file

### Step 1: open your workspace root

```bash
cd /path/to/your/workspace
```

### Step 2: create `bookkeeping-starter.bus`

```bash
cat > bookkeeping-starter.bus <<'BUS'
# Initialize baseline datasets for a new workspace
init all

# Add a small chart of accounts baseline
accounts add --code 1910 --name "Bank" --type asset
accounts add --code 3000 --name "Consulting Income" --type income
accounts add --code 2930 --name "VAT Payable" --type liability

# Add one customer entity
entities add --id CUST-ACME --name "Acme Oy"

# Record one balanced posting
journal add \
  --date 2026-02-20 \
  --desc "Starter posting" \
  --debit 1910=100.00 \
  --credit 3000=100.00

# Validate workspace after changes
validate
BUS
```

### Step 3: run check mode first

```bash
bus --check bookkeeping-starter.bus
```

### Step 4: apply the file

```bash
bus bookkeeping-starter.bus
```

### Step 5: verify quickly

```bash
bus accounts list
bus journal balance --as-of 2026-02-28
```

## Flow B: `dev`, `agent`, and `run` in one `.bus` file

Use this flow in a module or project directory where you want a quick diagnostics-and-automation check.

### Step 1: create `automation-starter.bus`

```bash
cat > automation-starter.bus <<'BUS'
# Show available bus-dev runnable tokens in current context
# (outside a repo this still prints built-ins)
dev list

# Detect installed agent runtimes
agent detect

# Show available bus-run tokens in current directory context
run list

# Show bus-run context variables for prompt/script authors
run context
BUS
```

### Step 2: run with trace

```bash
bus --trace automation-starter.bus
```

If `agent detect` returns no runtimes, install one runtime and run the file again.

## Flow C: collect end-user details in a focused GUI form

Use this when a `.bus` flow needs human-provided details (for example bank transaction context) before continuing.

### Step 1: add `books` launch command in your `.bus` file

```bus
# Open only journal/new in GUI and prefill known values.
# User can fill remaining fields and close when done.
books serve --print-url --open-view /journal/new --view-only \
  --view-param date=2026-02-20 \
  --view-param desc="Provide bank transaction details"
```

### Step 2: run and open the printed URL

```bash
bus --trace your-flow.bus
```

The URL includes the target route and launch values (hash query). In `--view-only` mode, Bus Books hides the normal navigation shell so the user sees only the intended form.

## Practical notes

- In `.bus` files, write module targets directly (`journal ...`, `dev ...`, `agent ...`, `run ...`), not `bus <module> ...`.
- One logical command is one command; use trailing `\` for line continuation when needed.
- Use `bus --check` before applying bookkeeping changes.
- Use `--trace` when debugging line-by-line behavior.

## Next step

After these starter flows, continue with:

- [`.bus` files — getting started step by step](./bus-script-files-getting-started)
- [`.bus` script files — writing and execution guide](./bus-script-files)

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-script-files-getting-started">`.bus` files — getting started step by step</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-script-files">`.bus` script files (writing and execution guide)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus module reference](../modules/bus)
- [bus-dev module reference](../modules/bus-dev)
- [bus-agent module reference](../modules/bus-agent)
- [bus-run module reference](../modules/bus-run)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Module SDD: bus](../sdd/bus)
