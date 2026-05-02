---
title: bus-integration-cloud
description: bus-integration-cloud defines provider-neutral cloud event contracts and direct bootstrap capability metadata.
---

## Cloud Integration Contract

`bus-integration-cloud` defines the provider-neutral event contract for Bus
cloud work. It is the shared boundary used by bootstrap tools, API providers,
and provider-specific cloud integrations.

Run the discovery commands after installing the `bus-integration-cloud` binary
from the same BusDK release set as `bus-api-provider-cloud`,
`bus-operator-cloud`, and the selected cloud provider integration. No cloud
credentials are required for these local contract checks. `--events` prints one
event name per line, `--events --format json` prints provider, event, and
direct-bootstrap capability metadata, and `--self-test` prints
`OK bus-integration-cloud self-test`.

The JSON capability fields are `provider_neutral` boolean, `providers` string
array, `events` string array, and `direct_bootstrap` boolean.
`provider_neutral` must be `true` for this contract module. `providers` lists
registered provider ids; the static diagnostic provider may appear even without
cloud credentials. `events` is the authoritative event-name list for routing.
`direct_bootstrap` tells bootstrap tools whether they can call the Go contract
without a remote Events service.

```sh
bus-integration-cloud --events
bus-integration-cloud --events --format json
bus-integration-cloud --self-test
```

Cloud request and response events include:

- `bus.cloud.plan.request` and `bus.cloud.plan.response`: request fields identify provider, deployment id, environment, desired resources, and credential references; response fields include `ok`, planned actions, diagnostics, and validation errors.
- `bus.cloud.apply.request` and `bus.cloud.apply.response`: request fields include the reviewed plan or desired state plus dry-run/confirmation flags; response fields include applied actions, provider-neutral resource ids, and error class.
- `bus.cloud.status.request` and `bus.cloud.status.response`: request fields identify provider and deployment id; response fields include resource status summaries and diagnostics.
- `bus.cloud.destroy.request` and `bus.cloud.destroy.response`: request fields include provider, deployment id, and explicit confirmation; response fields include deleted or retained resources and destructive-operation diagnostics.

Concrete providers such as `bus-integration-upcloud` register behind these
contracts. Operator commands and API providers call the provider-neutral
contract first so a Bus deployment can add another cloud provider without
changing the deployment controller.

This is a minimal `bus.cloud.plan.request` payload:

```json
{
  "deployment_id": "example-dev",
  "provider": "upcloud",
  "environment": "dev",
  "dry_run": true,
  "confirm": false,
  "credentials": {
    "token_file": "./local/upcloud-token"
  },
  "resources": {
    "network": "example-dev-private",
    "nodes": ["proxy", "gpu"]
  }
}
```

Minimal cloud response payloads use this shape:

```json
{
  "ok": true,
  "deployment_id": "example-dev",
  "provider": "upcloud",
  "actions": ["discover-provider", "compute-cloud-plan"],
  "resources": [],
  "diagnostics": []
}
```

Required fields per event are:

- `bus.cloud.plan.request`: `deployment_id` string, `provider` string, optional `resources` object, and `credentials.token_file` or `credentials.token_secret` unless credentials are configured in the provider service environment; `dry_run` defaults to `true`.
- `bus.cloud.apply.request`: `deployment_id` string, `provider` string, `resources` object, optional `dry_run` boolean defaulting to `true`, `credentials.token_file` or `credentials.token_secret` unless credentials are configured in the provider service environment, and `confirm` boolean; `confirm` must be `true` unless `dry_run` is `true`.
- `bus.cloud.status.request`: `deployment_id` string and `provider` string.
- `bus.cloud.destroy.request`: `deployment_id` string, `provider` string, `credentials.token_file` or `credentials.token_secret` unless credentials are configured in the provider service environment, and `confirm` boolean set to `true`.

Plan/apply/destroy requests require provider credentials unless the selected
provider has credentials in its service environment. Supported credential keys
are `token_file` for file references such as `./local/upcloud-token` and
`token_secret` for secret references such as
`secret://deployment/upcloud-token`. Inline token values are invalid and should
fail validation with `error_class: "bad_request"`. Error responses set `ok` to
`false`, include `error_class`, and include a human-readable diagnostic.

### Using from `.bus` files

Inside a `.bus` file, call the integration diagnostic command directly:

```bus
# same as: bus-integration-cloud --events
run command -- bus-integration-cloud --events
```

### Sources

- [bus-api-provider-cloud](./bus-api-provider-cloud)
- [bus operator cloud](./bus-operator-cloud)
- [bus-integration-upcloud](./bus-integration-upcloud)
