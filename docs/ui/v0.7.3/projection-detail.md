---
title: Library projection detail
description: BusDK UI library projected evidence detail contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`ProjectionDetail`](./projection-detail-component) renders public-safe
projection summary and evidence references. Provider payloads are projected
before render; raw private payloads are rejected.

| Field | Required | Behavior |
| --- | --- | --- |
| `title` | yes | Non-empty public-safe string. |
| `summary` | no | Public-safe string; omitted when unavailable. |
| `fields` | no | Array of `{label,value}` strings. `label` is non-empty public-safe text; `value` is public-safe text or number formatted by the controller. |
| `evidence` | no | Array of `{id,label,operation}` references. `id` is non-empty provider evidence id, `label` is public-safe text, and operation is `open`, `download`, or `preview`. |

Raw provider payloads, private customer data, tokens, SQL, stack traces, and
credential headers fail validation before render and report diagnostics through
the runtime error path:

```yaml
type: validation
component: ProjectionDetail
field: fields[0].value
reason: unsafe-content
```

The product view model owns which fields are visible and how evidence relates
to the product workflow.

## Consequence

Projection detail displays inspectable evidence context without exposing raw
provider payloads.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [ProjectionDetail](./projection-detail-component)
- [Evidence](../v0.7.1/evidence)
