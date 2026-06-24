---
title: "Bus Engine FAQ"
description: Frequently asked questions about Bus Engine, Bus Engine OS, development preview status, agent runtime, AI model fees, hardware targets, source delivery, and persistent storage.
---

# Bus Engine FAQ

## What is Bus Engine?

Bus Engine provides the blueprints, AI-powered engineering tools, deterministic
build operations, isolated execution environments, validation workflows, and
lifecycle tooling needed to create and maintain custom Linux systems.

## What is Bus Engine OS?

Bus Engine OS is the rolling Linux distribution being built and maintained
through Bus Engine. It is under active development and not yet production-ready.

## Why not just install an ordinary Linux distribution in a virtual machine?

You can, and that is the right choice for many general-purpose systems.

A general-purpose distribution gives a broad starting system. Bus Engine is
intended for cases where the operating-system decisions are part of the product:
kernel capabilities, package definitions, services, boot process, image
construction, tests, update behavior, and lifecycle policy must be maintained
together.

Its integrated agent can investigate requirements, create and revise the
blueprint, build the resulting system, diagnose failures, and maintain it as the
workload and upstream components change. The virtualization layer provides the
machine. Bus Engine provides the operating-system engineering lifecycle.

## Can Bus Engine package software from a source URL?

That is a core workflow Bus Engine is being built to support. The intended flow
is to provide a source URL, target profile, and acceptance tests. The agent
inspects the source and build files, determines package, service, and kernel
requirements, updates the system blueprint, creates or changes package
definitions, and asks deterministic tools to build the package, assemble the
image, boot it, and run tests.

In the June 2026 development state, the Engine runtime control path, artifact
catalog, local VM provider path, and QEMU integration are available. Native Bus
Engine OS packaging, image generation, update, recovery, and the complete
source-URL-to-system-build workflow remain active development work.

## How does Bus Engine help with component fixes?

When a component can legally be patched by the customer, Bus Engine is designed
to carry that change in the system blueprint, rebuild the affected package or
image, and validate it through the same boot and test evidence. That can let a
team move on its own maintenance schedule while a fix is proposed upstream or
carried as a customer-specific patch.

## What happens on 1 July 2026?

The public development preview is scheduled to begin on 1 July 2026. It starts
a rolling pre-production development channel for technical evaluation and
feedback.

## Is Bus Engine OS complete today?

No. The current implementation includes Engine, artifact, VM, QEMU, and AI
integration surfaces. Native Bus Engine OS images, complete update and recovery
workflows, and production release guarantees remain in active development.

## Are AI model fees included?

Third-party hosted-model usage and AI service fees are not included unless a
plan explicitly says otherwise. Customers may use supported hosted providers or
operate a compatible model inside their own infrastructure where the configured
Bus services and policies support that deployment.

## Does Bus Engine use REST to talk to the agent runtime?

No. [Codex App Server](https://github.com/openai/codex) uses bidirectional
JSON-RPC 2.0. Bus Engine may expose its own HTTP APIs, but those APIs are Bus
Engine APIs rather than the native App Server protocol.

## Can Bus Engine target physical hardware?

Virtualized targets are the initial supported environment. Customer-defined
physical targets can be configured with Bus Engine or enabled through paid
engineering support. Bus Engine enables hardware configuration; it does not
automatically certify arbitrary hardware.

## Is every BusDK module installed in every Bus Engine OS image?

No. Available means the commercial entitlement permits access, installed means
the module binary is present in a specific image, and enabled means a service,
listener, scheduled operation, or integration is active. Each blueprint should
install only the modules required for that system.

## Is source code public?

No public source-code publication is promised by default. Customer release areas
provide corresponding source to binary recipients for GPL, LGPL, MPL, and
similar covered components at no extra charge, together with the notices and
build materials required for the release.

## What does the 1 TB founder storage benefit include?

Founding Bus Engine customers receive a 1 TB Bus Engine Persistent Storage
allocation for supported BusDK-hosted virtualized systems, subject to the
applicable commercial and service terms. Detailed storage service terms belong
in the agreement.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./licensing">Software and source licensing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bus Engine</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../modules/bus-engine">bus-engine module reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
