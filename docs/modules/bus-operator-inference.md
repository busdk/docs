---
title: bus operator inference
description: bus operator inference manages provider-neutral AI inference runtime installation, model availability, and readiness.
---

## Inference Operations

`bus operator inference` controls AI inference runtime setup through a
provider-neutral command surface. It handles runtime installation, model
availability, status checks, and readiness verification for a selected node.
Concrete providers such as Ollama are implemented behind
`bus-integration-ollama`.

Run these commands from an operator workstation or bootstrap host that has the
Bus deployment inventory and can reach the selected node through the configured
node/SSH path. The `--node` value comes from the deployment inventory or cloud
status output. The selected provider must be available through
`bus-integration-inference`; for Ollama, install `bus-integration-ollama` and
ensure the target node has the OS permissions and network access needed to
install the runtime and fetch models. For Ollama, that means root or sudo
access on the target inference node and outbound HTTPS access to the configured
model source.

```sh
bus operator inference install --node gpu --provider ollama
bus operator inference model ensure --node gpu --provider ollama --model llama3.2:3b
bus operator inference status --node gpu --provider ollama
bus operator inference verify --node gpu --provider ollama
```

`install` succeeds with runtime install/configure actions. `model ensure`
succeeds with an idempotent model availability action. `status` returns the
provider runtime status for the node. `verify` returns readiness checks. If
readiness fails, run `bus operator node verify --id gpu` first, then
check the provider integration diagnostics such as `bus-integration-ollama
--self-test`.

Use this command when operating model-serving hosts as part of a Bus deployment.
In a running Bus system, `bus-api-provider-inference` exposes the matching
internal API surface and `bus-integration-inference` owns the shared event
contract.

### Sources

- [bus-api-provider-inference](./bus-api-provider-inference)
- [bus-integration-inference](./bus-integration-inference)
- [bus-integration-ollama](./bus-integration-ollama)
- [bus operator deploy](./bus-operator-deploy)
