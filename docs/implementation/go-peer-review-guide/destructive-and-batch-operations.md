---
title: Go destructive and batch operation review
description: Review destructive changes, schema rewrites, batch preflight, trace modes, and command-file execution.
---

## Destructive Mutation

Destructive mutation should be opt-in and policy-backed. Review delete, rename,
overwrite, schema-field removal, and type-change paths for explicit force flags
or schema policy, compatibility checks before writes, preservation of unknown
descriptor fields, and canonical serialization after mutation.

Code that rewrites unrelated rows, reorders schema fields by accident, drops
extension metadata, or deletes referenced resources by default is not just
risky; it changes the data contract.

## Batch Preflight

Batch command runners need preflight review. A runner that executes command
files, migration plans, or generated operation batches should tokenize and
validate the whole batch before running the first mutating command, expose
check-only and trace modes where useful, and document the transaction scope
honestly.

If a runner accepts a command language rather than a shell, reviewers should
verify that shell features such as pipes, redirection, variable expansion,
command substitution, and separators are not interpreted accidentally.

Bad:

```go
for scanner.Scan() {
	if err := executeLine(scanner.Text()); err != nil {
		return err
	}
}
```

Better:

```go
plan, err := ParseBatch(r)
if err != nil {
	return err
}
if err := plan.Validate(catalog); err != nil {
	return err
}
if checkOnly {
	return plan.Trace(w)
}
return runner.Apply(plan)
```

The better version lets the reviewer see the parse, validate, trace, and mutate
phases.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./control-flow-and-mutation">Control flow and mutation</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./errors-and-cli-diagnostics">Errors and CLI diagnostics</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Bus script files](../../cli/bus-script-files)
- [Error handling, dry-run, and diagnostics](../../cli/error-handling-dry-run-diagnostics)
- [LLM finding patterns](./llm-finding-patterns)
