---
title: Go documentation and traceability review
description: Review comments, help text, README material, module docs, public references, and invariant comments.
---

## Contract Documentation

Behavior changes need matching documentation. Review code comments, help text,
README material, module docs, and public reference pages when the change alters
user-visible behavior, CLI flags, API responses, validation rules, file formats,
or architecture boundaries. Documentation can be concise, but it must not
describe a shape the code no longer has.

When a change affects multiple surfaces, the review should name the stale or
missing surface instead of asking for "docs" in general. A flag change, for
example, may require help text, a README example, machine-readable command
metadata, tests, and a public module page update.

## Comments and Invariants

Comments should preserve intent and invariants. They should explain ownership,
safety constraints, non-obvious ordering, compatibility requirements, or why a
simpler-looking change would be wrong. Every top-level production-code unit
should have a short purpose comment, and non-obvious integration points should
keep concise `Used by:` notes accurate during refactors. Comments that restate
syntax should be removed or replaced with a better name.

Bad:

```go
// Loop over users.
for _, user := range users {
	process(user)
}
```

Better:

```go
// Process users in stable ID order so audit output is reproducible.
sort.Slice(users, func(i, j int) bool { return users[i].ID < users[j].ID })
for _, user := range users {
	process(user)
}
```

The better comment explains the invariant a future edit must preserve.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./tests-and-evidence">Tests and evidence</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./llm-finding-patterns">LLM finding patterns</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module repository structure](../module-repository-structure)
- [Module CLI reference index](../../modules/)
- [LLM finding patterns](./llm-finding-patterns)
