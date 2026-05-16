---
title: Go browser and UI boundary review
description: Review browser-adjacent Go, renderer safety, safe URLs, escaped markup, projected view models, and accessible output.
---

## Browser Boundary

Browser-adjacent Go should keep host APIs behind narrow adapters. Direct
browser globals, JavaScript callbacks, DOM mutation, raw HTML, and runtime
diagnostics should be owned by a small testable boundary. Rendering code must
validate before serializing, escape text and attribute values, keep deterministic
attribute ordering, and avoid serializing callback functions, secrets, or
diagnostic metadata into DOM attributes.

URL-bearing fields should accept only same-origin paths, host-resolved
resources, or explicitly allowlisted HTTPS origins. Reject `javascript:`,
`data:`, path traversal, credential-bearing URLs, and sensitive-looking public
runtime config keys before rendering or request execution.

Bad:

```go
fmt.Fprintf(w, `<a href="%s">%s</a>`, link.URL, link.Label)
```

Better:

```go
type LinkView struct {
	URL   SafeURL
	Label string
}

func NewLinkView(link Link) (LinkView, error) {
	url, err := ValidatePublicURL(link.URL)
	if err != nil {
		return LinkView{}, err
	}
	return LinkView{URL: url, Label: link.Label}, nil
}
```

Prefer `html/template` or the project's renderer helpers for output. The
review point is that URLs and text are validated before they reach markup.

## Projected View Models

UI-producing Go should project before it renders. Provider DTOs, raw provider
errors, authorization checks, and permission policy belong in provider or
product projection code, not in generic renderers.

View models should contain the visible labels, controls, events, errors,
loading and empty states, links, and permissions needed by the renderer. Review
generated or server-rendered UI for accessible names, form labels, text status
changes, table headers, safe external-link attributes, and an audited sanitizer
before any rich text or raw HTML reaches the tree.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./http-and-service-boundaries">HTTP and service boundaries</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./validation-and-domain-safety">Validation and domain safety</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../../ui/)
- [Accessibility and performance](../fi-webview-accessibility-and-performance)
- [LLM finding patterns](./llm-finding-patterns)
