---
title: bus-integration-node
description: bus-integration-node defines generic node bootstrap, hardening, status, and verification event contracts.
---

## Node Integration Contract

`bus-integration-node` defines generic Bus node event contracts. It covers
inside-the-machine work after a cloud provider has created or discovered a
host.

Run the discovery commands after installing the matching release binary. No SSH
credentials are required for these local contract checks. `--events` prints one
event name per line, `--events --format json` prints transport, event, and
direct-bootstrap capability metadata, and `--self-test` prints
`OK bus-integration-node self-test`.

```sh
bus-integration-node --events
bus-integration-node --events --format json
bus-integration-node --self-test
```

Node request and response events include:

- `bus.node.bootstrap.request` and `bus.node.bootstrap.response`: request fields include node id, transport target reference, packages, directories, credential references, and services; responses include applied actions, diagnostics, and error class.
- `bus.node.harden.request` and `bus.node.harden.response`: request fields include node id, SSH policy, firewall policy, service account rules, and confirmation; responses include hardening actions and diagnostics.
- `bus.node.status.request` and `bus.node.status.response`: request fields identify the node; responses include reachability, service state, and last diagnostic details.
- `bus.node.verify.request` and `bus.node.verify.response`: request fields include node id and expected listeners/services; responses include `ok`, check results, and first failing check.

The integration uses `bus-integration-ssh-runner` for remote command execution
instead of embedding SSH transport details in operator or API-provider modules.

Operators normally send these requests through `bus operator node` or the
internal `bus-api-provider-node` route. Direct event publishers send the JSON
payload to the Bus Events API with the matching event type, for example
`POST /api/v1/events` on `bus-api-provider-events` with a bearer token that has
event publish scope. Include a `correlation_id` field in the event envelope and
consume the matching response event with the same correlation id.

```json
{
  "event_type": "bus.node.bootstrap.request",
  "correlation_id": "deploy-001-node-proxy",
  "payload": {
    "node_id": "proxy",
    "transport": "ssh-runner",
    "target_ref": "nodes.proxy",
    "dry_run": true
  }
}
```

The bearer token used to publish this envelope must include the deployment's
Bus Events publish scope, such as `events:write`.

This is a minimal `bus.node.bootstrap.request` payload published through the
Bus Events API as the event payload for event type `bus.node.bootstrap.request`:

```json
{
  "node_id": "proxy",
  "transport": "ssh-runner",
  "target_ref": "nodes.proxy",
  "dry_run": true,
  "confirm": false,
  "packages": ["nginx"],
  "directories": ["/etc/bus"],
  "credentials": {
    "ssh_private_key_secret": "secret://deployment/proxy-ssh-key"
  },
  "checks": ["ssh", "systemd", "listeners"]
}
```

Minimal node response payloads use this shape:

```json
{
  "ok": true,
  "node_id": "proxy",
  "actions": ["check-ssh", "install-packages"],
  "checks": [],
  "diagnostics": []
}
```

Required fields per event are:

- `bus.node.bootstrap.request`: `node_id` string, `transport` string, `target_ref` string, optional `packages` string array, optional `directories` string array, optional `credentials` object, optional `dry_run` boolean defaulting to `true`, and `confirm` boolean required for real mutation.
- `bus.node.harden.request`: `node_id` string, `transport` string, `target_ref` string, optional `ssh_policy` object, optional `firewall_policy` object, optional `dry_run` boolean defaulting to `true`, and `confirm` boolean required for real mutation.
- `bus.node.status.request`: `node_id` string and optional `checks` string array.
- `bus.node.verify.request`: `node_id` string and `checks` string array, such as `["ssh","systemd","listeners"]`.

Response fields for every node response are `ok` boolean, `node_id` string,
`actions` string array, optional `checks` array of objects with `name`, `ok`,
and `diagnostic` fields for status/verify responses, `diagnostics` string
array, and optional `error_class` string when `ok` is `false`. Credential values must be file references or
secret references. `ssh_private_key_file` is resolved on the SSH runner host,
not on the event publisher's workstation; when publishing through the Events
API, prefer `ssh_private_key_secret` such as
`secret://deployment/proxy-ssh-key` so the runner resolves the credential in
its own environment. Error responses include the first failing action or check.
For example, a failed verify response can include
`"diagnostics":["listener 127.0.0.1:8080 is not reachable"]` and
`"error_class":"verify_failed"`.

### Sources

- [bus-api-provider-node](./bus-api-provider-node)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner)
- [bus operator node](./bus-operator-node)
