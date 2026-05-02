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

Run the provider directly only for loopback diagnostics:

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

For protected access through `bus-api`, enable the built-in provider by name
and enable the matching module mount. `bus-api` prints the capability URL on
startup; it has the form `http://host:port/{capability-token}/v1` unless
`--base-path` changes it. Store the Bus API capability token in an untracked
operator secret file before starting the service, then validate it is non-empty:

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
  --provider cloud \
  --enable-module cloud
```

Keep `bus-api serve` running in that shell. In a second shell, set
`$BUS_API_BASE_URL` to the local capability URL printed by `bus-api`, then
verify the protected route:

```sh
cd /path/to/deployment-repository
BUS_API_CAPABILITY_TOKEN="$(tr -d '\r\n' < ./local/bus-api-capability-token)"
test -n "$BUS_API_CAPABILITY_TOKEN"
export BUS_API_BASE_URL="http://127.0.0.1:8080/${BUS_API_CAPABILITY_TOKEN}/v1"
curl -fsS "$BUS_API_BASE_URL/api/internal/cloud/capabilities"
```

The direct loopback commands above are local provider-only verification. The
`bus-api` command is the supported protected route for operator automation.

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
