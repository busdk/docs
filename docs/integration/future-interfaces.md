---
title: Runtime interfaces (APIs, dashboards, wrappers)
description: BusDK uses CLIs, API providers, portals, dashboards, event workers, and external integrations around shared module contracts.
---

## Current interface families

The CLI remains the primary automation surface, but BusDK now also includes current API providers, portals, dashboards, event workers, and external integrations. Because modules already parse inputs, validate, and produce outputs, HTTP providers and browser surfaces can sit around the same module contracts without moving all behavior into one monolith.

[bus-api](../modules/bus-api) hosts provider modules for auth, billing, books, containers, data, events, LLM proxying, sessions, terminal access, usage, and VM status. [bus-portal](../modules/bus-portal), [bus-portal-auth](../modules/bus-portal-auth), [bus-portal-ai](../modules/bus-portal-ai), [bus-portal-accounting](../modules/bus-portal-accounting), [bus-ui](../modules/bus-ui), [bus-chat](../modules/bus-chat), and [bus-books](../modules/bus-books) provide browser-facing entry points. [bus-events](../modules/bus-events) and the `bus-integration-*` workers connect asynchronous work, provider APIs, usage capture, cloud operations, SSH execution, and payment-provider events.

The Git repository and workspace datasets are still important contracts for business-data modules. AI product modules add service runtime, authentication, billing, usage, and deployment surfaces around those contracts rather than replacing them.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./external-system-integration">External system integration patterns</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../integration/index">Integration and runtime interfaces</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../extensibility/index">Extensibility model</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Integration index](./index)
- [CLI as the primary interface](../architecture/cli-as-primary-interface)
- [AI and external services](../extensibility/ai-and-external-services)
- [bus-api module](../modules/bus-api)
- [bus-events module](../modules/bus-events)
- [bus-portal module](../modules/bus-portal)
