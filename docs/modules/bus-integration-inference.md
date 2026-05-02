---
title: bus-integration-inference
description: bus-integration-inference defines provider-neutral AI inference runtime event contracts.
---

## Inference Integration Contract

`bus-integration-inference` defines the provider-neutral event contract for AI
inference runtime operations. It keeps model-serving providers such as Ollama
behind a stable Bus boundary.

Run the discovery commands after installing `bus-integration-inference` from
the same BusDK release set as `bus-api-provider-inference`,
`bus-operator-inference`, and the selected provider integration. Verify the
installed version with `bus-integration-inference --version` and compare it to
the release tag used for the other modules. No runtime credentials are required
for these local contract checks. `--events` prints one event name per line,
`--events --format json` prints provider, event, and direct-bootstrap
capability metadata, and `--self-test` prints
`OK bus-integration-inference self-test`.

```sh
bus-integration-inference --events
bus-integration-inference --events --format json
bus-integration-inference --self-test
```

Inference request and response events include these JSON payload fields:

- `bus.inference.install.request`: `provider` string, `node_id` string, optional `runtime` object, optional `credentials` object, optional `dry_run` boolean defaulting to `true`, and optional `confirm` boolean defaulting to `false`.
- `bus.inference.install.response`: `ok` boolean, `provider` string, `node_id` string, `actions` string array, optional `runtime_status` string, `diagnostics` string array, and optional `error_class` string when `ok` is `false`.
- `bus.inference.model.ensure.request`: `provider` string, `node_id` string, `model` string, optional `dry_run` boolean defaulting to `true`, optional `confirm` boolean defaulting to `false`, and optional `policy` object.
- `bus.inference.model.ensure.response`: `ok` boolean, `provider` string, `node_id` string, `model` string, `actions` string array, `diagnostics` string array, and optional `error_class` string when `ok` is `false`.
- `bus.inference.status.request`: `provider` string and `node_id` string.
- `bus.inference.status.response`: `ok` boolean, `provider` string, `node_id` string, `runtime_status` string, optional `models` string array, `diagnostics` string array, and optional `error_class` string when `ok` is `false`.
- `bus.inference.verify.request`: `provider` string, `node_id` string, and optional `checks` string array. If `checks` is omitted, the provider uses its default runtime-readiness checks.
- `bus.inference.verify.response`: `ok` boolean, `provider` string, `node_id` string, `checks` object or array, `diagnostics` string array, and optional `error_class` string when `ok` is `false`.

Provider-specific inference modules register behind this contract. Bootstrap
tools and running Bus API providers use the same event names and capability
metadata.

Allowed `credentials` keys are `api_token_secret`, `tls_ca_file`, and
`ssh_private_key_secret`; inline secret values are invalid. Secret references
use the `secret://deployment/<name>` form and must already exist in the
deployment's Bus secret resolver, for example
`"api_token_secret": "secret://deployment/ollama-registry-token"` or
`"ssh_private_key_secret": "secret://deployment/gpu-ssh-key"`. Allowed
`runtime` keys are `listen` string, `context_length` integer, `service_user`
string, and `environment` string defaulting to `dev`. Allowed `policy` keys are
`allow_model_download` boolean defaulting to `false`,
`max_model_size_bytes` integer, and `require_confirmation_for_prod` boolean
defaulting to `true`. `checks` is a string array; known values are
`runtime-ready`, `model-ready`, and `loopback-only`, and unknown checks should
fail validation.

Submit these payloads through `POST $BUS_EVENTS_API_BASE_URL/api/v1/events` on
[bus-api-provider-events](./bus-api-provider-events), or use
[bus operator inference](./bus-operator-inference) for the operator CLI path.
Set `$BUS_EVENTS_API_BASE_URL` to the Bus Events provider base URL, for example
`https://example.test`, and set `$BUS_EVENTS_TOKEN` to a bearer token with
`events:write` for publish and `events:read` for streaming. The request must
use `Content-Type: application/json`. The event envelope uses `name` for the
event type and the request payload under `payload`. Save the envelope to
`./deploy/inference-model-event.json` before posting it:

