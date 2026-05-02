---
title: bus-integration-ollama
description: bus-integration-ollama provides Ollama-specific inference integration behind Bus inference contracts.
---

## Ollama Integration

`bus-integration-ollama` registers Ollama behind the provider-neutral
`bus-integration-inference` contract. It owns Ollama-specific installation,
loopback configuration, context-length configuration, model ensure, and
readiness checks.

Run `--events` first to verify the provider advertises the inference contract.
Use `--dry-run install` to inspect the Ollama action plan without changing the
host or downloading a model. A real install path runs on the target inference
node, currently a Linux host prepared by `bus operator node`, and must have
root privileges or `sudo` rights to install packages and manage the Ollama
service. It must also have network access to fetch the requested model from the
configured model source. `--self-test` succeeds by printing
`OK bus-integration-ollama self-test`.

```sh
bus-integration-ollama --events
bus-integration-ollama --events --format json
bus-integration-ollama --dry-run install --model llama3.2:3b
bus-integration-ollama install --model llama3.2:3b
bus-integration-ollama --self-test
```

The non-dry-run install command is the provider-specific path used by bootstrap
automation after the operator has confirmed the plan. Get the node id from
`bus operator cloud status --env-file ./deploy/cloud.env` or the deployment
inventory; `gpu` is the example node id below. Successful readiness is reported through
`bus operator inference verify --node gpu --provider ollama` returning
`ok: true`.

### Using From .bus Files

In a `.bus` workflow, call the provider through the normal command line so the
same CLI contract is used by humans and automation:

```bus
# same as: bus-integration-ollama --dry-run install --model llama3.2:3b
run command -- bus-integration-ollama --dry-run install --model llama3.2:3b
```

Use `bus operator inference` for operator-facing runtime commands. Use this
integration directly for provider diagnostics or when wiring a bootstrap flow
that needs Ollama-specific capability metadata.

### Sources

- [bus-integration-inference](./bus-integration-inference)
- [bus-api-provider-inference](./bus-api-provider-inference)
- [bus operator inference](./bus-operator-inference)
