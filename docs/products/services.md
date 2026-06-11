---
title: Bus Services
description: Product documentation entry point for BusDK's predictable project service-stack product line.
---

Bus Services is the BusDK product line for predictable project-level service
stacks. It uses public-safe `services.yml` contracts to validate, plan, start,
inspect, and stop process-level services without requiring virtualization.

Use this product when a project needs repeatable service startup without
drifting README steps, ad hoc shell scripts, or a container-only assumption.
Bus Services can support native user-land processes and provider-backed
runtime styles, but it is not a sandbox or security isolation layer.

## Start Here

1. Read [`bus services`](../modules/bus-services) for the user-facing command
   surface.
2. Use [`bus-api-provider-services`](../modules/bus-api-provider-services) when
   evaluating the API/controller surface.
3. Use [`bus-integration-services`](../modules/bus-integration-services) when
   evaluating runtime integration and lifecycle reconciliation.

## Product Modules

Bus Services owns [`bus-services`](../modules/bus-services),
[`bus-api-provider-services`](../modules/bus-api-provider-services), and
[`bus-integration-services`](../modules/bus-integration-services). Container,
VM, cloud, database, and AI Platform runtime modules may participate when a
service stack uses them, but they stay owned by their own product or platform
boundary.
