---
title: bus-api-provider-vm — VM API provider
description: bus-api-provider-vm is the planned cloud-neutral Bus API provider for VM/runtime status and lifecycle endpoints.
---

## `bus-api-provider-vm` — VM API provider

`bus-api-provider-vm` is the server-side provider for cloud-neutral VM/runtime
APIs.

Provider-specific cloud implementation details do not belong here. UpCloud
behavior is planned for `bus-integration-upcloud`, which will consume Bus Events
and publish result events.

### API

```text
GET  /api/v1/vm/status
POST /api/v1/vm/start
POST /api/v1/vm/stop
GET  /readyz
```

Requests use Bearer JWT authentication with audience `ai.hg.fi/api` by default.
Status requires `vm:read`; lifecycle requests require `vm:write`. The provider
can run with a deterministic static backend for local tests or in Bus Events
request/reply mode. In events mode, start the provider with `--backend events`,
`--events-url`, and `--api-token`; `--api-token` is a normal Bus API JWT
with audience `ai.hg.fi/api` and the VM domain scopes needed for the events it
sends and receives. The provider process owns the response listener and
correlates responses to in-flight HTTP requests.

### Sources

- [bus-api-provider-vm README](../../../bus-api-provider-vm/README.md)
