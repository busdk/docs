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
| `value` | no | string or binding | Current multiline content. Omitted renders an empty text area. Bindings must resolve to text or a value that can be deterministically formatted as text. |
| `rows` | no | integer | Visible row count. Defaults to `4`; valid values are positive integers from `1` through `40`. |

## Boundary

Multiline content is HTML-escaped before rendering. Markup in bound or user text
is displayed literally, not interpreted. Invalid non-text binding values fail
validation instead of being stringified unpredictably.

## Example

```yaml
kind: TextArea
props:
  name: body
  rows: 8
  value: { bind: draft.body }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./date-input">DateInput</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./select">Select</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