```sh
install -m 700 -d ./deploy
cat > ./deploy/inference-model-event.json <<'EOF'
{
  "name": "bus.inference.model.ensure.request",
  "correlation_id": "deploy-001-inference-model",
  "delivery": "broadcast",
  "payload": {
    "provider": "ollama",
    "node_id": "gpu",
    "model": "llama3.2:3b",
    "dry_run": true,
    "confirm": false
  }
}
EOF
curl -fsS -X POST "$BUS_EVENTS_API_BASE_URL/api/v1/events" \
  -H "Authorization: Bearer $BUS_EVENTS_TOKEN" \
  -H "Content-Type: application/json" \
  --data @./deploy/inference-model-event.json
```

A successful publish returns `202 Accepted` or `200 OK` with stored event
metadata. To wait for completion, stream the matching response event and filter
the same `correlation_id`:

```sh
curl -fsS -N "$BUS_EVENTS_API_BASE_URL/api/v1/events/stream?name=bus.inference.model.ensure.response&delivery=broadcast" \
  -H "Authorization: Bearer $BUS_EVENTS_TOKEN" |
  grep 'deploy-001-inference-model'
```

This is a minimal `bus.inference.model.ensure.request` payload:

```json
{
  "provider": "ollama",
  "node_id": "gpu",
  "model": "llama3.2:3b",
  "dry_run": true,
  "confirm": false
}
```

Use the request example for `bus.inference.model.ensure.request`. For
`bus.inference.install.request`, omit `model`; model installation uses
`bus.inference.model.ensure.request` unless a provider-specific extension
explicitly documents another field. `bus.inference.status.request` requires
`provider` and `node_id`. `bus.inference.verify.request` requires `provider`, `node_id`, and
optional `checks`, for example `["runtime-ready","model-ready"]`.

Minimal `bus.inference.model.ensure.response` payloads use this shape. Install,
status, and verify responses use their own required fields listed below.

```json
{
  "ok": true,
  "provider": "ollama",
  "node_id": "gpu",
  "model": "llama3.2:3b",
  "actions": ["ensure-model"],
  "diagnostics": []
}
```

Required fields per event are:

- `bus.inference.install.request`: `provider` string and `node_id` string; `runtime` is optional object metadata with keys such as `listen` string and `context_length` integer; `dry_run` defaults to `true`; `confirm` must be `true` unless `dry_run` is `true`.
- `bus.inference.model.ensure.request`: `provider` string, `node_id` string, and `model` string; `dry_run` defaults to `true`; `confirm` must be `true` unless `dry_run` is `true`; use `policy` for model-specific limits and keep runtime listener settings in `install.request`.
- `bus.inference.status.request`: `provider` string and `node_id` string.
- `bus.inference.verify.request`: `provider` string, `node_id` string, and optional `checks` string array.

Error responses set `ok` to `false`, include `error_class`, and include a
diagnostic message.

Accepted provider values come from `bus-integration-inference --events --format
json`; this deployment documents `ollama`. `node_id` is a deployment inventory
id such as `gpu` using letters, digits, `_`, or `-`. Common check values are
`runtime-ready` and `model-ready`. Common `runtime_status` values are
`unknown`, `installing`, `ready`, and `failed`.

Required response fields per event are:

- `bus.inference.install.response`: `ok` boolean, `provider` string, `node_id` string, `actions` string array, and `diagnostics` string array.
- `bus.inference.model.ensure.response`: `ok` boolean, `provider` string, `node_id` string, `model` string, `actions` string array, and `diagnostics` string array.
- `bus.inference.status.response`: `ok` boolean, `provider` string, `node_id` string, `runtime_status` string, optional `models` string array, and `diagnostics` string array.
- `bus.inference.verify.response`: `ok` boolean, `provider` string, `node_id` string, `checks` object or array, and `diagnostics` string array.

Every error response sets `ok` to `false`, includes `error_class` string, and
keeps provider secrets out of diagnostics.

### Using from `.bus` files

Inside a `.bus` file, call the integration diagnostic command directly:

```bus
# same as: bus-integration-inference --events
run command -- bus-integration-inference --events
```

### Sources

- [bus-api-provider-inference](./bus-api-provider-inference)
- [bus-integration-ollama](./bus-integration-ollama)
- [bus operator inference](./bus-operator-inference)
