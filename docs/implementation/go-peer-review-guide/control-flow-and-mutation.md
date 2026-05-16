---
title: Go control flow and mutation review
description: Review readable control flow, meaningful helper extraction, staged validation, deterministic writes, and no-partial-write behavior.
---

## Readable Flow

Review whether a reader can follow the main path without holding too much state
in memory. Deep nesting, long functions that mix parsing, validation, mutation,
and output, boolean parameters whose meaning is unclear at the call site, and
helpers named after implementation details are signs that responsibilities are
tangled.

Split code when the split names a real concept. Good helper extraction makes
invariants, error paths, or side effects easier to see. Bad helper extraction
hides simple code behind vague names such as `handle`, `process`, `doThing`, or
`runInternal`. A review should prefer small, meaningful units over both giant
functions and ornamental abstraction.

## Staged Mutation

Data mutation should be visibly staged. For commands that change repository
data, reviewers should be able to see validation before mutation, deterministic
ordering before write, and rollback or no-partial-write behavior on failure. If
a function writes as it validates, or appends data before all preconditions are
known, flag it.

Bad:

```go
for _, row := range rows {
	item, err := parse(row)
	if err != nil {
		return err // Earlier rows may already be written.
	}
	if err := store.Append(item); err != nil {
		return err
	}
}
```

Better:

```go
items, err := parseAll(rows)
if err != nil {
	return err
}
sort.Slice(items, func(i, j int) bool { return items[i].ID < items[j].ID })
return store.ReplaceAll(items)
```

The better version proves validation happens before mutation and writes in a
deterministic order.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./data-mapping">Data mapping</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./destructive-and-batch-operations">Destructive and batch operations</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Append-only and soft deletion](../../data/append-only-and-soft-deletion)
- [LLM finding patterns](./llm-finding-patterns)
