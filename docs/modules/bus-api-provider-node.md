---
title: bus-api-provider-node
description: bus-api-provider-node exposes internal node bootstrap and verification capabilities for running Bus deployments.
---

## Node API Provider

`bus-api-provider-node` is the running-Bus HTTP surface for node capability
discovery. Node mutation work is handled through `bus-integration-node` and
remote command execution is delegated to the SSH runner integration.

Run this provider on loopback or a protected internal network behind `bus-api`.
The current provider handler is an internal component and does not perform
public-client authentication by itself; production deployments must mount this
provider under `bus-api` internal routes matching `/api/internal/node/*`,
require an operator/internal token with node administration scope at the Bus API
layer, and keep the provider listener on loopback or a private service network.
The deployment route should forward `/api/internal/node/*` to
`http://127.0.0.1:8093`, and the Bus API auth policy should require an
operator token with `node:admin` or the deployment's equivalent internal node
administration scope.
Automation obtains its internal caller context from the deployed Bus auth/token
flow or from bootstrap-only internal credentials managed outside Git.

Available endpoints return `200` with JSON on success:

- `GET /healthz` returns `{"ok":true,"service":"bus-api-provider-node"}`.
- `GET /api/internal/node/capabilities` returns generic node capability metadata with transport, events, and direct-bootstrap support.

```sh
bus-api-provider-node --addr 127.0.0.1:8093
```

In a second shell, verify the provider:

```sh
curl -fsS http://127.0.0.1:8093/healthz
curl -fsS http://127.0.0.1:8093/api/internal/node/capabilities
```

The first check succeeds with `ok: true`; the second includes node event names
such as `bus.node.bootstrap.request`. Unknown paths return the normal HTTP
`404` response from the provider mux.

After mounting behind `bus-api`, verify the protected route:
The `./local/hs256-secret`, `ai.hg.fi/api` audience, and
`https://example.test` base URL in this example must match the Bus API
deployment that mounts the node provider.

```sh
BUS_OPERATOR_TOKEN="$(bus operator token --format token issue --local \
  --hs256-secret-file ./local/hs256-secret \
  --subject node-operator \
  --audience ai.hg.fi/api \
  --scope node:admin \
  --ttl 15m)"
curl -fsS -H "Authorization: Bearer $BUS_OPERATOR_TOKEN" \
  https://example.test/api/internal/node/capabilities
```

With a valid `node:admin` or equivalent internal token, the command returns
capability JSON. Without that token, the Bus API layer should reject the request
before it reaches this provider.

Use this provider on internal Bus routes. End users do not call it directly;
deployment and operator automation call it with the appropriate internal
authorization.

### Sources

- [bus-integration-node](./bus-integration-node)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner)
- [bus operator node](./bus-operator-node)
