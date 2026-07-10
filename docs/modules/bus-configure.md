---
title: bus configure — manage Bus environment files
description: Create, edit, inspect, validate, and diagnose Bus .env files from live module metadata, including BUS_PWD workspace selection.
---

## Manage Bus `.env` files from module metadata

Use `bus configure` to create and maintain the `.env` file for the effective
Bus workspace. It discovers environment-variable names, descriptions, feature
sets, and value schemas from installed module help instead of requiring a
separate generated configuration catalog.

`bus configure` manages environment files. It is separate from
[`bus config`](./bus-config), which manages workspace settings in
`datapackage.json`.

Start by listing or initializing the variables for one module:

```bash
bus configure --module journal list
bus configure --module journal init
bus configure BUS_JOURNAL_ACTOR=meri
bus configure --module journal validate
```

### Synopsis

```text
bus configure NAME=VALUE [NAME=VALUE...]
bus configure NAME [NAME...]
bus configure [--module MODULE] [--feature FEATURE] list
bus configure [--module MODULE] [--feature FEATURE] init [--force]
bus configure [--module MODULE] [--feature FEATURE] validate [--strict]
bus configure [--module MODULE] [--feature FEATURE] doctor [--strict]
```

Run `bus configure --help` for the complete option list and the currently
discovered environment variables.

### Set and read values

Use `NAME=VALUE` to set one or more values in `.env`. Use a name without `=` to
read its current value.

```bash
bus configure BUS_JOURNAL_ACTOR=meri
bus configure BUS_HOST=127.0.0.1 BUS_API_PORT=8090
bus configure BUS_JOURNAL_ACTOR
```

The default file is `.env` in the effective working directory. Use
`--env-file PATH` when you need to manage another explicitly named dotenv file.
Existing comments and unknown variables are preserved where practical. Secret
values discovered from module metadata are redacted in command output.

### Select a default workspace with `BUS_PWD`

`BUS_PWD` is a dispatcher setting for commands launched from a parent
directory. On first setup, run this from the directory whose `.env` should
select the workspace:

```bash
bus configure BUS_PWD=projects/busdk
```

Subsequent `bus` commands launched there run from `projects/busdk`, load
`projects/busdk/.env`, and resolve workspace files such as `services.yml` from
that directory.

After `BUS_PWD` is active, a normal `bus configure` command also runs in the
selected workspace and edits its `.env`. To read or change the original launch
directory's setting, put the dispatcher-global `--no-chdir` flag before
`configure`:

```bash
bus --no-chdir configure BUS_PWD
bus --no-chdir configure BUS_PWD=projects/busdk
```

This bypass affects only that invocation. Later commands use the newly stored
value normally. The [bus dispatcher](./bus) page describes path resolution,
dotenv loading, process-environment precedence, and `-C/--chdir` overrides in
more detail.

### Discover and initialize variables

`list` shows the variables discovered from installed module metadata and
whether each value is set. Restrict discovery with repeatable `--module` or
`--feature` options when you only need one module or concern.

```bash
bus configure --module journal list
bus configure --module api --feature security list
bus configure --refresh-cache --module journal list
```

`init` creates the dotenv file when it is missing and adds discovered variables
for the selected modules. It does not overwrite an existing file unless
`--force` is supplied.

```bash
bus configure --module journal init
bus configure --module api --feature security init
```

### Validate and diagnose

`validate` checks configured values against discovered schemas. `doctor` also
reports missing required variables, unsafe secret handling, unknown variables,
and metadata-discovery warnings. Add `--strict` to report unknown dotenv names.

```bash
bus configure --module journal validate
bus configure --module journal doctor
bus configure --module api --feature security doctor --strict
```

OpenCLI discovery results are cached for unchanged module binaries. Use
`--refresh-cache` when module metadata has changed and must be read again.

### Exit status

Exit `0` means the requested operation succeeded. Exit `1` means validation,
metadata discovery, or file access failed. Exit `2` means the command syntax or
an assignment was invalid. Diagnostics go to stderr; requested values and
machine-readable results go to stdout.

### Using from `.bus` files

Inside a `.bus` file, use the module target without the leading `bus`. The file
is managed relative to the busfile run's effective working directory.

```bus
# same as: bus configure BUS_JOURNAL_ACTOR=meri
configure BUS_JOURNAL_ACTOR=meri

# same as: bus configure --module journal validate
configure --module journal validate
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-config">bus-config</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Bus dispatcher](./bus)
- [Standard global flags](../cli/global-flags)
- [CLI command naming](../cli/command-naming)
- [Module CLI reference](./index)
