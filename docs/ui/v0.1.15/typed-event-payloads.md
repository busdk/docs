---
title: Typed event payloads
description: BusDK UI v0.1.15 typed Go event payloads for GX callbacks.
---

## Contract

`v0.1.15` keeps callbacks as ordinary Go functions and adds typed payloads for
the intrinsic events named in [v0.1.12](../v0.1.12/intrinsic-callback-naming).
Payloads describe the browser event source without introducing string event
names, controller registries, or a JavaScript expression language.

Callback props may keep the simple signatures from earlier patches:

```gx
<button onClick={save}><Text value={"Save"}></Text></button>
<input name="title" onInput={setTitle}></input>
```

They may also accept the typed payload for that event:

```gx
<button onClick={saveFromButton}><Text value={"Save"}></Text></button>
<form onSubmit={saveForm}>
  <input name="title" onInput={setTitle}></input>
  <button type="submit"><Text value={"Save"}></Text></button>
</form>
```

```go
func saveFromButton(event gx.ClickEvent) {
	_ = event.TargetID
}

func saveForm(event gx.SubmitEvent) {
	event.PreventDefault()
	_ = event.FormID
	_ = event.SubmitterName
}
```

## Payloads

This patch defines only small payload structs needed by current portal flows:

```go
type ClickEvent struct {
	TargetID    string
	TargetName  string
	TargetValue string
	Dataset      map[string]string
}

type SubmitEvent struct {
	FormID         string
	SubmitterID    string
	SubmitterName  string
	SubmitterValue string
	Dataset         map[string]string
}

func (event *SubmitEvent) PreventDefault()
func (event SubmitEvent) DefaultPrevented() bool

type InputEvent struct {
	TargetID   string
	TargetName string
	Value      string
	Dataset    map[string]string
}

type ChangeEvent struct {
	TargetID   string
	TargetName string
	Value      string
	Dataset    map[string]string
}

type KeyboardEvent struct {
	TargetID string
	Key      string
	Code     string
	CtrlKey  bool
	AltKey   bool
	ShiftKey bool
	MetaKey  bool
	Repeat   bool
}

type FocusEvent struct {
	TargetID   string
	TargetName string
	Direction  FocusDirection
}

type FocusDirection string

const (
	FocusIn  FocusDirection = "in"
	FocusOut FocusDirection = "out"
)
```

String zero values mean the browser did not provide that field or the element
does not have that attribute. A nil `Dataset` means there were no `data-*`
attributes. Boolean zero values are `false`.

`SubmitEvent.DefaultPrevented()` is false until `PreventDefault()` is called.
The runtime must call browser `preventDefault` before returning from the
callback when the event was prevented. Simple `func()` submit callbacks keep
the existing default-prevention behavior from [v0.1.7](../v0.1.7/).

The `input` and `change` callbacks may still use `func(string)` when only the
current value is needed. Use payload signatures when the handler needs target
identity or metadata.

## Requirements

- Callback signature validation must accept only the documented simple or
  payload signatures.
- Payloads must be plain Go structs with stable fields.
- Payloads must not expose raw JavaScript values.
- Prevent-default control is explicit on payloads that support it.
- Missing optional browser data is represented by zero values or empty maps,
  not by panics.

## Boundary

This patch does not add `FormData`, file-list access, drag/drop data transfer,
storage, fetch, or resource helpers. It only gives current callbacks typed Go
payloads.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Callback props](../v0.1.6/callback-props)
- [Go WASM frontend runtime](../v0.1.7/)
- [Intrinsic callback naming](../v0.1.12/intrinsic-callback-naming)
