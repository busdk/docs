---
title: bus remote - remote platform registry
description: Manage non-secret Bus remote platform definitions for hosted Bus Events endpoints, local Compose remotes, and repository-local defaults.
---

## `bus remote` - choose where Bus platform calls go

`bus remote` manages named remote platform definitions for a workspace. Use it
when a repository needs a stable name for a hosted Bus Events endpoint, a local
Docker Compose platform, a localhost development endpoint, or a developer-owned
Docker worker host reached through SSH.

The command owns non-secret repository config at `.bus/remote/config.json` and
reads user fallback config from `BUS_CONFIG_DIR/remote/config.json` or
`~/.config/bus/remote/config.json`. Repository-local definitions override
user-level definitions with the same id, and a repository-local default
overrides the user-level default. Other Bus modules can resolve remotes through
the same Go registry library, so scripts and higher-level commands use the
same selected endpoint.

### Try it first

Show the current default remote:

```bash
bus remote resolve
```

With no config, the default is `ai.hg.fi`, which resolves to
`https://ai.hg.fi` as a `bus-events` remote. Local development has two common
forms: `localhost` is a `compose` remote using
`compose.yaml` and `http://localhost:8081`, while
`localhost:8081` resolves directly to a `bus-events` remote at
`http://localhost:8081`.

```bash
bus remote resolve localhost
bus remote resolve localhost:8081
bus remote --format json resolve ai.hg.fi
```

### Commands

`list` prints all merged built-in, user, and repository-local remotes. `show`
and `resolve` print one remote; omit the id to use the selected default.
`add`, `remove`, and `default` write repository-local config only.

```bash
bus remote list
bus remote show ai.hg.fi
bus remote resolve https://events.example.invalid
bus remote add --id upcloud-gpu --url https://events.example.invalid --default
bus remote add --id localhost --kind compose --compose-file compose.yaml
bus remote add bus@lab-host:/srv/bus/workers/lab-host --tags gpu,linux --capacity 2
bus remote default localhost
bus remote remove upcloud-gpu
```

Valid remote ids are lowercase host-like names with optional ports, such as
`localhost`, `localhost:8081`, `ai.hg.fi`, `hg`, `remote`, and
`upcloud-gpu`. Full `http://` and `https://` URLs are accepted by
`resolve` without storing them. SSH-style add targets such as
`ssh://lab-host`, `ssh://bus@lab-host/srv/bus`, and
`bus@lab-host:/srv/bus/workers/lab-host` infer `kind=ssh-docker`, store only
non-secret routing metadata, and use the target path as `remote_workdir`.
Explicit `ssh-docker` config may also set `ssh_host`, `ssh_user`, `ssh_port`,
`controller_events_url`, `worker_events_url`, `compose_file`, `capacity`, and
tags. `bus remote` does not open SSH or Docker itself; downstream tools verify
the worker host, for example:

```bash
bus task --remote lab-host check
```

### Config file

The repository-local config is a small JSON registry. It can be committed when
the values are ordinary endpoint names, URLs, Compose file paths, and
non-secret worker selection metadata.

```json
{
  "default": "upcloud-gpu",
  "remotes": [
    {
      "id": "localhost",
      "kind": "compose",
      "url": "http://localhost:8081",
      "compose_file": "compose.yaml"
    },
    {
      "id": "lab-host",
      "kind": "ssh-docker",
      "ssh_target": "bus@lab-host",
      "ssh_host": "lab-host",
      "ssh_user": "bus",
      "ssh_port": 22,
      "remote_workdir": "/srv/bus/workers/lab-host",
      "controller_events_url": "https://controller.lab.example.invalid",
      "worker_events_url": "http://bus-events:8081",
      "capacity": 2,
      "tags": ["gpu", "linux"]
    },
    {
      "id": "upcloud-gpu",
      "kind": "bus-events",
      "url": "https://events.example.invalid",
      "worker_defaults": {
        "agent_backend": "codex-appserver",
        "model": "gpt-5.4",
        "reasoning_effort": "high",
        "auth_mode": "chatgpt-subscription"
      },
      "worker_profiles": {
        "codex-spark": {
          "model": "gpt-5.3-codex-spark",
          "reasoning_effort": "high",
          "auth_mode": "chatgpt-subscription",
          "credential_source": {
            "kind": "os-credential-label",
            "ref": "codex-chatgpt-subscription"
          }
        },
        "api-gpt-53": {
          "model": "gpt-5.3-codex",
          "reasoning_effort": "high",
          "auth_mode": "openai-api-key",
          "credential_source": {
            "kind": "deployment-secret",
            "ref": "openai-api-worker-key"
          }
        }
      }
    }
  ]
}
```

Do not put credentials in `.bus/remote/config.json`. Config files and URL
queries are rejected when they contain secret-looking keys such as `token`,
`api_token`, `password`, `jwt`, `refresh_token`, `private_key`, or
inline credential values. The reserved `credential_source` object is allowed
only as a non-secret reference: its `kind` names a resolver boundary such as
`user-config-key`, `os-credential-label`, `deployment-secret`, or `token-file`,
and its `ref` is a key, label, secret name, or token-file path that the caller
or remote worker resolves outside the repository.

Worker defaults and profiles let tools such as `bus task start`,
`bus task status`, and related worker/supervisor flows select a local model
worker, a ChatGPT subscription Codex worker, or an API-key Codex worker
without hard-coding model names in higher-level task tooling. Model strings are
opaque provider/App Server identifiers, so local profiles may use names like
`gpt-oss:120b` or `gemma4:31b`, while hosted Codex profiles can use
`gpt-5.3-codex-spark` or API model ids such as
`gpt-5.3-codex`.

### Using from `.bus` files

Inside a `.bus` file, call this module without the `bus` prefix. These examples
resolve the same remote choices as the CLI commands above.

```bus
# same as: bus remote resolve
remote resolve

# same as: bus remote resolve localhost:8081
remote resolve localhost:8081

# same as: bus remote add --id upcloud-gpu --url https://events.example.invalid --default
remote add --id upcloud-gpu --url https://events.example.invalid --default
```

### What it does not do

`bus remote` does not execute workers, provision cloud resources, implement Bus
Events internals, or manage credentials. It only records and resolves the
non-secret platform location that another command should use.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-remote-control">bus-remote-control</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-events](./bus-events)
- [Module reference: bus-task](./bus-task)
- [Module reference: bus-dev](./bus-dev)
- [Module reference: bus-secrets](./bus-secrets)
- [Standard global flags](../cli/global-flags)
