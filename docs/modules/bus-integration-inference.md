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

Inference request and response events include:

- `bus.inference.install.request` and `bus.inference.install.response`: request fields include provider, node id, runtime settings, credential references, dry-run, and confirmation; responses include install actions, runtime status, diagnostics, and error class.
- `bus.inference.model.ensure.request` and `bus.inference.model.ensure.response`: request fields include provider, node id, model name, and policy flags; responses include model availability, actions, diagnostics, and error class.
- `bus.inference.status.request` and `bus.inference.status.response`: request fields identify provider and node id; responses include runtime phase, model summary, and diagnostics.
- `bus.inference.verify.request` and `bus.inference.verify.response`: request fields include provider, node id, and readiness expectations; responses include `ok`, check results, and first failing check.

Provider-specific inference modules register behind this contract. Bootstrap
tools and running Bus API providers use the same event names and capability
metadata.

This is a minimal `bus.inference.model.ensure.request` payload:

```json
{
  "provider": "ollama",
  "node_id": "gpu",
  "model": "llama3.2:3b",
  "dry_run": true,
  "confirm": false,
  "runtime": {
    "listen": "127.0.0.1:11434",
    "context_length": 32768
  }
}
```

Use the request example for `bus.inference.model.ensure.request`. For
`bus.inference.install.request`, omit `model` unless the installer also ensures
a default model. `bus.inference.status.request` requires `provider` and
`node_id`. `bus.inference.verify.request` requires `provider`, `node_id`, and
optional `checks`, for example `["runtime-ready","model-ready"]`.

Minimal inference response payloads use this shape:

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

- `bus.inference.install.request`: `provider` string and `node_id` string; `runtime` is optional object metadata with keys such as `listen` string and `context_length` integer; `dry_run` defaults to `true`.
- `bus.inference.model.ensure.request`: `provider` string, `node_id` string, and `model` string; `confirm` must be `true` unless `dry_run` is `true`.
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
