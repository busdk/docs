---
title: bus-entities — juridical entity registry
description: bus entities maintains canonical juridical entity rows for a BusDK workspace and derives organization entity IDs from official identifiers such as business IDs and org IDs.
---

## `bus-entities` — juridical entity registry

### Synopsis

`bus entities init [-C <dir>] [global flags]`  
`bus entities list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus entities add --entity-type organization --display-name <name> (--business-id <id>|--org-id <id>) [-C <dir>] [global flags]`  
`bus entities add --entity-type person --display-name <name> --entity-id <prefixed-id> [-C <dir>] [global flags]`

### Description

`bus entities` owns the canonical juridical entity registry for a workspace. The dataset lives in `entities.csv` with a beside-the-table schema `entities.schema.json` at the workspace root.

Organization rows use official identifiers. `--business-id` and `--org-id` feed the canonical `entity_id` format, so a Finnish business ID becomes `fi:business-id:<value>` and an org or association ID becomes `fi:org-id:<value>`. If both identifiers are present on one row, the canonical `entity_id` is still derived from `business_id` and the `org_id` is stored on the same entity.

Person rows are also supported, but until a dedicated person-identifier field exists they require an explicit prefixed `--entity-id`.

### Commands

`init` creates the entity dataset and schema when they are missing. `list` validates the dataset and prints `entity_id`, `entity_type`, and `display_name` as TSV. `add` appends one validated entity row.

The public Go integration surface is split into three small packages. `paths` exposes the workspace-relative file locations, `bootstrap` ensures the entity registry exists, and `registry` provides validated read-only lookup access for dependent modules such as `bus-customers` and `bus-vendors`.

### Examples

```bash
bus entities init
bus entities add --entity-type organization --business-id 1234567-8 --display-name "Aurora Oy" --org-id ry-100
bus entities add --entity-type organization --org-id vero-fi --display-name "Vero Finland"
bus entities add --entity-type person --entity-id fi:person:matti-001 --display-name "Matti Meikalainen"
bus entities list --format tsv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-accounts">bus-accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-customers">bus-customers</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounts area](../layout/accounts-area)
- [Minimal workspace baseline](../layout/minimal-workspace-baseline)
- [CLI command naming](../cli/command-naming)
