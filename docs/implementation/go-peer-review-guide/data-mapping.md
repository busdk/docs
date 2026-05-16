---
title: Go data mapping review
description: Review import, extraction, alias, profile, prior-year, and external workspace mapping code.
---

## Explicit Mapping

Import, extraction, and mapping code should make user intent explicit. Prefer
canonical domain keys when source data already has them. When a source uses
non-canonical headers, aliases, prior-year inputs, or external workspace data,
require a versioned profile, schema metadata, flag, or other configured mapping
with documented override order.

Unknown, missing, or ambiguous mappings should fail with deterministic
diagnostics rather than silently guessing. A review should flag substring
matching, fuzzy aliases, and fallback rules that can silently import the wrong
field.

Bad:

```go
func mapColumn(name string) string {
	if strings.Contains(strings.ToLower(name), "date") {
		return "posting_date"
	}
	return name
}
```

Better:

```go
func mapColumn(profile Profile, name string) (FieldID, error) {
	field, ok := profile.Columns[name]
	if !ok {
		return "", fmt.Errorf("profile %q: unknown column %q", profile.Name, name)
	}
	return field, nil
}
```

Guessing can silently import the wrong data. A configured mapping makes the
user's intent reviewable.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./source-transforms-and-evaluators">Source transforms and evaluators</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./control-flow-and-mutation">Control flow and mutation</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [CSV conventions](../../data/csv-conventions)
- [Table schema contract](../../data/table-schema-contract)
- [LLM finding patterns](./llm-finding-patterns)
