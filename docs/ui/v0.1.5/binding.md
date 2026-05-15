---
title: Binding UI concept
description: BusDK UI binding references, defaults, and scoped data paths.
---

## Purpose

A binding maps data into template props, component props, loop scopes, or
controller-owned resource payload fields without coupling the view to a
specific data storage format. The primary binding surface is Go. The data
object may be any provider result, typed Go value, fixture, or host-supplied
object that the controller can expose through typed helpers.

## Contract

Use Go helpers when a component prop reads from data:

```go
func BindDraft(d Draft) gx.Bindings {
	return gx.Bindings{
		"draftTitle": gx.Value(d.Title),
	}
}
```

In templates, `{name}` reads a Go value in scope. Fixture documents may still
use named bindings and object-form `bind` values when a portable YAML or JSON
test fixture is clearer than Go setup.

Go bindings resolve from lexical Go scope and typed helper inputs. Fixture
paths resolve from the current component data scope: repeated-item data is
checked first, then component props, then document data. Missing optional
bindings render the component default; missing required bindings fail
validation.

Fixture binding selectors use this path grammar:

```text
path        = segment { "." segment | "[" index "]" | "[" quoted-key "]" }
segment     = letter { letter | digit | "_" }
index       = digit { digit }
quoted-key  = quoted string with Go-style escapes
```

Dot segments read struct fields, methods with no parameters, or map keys by
name. Bracket indexes read arrays or slices. Bracket quoted keys read map keys
that contain dots, spaces, hyphens, or brackets. Selectors do not support
function calls, arithmetic, comparisons, wildcards, filters, optional chaining,
or provider calls. A missing selector segment is treated as a missing binding:
optional bindings use the component default, and required bindings fail
validation with the missing path.

Bindings are selectors, not expression strings and not execution targets.
Computed values, permission decisions, provider calls, navigation, and handler
selection belong in the controller/runtime layer before the view renders or
when an event fires.

Template, generated Go, model data, binding helpers, and controller/runtime
code stay separate. The template owns structure, generated Go owns checked
render implementation, model data may be any host-provided shape, bindings adapt
that model to view values, and controllers own side effects.

## Defaults

Component props should declare defaults whenever omission is meaningful. Go
binding helpers and fixture binding files may omit bindings for defaulted
props; templates should only require a binding when the component cannot render
a useful or safe state without it.

Missing values follow one rule: explicit binding value first, fixture default
when a fixture is active, component default next, then a validation error for a
required value or the declared empty value for an optional value.

## Template

```gx
package notesui

var draftTitleTemplate = <Text value={draftTitle}></Text>
```

## Data

```yaml
draft:
  title: April close
```

## Fixture Bindings

```yaml
bindings:
  draftTitle: draft.title
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Go bindings](./go-bindings)
- [Custom component concept](../v0.1.4/component)
