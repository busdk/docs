---
title: Go authentication and credential review
description: Review OTPs, refresh tokens, account identity, credential clients, replaceable security primitives, and internal tokens.
---

## Authentication Paths

Authentication code needs extra review beyond ordinary request validation. OTPs
and refresh tokens should be short-lived, one-time-use where applicable, and
stored hashed or otherwise non-recoverable. Login and verification paths should
rate-limit by stable normalized keys such as normalized email and client
address.

Account identity should come from provider-issued stable IDs or verified JWT
claims, not email addresses or caller-supplied account metadata. Admin powers
should be represented by scopes rather than boolean flags, and internal-token
issuing must stay on a protected internal boundary.

## Credential Clients

Credential clients should not synthesize tokens or infer approval state
locally. They should request tokens from the provider, store credentials only in
explicit user or configured paths with restrictive permissions, avoid
repository-local token files by default, and keep token storage, API base URL,
timeout, and output format injectable for tests.

Cryptographic and authentication components should be replaceable at clear
interfaces. Signers, verifiers, random sources, clocks, token stores, OTP
senders, rate limiters, and internal-token authorizers are review points because
hardcoding them makes rotation, migration, and deterministic security tests
harder.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./validation-and-domain-safety">Validation and domain safety</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./external-runners">External runners</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [API JWT audiences and scopes](../../architecture/api-jwt-audiences-and-scopes)
- [Append-only and security](../../architecture/append-only-and-security)
- [LLM finding patterns](./llm-finding-patterns)
