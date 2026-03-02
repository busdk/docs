---
title: "FAQ: AI assistants, automation, and safety"
description: FAQ on BusDK AI usage, approval controls, command execution context, reproducibility expectations, and safe automation patterns.
---

## FAQ: AI assistants, automation, and safety

### Is AI required to use BusDK?

No. BusDK is [CLI-first](../design-goals/cli-first) and deterministic without AI. AI-assisted flows are optional convenience layers on top of command and dataset contracts.

### What should AI do in a BusDK workflow?

AI should help users compose, validate, and explain deterministic command flows. It should not replace core evidence, control gates, or explicit business decisions required by policy in [workflow controls](../workflow/index) and [compliance guidance](../compliance/fi-bookkeeping-and-tax-audit).

### Can AI run commands automatically?

AI-enabled interfaces such as [`bus-ledger`](../modules/bus-ledger) and [`bus-factory`](../modules/bus-factory) can run repository-local commands, but approval and control behavior should remain explicit. Command execution should stay observable in logs and traceable to the active workflow context.

### How should teams treat AI-generated output?

Treat AI output as draft guidance unless it has been verified by deterministic command results and domain controls. The authoritative result is always the reproducible workflow output produced by module commands such as [`bus-replay`](../modules/bus-replay) and [`bus-validate`](../modules/bus-validate), not the model narrative.

### How do approvals fit into safe automation?

Approval mediation is the checkpoint between suggestion and execution. It allows users to review proposed actions, accept with scope, or reject while preserving audit-friendly operation traces in assistant-enabled flows from [`bus-agent`](../modules/bus-agent) and [`bus-run`](../modules/bus-run).

### How do we avoid leaking sensitive information to AI services?

Use strict input boundaries, explicit file selection, and secret reference handling. Teams should avoid sending unnecessary workspace material and should keep sensitive handling aligned with module-level security policy and [`bus-secrets`](../modules/bus-secrets).

### Can AI-assisted workflows still be reproducible?

Yes, if AI is used to generate deterministic commands and those commands are replayed against the same declared inputs. Reproducibility depends on command/data contracts and [deterministic `.bus` files](../design-goals/deterministic-busfiles), not on conversational text.

### What should be logged in AI-enabled operations?

Logs should capture user actions, command intent, error details, and state transitions needed for diagnosis. High-signal logs make it possible to investigate behavior without relying on browser-only debugging, aligned with [error handling and diagnostics](../cli/error-handling-dry-run-diagnostics) and [validation and safety checks](../cli/validation-and-safety-checks).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./workspaces-datasets-and-compliance">FAQ: workspaces, datasets, and compliance boundaries</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">FAQ index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./modules-repositories-and-contribution-model">FAQ: modules, repositories, and contribution model</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-agent module reference](../modules/bus-agent)
- [bus-run module reference](../modules/bus-run)
- [bus-dev module reference](../modules/bus-dev)
- [bus-ledger module reference](../modules/bus-ledger)
- [bus-factory module reference](../modules/bus-factory)
