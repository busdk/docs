---
title: "Bus Engine status and roadmap"
description: Current Bus Engine implementation status, development-preview boundaries, rolling release model, supported targets, and planned later work.
---

# Bus Engine status and roadmap

Bus Engine OS is under active development. The accepted `virtual-server`
profile is available for technical evaluation, but Bus Engine OS is not yet a
production-ready product, generally available release, or production-SLA
service.

## Available now

Current repository evidence supports these capability labels:

| Area | Evidence |
| --- | --- |
| Engine CLI | `bus engine status`, `start`, `stop`, and `ssh` are documented in the `bus-engine` module. |
| Engine API | `bus-api-provider-engine` documents authenticated REST routes for status, start, stop, and SSH session requests. |
| Engine orchestration | `bus-integration-engine` documents Events API requests for Engine status, start, stop, and SSH session work. |
| Artifacts | `bus-artifacts`, `bus-api-provider-artifacts`, and `bus-integration-artifacts` document catalog, fetch, verify, import, update, and mirror behavior. |
| VM provider path | `bus-integration-vm` and `bus-integration-qemu` document provider-neutral VM routing and local QEMU execution. |
| AI integration modules | `bus-api-provider-llm`, `bus-integration-codex`, and `bus-integration-ollama` document hosted and local model integration surfaces. |
| Bus Engine OS virtual-server image | `bus-engine-os` builds package archives, assembles the package-built root filesystem, produces QEMU artifacts, boots the accepted `virtual-server` image, and promotes local Engine artifacts. |

## In active development

The active Bus Engine OS line still covers update and recovery workflows,
rollback guarantees, production release operations, persistent storage
workflows, GUI profile completion, and release-material handling.

## Development preview channel

Preview users should expect rolling development builds, target-profile
refinement, validation evidence, and feedback-driven changes as the Bus Engine
OS pipeline matures.

## Planned later

Production support channels, broader target validation, complete update and
recovery guarantees, rollback guarantees, production image guarantees, and a
production SLA belong to later work after the relevant implementation and
release processes have been tested.

## Target support

Virtualized targets are the initial supported environment. Customer-defined
bare-metal servers, appliances, boards, and embedded systems can be configured
with Bus Engine or enabled through paid engineering support.

Bus Engine enables hardware configuration; it does not automatically certify
arbitrary hardware.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./architecture">Architecture</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bus Engine</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./os-configuration">Bus Engine OS configuration files</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
