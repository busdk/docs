---
title: "Bus Engine architecture"
description: Bus Engine combines a Bus orchestration layer, Codex App Server, configured AI models, Linux tools, build environments, validation, blueprints, and evidence.
---

# Bus Engine architecture

Bus Engine separates user-facing control, agent coordination, deterministic
Linux operations, and evidence storage.

```text
Bus Engine UI / CLI / external API
        ↓
Bus Engine orchestration, policy, and audit layer
        ↓
Codex App Server adapter
        ↓
Codex App Server
        ↓
Customer-selected hosted or local model provider

Bus Engine Linux tools
        ↓
Isolated build environment
        ↓
Boot and validation environment
        ↓
System blueprint and evidence
```

Codex App Server is a separate open-source Codex agent-runtime component. Bus
Engine supplies Linux-specific tools, system blueprints, policies, approval
rules, inventory and inspection tools, kernel configuration tools, package and
image builders, isolated build environments, boot and test environments,
validation tools, logs, and evidence.

Codex App Server uses bidirectional JSON-RPC 2.0. Bus Engine may expose its own
HTTP APIs to user interfaces and external systems, but those APIs are not the
native Codex App Server protocol.

## Lifecycle

Bus Engine uses the same lifecycle across preview targets:

1. Discover declared requirements and available evidence from target profiles,
   running Linux systems, hardware inventories, workloads, source repositories,
   build systems, configuration, logs, and acceptance tests.
2. Infer required capabilities, dependencies, kernel features, packages,
   services, boot components, filesystems, policies, and validation
   requirements.
3. Configure a versioned system blueprint covering the kernel, userspace,
   packages, services, boot process, filesystems, networking, security
   configuration, target profile, build outputs, and tests.
4. Build kernels, packages, filesystems, and images with deterministic tools.
5. Verify the generated system by booting it in an isolated environment and
   running platform and workload tests.
6. Diagnose and repair failed builds, boot failures, missing dependencies,
   kernel problems, service failures, and test regressions.
7. Maintain the blueprint as workloads, source code, kernels, packages,
   toolchains, policies, and upstream projects change.

AI performs the adaptable engineering. Deterministic tools perform and verify
the repeatable operations.

## Permissions and approvals

The agent may inspect, decide, modify, build, diagnose, and repair within the
permissions and policies configured for the project. High-impact operations can
require explicit approval, while lower-risk workflows may be automated according
to customer policy.

Incomplete evidence creates uncertainty. Bus Engine reasons from customer
intent, target inventories, source analysis, runtime observations, logs, tests,
and previous build and maintenance evidence.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Bus Engine overview</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bus Engine</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./status">Status and roadmap</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
