## CLI command naming

BusDK module CLIs use short, consistent subcommand names so that the same verb means the same kind of operation across modules. All module CLIs in the [Module CLI reference](../modules/index) follow these conventions.

Use a single short verb when the module has only one operation of that type. For example, if a module has exactly one command that adds a record to its primary dataset, name it `add` rather than a longer form like `add-item`. That keeps `bus accounts add`, `bus entities add`, `bus journal add`, and `bus inventory add` parallel. When a module has multiple distinct add-like operations (for example, adding a header vs adding a line), the subcommands must be distinguished — for example `add` for the main entity and a qualified form or positional for the sub-entity (e.g. `bus invoices add` for a new invoice and `bus invoices <invoice-id> add` for a line).

Use the same verb across modules for the same kind of action. `init` creates baseline datasets and schemas when absent. `list` prints records in deterministic order. `add` appends a new record to the primary dataset. `validate` checks data against schemas or invariants. Modules that need extra verbs use them consistently: `report` and `export` for outputs, `open`, `close`, and `lock` for lifecycle state, `match` and `allocate` for reconciliation, and so on. Avoid introducing a new verb when an existing one already fits (e.g. use `add` for the single “add item” command, not `add-item`).

For multi-word concepts that are standard terms (e.g. report types), hyphenated subcommand names are acceptable: `trial-balance`, `general-ledger`, `profit-and-loss`, `balance-sheet`. For a single “record a movement” operation, use the short verb `move` rather than `record-movement`.

This document defines the current naming convention only. Deprecated or alternate command names are not maintained; the canonical names are those documented in each module’s CLI reference and in the [minimum required command surface](./minimum-command-surface).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./global-flags">Standard global flags</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next">&rarr; <a href="./minimum-command-surface">Minimum required command surface</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference](../modules/index)
- [Command structure and discoverability](./command-structure)
- [Minimum required command surface](./minimum-command-surface)
