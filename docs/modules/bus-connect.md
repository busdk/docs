---
title: bus-connect — x402-gated messaging daemon
description: "bus-connect is a self-hostable BusDK daemon intended to gate new conversation threads with x402 payments; the current build ships only CLI foundation commands."
---

## Overview

`bus-connect` is a small, self-hostable BusDK module intended to gate the start of a new conversation thread behind an x402 payment, then let the paying sender poll for replies and send bounded follow-ups on that same thread without paying again. Choose it when you want a single-recipient inbox that unknown senders — human or AI agent — can only reach after paying a small initiation fee, not a general-purpose messaging platform, payment gateway, or wallet.

## Current status: foundation build only

This is a foundation-phase build, not a working messaging daemon. The only committed, tested behavior is the command-line handling shown below: printing help and version text, and reporting invalid usage or an explicit "not implemented yet" diagnostic for any other command.

The daemon process, its REST API and OpenAPI description, x402 payment gating, SQLite-backed thread storage, thread capabilities, operator actions, paid send/poll/follow-up, and discovery are not available in this build. `bus-connect` has not been released or merged into any published BusDK distribution, so no released `bus` dispatcher currently includes a `connect` command.

## Try it

The foundation build described on this page is not published yet. It cannot currently be obtained by cloning a public BusDK repository, and there is no release to download or install today.

Once a source checkout is published, the following commands are the ones to run from that exact checkout to build the binary and exercise the two commands that work in this foundation build:

```bash
make clean build
make install PREFIX="$PWD/.make/prefix"
./.make/prefix/bin/bus-connect --help
./.make/prefix/bin/bus-connect --version
```

Contributors building from source can run the module's own test suite the same way, from a clean published checkout:

```bash
make test
make test-e2e
```

Treat the exact repository location, branch, and release channel as unconfirmed until publication, and validate the real public acquisition instructions against the published repository once it exists rather than assuming these commands are complete on their own.

## Intended product shape (not available yet)

REST is intended to be the canonical product surface once implemented: a documented HTTP API that an agent could integrate against from documentation alone. `bus-connect`, and the eventual dispatcher alias `bus connect …`, are intended to stay thin convenience paths over that same service behavior, never a second or privileged surface.

One static Go binary is intended to serve both roles the module targets: an operator who runs the daemon and handles reading, replying to, and closing threads, and a contacting party who pays to open a thread and then polls or follows up for free on that same thread. The intended future product model has any counterparty run their own instance and act as their own service provider, keeping their own initiation fees and their own operational and legal responsibility. A contacting party only needs a wallet capable of signing an x402 payment, not an endpoint or hosted instance of its own.

The repository is Fair Source, source-available under the Functional Source License, Version 1.1, MIT Future License (FSL-1.1-MIT); each release converts to the MIT license two years after that release is made available. Self-hosting is subject to those current terms, and general competing commercial self-hosting cannot be promised under today's FSL-1.1-MIT license. The distribution model that supports the intended self-host-as-your-own-service-provider product still needs to be resolved before release. The exact FSL-1.1-MIT license text is carried as `LICENSE.md` in the source candidate and will be available alongside the source once it is published; see the [Functional Source License](https://fsl.software/) for the general public explanation of these terms in the meantime.

The target economics point at USDC and EURC on Base, but no facilitator, network, or asset is wired up in this build. This module intentionally has no registry, no multi-tenant hosting, no subscriptions, no KYB, no SDKs, no webhooks, no MCP surface, and no platform integrations in scope.

Once the payment gate exists, a successful x402 payment will only demonstrate acceptance of a valid payer authorization and either control of the paying wallet or delegated signing authority over it at the moment of signing. It will not prove direct ownership of that wallet, and it will not identify a specific human, AI agent, organization, or legal entity as the sender. Any claim inside the message body remains unverified. Wallet addresses are payment principals, not reachable routes; a reply is intended to work by the sender polling its own thread, not by anything being sent to an address.

### Using from `.bus` files

Once `bus-connect` is composed into the `bus` dispatcher, the intended form inside a `.bus` file drops the `bus` prefix, the same as other modules:

```bus
# intended source-composition form once `bus connect` is wired into the dispatcher
connect --help
```

That composed form does not exist yet. With today's standalone candidate, call the binary directly instead:

```bash
bus-connect --help
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-configure">bus-configure</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [x402 protocol specification](https://github.com/x402-foundation/x402)
- [Coinbase Developer Platform — x402 network support](https://docs.cdp.coinbase.com/x402/network-support)
- [Circle — USDC contract addresses](https://developers.circle.com/stablecoins/usdc-contract-addresses)
- [Circle — EURC contract addresses](https://developers.circle.com/stablecoins/eurc-contract-addresses)
- [Functional Source License (FSL-1.1-MIT)](https://fsl.software/)
