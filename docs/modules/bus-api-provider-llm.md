---
title: bus-api-provider-llm — OpenAI-compatible LLM provider
description: bus-api-provider-llm is the planned Bus API provider for OpenAI-compatible /v1 model proxy behavior.
---

## `bus-api-provider-llm` — OpenAI-compatible LLM provider

`bus-api-provider-llm` is the provider for OpenAI-compatible `/v1/*` model
proxy behavior extracted from AI Platform api-proxy.

The provider should validate Bus auth model-access JWTs as one supported
credential source. Existing `bus-agent` providers and credential flows must
remain available.

### API

```text
GET  /readyz
ANY  /v1/*
```

Requests use Bearer JWT authentication with audience `ai.hg.fi/api` by default
and require `llm:proxy`. The JWT `sub` must be the stable account UUID. The
provider forwards OpenAI-compatible requests to the configured backend, strips
client authorization before forwarding, and records request and token usage
through `bus-api-provider-usage`.

### Sources

- [bus-api-provider-llm README](../../../bus-api-provider-llm/README.md)
