---
title: bus-api-provider-inference
description: bus-api-provider-inference exposes internal inference runtime capabilities for running Bus deployments.
---

## Inference API Provider

`bus-api-provider-inference` is the running-Bus HTTP surface for inference
runtime capabilities. It keeps API controllers provider-neutral and delegates
provider-specific runtime work through `bus-integration-inference`.

Run this provider on loopback or a protected internal network behind `bus-api`.
The current provider handler is an internal component and does not perform
public-client authentication by itself; production deployments must protect
`/api/internal/inference/*` with Bus API routing, internal networking, and
operator authorization. Configure the matching inference integration providers
before using the capability endpoint in a deployment. For Ollama-backed
deployments this means installing `bus-integration-ollama` from the same BusDK
release set and setting `BUS_INFERENCE_PROVIDER=ollama` in the operator or
service environment.

Available endpoints return `200` with JSON on success:

- `GET /healthz` returns `{"ok":true,"service":"bus-api-provider-inference"}`.
- `GET /api/internal/inference/capabilities` returns provider-neutral inference capability metadata with providers, events, and direct-bootstrap support.

```sh
BUS_INFERENCE_PROVIDER=ollama bus-api-provider-inference --addr 127.0.0.1:8094
```

In a second shell, verify the provider:

```sh
curl -fsS http://127.0.0.1:8094/healthz
curl -fsS http://127.0.0.1:8094/api/internal/inference/capabilities
```

The first check succeeds with `ok: true`; the second includes inference event
names such as `bus.inference.install.request`.

For protected access through `bus-api`, enable the built-in provider by name
and enable the matching module mount. Store the Bus API capability token in an
untracked operator secret file before starting the service, then validate it is
non-empty:

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
  --provider inference \
  --enable-module inference
```

Keep `bus-api serve` running in that shell. In a second shell, set
`$BUS_API_BASE_URL` to the local capability URL printed by `bus-api`, then
verify the protected route:

```sh
cd /path/to/deployment-repository
BUS_API_CAPABILITY_TOKEN="$(tr -d '\r\n' < ./local/bus-api-capability-token)"
test -n "$BUS_API_CAPABILITY_TOKEN"
export BUS_API_BASE_URL="http://127.0.0.1:8080/${BUS_API_CAPABILITY_TOKEN}/v1"
curl -fsS "$BUS_API_BASE_URL/api/internal/inference/capabilities"
```

Use this provider on internal Bus routes for operator and deployment
automation. Ollama-specific work belongs to `bus-integration-ollama`.

### Using From .bus Files

Repository-local automation should start the provider on loopback with an
explicit provider environment and let `bus-api` or the supervisor own public
routing:

```bus
# same as: BUS_INFERENCE_PROVIDER=ollama bus-api-provider-inference --addr 127.0.0.1:8094
run command -- sh -c 'BUS_INFERENCE_PROVIDER=ollama exec bus-api-provider-inference --addr 127.0.0.1:8094'
```

### Sources

- [bus-integration-inference](./bus-integration-inference)
- [bus-integration-ollama](./bus-integration-ollama)
- [bus operator inference](./bus-operator-inference)
