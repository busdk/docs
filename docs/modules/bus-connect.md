---
title: bus-connect — paid inbound messaging
description: "bus-connect runs a paid message address for one recipient: a sender pays a small charge to open one conversation, then follows up for free. Installing, configuring, running, and operating the service."
---

## Overview

`bus-connect` runs a paid message address for a single recipient. Someone who wants to reach that recipient sends a message and pays for it in the same request, which opens one conversation. Inside that conversation they send further messages and read replies without paying again. Payment is carried over x402, an HTTP payment protocol in which an unpaid request receives a `402 Payment Required` answer describing the price, and a capable client pays and retries.

Choose it when you want one published address that people with no prior relationship to you — and the software agents acting for them — can reach without an account, where the charge keeps unwanted volume uneconomic. It serves one recipient per running instance, and it adds no directory of recipients, tenancy, or wallet of its own.

## Current status: accepted, not yet released

The command-line foundation is promoted: printing help and version text, and reporting invalid usage.

The service has passed independent review, and its storage behavior has been proven against a real PostgreSQL-backed Bus Events backend under a dedicated least-privilege identity, including persistence across an Events service restart and isolation between identities. It is **not yet promoted, pinned, or installed**, so it is still not something you can obtain or run from a release. The candidate covers the `serve` daemon, `create` and `get` as thin HTTP clients, an x402 v2 `402` challenge for an unpaid request, paid conversation initiation, access-scoped reads, bounded free follow-ups, and durable recovery when a settlement is interrupted between the external transfer and the local commit. It refuses any non-loopback listen or facilitator URL, so it cannot reach a real payment network, and no live facilitator path has been proven.

An operator surface does not exist yet. Reading, replying to, and closing conversations from the recipient's own side has no command and no endpoint in this build, and the transport for it remains an open decision. The routes that exist serve the paying sender: paid initiation, an access-scoped read of one conversation, and a bounded free follow-up. Everything described below is what the current build does.

Also not available: hosted deployment, a live facilitator, real payments, an OpenAPI description, and Bazaar listing. The `/.well-known/x402` manifest is served, so machine-readable terms are published; what is missing is vendor catalog discovery, which is covered below. `bus-connect` has not been released or merged into any published BusDK distribution, so no released `bus` dispatcher currently includes a `connect` command.

## Installing

Building requires Go, GNU `make`, and the sibling `bus-events` and `bus-help` module sources, because the durable conversation store depends on them. Build from a checkout that has those siblings present. There is no release to download or install today, so treat the exact repository location, branch, and release channel as unconfirmed until publication.

```bash
cd bus-connect
make clean build install
bus-connect --version
```

`make install` places the program in `~/.local/bin` by default. Add that directory to `PATH` if it is not there already. Set `PREFIX` for a different location and `DESTDIR` for staged or packaged installs.

Contributors can run the module's own test suite the same way:

```bash
make test
make test-e2e
make test-protocol-e2e
```

`make test-protocol-e2e` runs the service, a local test facilitator, and the CLI end to end, including the case where a settlement is interrupted between the external transfer and the local commit. It is loopback-only and uses no network, credentials, or money.

## Configuring and running

The service needs an address to listen on, the destination that receives payments, a key file, a settlement facilitator, and somewhere to keep conversations.

```bash
bus-connect serve \
  --listen 127.0.0.1:8402 \
  --pay-to 0x000000000000000000000000000000000000dEaD \
  --capability-key-file ./capability.key \
  --facilitator-url http://127.0.0.1:9402 \
  --store file --store-file ./conversations.log
```

`--pay-to` is the address that receives charges. It is what the price document advertises, and a payment naming a different destination is refused.

### The instance key

One key per running instance derives every conversation access token. It never leaves the process, and it is what makes an interrupted payment recoverable, because the same payment and message body always re-derive the same token. Keep it secret and keep it stable: replacing it invalidates every access token already issued, locking senders out of conversations they paid for.

```bash
head -c 32 /dev/urandom | xxd -p | tr -d '\n' > capability.key
chmod 600 capability.key
```

### Settlement

A facilitator settles a payment and can later be asked, authoritatively, what happened to one. The repository ships a local test facilitator for development. It records settlements durably and can be told to withhold its answer, which is how the interrupted-payment path is reproduced.

```bash
go build -o fakefacilitator ./tests/fakefacilitator
mkdir -p facilitator-state
./fakefacilitator 127.0.0.1:9402 ./facilitator-state &
```

The target economics point at USDC and EURC on Base. Base USDC is enabled; Base EURC is allowlisted and stays disabled until a live facilitator path is proven. No settlement network is reachable from this build.

### Storage

Three storage providers sit behind one contract, and all three are exercised by the same conformance suite. `file` is a durable single-process append-only log, suitable for evaluation and used by the protocol end-to-end gate. `events` targets a live Bus Events API and is the deployment choice. `memory` is test-only and keeps nothing across a restart.

