---
title: bus-gateway
description: Local BusDK authentication gateway for browser-facing modules.
---

## Overview

`bus-gateway` is the local entry layer for authenticated BusDK browser modules.
It is intended to sit in front of modules such as `bus-ledger`,
`bus-portal`, and `bus-inspection`, own workspace-local login and session
state, and start plus proxy the configured downstream tools for the current
user.

`bus-gateway serve` starts a token-gated local HTTP server, creates
`.bus/bus-gateway/state.json` on first use, prints a one-time bootstrap admin
password to stdout, and serves anonymous plus authenticated session responses
over `/v1/app`, `/v1/session/login`, and `/v1/session/logout`.

The gateway state is intentionally local-first and deterministic. Users,
password hashes, the workspace service catalog, and per-user visible-service
settings live in the selected workspace rather than in a mandatory remote
identity service. Admin users can edit the service catalog and user settings
through the gateway UI or from the CLI, and each launchable tool is exposed
through a stable gateway route under `/<token>/apps/<service-id>/`.

## Usage

Start the gateway server and print the token-gated URL:

```bash
bus-gateway serve --print-url
```

Or use the default command:

```bash
bus-gateway --print-url
```

On the first run in a workspace, the server prints:

```text
BOOTSTRAP_PASSWORD admin <password>
```

Use that password with the login API or a future gateway UI. The gateway keeps
the credential out of anonymous API payloads after startup.

## Service and user configuration

The gateway stores downstream launcher rows in `.bus/bus-gateway/state.json`.
Each row defines:

- a stable service id such as `bus-ledger`
- a user-facing title
- the downstream command to execute
- how the workspace root is passed to that command
- optional extra launcher arguments
- whether the service is enabled

User settings then define which configured services are visible and launchable
for each account. This keeps the service catalog separate from per-user access.

The CLI exposes the same model for automation. `bus-gateway -C ./workspace
service set ...` adds or updates one service row, `bus-gateway -C ./workspace
service list` prints the configured catalog, `bus-gateway -C ./workspace user
add ...` creates a local user, `bus-gateway -C ./workspace user set ...`
updates that user, and `bus-gateway -C ./workspace user services set ...`
replaces the visible-service list for one account.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing-vero">bus-filing-vero</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-init">bus-init</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-gateway module README](/Users/jhh/git/busdk/busdk/bus-gateway/README.md)
- [bus-gateway module SDD](/Users/jhh/git/busdk/busdk/sdd/docs/modules/bus-gateway.md)
