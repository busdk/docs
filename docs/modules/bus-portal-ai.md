---
title: bus-portal-ai — AI portal UI module
description: bus-portal-ai provides chat and Codex terminal browser UI for the modular Bus portal host.
---

## `bus-portal-ai` — AI portal UI module

`bus-portal-ai` provides browser UI for AI Platform access: chat mode,
Codex/container session controls, terminal entry points, and billing/setup
prompts.

Portal hosts mount the module under `/modules/ai/`. The module must use Bus API
providers for backend work: auth, billing, LLM, containers, and terminal. It
must not integrate directly with `bus-integration-*` workers.
The module currently declares itself experimental and not default-enabled, so
`bus-portal` requires an explicit `--experimental --enable-module ai` opt-in
before mounting it.

The module serves external JavaScript and reads the API token from the shared
`bus-portal-auth` session. It calls billing status/setup/portal APIs, the
OpenAI-compatible `/v1/chat/completions` API, user-owned container run APIs,
and terminal session APIs with bearer authorization. Billing or entitlement
failures are shown as guidance; the frontend does not make backend
entitlement decisions.

AI-assisted theme customization calls configured portal theme APIs for
suggestions and persistence. It accepts only structured `--portal-*` theme
tokens and rejects raw CSS, external resource references, nested CSS variable
references, and rule breakouts before sending tokens to the persistence API.