Bus Events is the durable authority for a real deployment. What `bus-connect` requires of it is a set of behaviors, with no database vendor named: an atomic conditional append, a deterministic ordered replay, persistence across an Events restart, and isolation of history and keys by authenticated identity. `bus-connect` does not choose, run, migrate, or back up a database of its own, and whatever backend Events runs on is not its concern.

```bash
bus-connect serve \
  --listen 127.0.0.1:8402 \
  --pay-to 0x000000000000000000000000000000000000dEaD \
  --capability-key-file ./capability.key \
  --facilitator-url http://127.0.0.1:9402 \
  --store events \
  --events-api-url http://127.0.0.1:8081 \
  --events-token-file ./bus-connect.jwt \
  --instance production
```

Give the service its own Events identity holding only `events:send` and `events:listen` instead of reusing a broad identity that other services share. Events scopes both event history and conditional keys to the authenticated identity, so a dedicated identity is what keeps one instance's conversations invisible and immutable to every other identity. Keep the token in a file readable only by the service account and pass the path, never the token itself.

All state for one instance lives in a single identity-scoped aggregate: one conditional key, one event per accepted transition, each validated against the folded projection and appended under a compare-and-set guard. That single serialization point is what makes limits spanning conversations — the global admission bound and the simultaneous-settlement bound — hold exactly.

## What a sender sees

An unpaid request receives `402` with the exact terms a payer must match: protocol version, scheme, network, asset contract, decimals, atomic amount, and destination. The same document is served at `/.well-known/x402` for discovery. The terms state that the charge is non-refundable and guarantees no response, so a payer knows what it is buying before it pays.

```bash
curl -s http://127.0.0.1:8402/v1/threads \
  -X POST -H 'Content-Type: application/json' \
  -d '{"message":"hi"}'
```

`bus-connect` never creates a payment authorization. It holds no signer, seed, or wallet key and cannot send funds. The contacting side signs elsewhere and presents the envelope.

```bash
cat > payment.json <<'JSON'
{"x402Version":2,"scheme":"exact","network":"eip155:8453",
 "asset":"0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913","amount":"20000",
 "payTo":"0x000000000000000000000000000000000000dEaD",
 "from":"0xSomeAgentWallet","nonce":"demo-1","signature":"demo-signature-1"}
JSON

printf 'Hello, I would like to talk to you.' > message.txt

bus-connect create --api-url http://127.0.0.1:8402 \
  --body-file message.txt --payment-file payment.json
```

A successful call returns a conversation id, the state `active`, one message, and one access token. The token is issued on the response that creates the conversation and on an exact replay of that same request; a later read never echoes it. `create` and `get` are ordinary HTTP clients of the same surface any client uses, and both reject every server-side storage option, so neither can be pointed at your storage.

Follow-ups on an open conversation are free within the limits below:

```bash
curl -s http://127.0.0.1:8402/v1/threads/THREAD_ID/messages \
  -X POST -H "Authorization: Bearer CAPABILITY" \
  -H 'Content-Type: application/json' \
  -d '{"message":"any update?","idempotencyKey":"k1"}'
```

## Behavior worth verifying

Each of the following is a place a payment endpoint usually gets something wrong, and each can be checked directly against a local instance.

Presenting the same payment twice returns the same conversation, the same access token, and still one message. That covers the sender whose connection dropped before the first answer arrived: a retry is safe and is not charged again. Presenting the same payment with a different message body is refused as `409 authorization_body_conflict`, because one authorization is bound to one message body. A payment that does not match the advertised terms, such as one naming a different network, is refused before the facilitator is contacted at all.

Sending the same free follow-up twice with one idempotency key leaves one message; reusing that key with a different body is refused instead of being silently dropped. An access token from one conversation is refused on another exactly like an unknown token, so probing cannot map which conversations exist. Access tokens travel only in `Authorization`, never appear in a URL, and never reach a log; only a keyed digest is persisted, so someone who reads your storage still cannot open a conversation.

The interrupted payment is the case worth running. Tell the facilitator to settle but withhold its answer, then pay with a fresh nonce. The request fails with `settlement_unresolved`: the money moved and the service does not know it. Nothing is marked failed, because the answer was lost while the payment stood.

```bash
touch ./facilitator-state/withhold
# ... send the paid request, observe settlement_unresolved ...
rm ./facilitator-state/withhold
```

Repeating the identical request reconciles into the original conversation, active, with exactly one message. Killing the process with `SIGKILL` while the answer is withheld, restarting, and replaying gives the same outcome, because the durable record survives the process.

## Limits

These are enforced, and the advertised terms match what is enforced.

