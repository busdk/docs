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
event publish scope. Set `$BUS_EVENTS_API_BASE_URL` to the Bus Events provider
base URL, for example `https://example.test`, and set `$BUS_EVENTS_TOKEN` to a
token with `events:write` for publish and `events:read` for streaming. Include
a `correlation_id` field in the event envelope. A `bus-integration-node`
worker or `bus-api-provider-node` route must already be running and subscribed;
otherwise the event can be stored but no node action or response event appears.
The node inventory must be configured where that worker or provider resolves
`target_ref`; exporting `BUS_NODE_TARGETS_FILE` in the publisher shell is only
valid when the same shell starts the local worker. For a service-managed worker,
install the inventory on the worker host and restart the worker with that
environment before publishing:

```sh
sudo install -m 700 -d /etc/bus
sudo tee /etc/bus/nodes.json >/dev/null <<'EOF'
{
  "proxy": {
    "host": "10.0.0.10",
    "user": "bus",
    "port": 22
  }
}
EOF
sudo systemctl set-environment BUS_NODE_TARGETS_FILE=/etc/bus/nodes.json
sudo systemctl set-environment BUS_SSH_PRIVATE_KEY_SECRET=secret://deployment/proxy-ssh-key
sudo systemctl restart bus-integration-node
```

The `secret://deployment/proxy-ssh-key` secret must already resolve on the
`bus-integration-ssh-runner` host to a private key accepted by `bus@10.0.0.10`.
Then publish from the operator shell:

```sh
install -m 700 -d ./deploy
cat > ./deploy/node-bootstrap-event.json <<'EOF'
{
  "name": "bus.node.bootstrap.request",
  "correlation_id": "deploy-001-node-proxy",
  "delivery": "broadcast",
  "payload": {
    "node_id": "proxy",
    "transport": "ssh-runner",
    "target_ref": "nodes.proxy",
    "credentials": {
      "ssh_private_key_secret": "secret://deployment/proxy-ssh-key"
    },
    "dry_run": true,
    "confirm": false
  }
}
EOF
curl -fsS -X POST "$BUS_EVENTS_API_BASE_URL/api/v1/events" \
  -H "Authorization: Bearer $BUS_EVENTS_TOKEN" \
  -H "Content-Type: application/json" \
  --data @./deploy/node-bootstrap-event.json
```

Successful publish returns `202 Accepted` or `200 OK` with stored event
metadata. Consume the matching response event with the same correlation id
through the Events stream endpoint:

```sh
curl -fsS -N "$BUS_EVENTS_API_BASE_URL/api/v1/events/stream?name=bus.node.bootstrap.response&delivery=broadcast" \
  -H "Authorization: Bearer $BUS_EVENTS_TOKEN" |
  grep '"correlation_id":"deploy-001-node-proxy"'
```

`target_ref` is resolved by `bus-integration-node` from deployment inventory.
The `nodes.<id>` namespace maps to a node entry, for example
`nodes.proxy={"host":"10.0.0.10","user":"bus","port":22}` from
`BUS_NODE_TARGETS_FILE` or the running Bus node inventory service.

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
  }
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

- `bus.node.bootstrap.request`: `node_id` string, `transport` string, `target_ref` string, optional `packages` string array, optional `directories` string array, optional `credentials` object, optional `dry_run` boolean defaulting to `true`, and `confirm` boolean. Bootstrap changes are applied only when `dry_run` is `false` and `confirm` is `true`.
- `bus.node.harden.request`: `node_id` string, `transport` string, `target_ref` string, optional `ssh_policy` object, optional `firewall_policy` object, optional `dry_run` boolean defaulting to `true`, and `confirm` boolean. Hardening changes are applied only when `dry_run` is `false` and `confirm` is `true`.
- `bus.node.status.request`: `node_id` string and optional `checks` string array.
- `bus.node.verify.request`: `node_id` string and `checks` string array, such as `["ssh","systemd","listeners"]`.

Allowed `credentials` keys are `ssh_private_key_secret`,
`ssh_private_key_file`, `sudo_password_secret`, and `known_hosts_file`; inline
secret values are invalid. `ssh_policy` may contain `disable_password_auth`
boolean defaulting to `true`, `allow_root_login` boolean defaulting to `false`,
and `authorized_key_secret` string secret reference. `firewall_policy` may
contain `allowed_ports` integer array, `default_deny_inbound` boolean
defaulting to `true`, and `allow_established` boolean defaulting to `true`.
Every policy object is optional, but unknown keys should fail validation.

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

### Using from `.bus` files

Inside a `.bus` file, call the integration diagnostic command directly:

```bus
# same as: bus-integration-node --events
run command -- bus-integration-node --events
```

### Sources

- [bus-api-provider-node](./bus-api-provider-node)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner)
- [bus operator node](./bus-operator-node)
