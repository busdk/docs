---
title: "Test multi-remote workers without paid provisioning"
description: Operator checklist for validating Bus task worker placement with localhost dry-runs and an externally prepared Events runner.
---

## Operator Goal

Use this checklist when you need to prove that `bus task` can plan or run
recipient work across worker systems without asking BusDK to create cloud
resources. The no-spend path starts with `--dry-run` against the built-in
`localhost` remote, then uses `--remote eligible` as a negative control when
no repository or user worker remotes are configured. A live external test is
optional and uses an Events endpoint and worker fleet that the operator has
already prepared.

This page does not describe cloud creation, VM sizing, image builds, or paid provisioning. If an UpCloud or other external runner is part of the test, it must already exist, have its own spending limit and shutdown policy, and expose a Bus Events endpoint plus a development-task worker that can claim the intended recipients.

## No-Spend Boundary

`--dry-run` is the hard boundary for planning tests. It prints the deterministic worker-placement plan without creating Events tasks, launching workers, provisioning systems, or resizing infrastructure. Use it before every live run and keep the dry-run output with the test evidence.

The built-in `localhost` remote is a `compose` remote for the local Docker Compose worker platform and the local Events endpoint. A dry-run against `localhost` does not start Compose by itself. A non-dry-run local test may launch local containers and may consume local agent quota if the selected worker backend uses Codex or another paid agent runtime.

`--remote eligible` is intentionally conservative. When no repository or user worker remotes are configured, it should report that there are no eligible configured remotes instead of silently selecting a hosted or paid target.

## Localhost Dry-Run

Run the first test from the BusDK checkout or module repository where the recipients are visible:

```sh
bus task --remote localhost start --dry-run \
  @bus-ledger @docs \
  "Test multi-remote worker execution without paid provisioning."
```

The pass condition is an exit code of `0` and a plan that names one work stream per recipient, keeps the remote id as `localhost`, and records the remote kind as `compose`. The output must identify the command as a dry-run plan and must not create persistent task events, start workers, or ask for an UpCloud token.

Use `eligible` as the negative control before any live runner test:

```sh
bus task --remote eligible start --dry-run \
  @bus-ledger @docs \
  "Test multi-remote worker execution without paid provisioning."
```

With no repository or user worker remotes configured, the expected result is a clear no-eligible-remotes diagnostic. That result is a pass for the safety check because it proves `eligible` is not inventing a paid target.

## External Events Runner

For an operator-owned UpCloud or other external runner, register only the non-secret Events endpoint. Store tokens through the normal Bus auth or secret mechanisms, not in `.bus/remote/config.json`. This example reads a preissued test token from an untracked local file and keeps every command pinned to the explicit remote id instead of making the external runner the default.

```sh
export BUS_API_TOKEN="$(cat ./local/upcloud-devtask.token)"

bus remote add \
  --id upcloud-devtask \
  --url https://events.operator.example

bus remote resolve upcloud-devtask
```

The runner side must already be operating before the live test. It should have a development-task worker for each recipient or an agreed recipient-routing rule, a token with `events:send events:listen dev:task:send dev:task:read dev:task:reply dev:task:claim` scopes, a policy for worker concurrency, and a cleanup plan for any local worktrees or containers it owns. This checklist only verifies that BusDK can address and observe that prepared runner.

Dry-run the external placement before creating task streams:

```sh
bus task --remote upcloud-devtask start --dry-run \
  @bus-ledger @docs \
  "Test external dev-task worker routing without provisioning."
```

The pass condition is a dry-run plan that names `upcloud-devtask` as the remote id and `bus-events` as the remote kind. If the plan points to `localhost`, `ai.hg.fi`, or any unexpected endpoint, stop and fix the remote registry before running a live test.

Run a live external test only after the dry-run output is accepted:

```sh
bus task --remote upcloud-devtask start \
  @bus-ledger @docs \
  "Read-only remote smoke: inspect the recipient checkout, run git status --short, report the remote id/kind and work ref, and exit without editing files."
```

Record the task group ref and child work refs printed by `start`. Then watch the task group and collect stats from the same remote:

```sh
bus task --remote upcloud-devtask watch <task-group-ref> --timeout 30m
bus task --remote upcloud-devtask stats --all
```

The test passes when each child stream reaches a terminal state that matches the planned smoke scope, the stream events include the expected remote id and kind, and `stats --all` groups the work under that remote and recipient. A blocked result can still be a valid infrastructure pass when the block message is about the task content and the worker clearly claimed, ran, and reported through the external Events endpoint.

The test fails when the dry-run selects the wrong remote, a live command creates no task refs, workers never claim the streams, `watch` cannot replay the task events, `stats --all` omits the remote id/kind, the runner provisions or resizes cloud resources as part of the test, or the run requires undocumented credentials in repository files.

Remove a one-off external test remote after evidence collection unless the
operator intentionally wants it to remain available for later `--remote
eligible` planning:

```sh
bus remote remove upcloud-devtask
bus task --remote eligible start --dry-run \
  @bus-ledger @docs \
  "Verify the temporary external test remote was removed."
```

## Evidence To Keep

Keep the command lines, timestamps, operator, Git branch or commit, selected
remote id, selected remote kind, and task refs. For live runs, also keep
`bus task show <ref>` or `watch` output for the task group, `bus task stats
--all`, worker identifiers, Bus Notes ids or a notes query, and a short
statement that no cloud creation or paid provisioning was performed by the
test.

For localhost-only tests, the required evidence is the successful `localhost` dry-run and the negative `eligible` dry-run. For external-runner tests, add the external dry-run, the live task refs, and the `stats --all` grouping by remote id/kind.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./deployment-and-data-control">Deployment and data control</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Integration and runtime interfaces</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./upcloud-stripe-setup">Set up UpCloud runtime and Stripe billing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-dev module reference](../modules/bus-dev)
- [bus remote module reference](../modules/bus-remote)
- [bus integration task module reference](../modules/bus-integration-task)
- [Deployment and data control](./deployment-and-data-control)
