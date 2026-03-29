---
title: bus-customers — customer registry
description: bus customers maintains customer registry rows linked to canonical juridical entities from bus-entities.
---

## `bus-customers` — customer registry

### Synopsis

`bus customers init [-C <dir>] [global flags]`  
`bus customers list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus customers add --customer-id <customer-id> --entity-id <entity-id> [flags]`

### Description

`bus customers` keeps customer numbering separate from the legal-entity registry. Each row in `customers.csv` points to one canonical `entity_id` from `bus-entities`, while `customer_id` remains the business-facing customer number that can vary by ERP, branch, or department.

`init` bootstraps `bus-entities` automatically through its public Go library if the entity registry does not already exist. `add` requires `--customer-id` and `--entity-id`. When you omit `--display-name`, the module snapshots the linked entity display name into the customer row.

### Examples

```bash
bus customers init
bus entities add --entity-type organization --business-id 1234567-8 --display-name "Aurora Oy"
bus customers add --customer-id c-100 --entity-id fi:business-id:1234567-8
bus customers list --format tsv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-entities">bus-entities</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vendors">bus-vendors</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounts area](../layout/accounts-area)
- [bus-entities](./bus-entities)
