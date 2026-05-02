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
Confirm the release set before running them:

```sh
bus-integration-cloud --version
bus-api-provider-cloud --version
bus-operator-cloud --version
# UpCloud example; replace with the selected provider integration binary.
bus-integration-upcloud --version
```

The printed versions must be the same BusDK release tag, or all be local
development builds from the same checkout.

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

This is a minimal `bus.cloud.plan.request` schema example. Submit it through
the Bus Events `POST $BUS_EVENTS_API_BASE_URL/api/v1/events` API using
`Content-Type: application/json` and a bearer token with `events:write`, or use
[bus operator cloud](./bus-operator-cloud) for the operator CLI path. The
Events API envelope uses this outer shape:

```json
{
  "name": "bus.cloud.plan.request",
  "correlation_id": "deploy-001-cloud-plan",
  "delivery": "broadcast",
  "payload": {}
}
```

Put the cloud request fields below inside `payload`.

```json
{
  "deployment_id": "example-dev",
  "provider": "upcloud",
  "environment": "dev",
  "dry_run": true,
  "credentials": {
    "token_secret": "secret://deployment/upcloud-token"
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
  "resources": {
    "network": "example-dev-private",
    "nodes": ["proxy", "gpu"]
  },
  "diagnostics": []
}
```

Required fields per event are:

- `bus.cloud.plan.request`: `deployment_id` string, `provider` string, optional `environment` string defaulting to `dev`, optional `resources` object with `network` string, `nodes` string array or object map, optional `addresses` string array, and optional `dns` object, plus `credentials.token_file` or `credentials.token_secret` unless credentials are configured in the provider service environment; `dry_run` defaults to `true`.
- `bus.cloud.apply.request`: `deployment_id` string, `provider` string, `resources` object using the same shape as `plan.request`, optional `planned_actions` string array from a reviewed plan, optional `dry_run` boolean defaulting to `true`, `credentials.token_file` or `credentials.token_secret` unless credentials are configured in the provider service environment, and `confirm` boolean; `confirm` must be `true` unless `dry_run` is `true`.
- `bus.cloud.status.request`: `deployment_id` string, `provider` string, and optional `resources` filter object with `nodes` string array and `network` string when only part of a deployment should be inspected.
- `bus.cloud.destroy.request`: `deployment_id` string, `provider` string, `credentials.token_file` or `credentials.token_secret` unless credentials are configured in the provider service environment, and `confirm` boolean set to `true`.

Required response fields per event are:

- `bus.cloud.plan.response`: `ok` boolean, `deployment_id` string, `provider` string, `actions` string array, `resources` object using the plan-request shape with planned provider-neutral ids when known, and `diagnostics` string array; when `ok` is `false`, include `error_class`.
- `bus.cloud.apply.response`: `ok` boolean, `deployment_id` string, `provider` string, `actions` string array, `resources` object using the plan-request shape plus provider-neutral ids for created or updated resources, and `diagnostics` string array; when `ok` is `false`, include `error_class`.
- `bus.cloud.status.response`: `ok` boolean, `deployment_id` string, `provider` string, `resources` object using the same keys but containing current provider state, and `diagnostics` string array.
- `bus.cloud.destroy.response`: `ok` boolean, `deployment_id` string, `provider` string, `actions` string array, `deleted_resources` string array, `retained_resources` string array, and `diagnostics` string array; when `ok` is `false`, include `error_class`.

Plan/apply/destroy requests require provider credentials unless the selected
provider has credentials in its service environment. Supported credential keys
are `token_file` for file references such as `./local/upcloud-token` and
`token_secret` for secret references such as
`secret://deployment/upcloud-token`. Inline token values are invalid and should
fail validation with `error_class: "bad_request"`. When submitted through the
Events API, `token_file` must be readable by the provider service process, not
only by the publisher shell; prefer `token_secret` for remote submissions. The `resources` object may
contain `network` string, `nodes` string array or object map, `addresses`
string array, and `dns` object. An apply request should reuse the reviewed
`resources` object and may include `planned_actions` string array copied from a
prior plan response for auditability. Destroy requests accept only the
deployment id, provider, credentials, and `confirm: true`; they must not accept
inline token values.

Error responses set `ok` to `false`, include `error_class`, and include a
human-readable diagnostic. Allowed `error_class` values are `bad_request` for
invalid JSON, invalid credentials references, or unsupported resource keys;
`unauthorized` for missing or rejected provider credentials; `conflict` when a
provider resource exists with incompatible ownership; `provider_error` for
cloud API failures; and `timeout` when provider operations exceed the request
deadline.

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
