---
title: bus-init — initialize a new BusDK workspace
description: bus init bootstraps a workspace by running bus config init first and then, when requested, the selected module init commands in a fixed order.
---

## `bus init` — initialize a new BusDK workspace

`bus init` is the workspace bootstrap command. Use it when you want to create the initial configuration only, or when you want one command to run the chosen module `init` commands in the correct order.

It does not implement the module inits itself. Instead, it delegates to `bus config init` first and then to the selected module init commands.

### Common tasks

Create only the workspace configuration:

```bash
bus init
```

The same config-only bootstrap with the explicit subcommand:

```bash
bus init defaults
```

Create a practical accounting baseline without every module:

```bash
bus init --accounts --entities --period --journal --invoices --attachments --bank
```

Create the full baseline and leave out one module:

```bash
bus init all --no-payroll
```

The same full-bootstrap flow with the flag form:

```bash
bus init --all --no-payroll
```

Initialize another workspace directory without changing your shell directory:

```bash
bus init -C ./customer-a all --no-assets --no-inventory
```

### Synopsis

`bus init [defaults | all] [--all] [--no-accounts] [--no-entities] [--no-period] [--no-journal] [--no-invoices] [--no-vat] [--no-attachments] [--no-bank] [--no-budget] [--no-assets] [--no-inventory] [--no-loans] [--no-payroll] [--accounts] [--entities] [--period] [--journal] [--invoices] [--vat] [--attachments] [--bank] [--budget] [--assets] [--inventory] [--loans] [--payroll] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`

### How it behaves

With no subcommand and no module flags, `bus init` only runs `bus config init`. This creates or repairs `datapackage.json` but does not create domain datasets such as accounts, journal, invoices, or bank rows.

`defaults` means the same config-only behavior explicitly.

`all` runs `bus config init` and then all supported data-owning module init commands in a fixed order. `--all` means the same thing in flag form. Use `--no-<module>` flags to skip selected modules.

If you pass explicit module flags instead of `all` or `--all`, only those selected modules run after config init.

### When should you use which style?

Use plain `bus init` or `bus init defaults` when you only want the workspace configuration first and will build the rest step by step.

Use explicit module flags when you want a small, deliberate baseline for one use case.

Use `all` when you want a maximal starting point and are comfortable pruning with `--no-...` flags.

### Typical workflow

For many users the first steps in a clean workspace look like this:

```bash
bus init --accounts --entities --period --journal --invoices --attachments --bank
bus config set --business-name "Example Oy" --business-id 1234567-8
bus period add --period 2026-01 --retained-earnings-account 3200
bus period open --period 2026-01
```

If you prefer to bootstrap gently:

```bash
bus init
bus config set --business-name "Example Oy"
bus accounts init
bus period init
bus journal init
```

### Important details

`bus init` always runs `bus config init` first.

It depends on the `bus` dispatcher being available in `PATH`, because it calls module commands through that dispatcher.

If one delegated step fails, `bus init` stops immediately and returns that failure.

`--no-<module>` flags only matter with `all` or `--all`.

`defaults` forces config-only bootstrap even if `--all` is also present.

### Output and flags

These commands use the normal [Standard global flags](../cli/global-flags), except `--format` is not meaningful here.

`-C` is the most useful flag when you manage multiple workspaces.

For the complete bootstrap matrix, run `bus init --help`.

### Files

`bus init` does not own the files it creates indirectly. `datapackage.json` belongs to [bus-config](./bus-config), accounts files belong to [bus-accounts](./bus-accounts), journal files belong to [bus-journal](./bus-journal), and so on.

### Exit status

`0` on success. Non-zero on invalid usage, missing `bus` dispatcher, or any delegated module init failure.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus init defaults
init defaults

# same as: bus init --accounts --entities --period --journal
init --accounts --entities --period --journal
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-config">bus-config</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-init](../modules/bus-init)
- [bus-config CLI reference](./bus-config)
- [Layout: Minimal workspace baseline](../layout/minimal-workspace-baseline)
- [Workflow: Initialize repo](../workflow/initialize-repo)
