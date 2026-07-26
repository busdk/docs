---
title: bus-connect — paid inbound messaging
description: "bus-connect runs a paid message address for one recipient: a sender pays a small charge to open one conversation, then follows up for free. Installing, configuring, running, and operating the service."
---

## Overview

`bus-connect` runs a paid message address for a single recipient. Someone who wants to reach that recipient sends a message and pays for it in the same request, which opens one conversation. Inside that conversation they send further messages and read replies without paying again. Payment is carried over x402, an HTTP payment protocol in which an unpaid request receives a `402 Payment Required` answer describing the price, and a capable client pays and retries.

Choose it when you want one published address that people with no prior relationship to you — and the software agents acting for them — can reach without an account, where the charge keeps unwanted volume uneconomic. It serves one recipient per running instance, and it adds no directory of recipients, tenancy, or wallet of its own.

## Current status: proven locally, not yet released

The paid message path is complete and proven. It has passed independent review, is promoted, pinned in the BusDK superproject, installed, and covered by an installed smoke check. Its storage behavior has been proven against a real PostgreSQL-backed Bus Events backend under a dedicated least-privilege identity, including persistence across an Events service restart and isolation between identities. You can install it, run the whole service on your own machine, send paid messages through it today, and it already publishes its machine-readable terms.

That covers the `serve` daemon, `create` and `get` as thin HTTP clients, an x402 v2 `402` challenge for an unpaid request, paid conversation initiation, access-scoped reads, bounded free follow-ups, the `/.well-known/x402` manifest, and durable recovery when a settlement is interrupted between the external transfer and the local commit. In that build the initiation price and the conversation limits are whatever each instance's seller configured, and the advertised values are the enforced ones.

Setting your own price and limits, and the revised wording of the initiation terms, have passed independent review, are promoted and pinned, and are covered by an installed smoke check that ran a non-default configured instance end to end. Both are in the build you can install today.

Promoted and installed is not released. It refuses any non-loopback listen or facilitator URL, so it cannot reach a real payment network, and no live facilitator path has been proven. Publishing it on the open internet and charging real money are still ahead.

The recipient's own inbox does not exist yet. Listing, reading, replying to, and closing conversations from the recipient's side has no command and no endpoint in this build, and the transport for it remains an open decision. `create` and `get` are not an operator inbox: like the routes, they serve the paying sender. Everything described below is what the current build does.

Also not available: hosted deployment, a live facilitator, real payments, an OpenAPI description, and Bazaar listing, which waits on live settlement. `bus-connect` has not been merged into any published BusDK distribution, so no released `bus` dispatcher currently includes a `connect` command.

## Installing

Building requires Go, GNU `make`, and the sibling `bus-events` and `bus-help` module sources, because the durable conversation store depends on them. Build from a checkout that has those siblings present. There is no public release channel yet, so treat the exact repository location, branch, and release channel as unconfirmed until publication.

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

### Setting your price and limits

**Available in the installed build.** An installed `bus-connect` prices each instance at whatever you configure; the default below applies only when you set nothing.

You set the price of reaching you and the limits a sender sees. Whatever you configure is what the `402` answer and the `/.well-known/x402` manifest advertise, and it is exactly what the service enforces.

```bash
bus-connect serve \
  --listen 127.0.0.1:8402 \
  --pay-to 0x000000000000000000000000000000000000dEaD \
  --capability-key-file ./capability.key \
  --facilitator-url http://127.0.0.1:9402 \
  --price-atomic 50000 \
  --max-initial-body-bytes 8192 \
  --max-follow-up-bytes 4096 \
  --free-follow-ups 20 \
  --store file --store-file ./conversations.log
```

| Flag | Meaning | Default | Range |
|---|---|---|---|
| `--price-atomic` | Price to open one conversation, in atomic units | `20000` | 1 to 32 digits, no leading zero |
| `--max-initial-body-bytes` | Largest first message you accept, in decoded message bytes | `16384` | 1 to 16384 |
| `--max-follow-up-bytes` | Largest single free follow-up you accept, in decoded message bytes | `16384` | 1 to 16384 |
| `--free-follow-ups` | Free follow-ups allowed after the paid message | `63` | 0 to 63 |

`--price-atomic` is in atomic units of the advertised asset and performs no decimal or currency conversion. USDC has six decimals, so `50000` is 0.05 USDC and `20000` is 0.02 USDC. The value is compared exactly, so a spelling like `020000` is refused when the service starts rather than becoming a price no payment can match. A price that is not a whole number above zero is refused the same way.

Both byte limits count the decoded message itself, so a message of exactly the size you set is accepted. The JSON that carries it — field names, quotes, escaping, and a follow-up's idempotency key — is protocol metadata and does not eat into the limit you advertised. The request as a whole still has its own finite ceiling, so an oversized or malformed body is refused before any settlement.

The three limit flags may only be lowered from their defaults, which are also their maximums. Raising them is not a configuration change: the accepted resource envelope would need fresh capacity evidence first.

`--free-follow-ups` is the number a sender is promised and the number they get. The paid first message is stored as message one and does not consume the allowance, so setting `20` accepts exactly twenty free follow-ups and refuses the twenty-first.

Anything invalid is refused before the service binds a port, so an instance either advertises exactly what it will enforce or does not start.

