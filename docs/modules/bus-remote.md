---
title: bus remote - remote platform registry
description: Manage non-secret Bus remote platform definitions for hosted Bus Events endpoints, local Compose remotes, and repository-local defaults.
---

## `bus remote` - choose where Bus platform calls go

`bus remote` manages named remote platform definitions for a workspace. Use it
when a repository needs a stable name for a hosted Bus Events endpoint, a local
Docker Compose platform, or a localhost development endpoint.

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
`compose.dev-task-docker.yaml` and `http://localhost:8081`, while
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
bus remote add --id localhost --kind compose --compose-file compose.dev-task-docker.yaml
bus remote default localhost
bus remote remove upcloud-gpu
```

Valid remote ids are lowercase host-like names with optional ports, such as
`localhost`, `localhost:8081`, `ai.hg.fi`, `hg`, `remote`, and
`upcloud-gpu`. Full `http://` and `https://` URLs are accepted by
`resolve` without storing them.

### Config file

The repository-local config is a small JSON registry. It can be committed when
the values are ordinary endpoint names, URLs, and Compose file paths.

```json
{
  "default": "upcloud-gpu",
  "remotes": [
    {
      "id": "localhost",
      "kind": "compose",
      "url": "http://localhost:8081",
      "compose_file": "compose.dev-task-docker.yaml"
    },
    {
      "id": "upcloud-gpu",
      "kind": "bus-events",
      "url": "https://events.example.invalid"
    }
  ]
}
```

Do not put credentials in `.bus/remote/config.json`. Config files and URL
queries are rejected when they contain secret-looking keys such as `token`,
`api_token`, `password`, `jwt`, `refresh_token`, `private_key`, or
`credential`. Use the normal Bus authentication and secret-reference tools for
tokens and passwords.

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
- [Module reference: bus-work](./bus-work)
- [Module reference: bus-dev](./bus-dev)
- [Module reference: bus-secrets](./bus-secrets)
- [Standard global flags](../cli/global-flags)
