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

For protected access through `bus-api`, enable the built-in provider by name
and enable the matching module mount. Store the Bus API capability token in an
untracked operator secret file before starting the service, then validate it is
non-empty. This starts the node provider in the `bus-api` process; it does not
require a separate `bus-api-provider-node --addr 127.0.0.1:8093` process. The
standalone provider command above is only for loopback diagnostics.

```sh
cd /path/to/deployment-repository
install -m 700 -d ./local
git check-ignore -q ./local/bus-api-capability-token || printf '%s\n' '/local/' >> .git/info/exclude
git check-ignore -q ./local/bus-api-capability-token
test -s ./local/bus-api-capability-token || openssl rand -hex 32 > ./local/bus-api-capability-token
chmod 600 ./local/bus-api-capability-token
test -s ./local/bus-api-capability-token
BUS_API_CAPABILITY_TOKEN="$(tr -d '\r\n' < ./local/bus-api-capability-token)"
test -n "$BUS_API_CAPABILITY_TOKEN"
bus-api serve --token "$BUS_API_CAPABILITY_TOKEN" --port 8080 \
  --provider node \
  --enable-module node
```

Keep `bus-api serve` running in that shell. In a second shell, set
`$BUS_API_BASE_URL` to the local capability URL printed by `bus-api`, then
verify the protected route:

```sh
cd /path/to/deployment-repository
BUS_API_CAPABILITY_TOKEN="$(tr -d '\r\n' < ./local/bus-api-capability-token)"
test -n "$BUS_API_CAPABILITY_TOKEN"
export BUS_API_BASE_URL="http://127.0.0.1:8080/${BUS_API_CAPABILITY_TOKEN}/v1"
curl -fsS "$BUS_API_BASE_URL/api/internal/node/capabilities"
```

With the correct Bus API capability URL, the command returns capability JSON.
Without that URL token, the Bus API layer returns a 404 before it reaches this
provider.

Use this provider on internal Bus routes. End users do not call it directly;
deployment and operator automation call it with the appropriate internal
authorization.

### Sources

- [bus-integration-node](./bus-integration-node)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner)
- [bus operator node](./bus-operator-node)
