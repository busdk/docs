---
title: bus-secrets
description: "How to store and resolve secret references for BusDK workflows with user and repository scopes, and how to use them from bus dev and bus run."
---

## `bus-secrets` - manage secret references for BusDK workflows

### Synopsis

`bus secrets [global flags] set <name> <value> [--scope user|repo]`  
`bus secrets [global flags] get <name> [--scope auto|user|repo]`  
`bus secrets [global flags] list [--scope auto|user|repo]`  
`bus secrets [global flags] resolve <value> [--scope auto|user|repo]`

### Description

`bus-secrets` stores and resolves secret values by name. It supports user scope and repository scope so you can keep per-user credentials local while still defining repository-level defaults.

A secret reference uses the form `secret:<name>`. When a value is resolved in `auto` scope, lookup order is repository first, then user.

### Commands

`bus secrets set <name> <value> [--scope user|repo]` writes a secret value. Scope defaults to `user` for `set`.

`bus secrets get <name> [--scope auto|user|repo]` reads one secret value and prints it to stdout.

`bus secrets list [--scope auto|user|repo]` prints known secret names in sorted order.

`bus secrets resolve <value> [--scope auto|user|repo]` resolves plain values and `secret:<name>` references. Plain values are returned unchanged.

### Secret name format

Secret names must be lowercase and may contain lowercase letters, digits, `.`, `-`, and `_`.

### Scope and precedence

User scope is stored via [bus-preferences](./bus-preferences) keys under `secrets.<name>`.

Repository scope is stored in workspace `datapackage.json` under `busdk.secrets.<name>`.

Auto scope resolves in this order:

1. Repository scope (`datapackage.json`, `busdk.secrets.<name>`)
2. User scope (`bus-preferences`, `secrets.<name>`)

This keeps repository-level configuration deterministic while still allowing user-scope fallback when the repository value is not set.

### Typical workflow

Set a local API key in user scope, then use a reference in step-level env configuration:

```bash
bus secrets set openai_api_key 'sk-...' --scope user
bus dev set env-for @work OPENAI_API_KEY secret:openai_api_key
bus run set env-for summarize OPENAI_API_KEY secret:openai_api_key
```

Check what is stored and how resolution works:

```bash
bus secrets list --scope auto
bus secrets get openai_api_key --scope user
bus secrets resolve secret:openai_api_key --scope auto
```

Define both values and verify repository override in `auto` scope:

```bash
bus secrets set openai_api_key '<set-this-in-user-scope>' --scope repo
bus secrets set openai_api_key 'sk-local-user-key' --scope user
bus secrets resolve secret:openai_api_key --scope auto
```

### Security guidance

User scope is the safer default for real credentials because values stay in user preferences and are not meant to be committed with repository data.

Repository scope writes to `datapackage.json`. Treat repository-scoped secrets as visible project configuration and avoid storing production credentials there unless your repository policy explicitly allows it.

### Global flags

Standard global flags are supported: `-h`, `-V`, `-C`, `-o`, and `-q`.

### Files

`bus-secrets` reads and writes user-scope values through [bus-preferences](./bus-preferences). It reads and writes repository-scope values through [bus-config](./bus-config) workspace configuration path resolution and `datapackage.json`.

### Exit status and errors

Exit code `0` means success. Exit code `1` means execution failure, such as not found in `get`/`resolve` or an unreadable workspace path. Exit code `2` means invalid usage, such as unknown command, missing required arguments, invalid scope, or invalid secret name.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus secrets set openai_api_key 'sk-...' --scope user
secrets set openai_api_key 'sk-...' --scope user

# same as: bus secrets resolve secret:openai_api_key --scope auto
secrets resolve secret:openai_api_key --scope auto
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-shell">bus-shell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-secrets README](https://github.com/busdk/bus-secrets)
- [bus-dev CLI reference](./bus-dev)
- [bus-run CLI reference](./bus-run)
- [bus-preferences CLI reference](./bus-preferences)
- [bus-config CLI reference](./bus-config)
- [Workspace configuration](../data/workspace-configuration)
