---
title: Library assistant models
description: BusDK UI library assistant model selection contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`AIModelSelect`](./ai-model-select) renders model choice from
controller-supplied model options and selected model id. Selection emits
interaction identity through the configured event.

| Prop | Required | Behavior |
| --- | --- | --- |
| `models` | yes | Array of `{id,label}` objects. `id` is a unique string; `label` is public-safe text. |
| `value` | no | Selected model id. Empty means no selected model. Unknown ids fail validation. |
| `select` | no | Runtime event name emitted when the user selects a model; omitted suppresses event emission. |

Selection emits source identity and selected item id. The `event` value is the
component `select` prop value; `select-model` is only the example event name
below.

```go
emitted := map[string]any{
	"event": "select-model",
	"source": map[string]string{
		"id":   "model-picker",
		"path": "/AIPanel[0]/AIModelSelect[0]",
	},
	"item": map[string]string{
		"id": "gpt-example",
	},
}
```

Provider availability, model policy, account entitlements, and fallback
selection are applied by the product controller before rendering. The component
receives only allowed options.

## Consequence

Model selection is reusable because policy is projected before render.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIModelSelect](./ai-model-select)
- [Callback props](../v0.1.6/callback-props)
