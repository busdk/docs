---
title: Bus AI Platform
description: Product documentation entry point for BusDK's self-hostable AI infrastructure product line.
---

Bus AI Platform is the BusDK product line for running and productizing AI
services on infrastructure the user controls. It combines OpenAI-compatible
model access, inference backends, runtime environments, deployment automation,
auth, usage metering, billing, and service lifecycle hooks.

Use this product when you need more than a raw model runner or a cloud-only API
call. Bus AI Platform provides the product layer around AI services: API
surfaces, runtime control, deployment, auth/session handling, entitlement,
usage capture, billing, and operator workflows.

## Start Here

1. Read [deployment and data control](../integration/deployment-and-data-control)
   for managed, dedicated, and self-hosted deployment models.
2. Read [AI and external services](../extensibility/ai-and-external-services)
   for how AI integrations fit BusDK.
3. Use [`bus api provider llm`](../modules/bus-api-provider-llm) for
   OpenAI-compatible model proxying.
4. Use [`bus api provider inference`](../modules/bus-api-provider-inference),
   [`bus integration inference`](../modules/bus-integration-inference), and
   runtime-specific modules for inference/runtime backends.
5. Use auth, usage, and billing modules when an AI service needs product
   controls.

## Product Modules

Model and inference modules include [`bus-api-provider-llm`](../modules/bus-api-provider-llm),
[`bus-api-provider-inference`](../modules/bus-api-provider-inference),
[`bus-integration-inference`](../modules/bus-integration-inference),
[`bus-integration-codex`](../modules/bus-integration-codex), and
[`bus-integration-ollama`](../modules/bus-integration-ollama).

Runtime, deployment, auth, usage, and billing modules include
[`bus-vm`](../modules/bus-vm), [`bus-containers`](../modules/bus-containers),
[`bus-auth`](../modules/bus-auth), [`bus-billing`](../modules/bus-billing),
[`bus-portal-auth`](../modules/bus-portal-auth), [`bus-api-provider-usage`](../modules/bus-api-provider-usage),
[`bus-operator-deploy`](../modules/bus-operator-deploy),
[`bus-operator-inference`](../modules/bus-operator-inference),
[`bus-integration-ssh-runner`](../modules/bus-integration-ssh-runner), and
the cloud, database, node, Stripe, usage, VM, container, and terminal provider
modules listed in the [module reference](../modules/).
