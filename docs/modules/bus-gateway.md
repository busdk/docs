---
title: bus-gateway
description: Local BusDK authentication gateway for browser-facing modules.
---

## Overview

`bus-gateway` is the local entry layer for authenticated BusDK browser modules.
It is intended to sit in front of modules such as `bus-ledger`,
`bus-portal`, and `bus-inspection`, own workspace-local login and session
state, and later start and proxy allowed downstream modules for the current
user.

The current first pass focuses on the local auth foundation instead of full
module proxying. `bus-gateway serve` starts a token-gated local HTTP server,
creates `.bus/bus-gateway/state.json` on first use, prints a one-time bootstrap
admin password to stdout, and serves anonymous plus authenticated session
responses over `/v1/app`, `/v1/session/login`, and `/v1/session/logout`.

The gateway state is intentionally local-first and deterministic. Users,
password hashes, and module grants live in the selected workspace rather than
in a mandatory remote identity service. Later versions can build module-access
management and proxy/startup orchestration on top of the same workspace-local
contract.

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
