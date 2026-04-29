---
title: Deployment and data control
description: How BusDK deployments separate managed Finnish cloud operation, dedicated environments, customer self-hosting, secrets, runtime workers, and data-processing boundaries.
---

## Deployment models

BusDK can run in more than one operating model. The same module families can be used in a managed environment, a dedicated customer environment, or a customer self-hosted installation. The deployment choice decides who operates the infrastructure, where service data is processed, who supplies secrets, and which support or licensing terms apply.

A managed Finnish cloud deployment means Heusala operates the BusDK service stack for the customer on Finnish cloud infrastructure. BusDK's current UpCloud integration supports provider-specific VM and container work through [bus-integration-upcloud](../modules/bus-integration-upcloud), while the public VM and container APIs stay cloud-neutral in [bus-api-provider-vm](../modules/bus-api-provider-vm) and [bus-api-provider-containers](../modules/bus-api-provider-containers). The [UpCloud Cloud Servers availability reference](https://upcloud.com/docs/products/cloud-servers/availability/) documents Helsinki locations such as `fi-hel1` and `fi-hel2`.

A dedicated deployment uses the same BusDK modules but gives the customer a separately operated environment. This model is useful when a customer needs explicit data-processing terms, isolated runtime resources, custom billing or onboarding, or stronger operational separation from shared services.

A customer self-hosted deployment puts operation under the customer's control. The customer hosts the Bus API, provider modules, portal modules, event workers, databases, model backends, container or VM runtime, secrets, and observability in its own systems. BusDK modules are designed to keep those responsibilities separable: CLIs remain scriptable, API providers own HTTP surfaces, `bus-integration-*` workers own asynchronous provider work, and data-owning modules retain their dataset contracts.

## Runtime responsibilities

AI product deployments usually combine several module groups. [bus-api](../modules/bus-api) hosts provider modules. [bus-auth](../modules/bus-auth) and [bus-api-provider-auth](../modules/bus-api-provider-auth) handle login and scoped Bus API tokens. [bus-api-provider-llm](../modules/bus-api-provider-llm) exposes OpenAI-compatible model proxy routes. [bus-events](../modules/bus-events) and [bus-api-provider-events](../modules/bus-api-provider-events) provide event delivery and replay. [bus-integration-usage](../modules/bus-integration-usage), [bus-integration-billing](../modules/bus-integration-billing), and [bus-integration-stripe](../modules/bus-integration-stripe) handle usage and billing work outside the request-facing API provider.

Runtime and cloud operations are intentionally split. [bus-vm](../modules/bus-vm) and [bus-containers](../modules/bus-containers) are user-facing clients for runtime status and container runs. [bus-api-provider-vm](../modules/bus-api-provider-vm) and [bus-api-provider-containers](../modules/bus-api-provider-containers) own the HTTP APIs. [bus-integration-upcloud](../modules/bus-integration-upcloud) handles UpCloud-specific event work, and [bus-integration-ssh-runner](../modules/bus-integration-ssh-runner) handles generic SSH script execution behind event requests.

Portal deployments can include [bus-portal](../modules/bus-portal), [bus-portal-auth](../modules/bus-portal-auth), [bus-portal-ai](../modules/bus-portal-ai), [bus-portal-accounting](../modules/bus-portal-accounting), [bus-ui](../modules/bus-ui), [bus-chat](../modules/bus-chat), [bus-books](../modules/bus-books), and [bus-api-provider-terminal](../modules/bus-api-provider-terminal). These browser-facing surfaces do not remove the CLI boundary; they are additional entry points around the same platform modules.

## Data and secrets

Deployment documents and contracts should distinguish product data, workspace datasets, usage records, billing records, runtime logs, model-provider requests, and operational secrets. BusDK modules should not require real secrets in public docs, public compose examples, or repository-tracked files. Real credentials belong in environment variables, deployment secrets, local untracked configuration, or customer-operated secret management.

Contractual data processing is not a command-line feature. It is an agreement about where the service runs, which party operates it, what data is processed, how credentials are supplied, and which support, licensing, or data-processing terms apply. The technical platform supports that separation by keeping module responsibilities explicit and by allowing deployments to place APIs, workers, databases, model backends, and workspace data under the required operator boundary.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Integration and runtime interfaces</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Integration and runtime interfaces</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./external-system-integration">External system integration patterns</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-integration-upcloud module](../modules/bus-integration-upcloud)
- [bus-api-provider-vm module](../modules/bus-api-provider-vm)
- [bus-api-provider-containers module](../modules/bus-api-provider-containers)
- [bus-api-provider-llm module](../modules/bus-api-provider-llm)
- [bus-events module](../modules/bus-events)
- [bus-integration-billing module](../modules/bus-integration-billing)
- [bus-integration-stripe module](../modules/bus-integration-stripe)
- [bus-integration-usage module](../modules/bus-integration-usage)
- [UpCloud Cloud Servers availability](https://upcloud.com/docs/products/cloud-servers/availability/)
