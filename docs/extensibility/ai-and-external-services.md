---
title: AI and external service integration
description: BusDK AI integration uses deterministic CLIs, API providers, event workers, runtime providers, portals, and auditable workspace data.
---

## How AI integrations fit

AI integration uses the same deterministic interfaces as human workflows. BusDK modules expose command-line tools, HTTP providers, event workers, portal surfaces, and workspace datasets so AI automation can be reviewed, repeated, and operated without bypassing module ownership.

For model access, [bus-api-provider-llm](../modules/bus-api-provider-llm) provides OpenAI-compatible `/v1/*` proxy routes with Bus authentication, backend header isolation, runtime wake-up, usage capture, and optional billing entitlement checks. For runtime control, [bus-api-provider-vm](../modules/bus-api-provider-vm), [bus-api-provider-containers](../modules/bus-api-provider-containers), [bus-vm](../modules/bus-vm), and [bus-containers](../modules/bus-containers) keep VM and container surfaces cloud-neutral while provider-specific work stays in integration workers such as [bus-integration-upcloud](../modules/bus-integration-upcloud) and [bus-integration-ssh-runner](../modules/bus-integration-ssh-runner).

Agentic workflows are separate from the model proxy. [bus-agent](../modules/bus-agent), [bus-dev](../modules/bus-dev), [bus-run](../modules/bus-run), and [bus-work](../modules/bus-work) provide local and durable work surfaces for prompts, tasks, scripts, and event-delivered work. These tools can read structured workspace datasets, run the same CLI workflows as a human, and propose changes as reviewable updates to repository data.

Product operation adds another layer. [bus-auth](../modules/bus-auth), [bus-billing](../modules/bus-billing), [bus-events](../modules/bus-events), [bus-api-provider-usage](../modules/bus-api-provider-usage), [bus-integration-billing](../modules/bus-integration-billing), [bus-integration-stripe](../modules/bus-integration-stripe), [bus-integration-usage](../modules/bus-integration-usage), and the `bus operator` modules cover authentication, scoped service tokens, billing setup, entitlement checks, usage collection, catalog operations, and payment-provider integration.

BusDK remains usable without model automation. Accounting, reporting, validation, and filing modules still operate through deterministic CLI and dataset contracts. The AI-specific modules extend the platform for hosted or self-hosted AI products rather than replacing the human-operable workflows, consistent with [AI-readiness](../design-goals/ai-readiness), [Git as source of truth](../design-goals/git-as-source-of-truth), and [Deployment and data control](../integration/deployment-and-data-control).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../extensibility/index">Extensibility model</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./core-schema-governance">Governance of core schemas</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Extensibility index](./index)
- [Independent modules](../architecture/independent-modules)
- [Plug-in modules via new datasets](./plugin-modules-via-datasets)
- [bus-api-provider-llm module](../modules/bus-api-provider-llm)
- [bus-events module](../modules/bus-events)
- [bus-work module](../modules/bus-work)
- [Deployment and data control](../integration/deployment-and-data-control)
