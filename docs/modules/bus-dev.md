---
title: bus-dev
description: "bus dev provides developer-only repository helpers: init, stage, commit, spec, triage, reusable quality checks, and repository-local pipeline/action/script management."
---

## `bus-dev` — developer helpers

`bus dev` is the BusDK developer companion for source repositories. It keeps
the small workflows that have proved useful for contributors and automation:

```bash
bus dev init [DIR] [--lang go]
bus dev spec
bus dev stage [commit]
bus dev commit
bus dev triage
bus dev quality lint [PATH...]
bus dev each TOKEN...
bus dev pipeline <set|unset|list|preview> ...
bus dev action <set|unset|list|generate> ...
bus dev script <set|unset|list|generate> ...
```

Generic task threads and worker orchestration no longer live under
`bus dev task` or `bus dev work`. Use [`bus task`](./bus-task) for task streams,
multi-remote worker selection, Spark workers, App Server profiles, status,
watching, reopening, and worker launch control.

The old built-in `plan`, `work`, and `e2e` commands were removed from the
`bus-dev` public interface. If a repository wants those workflows, define them
explicitly with `.bus/dev` pipelines, prompt actions, or script actions:

```bash
bus dev pipeline set repo verify script-test stage commit
bus dev pipeline preview verify
bus dev verify
```

`bus dev work` now prints a migration diagnostic. `bus dev task --help` points
to `bus task`.

### Locks

Repository-writing commands use `.bus-dev.lock` for per-directory concurrency.
New lock directories contain `owner.pid`; if a previous process exits and
leaves an old lock behind, a later `bus dev` invocation can remove the stale
ownerless or exited-owner lock safely.

### Boundaries

`bus-dev` remains developer-only. It does not push, pull, fetch, clone, rewrite
history, or operate on accounting workspace data. `commit` commits staged
changes only. `stage` may prepare and stage intended files, but it does not
commit or contact remotes.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-task">bus-task</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
</p>
<!-- busdk-docs-nav end -->
