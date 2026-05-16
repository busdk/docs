---
title: Expanded intrinsic elements
description: BusDK UI v0.1.14 safe HTML-compatible intrinsic element table.
---

## Contract

`v0.1.14` expands the lowercase intrinsic element table introduced in
[v0.1.6](../v0.1.6/intrinsic-elements). The table stays closed: every new tag
and prop must be deliberate, typed, validated, and safe for deterministic HTML
rendering and Go WebAssembly mounting.

This patch adds only the portal baseline needed by current applications.

`a`:

| Prop       | Type   | Default | Constraints                  |
| ---------- | ------ | ------- | ---------------------------- |
| `href`     | string | none    | safe relative, same-origin, or `https` URL |
| `download` | bool   | `false` | omitted when false           |
| `id`       | string | none    | safe HTML id                 |
| `class`    | string | none    | safe class text              |
| `title`    | string | none    | escaped text                 |
| `role`     | string | none    | safe role token              |
| `aria-*`   | string | none    | escaped text                 |
| `data-*`   | string | none    | escaped text                 |

`textarea`:

| Prop           | Type   | Default | Constraints        |
| -------------- | ------ | ------- | ------------------ |
| `name`         | string | none    | safe form name     |
| `value`        | string | `""`    | escaped text       |
| `placeholder`  | string | none    | escaped text       |
| `required`     | bool   | `false` | omitted when false |
| `autocomplete` | string | none    | safe token         |
| `id`           | string | none    | safe HTML id       |
| `class`        | string | none    | safe class text    |
| `aria-*`       | string | none    | escaped text       |
| `data-*`       | string | none    | escaped text       |

`select`:

| Prop       | Type   | Default | Constraints        |
| ---------- | ------ | ------- | ------------------ |
| `name`     | string | none    | safe form name     |
| `value`    | string | none    | matches option value when controlled |
| `multiple` | bool   | `false` | omitted when false |
| `required` | bool   | `false` | omitted when false |
| `id`       | string | none    | safe HTML id       |
| `class`    | string | none    | safe class text    |
| `aria-*`   | string | none    | escaped text       |
| `data-*`   | string | none    | escaped text       |

`option`:

| Prop       | Type   | Default | Constraints        |
| ---------- | ------ | ------- | ------------------ |
| `value`    | string | body    | escaped text       |
| `selected` | bool   | `false` | omitted when false |
| `disabled` | bool   | `false` | omitted when false |
| `label`    | string | none    | escaped text       |

`pre`:

| Prop     | Type   | Default | Constraints     |
| -------- | ------ | ------- | --------------- |
| `id`     | string | none    | safe HTML id    |
| `class`  | string | none    | safe class text |
| `title`  | string | none    | escaped text    |
| `aria-*` | string | none    | escaped text    |
| `data-*` | string | none    | escaped text    |

`iframe`:

| Prop     | Type   | Default | Constraints              |
| -------- | ------ | ------- | ------------------------ |
| `src`    | string | none    | safe relative, same-origin, or `https` URL |
| `title`  | string | required when `src` is set | escaped text |
| `id`     | string | none    | safe HTML id             |
| `class`  | string | none    | safe class text          |
| `aria-*` | string | none    | escaped text             |
| `data-*` | string | none    | escaped text             |

File-capable `input`:

| Prop       | Type   | Default | Constraints        |
| ---------- | ------ | ------- | ------------------ |
| `type`     | string | `text`  | `file` added here  |
| `name`     | string | none    | safe form name     |
| `accept`   | string | none    | comma-separated MIME or extension tokens |
| `multiple` | bool   | `false` | omitted when false |
| `required` | bool   | `false` | omitted when false |
| `id`       | string | none    | safe HTML id       |
| `class`    | string | none    | safe class text    |
| `aria-*`   | string | none    | escaped text       |
| `data-*`   | string | none    | escaped text       |

URL-bearing attributes must be validated. Relative URLs and same-origin paths
are allowed. External URLs require an explicit safe scheme, such as `https`.
Inline JavaScript, raw event-handler strings such as `onclick`, and unsafe
schemes such as `javascript:` are rejected.

```go
func AttachmentLink(url string) gx.Node {
	return gx.Element("a",
		gx.Props{
			"download": true,
			"href":     url,
		},
		gx.Text("Download"),
	)
}
```

## Requirements

- Unsupported tags still fail validation.
- Unsupported props still fail validation.
- Boolean attributes require boolean values.
- URL attributes reject unsafe schemes before static render and before WASM
  mount.
- `data-*` and `aria-*` remain string-safe extension points, not arbitrary
  callback or script channels.
- File inputs expose safe element attributes only; file access itself is not
  added in this patch.

## Boundary

This patch does not add event payload structs, form data extraction, file-list
access, drag/drop, storage, fetch, or resource helpers. It only makes the safe
intrinsic render surface large enough for current portal markup.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Props reference](../v0.1.1/props)
- [Intrinsic interactive elements](../v0.1.6/intrinsic-elements)
- [Intrinsic callback naming](../v0.1.12/intrinsic-callback-naming)
