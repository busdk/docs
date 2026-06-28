---
title: "Bus Engine overview"
description: Bus Engine provides AI-assisted Linux system engineering for Bus Engine OS, the rolling Linux distribution under active development.
---

# Bus Engine overview

Bus Engine provides the blueprints, AI-powered engineering tools, deterministic
build operations, isolated execution environments, validation workflows, and
lifecycle tooling needed to create and maintain custom Linux systems.

Bus Engine OS is the rolling Linux distribution being built and maintained
through Bus Engine. The accepted current profile is `virtual-server`, a
source-built QEMU/KVM server image assembled from validated Bus packages and
boot-tested in QEMU. Bus Engine OS remains a development-preview operating
system, not a production-supported general-purpose distribution.

Commercial product details live at [busdk.com/engine](https://busdk.com/engine/).
This documentation describes the technical model, status boundaries, and module
surfaces.

## Why Bus Engine?

A general-purpose distribution gives a broad starting system. Bus Engine is for
systems where the operating system itself has to be engineered around a
workload: kernel capabilities, package definitions, services, boot files, image
construction, update behavior, tests, and lifecycle policy.

In a conventional VM workflow, those decisions can drift into shell history,
hand-edited files, package notes, and an image that becomes difficult to
rebuild. Bus Engine keeps them in a versioned system blueprint that can be
inspected, rebuilt, booted, tested, and revised. The virtualization layer
provides the machine. Bus Engine provides the operating-system engineering
lifecycle.

## Example workflow

A team may have an application that should become part of a small server image
with one service, a private package, a specific kernel feature, and a boot test.
Bus Engine is being built to support a workflow where the operator provides a
source URL, target profile, and acceptance tests. The agent inspects the source
and build files, determines package, service, and kernel requirements, updates
the system blueprint, creates or changes package definitions, and asks
deterministic tools to build the package, assemble the image, boot it, and run
tests.

Failed builds and failed boots feed back into the same loop. The agent reads
logs and test evidence, changes the blueprint or package definition, and runs
the controlled build again. The output is a maintained definition of how the OS
is built and verified, plus the generated image and package artifacts.

The same model applies to component fixes. When a component can legally be
patched by the customer, Bus Engine is designed to carry that change in the
blueprint, rebuild the affected package or image, and validate it without
waiting for a general-purpose distribution to accept the change upstream.
Upstreaming can still be the right long-term maintenance path.

## Current status

The currently documented implementation includes:

- `bus engine` CLI and client commands for status, start, stop, and SSH session
  access;
- authenticated Engine API routes that publish Engine requests through Bus
  Events;
- Engine, artifact, VM, and QEMU integration workers for the local development
  runtime;
- generic artifact catalog, fetch, verify, import, update, and mirror surfaces;
- Bus Engine OS source package builds, rootfs assembly, virtual-server image
  generation, QEMU boot acceptance, and local Engine artifact promotion;
- hosted and local model integration modules that can participate in
  Bus-managed AI execution paths.

Complete update and recovery workflows, rollback guarantees, production support
channels, broader hardware validation, and GUI profile completion remain active
development work.

## Development preview

The development preview is a rolling pre-production channel, not Bus Engine OS
version 1.0 and not a complete production distribution.

Example build labels use date-based development identifiers:

| Field | Example |
| --- | --- |
| Product | Bus Engine OS Development |
| Build | 2026.07 |
| Channel | development |
| Status | pre-production |

## Main docs

- [Architecture](./architecture)
- [Status and roadmap](./status)
- [Bus Engine OS configuration files](./os-configuration)
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
