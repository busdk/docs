---
title: bus-api-provider-cloud
description: bus-api-provider-cloud exposes provider-neutral cloud capabilities and planning endpoints for running Bus deployments.
---

## Cloud API Provider

`bus-api-provider-cloud` is the running-Bus HTTP surface for provider-neutral
cloud operations. It exposes cloud capability and planning endpoints that are
implemented through `bus-integration-cloud` contracts instead of direct
provider-specific code.

Run this provider on loopback or a protected internal network behind `bus-api`.
The supported deployment boundary is `bus-api` routing with internal routes
matching `/api/internal/cloud/*`, an operator/internal token accepted at the
Bus API layer, and reverse-proxy rules that do not expose the provider listener
directly to the public internet. The current provider handler is an internal
component and does not perform public-client authentication by itself.

Available endpoints return `200` with JSON on success:

- `GET /healthz` returns `{"ok":true,"service":"bus-api-provider-cloud"}`.
- `GET /api/internal/cloud/capabilities` returns provider-neutral capability metadata with `providers`, `events`, and `direct_bootstrap`.
- `GET /api/internal/cloud/plan` returns `{"ok":true,"actions":[...]}` for the current cloud plan view.

Run the provider behind the internal Bus API route used by operators and
deployment automation:

```sh
bus-api-provider-cloud --addr 127.0.0.1:8091
```

In a second shell, verify the provider:

```sh
curl -fsS http://127.0.0.1:8091/healthz
curl -fsS http://127.0.0.1:8091/api/internal/cloud/capabilities
```

The first check succeeds with `ok: true`; the second includes cloud event names
such as `bus.cloud.plan.request`.

Obtain `$BUS_OPERATOR_TOKEN` through the deployment's token bootstrap flow. For
a local HS256 deployment, the command is:

```sh
BUS_OPERATOR_TOKEN="$(bus operator token --format token issue --local \
  --hs256-secret-file ./local/hs256-secret \
  --subject cloud-operator \
  --audience ai.hg.fi/api \
  --scope cloud:admin \
  --ttl 15m)"
```

Before mounting behind `bus-api`, add the provider route to the deployment's
`bus-api` route configuration, for example `./deploy/bus-api-routes.json`:

```json
{
  "routes": [
    {
      "prefix": "/api/internal/cloud/",
      "upstream": "http://127.0.0.1:8091",
      "required_scope": "cloud:admin"
    }
  ]
}
```

Load that file through the Bus API service configuration used by your
deployment. Replace `https://example.test` below with the public or internal
base URL of that mounted Bus API. After the route exists, verify the protected
route:

```sh
curl -fsS -H "Authorization: Bearer $BUS_OPERATOR_TOKEN" \
  https://example.test/api/internal/cloud/capabilities
```

The direct loopback commands above are local provider-only verification.

### Using From .bus Files

Repository-local automation should start the provider on loopback and let
`bus-api` or the supervisor own public routing:

```bus
# same as: bus-api-provider-cloud --addr 127.0.0.1:8091
run command -- bus-api-provider-cloud --addr 127.0.0.1:8091
```

Provider-specific credentials and API behavior belong to integration modules.
For UpCloud-backed deployments, `bus-integration-upcloud` owns the UpCloud API
calls and `bus-integration-cloud` owns the shared cloud event contract.

### Sources

- [bus-integration-cloud](./bus-integration-cloud)
- [bus-integration-upcloud](./bus-integration-upcloud)
- [bus operator cloud](./bus-operator-cloud)
