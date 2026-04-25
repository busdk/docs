---
title: bus-api-provider-auth
description: Bus auth provider verifies email ownership and issues short-lived API JWTs.
---

## Auth Provider For Bus API

`bus-api-provider-auth` is the authentication provider used by Bus API
deployments that need AI Platform account access. Users register by email,
verify email ownership with an OTP, wait for admin approval, and then request a
short-lived JWT for api-proxy. Email is never the account ID, so an email change
does not change the identity seen by api-proxy or billing systems.

The public flow is passwordless but approval-gated. OTP verification returns an
auth-service token with `aud=ai.hg.fi/auth`; it does not grant model access.
Only an approved verified user can request an AI Platform token with
`aud=ai.hg.fi/api` and `scope=llm:proxy`.

The provider is enabled through `bus-api` as an explicit provider named `auth`.
For local development, set `BUS_AUTH_HS256_SECRET` to a deployment secret value
of at least 32 bytes before starting `bus api serve --provider auth`.
Set `BUS_AUTH_STORE_PATH` when account identities and revocations must survive
process restarts. Set `BUS_AUTH_OTP_SENDER=console` for a development-only
sender that writes OTP codes to stdout with a `BUS_AUTH_OTP` prefix. Set
`BUS_AUTH_SMTP_HOST` and `BUS_AUTH_SMTP_FROM` when OTPs should be delivered
through an SMTP relay.

Use `bus-api-provider-auth --help` for operator-facing module help. The help
output follows Git-style sections and is covered by automated tests so normal
quality runs catch formatting regressions.

### API Surface

The provider exposes `POST /auth/register`, `POST /auth/otp/request`,
`POST /auth/otp/verify`, `GET /auth/status`, `POST /auth/token`,
`POST /auth/token/refresh`, `POST /auth/logout`, and `GET /me`. Admin waitlist
endpoints are `GET /auth/admin/waitlist`, `POST /auth/admin/approve`, and
`POST /auth/admin/reject`. Internal auth-service token issuing is separate from
the public user flow and is protected by the configured internal shared key.

api-proxy should validate the JWT, read `sub` as `account_id`, check `aud` and
`scope`, and record usage. It should not know emails, OTPs, or auth-service user
records.

### Sources

- [bus-api](./bus-api)
- [bus-auth](./bus-auth)
