---
title: Custom component checks
description: BusDK UI v0.1.4 author-visible custom component checks.
---

## Valid Component

Save the valid example from [component functions](./component-functions)
as `notice.gx`. The entry name in that fixture is `noticeExample`. With BusDK
commands on `PATH`, run:

```sh
bus gx fmt --check notice.gx
bus gx lint --format json notice.gx
bus gx compile notice.gx --output notice.go
```

Valid fixtures exit `0`; `lint --format json` prints an empty diagnostics
array, and `compile` writes `notice.go`.

## Invalid Components

Keep the valid `notice.gx` component definition from
[component functions](./component-functions) beside the prop-related invalid
files. Save each invalid case as the listed file and run
`bus gx lint --format json <file>`. Lint exits non-zero and reports the listed
diagnostic code.

`unknown-component.gx` reports `unknown-component`:

```gx
package notices

var badTag = <Notcie message={"Saved"}></Notcie>
```

`missing-prop.gx` reports `missing-prop`:

```gx
package notices

var missingProp = <Notice></Notice>
```

`unknown-prop.gx` reports `unknown-prop`:

```gx
package notices

var unknownProp = <Notice message={"Saved"} tone={"info"}></Notice>
```

`unexpected-children.gx` reports `unexpected-children`:

```gx
package notices

var unexpectedChildren = <Notice message={"Saved"}><span>Extra</span></Notice>
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component call patch](./custom-components)
- [Component functions](./component-functions)
