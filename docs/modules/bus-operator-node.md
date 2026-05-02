---
title: bus operator node
description: bus operator node bootstraps, hardens, checks, and verifies generic Bus deployment nodes.
---

## Node Operations

`bus operator node` handles inside-the-machine setup for Bus hosts. Cloud
modules create or discover machines; node modules prepare the operating system,
service directories, credentials, firewall policy, listener checks, and service
readiness.

Run these commands from an operator workstation or bootstrap host that can reach
the target node through the configured transport. The `--id` value comes from
the deployment inventory or cloud status output, for example `proxy`, `gpu`, or
another host role id. For direct bootstrap, provide transport data to the node
integration through `BUS_NODE_TARGETS_FILE` and SSH credentials through
`BUS_SSH_PRIVATE_KEY_FILE`; running Bus deployments resolve the same values
through `bus-api-provider-node`, `bus-integration-node`, and
`bus-integration-ssh-runner`. Bootstrap and hardening require the operator
credentials or delegated service account needed to install packages, write
service files, place credentials, and update firewall rules on the target host.
The target file is JSON such as
`{"proxy":{"host":"10.0.0.10","user":"bus","port":22}}`. The SSH private key
file should be mode `0600` and accepted by the target account. Before running
`harden`, confirm you have an out-of-band recovery console or that SSH port 22
and the Bus service ports you need remain allowed by the firewall policy.
Define the firewall policy in the same deployment inventory that defines the
node targets, for example
`{"proxy":{"allowed_ports":[22,80,443,8080],"host":"10.0.0.10","user":"bus","port":22}}`,
then run `bus operator node status --id proxy` before `harden` to confirm the
node is reachable.

```sh
umask 077
install -m 700 -d ./deploy ./local
cat > ./deploy/nodes.json <<'EOF'
{"proxy":{"host":"10.0.0.10","user":"bus","port":22,"allowed_ports":[22,80,443,8080]}}
EOF
export BUS_NODE_TARGETS_FILE=./deploy/nodes.json
export BUS_SSH_PRIVATE_KEY_FILE=./local/id_ed25519
test "$(stat -f %Lp "$BUS_SSH_PRIVATE_KEY_FILE" 2>/dev/null || stat -c %a "$BUS_SSH_PRIVATE_KEY_FILE")" = "600"
bus operator node bootstrap --id proxy
bus operator node harden --id proxy
bus operator node status --id proxy
bus operator node verify --id proxy
```

`bootstrap` exits 0 with `ok: true` and package, directory, and credential
actions. `harden` exits 0 with SSH and firewall actions. `status` exits 0 with
`ok: true`, `node_id`, and status actions. `verify` exits 0 with `ok: true`,
listener checks, and service checks. If
verification fails, run `bus-integration-node --self-test` to confirm the node
contract is available, then inspect the SSH runner service logs with
`journalctl -u bus-integration-ssh-runner --since -1h` on the host that runs
the `bus-integration-ssh-runner` service.

The node identifier comes from operator deployment inputs. In a running Bus
deployment, `bus-api-provider-node` exposes the internal API surface and
`bus-integration-node` owns the event-driven node work. Remote command
execution is delegated to `bus-integration-ssh-runner`.

### Sources

- [bus-api-provider-node](./bus-api-provider-node)
- [bus-integration-node](./bus-integration-node)
- [bus-integration-ssh-runner](./bus-integration-ssh-runner)
- [bus operator deploy](./bus-operator-deploy)
