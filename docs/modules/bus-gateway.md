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
gateway-owned managed tables and schema files at the workspace root on first
use, prints a one-time bootstrap admin password to stdout, and serves
anonymous plus authenticated session responses over `/v1/app`,
`/v1/session/login`, and `/v1/session/logout`. The same token-gated root page
also supports plain HTML form login/logout, so the shared login screen works
without module-local JavaScript.

The gateway state is intentionally local-first and deterministic. Users,
password hashes, the workspace service catalog, and per-user visible-service
settings live in the selected workspace rather than in a mandatory remote
identity service. The gateway stores that configuration through the shared
`bus-data` layer, so the same logical tables work on filesystem-backed
workspaces and on workspaces that opt into PostgreSQL storage. Admin users can
edit the service catalog and user settings through the gateway UI or from the
CLI, and each launchable tool is exposed through a stable gateway route under
`/<token>/apps/<service-id>/`.

When the gateway proxies a child module request, it also forwards a short-lived
signed trusted-identity envelope for the current account. That lets child
modules such as `bus-inspection` rely on gateway-owned authentication instead
of running a second login flow.

The workspace can also customize the login-card title and optional helper
copy. When those settings are blank, the page falls back to a generic `Sign
in` heading and omits helper text entirely.

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

Use that password with either the login page or the login API. The gateway
keeps the credential out of anonymous API payloads after startup.

## Service and user configuration

The gateway stores downstream launcher rows, user assignments, and singleton
workspace login-page settings in shared managed tables at the workspace root.
The main logical rows define:

- a stable service id such as `bus-ledger`
- a user-facing title
- the downstream command to execute
- how the workspace root is passed to that command
- optional extra launcher arguments
- whether the service is enabled

User settings then define which configured services are visible and launchable
for each account. This keeps the service catalog separate from per-user access
while still using the same workspace storage backend as the rest of BusDK data.

The CLI exposes the same model for automation. `bus-gateway -C ./workspace
service add/get/set/remove ...` and `service list` provide full CRUD-style
control over the workspace service catalog. `bus-gateway -C ./workspace user
add/get/set/remove ...` and `user list` do the same for local gateway users,
while `bus-gateway -C ./workspace user services set ...` replaces the
visible-service list for one account. `bus-gateway -C ./workspace settings
get` and `settings set ...` read or update the login title/helper copy for the
workspace.

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
