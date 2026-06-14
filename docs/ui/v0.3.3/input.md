---
title: Input UI component
description: Dedicated BusDK UI reference for Input.
---

## Purpose

`Input` is the public generic typed input component. Use it when no named
helper fits, and pair visible inputs with a `Field` label or an explicit
accessible label supplied by the surrounding form. The preferred node-first
path is `ui.Input` inside `FieldProps.RenderControlNode`.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `type` | yes | HTML input type | Exact accepted set: `text`, `search`, `email`, `url`, `number`, `date`, `password`, `checkbox`, `radio`, `hidden`. Unsupported values fail validation. |
| `name` | yes | string | Submitted field name. |
| `value` | no | scalar | Current value. Required for each `radio` option so options sharing a `name` submit distinct values instead of browser default `on`. |
| `checked` | no | boolean | Applies only to checkbox/radio controls. Default `false`; checked checkbox controls submit `value` or `on` when value is omitted, checked radio controls submit their explicit `value`, and unchecked controls submit nothing. |
| `onInput` | no | `func(string)` or `func(gx.InputEvent)` | Applies to text-like controls when the parent wants live edits. The string form receives the current value. |
| `onChange` | no | `func(string)`, `func(bool)`, `func()`, or `func(gx.ChangeEvent)` | Applies to committed changes and checked controls. Text-like controls pass the current value to `func(string)`. Checkbox and radio controls pass checked state to `func(bool)` or may use `func()` when the parent already knows which control changed. |
| `labelledBy` | no | element id | Associates a bare input with external visible label text when it is not wrapped by `Field`. Either `Field` or `labelledBy` must provide the accessible name for visible inputs. |

## Boundary

This patch covers scalar form controls. Bare visible inputs must have an
accessible name through `Field` or `labelledBy`; hidden inputs do not need a
visible label. The public `pkg/ui` facade exposes `ui.Input` as the node-first
entry point and `ui.RenderHTML` for the render boundary.

## Example

```gx
func QuantityField(quantity string, setQuantity func(string)) gx.Node {
  return (
    <Field label="Quantity">
      <Input type="number" name="quantity" value={quantity} onInput={setQuantity}></Input>
    </Field>
  )
}
```

Checkbox and radio controls use the same component with explicit `checked` state. A simple
toggle callback is acceptable when the parent component owns the previous state:

```gx
func IncludeArchivedField(includeArchived bool, toggleArchived func()) gx.Node {
  return (
    <Field label="Include archived records">
      <Input type="checkbox" name="include_archived" value="yes" checked={includeArchived} onChange={toggleArchived}></Input>
    </Field>
  )
}
```

Node-first public callers can use the same shape through `pkg/ui`:

```go
package notesui

import (
	"github.com/busdk/bus-ui/pkg/ui"
)

func quantityField(quantity string, setQuantity func(string)) (string, error) {
	node, err := ui.Field(ui.FieldProps{
		Label:       "Quantity",
		ControlID:   "quantity",
		ControlName: "quantity",
		RenderControlNode: func(attrs map[string]string) (ui.GxNode, error) {
			return ui.Input(ui.InputProps{
				Type:  ui.InputTypeNumber,
				Name:  "quantity",
				Value: quantity,
				OnInput: setQuantity,
				Attrs: attrs,
			})
		},
	})
	if err != nil {
		return "", err
	}
	return ui.RenderHTML(node)
}
```

## Legacy compatibility

The older `InputNodeChecked` and `TextInputNodeChecked` helpers remain
available for migration, but they are no longer the preferred public path.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
