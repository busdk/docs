---
title: Select UI component
description: Dedicated BusDK UI reference for Select.
---

## Purpose

`Select` is a native bounded option helper. Use it for submitted values that
must come from a known option set.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `options` | yes | Go slice of option values | Each option has a unique string `id`, public-safe `label`, and optional disabled state. Empty option lists render a disabled empty select. Duplicate ids fail validation. |
| `selected` | no | string | Selected option id. Omitted selects no option unless the parent supplies a default. A non-empty id outside `options` fails validation. |
| `onChange` | no | Go callback | Receives the selected id as a simple string callback or typed change event callback. |

## Boundary

Selected state is explicit and deterministic. Product view models should provide
the selected value instead of relying on browser first-option defaults.

## Example

```gx
func StatusField(status string, setStatus func(string)) gx.Node {
  options := []ui.Option{
    {ID: "draft", Label: "Draft"},
    {ID: "review", Label: "Review"},
    {ID: "approved", Label: "Approved"},
  }

  return (
    <Field label="Status">
      <Select name="status" selected={status} options={options} onChange={setStatus}></Select>
    </Field>
  )
}
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go
expressions inside markup bodies. [Typed event payloads](../v0.1.15/typed-event-payloads)
document when an `onChange` callback uses a payload instead of a plain string.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