- Initial message and each follow-up: 16 KiB.
- 64 message rows per conversation. The paid message is row one, so 63 free follow-ups.
- 100 conversations occupying admission at once.
- 2 settlements in flight at once.
- 2-second facilitator deadline, 5-second shutdown deadline.

When a limit is reached the request is refused before settlement, so a sender is never charged for a conversation that will not be created.

## Shutting down

Send `SIGTERM`. The service stops accepting connections, drains within a bounded deadline, closes its storage, and exits. If shutdown exceeds the deadline it reports that and still exits, leaving no background process behind.

## Before taking real money

The build is complete as a protocol. Hosted paid operation needs more, and none of it is implemented today.

The largest item sits outside the protocol. A settled payment tells you the money arrived and gives you a wallet address, which tells you nothing about your customer. Selling a digital service from a Finnish company into the EU means establishing, before the sale completes, whether the buyer is a business or a consumer, where they are, and how to reach them with a receipt — then charging the right VAT, validating a VAT number where one is claimed, honouring the withdrawal right that applies to consumers buying digital services, and retaining all of it. Bus already covers this through its customers, entities, VAT, VIES validation, invoices, bookkeeping, and Finnish tax filing modules, so the work is to route initiation through them. Confirm the specifics for your jurisdiction and turnover with your accountant and counsel; nothing here is legal advice.

The remaining items are public exposure, since the build refuses non-loopback listen and facilitator URLs; a live facilitator path proven against the payment network with an approved live check; an operator surface for reading, replying to, and closing conversations, where the public paid endpoint must stay outside platform authentication because its callers have no account with you by design; conversation expiry and retention applied on a schedule; a durability policy for the Events backend appropriate for settled-payment records; and discovery with an OpenAPI description.

## Discovery

The manifest at `/.well-known/x402` serves the same challenge the paid endpoint advertises, so an agent holding your address can read the price, currency, destination, and terms without making a request that fails first. Publishing it costs nothing and requires no facilitator call. The official x402 specifications define no well-known manifest: this is a community convention adopted by Bus, and it is neither a normative x402 surface nor a CDP-official one.

Bazaar discovery has two layers worth keeping apart. Declaring a route discoverable rides on x402's own optional extension mechanism, alongside the payment-identifier extension and Sign-In-With-X, so advertising discovery metadata is part of how the protocol is designed to be extended. The catalog agents actually search, together with its indexing and retention policy, is CDP vendor territory rather than protocol.

A route opts in by declaring the Bazaar extension and discovery metadata, and indexing follows the first successful settlement through the CDP facilitator; a verify alone does not index, and the settlement payload must identify the paid resource. Under vendor policy current as of 2026-07-17, resources with prior calls but no activity in the last 30 days are excluded from discovery results; the endpoint stays live and only stops appearing in search. Those are dated vendor facts that need rechecking before implementation. Bus Connect does not implement the Bazaar extension today, and since this build reaches no live facilitator, no listing can happen from it.

Treat a successful Bazaar opt-in as a catalog entry and nothing further. Search appearance, propagation delay, and actual agent use each require live observation, and none of them is claimed here. The likely first traffic source is ordinary links, so publish the endpoint and its terms wherever agent operators already look: your website, your documentation, a repository README, an `llms.txt`.

## What a settled payment proves

A successful x402 payment demonstrates acceptance of a valid payer authorization and either control of the paying wallet or delegated signing authority over it at the moment of signing. It does not prove direct ownership of that wallet, and it does not identify a specific human, AI agent, organization, or legal entity as the sender. Any claim inside the message body remains unverified. Wallet addresses are payment principals, and no route back to the sender is derived from one: a reply reaches the sender when they poll their own conversation.

## Product shape and license

REST is the canonical product surface: an HTTP API that an agent could integrate against from documentation alone. `bus-connect`, and the eventual dispatcher alias `bus connect …`, are intended to stay thin convenience paths over that same service behavior, never a second or privileged surface.

One running instance serves one recipient and one payment destination. There is no registry, no other hosted tenants, no subscriptions, no KYB, no SDKs, no webhooks, no MCP surface, and no platform integrations in scope. The intended product model has any counterparty run their own instance and act as their own service provider, keeping their own charges and their own operational and legal responsibility. A contacting party needs only a wallet capable of signing an x402 payment, not an endpoint or hosted instance of its own.

The repository is Fair Source, source-available under the Functional Source License, Version 1.1, MIT Future License (FSL-1.1-MIT); each release converts to the MIT license two years after that release is made available. Self-hosting is subject to those current terms, and general competing commercial self-hosting cannot be promised under today's FSL-1.1-MIT license. The distribution model that supports the intended self-host-as-your-own-service-provider product still needs to be resolved before release. The exact FSL-1.1-MIT license text is carried as `LICENSE.md` in the source candidate and will be available alongside the source once it is published; see the [Functional Source License](https://fsl.software/) for the general public explanation of these terms in the meantime.

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
