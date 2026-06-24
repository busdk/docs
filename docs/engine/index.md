---
title: "Bus Engine overview"
description: Bus Engine provides AI-assisted Linux system engineering for Bus Engine OS, the rolling Linux distribution under active development.
---

# Bus Engine overview

Bus Engine provides the blueprints, AI-powered engineering tools, deterministic
build operations, isolated execution environments, validation workflows, and
lifecycle tooling needed to create and maintain custom Linux systems.

Bus Engine OS is the rolling Linux distribution being built and maintained
through Bus Engine. It is under active development and is not yet a complete or
production-ready Linux distribution.

Commercial product details live at [busdk.com/engine](https://busdk.com/engine/).
This documentation describes the technical model, status boundaries, and module
surfaces.

## Why Bus Engine?

Use Bus Engine when the operating system itself must adapt to the workload, not
merely host it. A conventional Linux virtual machine starts with a
general-purpose distribution. Bus Engine maintains a versioned system blueprint
that records kernel capabilities, packages, services, boot process, image
construction, tests, and lifecycle policy.

The virtualization layer provides the machine. Bus Engine provides the
operating-system engineering lifecycle.

## Current status

The currently documented implementation includes:

- `bus engine` CLI and client commands for status, start, stop, and SSH session
  access;
- authenticated Engine API routes that publish Engine requests through Bus
  Events;
- Engine, artifact, VM, and QEMU integration workers for the local development
  runtime;
- generic artifact catalog, fetch, verify, import, update, and mirror surfaces;
- hosted and local model integration modules that can participate in
  Bus-managed AI execution paths.

Bus Engine OS image production, complete update and recovery workflows,
production support channels, and broader hardware validation remain active
development work.

## Development preview

The public development preview is scheduled to begin on 1 July 2026. The first
preview is a rolling pre-production development channel, not Bus Engine OS
version 1.0 and not a complete distribution.

Example build labels use date-based development identifiers:

| Field | Example |
| --- | --- |
| Product | Bus Engine OS Development |
| Build | 2026.07.01 |
| Channel | development |
| Status | pre-production |

## Main docs

- [Architecture](./architecture)
- [Status and roadmap](./status)
- [Software and source licensing](./licensing)
- [FAQ](./faq)
- [bus-engine module reference](../modules/bus-engine)
- [bus-engine-os module reference](../modules/bus-engine-os)
- [bus-integration-engine module reference](../modules/bus-integration-engine)
- [bus-integration-qemu module reference](../modules/bus-integration-qemu)

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./architecture">Architecture</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
