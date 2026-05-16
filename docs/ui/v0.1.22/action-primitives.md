---
title: Action primitives
description: BusDK UI v0.1.22 Go action primitives for callback dispatch and visible action state.
---

## Contract

`v0.1.22` adds Go action primitives for recurring click, change, and submit
flows. An action is a typed Go function with visible state: idle, running,
success, validation error, provider error, or canceled. Components can render
that state through ordinary GX nodes and request updates through the state
runtime.

```gx
save := uiaction.Action[Draft]{
	Name: "save-draft",
	Run: func(ctx context.Context, draft Draft) uiaction.Result {
		return client.Save(ctx, draft)
	},
}

func SaveButton(draft Draft) gx.Node {
	state := uiaction.UseAction(save)
	return <button onClick={state.Run(draft)} disabled={state.Running()}>
		<Text value={state.Label("Save")}></Text>
	</button>
}
```

Actions centralize dispatch, pending state, result projection, redacted failure
logging, and test fakes. They can be called from server-rendered markup,
mounted WASM views, and pure unit tests without embedding JavaScript clients.

## Requirements

- Actions are typed Go values, not string event registries.
- `RunAction` exposes context cancellation and deterministic result state.
- Busy, success, validation-error, provider-error, and canceled states are
  visible to renderers.
- Tests can fake action results without a browser or provider.
- Native form events use the helpers from
  [v0.1.19](../v0.1.19/event-form-helpers).

## Boundary

This patch does not define HTTP resources, session storage, redirects, upload
policy, or provider-specific errors. Actions describe local dispatch and result
state; resource and session primitives provide the host-facing pieces later.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UseState](../v0.1.17/use-state)
- [Event and form helpers](../v0.1.19/event-form-helpers)
- [UI testkit renderer](../v0.1.20/uikittest-renderer)
