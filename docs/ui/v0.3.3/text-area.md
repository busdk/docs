---
title: TextArea UI component
description: Dedicated BusDK UI reference for TextArea.
---

## Purpose

`TextArea` is a form component. Multiline text field. Use for notes, comments,
prompts, and drafts.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `value` | no | string or Go value | Current multiline content. Omitted renders an empty text area. Values must resolve to text or a value that can be deterministically formatted as text. |
| `rows` | no | integer | Visible row count. Defaults to `4`; valid values are positive integers from `1` through `40`. |

## Boundary

Multiline content is HTML-escaped before rendering. Markup in bound or user text
is displayed literally, not interpreted. Invalid non-text values fail
validation instead of being stringified unpredictably.

## Example

```yaml
kind: TextArea
props:
  name: body
  rows: 8
  value:
    bind: draft.body
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