Changing your price affects new conversations only. Someone who already paid at the old price keeps what they paid for: repeating that exact payment and message returns their original conversation and the same access token, even after you restart at a different price. A payment at your old price that never opened a conversation is refused like any other mismatch, and reusing an old payment for a different message is still refused as a conflict.

### Running more than one instance

`--instance NAME` names the Events aggregate that holds one instance's conversations; it defaults to `default`. Two instances sharing a single Events identity must use different names, or they would write into the same aggregate. Giving each instance its own Events identity is the stronger separation, described under Storage below.

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

An unpaid request receives `402` with the exact terms a payer must match: protocol version, scheme, network, asset contract, decimals, atomic amount, and destination, together with the conversation limits. The same document is served at `/.well-known/x402` for discovery, so a payer reading either surface sees the same price and terms.

The terms state that the charge is non-refundable and guarantees no response, so a payer knows what it is buying before it pays. An installed build states all three facts: delivery and consideration of one message by the recipient, non-refundable, with no reply guaranteed, alongside the limits you configured.

```bash
curl -s http://127.0.0.1:8402/v1/threads \
  -X POST -H 'Content-Type: application/json' \
  -d '{"message":"hi"}'
```

`bus-connect` never creates a payment authorization. It holds no signer, seed, or wallet key and cannot send funds. The contacting side signs elsewhere and presents the envelope.

The `amount` below must equal the `maxAmountRequired` the endpoint advertises. Anything else is refused before the facilitator is contacted.

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

Once configuration is available, your configured price and limits are worth checking against the endpoint itself. `curl -s http://127.0.0.1:8402/.well-known/x402` shows the advertised `maxAmountRequired` and `busTerms`; both should equal what you passed to `serve`, and the manifest should be identical to the body of the `402`. Paying a different amount is refused with `payment_rejected` before the facilitator is contacted. Sending one more free follow-up than you allowed is refused after exactly that many succeed.

The interrupted payment is the case worth running. Tell the facilitator to settle but withhold its answer, then pay with a fresh nonce. The request fails with `settlement_unresolved`: the money moved and the service does not know it. Nothing is marked failed, because the answer was lost while the payment stood.

```bash
touch ./facilitator-state/withhold
# ... send the paid request, observe settlement_unresolved ...
rm ./facilitator-state/withhold
```

Repeating the identical request reconciles into the original conversation, active, with exactly one message. Killing the process with `SIGKILL` while the answer is withheld, restarting, and replaying gives the same outcome, because the durable record survives the process.

## Limits

These are enforced, and the advertised terms match what is enforced.

In the installed build these are fixed. The flags shown are the authored, not-yet-promoted way to lower them:

- Initial message: 16 KiB of decoded message content, lowerable via `--max-initial-body-bytes`.
- Each follow-up: 16 KiB of decoded message content, lowerable via `--max-follow-up-bytes`.
- 63 free follow-ups, lowerable via `--free-follow-ups`. The paid message is message one and does not count against the allowance.

These protect the deployment and are not configurable:

- 100 conversations occupying admission at once.
- 2 settlements in flight at once.
- 2-second facilitator deadline, 5-second shutdown deadline.

When a limit is reached the request is refused before settlement, so a sender is never charged for a conversation that will not be created.

## Shutting down

Send `SIGTERM`. The service stops accepting connections, drains within a bounded deadline, closes its storage, and exits. If shutdown exceeds the deadline it reports that and still exits, leaving no background process behind.

## Before taking real money

The build is complete as a protocol. Hosted paid operation needs more, and none of it is implemented today.

The largest item sits outside the protocol. A settled payment tells you the money arrived and gives you a wallet address, which tells you nothing about your customer. Selling a digital service from a Finnish company into the EU means establishing, before the sale completes, whether the buyer is a business or a consumer, where they are, and how to reach them with a receipt — then charging the right VAT, validating a VAT number where one is claimed, honouring the withdrawal right that applies to consumers buying digital services, and retaining all of it. Bus already covers this through its customers, entities, VAT, VIES validation, invoices, bookkeeping, and Finnish tax filing modules, so the work is to route initiation through them. Confirm the specifics for your jurisdiction and turnover with your accountant and counsel; nothing here is legal advice.

The remaining items are public exposure, since the build refuses non-loopback listen and facilitator URLs; a live facilitator path proven against the payment network with an approved live check; a recipient inbox for listing, reading, replying to, and closing conversations, where the public paid endpoint must stay outside platform authentication because its callers have no account with you by design; conversation expiry and retention applied on a schedule; a durability policy for the Events backend appropriate for settled-payment records; and discovery with an OpenAPI description.

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

The repository is Fair Source, source-available under the Functional Source License, Version 1.1, MIT Future License (FSL-1.1-MIT); each release converts to the MIT license two years after that release is made available. Self-hosting is subject to those current terms, and general competing commercial self-hosting cannot be promised under today's FSL-1.1-MIT license. The distribution model that supports the intended self-host-as-your-own-service-provider product still needs to be resolved before release. The exact FSL-1.1-MIT license text is carried as `LICENSE.md` in the module source and will be available alongside it once it is published; see the [Functional Source License](https://fsl.software/) for the general public explanation of these terms in the meantime.

### Using from `.bus` files

Once `bus-connect` is composed into the `bus` dispatcher, the intended form inside a `.bus` file drops the `bus` prefix, the same as other modules:

```bus
# intended source-composition form once `bus connect` is wired into the dispatcher
connect --help
```

That composed form does not exist yet. Call the binary directly instead:

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
