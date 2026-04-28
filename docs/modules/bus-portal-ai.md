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
