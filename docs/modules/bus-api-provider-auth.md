---
title: bus-api-provider-auth
description: Bus auth provider verifies email ownership and issues short-lived API JWTs.
---

## Auth Provider For Bus API

`bus-api-provider-auth` is the authentication provider used by Bus API
deployments that need account registration, approval, and API token issuing.
Users register by email, verify email ownership with an OTP, wait for admin
approval, and then request short-lived Bus API JWTs for services such as LLM
hosting, billing, containers, events, and terminal access. Email is never the
account ID, so an email change does not change the identity seen by API
providers or billing systems.

The public flow is passwordless but approval-gated. OTP verification returns an
auth-service token with `aud=ai.hg.fi/auth`; it does not grant model access.
Only an approved verified user can request a Bus API token with
`aud=ai.hg.fi/api` and feature scopes such as `llm:proxy`.
Approved users can request the same API-audience JWT with domain scopes such as
`vm:read` and `container:run`, not broad event-pattern scopes. Those tokens use
`aud=ai.hg.fi/api` and work for both REST APIs and Events API endpoints. The
provider only issues user API scopes allowed by `BUS_AUTH_API_USER_SCOPES`.

The provider is enabled through `bus-api` as an explicit provider named `auth`.

The local compose example in `bus-api-provider-auth/examples/local-compose/`
starts PostgreSQL, MailHog, and `bus-api` with the auth provider enabled. The
generic module path remains available at `/local-dev/v1/modules/auth`, and the
production-friendly routes are available at `/local-dev/v1/api/v1/auth/*` and
`/local-dev/v1/api/internal/auth/*`. It uses only non-secret development defaults and
prefers the published `ghcr.io/busdk/bus-api:latest` image by default. MailHog
exposes its HTTP UI/API on `http://127.0.0.1:8025` so operators can read local
OTP email messages.

For an AI Platform smoke check, use the token returned by the local
`bus auth` login and token flow against `https://ai.hg.fi/v1`. Do not depend on
developer-specific checkout paths or external JWT-issuing commands.

Use `bus-api-provider-auth --help` for operator-facing module help. The help
output follows Git-style sections for name, synopsis, description, options,
environment, examples, and related documentation.

### `BUS_AUTH_HS256_SECRET`

Sets the JWT signing secret.

Use a deployment secret value of at least 32 bytes. Plain values are raw text
even when they look like base64; use `base64:<value>` only for intentionally
base64-encoded secrets.

### `BUS_AUTH_INTERNAL_TOKEN_TTL_SECONDS`

Sets the lifetime for trusted internal service tokens issued by
`/api/internal/auth/token`.

The default is 600 seconds. Raise it only for trusted long-running workers that
cannot rotate tokens more frequently.

### `BUS_AUTH_STORE_PATH`

Enables file-backed persistence for account identities and revocations.

Use PostgreSQL for production deployments that need durable auth state.

### `BUS_AUTH_POSTGRES_DSN`

Enables PostgreSQL persistence.

Store the DSN in deployment secrets or untracked operator configuration when it
contains credentials.

### `BUS_AUTH_OTP_SENDER`

Selects the OTP sender.

Use `console` only for local development. The console sender writes OTP codes
to stdout with a `BUS_AUTH_OTP` prefix.

### `BUS_AUTH_SMTP_HOST`

Sets the SMTP host for email OTP delivery.

MailHog is suitable for local development.

### `BUS_AUTH_SMTP_FROM`

Sets the sender address used for OTP email.

### `POST /api/v1/auth/register`

Creates or finds a registration candidate for an email address.

New users start waitlisted. Registration alone does not issue paid API access.

### `POST /api/v1/auth/otp/request`

Creates a short-lived OTP challenge and sends it through the configured OTP
provider.

The console OTP provider is for local development only.

### `POST /api/v1/auth/otp/verify`

Verifies the OTP and returns an auth-service token when verification succeeds.

The returned token uses audience `ai.hg.fi/auth`; it is not an LLM or container
API token.

### `GET /api/v1/auth/status`

Returns the current user's verification and approval status.

Use it after OTP verification to see whether the account is still waitlisted,
approved, or rejected.

### `POST /api/v1/auth/token`

Issues a Bus API token for an approved user.

The provider only grants scopes allowed by `BUS_AUTH_API_USER_SCOPES` and the
account policy.

### `POST /api/v1/auth/token/refresh`

Refreshes an auth-service session when refresh is allowed by deployment
configuration.

### `POST /api/v1/auth/logout`

Revokes or ends the current auth session.

Clients should also clear local browser or CLI session storage.

### `GET /api/v1/auth/me`

Returns the current auth-service user identity and account information.

Email remains auth-service data. API providers use the stable account UUID.

### `GET /api/v1/auth/check`

Validates a bearer JWT and returns parsed claims.

This is a diagnostic auth-service endpoint. Domain API providers still enforce
their own audience, scope, account ownership, and billing rules.

### `GET /api/v1/auth/admin/waitlist`

Lists waitlisted users for an authorized operator.

Requires auth-service admin scopes.

### `POST /api/v1/auth/admin/approve`

Approves a verified waitlisted user.

Approval creates or activates the stable account UUID used as API token `sub`.

### `POST /api/v1/auth/admin/reject`

Rejects a waitlisted user.

Rejected users cannot request paid feature API tokens.

### `POST /api/internal/auth/token`

Issues trusted internal service tokens.

This endpoint is separate from the public user flow and is protected by the
configured internal shared key. Internal service tokens may target the
auth-service audience or the normal Bus API audience with domain scopes.

### Compatibility Paths

Current `/auth/*`, `/me`, and `/internal/token` paths remain aliases for local
deployments.

API providers validate the JWT, read `sub` as `account_id`, check `aud` and
`scope`, enforce their own account ownership rules, and record usage when work
is billable. Providers should not know emails, OTPs, or auth-service user
records.

### Billing And Approval Boundary

Approval controls whether a verified user may request feature scopes. Billing
controls whether a paid feature may start work. For example, an approved user
may receive an `llm:proxy` token, but `bus-api-provider-llm` can still deny a
request with `billing_required` or `quota_exceeded` before waking a runtime.

Admin and service operations use internal-audience tokens. End-user
`aud=ai.hg.fi/api` tokens must not grant cross-account access, service
maintenance powers, or billing catalog management.

### Sources

- [bus-api](./bus-api)
- [bus-auth](./bus-auth)
- [bus-operator-auth](./bus-operator-auth)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
