---
title: bus-portal-ai — AI portal UI module
description: bus-portal-ai provides chat and Codex terminal browser UI for the modular Bus portal host.
---

## `bus-portal-ai` — AI portal UI module

`bus-portal-ai` provides browser UI for AI Platform access: chat mode,
Codex/container session controls, terminal entry points, and billing/setup
prompts.

Portal hosts mount the module under `/modules/ai/`. The module uses Bus API
providers for backend work: auth, billing, LLM, containers, and terminal.

Enable the module from the portal host when you want to expose AI chat or
container-backed Codex terminal access:

```bash
bus portal serve --print-url --enable-module ai
```

The module serves external JavaScript and reads the API token from the shared
`bus-portal-auth` session. It calls billing status/setup/portal APIs, the
OpenAI-compatible `/v1/chat/completions` API, user-owned container run APIs,
and terminal session APIs with bearer authorization. Billing or entitlement
failures are shown as guidance; the frontend does not make backend
entitlement decisions.

### User Experience

Chat mode sends authenticated requests to the Bus LLM API. If the user is not
logged in, not approved, missing billing setup, or over quota, the module shows
the server-provided guidance instead of trying to bypass the provider decision.

The model selector is deployment configuration. Operators can expose hosted
models and Codex-backed local models in the same list. The portal sends only
the selected model name to `/v1/chat/completions`; the LLM provider decides
which runtime to use and records usage for billing.

Container/Codex mode starts user-owned container work through the containers
API and opens terminal access through the terminal API. Container runs are
owned by the account in the API token and are subject to the same billing and
quota checks as other container clients.

Terminal output uses the terminal provider's authenticated Server-Sent Events
stream. Terminal input and resize actions use the terminal provider's input and
resize endpoints. Account isolation remains enforced by the terminal provider.

The module can show billing setup and portal actions by calling the Billing
API. It does not talk to Stripe directly and does not store payment provider
secrets in the browser.

AI-assisted theme customization calls configured portal theme APIs for
suggestions and persistence. It accepts only structured `--portal-*` theme
tokens and rejects raw CSS, external resource references, nested CSS variable
references, and rule breakouts before sending tokens to the persistence API.

### Required APIs

An AI portal deployment normally provides these browser-reachable APIs:

```text
/api/v1/auth/*
/api/v1/billing/*
/v1/chat/completions
/v1/models
/api/v1/containers/status
/api/v1/containers/runs
/api/v1/terminal/sessions
/api/v1/terminal/sessions/{id}/input
/api/v1/terminal/sessions/{id}/stream
/api/v1/terminal/sessions/{id}/resize
```

The browser origin must be allowed by the portal Content Security Policy
`connect-src`. Each backend API still validates its own JWT audience, scopes,
account ownership, billing entitlement, and quota state.

### Sources

- [bus-portal](./bus-portal)
- [bus-portal-auth](./bus-portal-auth)
- [bus-api-provider-billing](./bus-api-provider-billing)
- [bus-api-provider-llm](./bus-api-provider-llm)
- [bus-api-provider-containers](./bus-api-provider-containers)
- [bus-api-provider-terminal](./bus-api-provider-terminal)
