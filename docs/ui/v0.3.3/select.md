---
title: Select UI component
description: Dedicated BusDK UI reference for Select.
---

## Purpose

`Select` is a form component. Native bounded option set. Use for bounded submitted values.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `options` | yes | array of `{value,label,disabled}` | Each option has string or number `value` and non-empty string `label`; optional `disabled` prevents selection. Empty option lists render a disabled empty select. Duplicate values fail validation. |
| `selected` | no | string, number, or binding | Selected value. Omitted selects no option unless the host form supplies a default. A value outside `options` fails validation. |

## Boundary

Selected state is explicit and deterministic. Product view models should provide
the selected value instead of relying on browser first-option defaults.

## Example

```yaml
kind: Select
props:
  name: status
  selected: review
  options:
    - value: review
      label: Review
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
