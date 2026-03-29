---
title: bus-vendors — vendor registry
description: bus vendors maintains vendor registry rows linked to canonical juridical entities from bus-entities.
---

## `bus-vendors` — vendor registry

### Synopsis

`bus vendors init [-C <dir>] [global flags]`  
`bus vendors list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus vendors add --vendor-id <vendor-id> --entity-id <entity-id> [flags]`

### Description

`bus vendors` keeps vendor numbering separate from the legal-entity registry. Each row in `vendors.csv` points to one canonical `entity_id` from `bus-entities`, while `vendor_id` remains the business-facing supplier number that can vary by ERP, branch, or department.

`init` bootstraps `bus-entities` automatically through its public Go library if the entity registry does not already exist. `add` requires `--vendor-id` and `--entity-id`. When you omit `--display-name`, the module snapshots the linked entity display name into the vendor row.

### Examples

```bash
bus vendors init
bus entities add --entity-type organization --business-id 1234567-8 --display-name "Aurora Oy"
bus vendors add --vendor-id v-100 --entity-id fi:business-id:1234567-8
bus vendors list --format tsv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-customers">bus-customers</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-period">bus-period</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounts area](../layout/accounts-area)
- [bus-entities](./bus-entities)
