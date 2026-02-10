## bus-entities

### Name

`bus entities` — manage counterparty reference data.

### Synopsis

`bus entities <command> [options]`

### Description

`bus entities` maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules. Entity data is schema-validated and append-only for auditability.

### Commands

- `init` creates the baseline entity datasets and schemas.
- `list` prints the entity registry in stable identifier order.
- `add` adds a new entity record.

### Options

`add` accepts `--id <entity-id>` and `--name <display-name>`. `list` has no module-specific filters. For global flags and command-specific help, run `bus entities --help`.

### Files

Entity datasets and their beside-the-table schemas in the entities/reference area.

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-accounts">bus-accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-period">bus-period</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-entities](../sdd/bus-entities)
- [Data organization: Data package organization](../data/data-package-organization)

