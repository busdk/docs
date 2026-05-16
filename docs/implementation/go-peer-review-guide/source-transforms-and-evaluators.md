---
title: Go source transform and evaluator review
description: Review parsers, formatters, compilers, generators, linters, expression evaluators, and safety limits.
---

## Source Transformations

Source transformation code needs structural review. Parsers, formatters,
compilers, code generators, and linters should parse the source language
deliberately instead of scanning with brittle string rules. They should preserve
surrounding source shape where that is part of the contract, fail closed on
unsupported constructs, produce stable diagnostics, write no partial output on
source errors, generate `gofmt`-clean Go, and keep golden plus command-surface
tests for generated output.

Reviewers should ask whether the transformation owns a clear input language,
whether unsupported syntax is rejected deterministically, and whether generated
files can be reviewed without hidden machine-local details.

## Safe Evaluators

Expression, query, and rule evaluators need safety review. User-provided
expressions should be parsed and evaluated by side-effect-free libraries with
explicit dialects, typed errors, stable source spans, and limits for source
length, AST size, recursion depth, evaluation steps, collection sizes, and
numeric overflow or division behavior.

Reviewers should reject evaluators that can reach the filesystem, environment,
network, reflection, time, or unbounded loops unless those effects are the
documented product contract.

Bad:

```go
func Eval(expr string) (any, error) {
	return runJavaScript(expr) // Can loop forever and access host APIs.
}
```

Better:

```go
type Limits struct {
	MaxSourceBytes int
	MaxEvalSteps   int
}

func Eval(expr string, vars Vars, limits Limits) (Value, error) {
	ast, err := parseFormula("bus-formula/v1", expr, limits.MaxSourceBytes)
	if err != nil {
		return Value{}, err
	}
	return evalSideEffectFree(ast, vars, limits.MaxEvalSteps)
}
```

The better version names the dialect and limits. A reviewer can ask whether
each limit has tests.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./api-and-type-design">API and type design</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./data-mapping">Data mapping</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Testing strategy](../../testing/testing-strategy)
- [Error handling, dry-run, and diagnostics](../../cli/error-handling-dry-run-diagnostics)
- [LLM finding patterns](./llm-finding-patterns)
