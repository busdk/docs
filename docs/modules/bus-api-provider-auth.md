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

Start the standalone auth compose example from the superproject root with:

```sh
docker compose -f bus-api-provider-auth/examples/local-compose/docker-compose.yml up --build
curl -fsS http://127.0.0.1:8080/local-dev/v1/healthz
```

The readiness request should return JSON with `"ok":true`.

The BusDK superproject root `compose.yaml` uses the same auth provider through
`bus-api`, together with the broader local AI Platform stack. In that stack,
nginx exposes `/api/v1/auth/*` and `/api/internal/auth/*` on
`http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}`. The default SMTP host is
MailHog, and `BUS_AUTH_API_USER_SCOPES` controls which feature scopes an
approved local user may request.

For an AI Platform smoke check, use the token returned by the hosted
`bus auth` login and token flow against `https://ai.hg.fi/v1`:

```sh
export BUS_AUTH_API_URL=https://ai.hg.fi/api/v1/auth
bus auth login --email user@example.com
bus auth verify --email user@example.com --otp <otp-from-email>
bus auth token --scope "llm:proxy"
curl -fsS -H "Authorization: Bearer $(cat ~/.config/bus/auth/api-token)" \
  https://ai.hg.fi/v1/models
```

The email account must already be approved before `bus auth token` can issue an
`llm:proxy` API token. Operators approve verified accounts through
`bus operator auth approve` or the deployment's normal approval workflow. The
final request should return the deployment's model catalog. Do not depend on
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

### `BUS_AUTH_INTERNAL_SHARED_KEY`

Protects `/api/internal/auth/token`.

Set this as a deployment secret when trusted services or operator automation
need the auth provider to mint internal or service tokens. If the key is unset
or the request omits the matching `X-Bus-Internal-Key` header, internal token
issuing fails with `403 Forbidden`. Store the value in a secret manager or
untracked local operator configuration, not in command-line arguments.

### `BUS_AUTH_STORE_PATH`

Enables file-backed persistence for account identities and revocations.

When neither file-backed nor PostgreSQL persistence is configured, deployments
use in-memory auth state. In-memory state is suitable only for local
development because users, approvals, sessions, and revocations disappear on
restart. Use PostgreSQL for production deployments that need durable auth
state.

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

### `BUS_AUTH_API_USER_SCOPES`

Sets the end-user API scopes the provider is allowed to issue after approval.
The value is a space-separated list such as
`llm:proxy billing:read vm:read container:read container:run`. If the variable
is empty, the deployment default applies. A token request that asks for a scope
outside this allow-list fails with a deterministic authorization error instead
of silently widening access.

### `POST /api/v1/auth/register`

Creates or finds a registration candidate for an email address. Send
`Content-Type: application/json` with `{"email":"user@example.com"}`. Success
returns `200 OK` with the user status, usually `waitlisted`. Registration
alone does not issue paid API access. Invalid email returns `400 Bad Request`.

New users start waitlisted.

### `POST /api/v1/auth/otp/request`

Creates a short-lived OTP challenge and sends it through the configured OTP
provider. Send `{"email":"user@example.com"}`. Success returns `200 OK` with a
challenge status and no OTP secret in the response. Rate-limit failures return
`429 Too Many Requests`.

The console OTP provider is for local development only.

### `POST /api/v1/auth/otp/verify`

Verifies the OTP and returns an auth-service token when verification succeeds.
Send `{"email":"user@example.com","otp":"123456"}`. Success returns `200 OK`
with a token, expiry, user UUID, verification status, and waitlist status.
Wrong, expired, or reused OTPs return `401 Unauthorized` or `400 Bad Request`
depending on the failure.

The returned token uses audience `ai.hg.fi/auth`; it is not an LLM or container
API token.

### `GET /api/v1/auth/status`

Returns the current user's verification and approval status. Send
`Authorization: Bearer <auth-service JWT>`. Success returns `200 OK` with
`verified`, `status`, `user_id`, and `account_id` when approved.

Use it after OTP verification to see whether the account is still waitlisted,
approved, or rejected.

### `POST /api/v1/auth/token`

Issues a Bus API token for an approved user. Send
`Authorization: Bearer <auth-service JWT>` and a JSON body such as
`{"scope":"llm:proxy billing:read","ttl_seconds":3600}`. Success returns
`200 OK` with the API JWT, expiry, audience `ai.hg.fi/api`, and granted scope.
Waitlisted, rejected, unverified, or underscoped users receive `403 Forbidden`.

The provider only grants scopes allowed by `BUS_AUTH_API_USER_SCOPES` and the
account policy.

### `POST /api/v1/auth/token/refresh`

Refreshes an auth-service session when refresh is allowed by deployment
configuration. Send `Authorization: Bearer <auth-service JWT>`. Success returns
a replacement auth-service token. Expired or revoked sessions return
`401 Unauthorized`.

### `POST /api/v1/auth/logout`

Revokes or ends the current auth session. Send
`Authorization: Bearer <auth-service JWT>`. Success returns `204 No Content`
or a small JSON confirmation. Clients should also clear local browser or CLI
session storage.


### `GET /api/v1/auth/me`

Returns the current auth-service user identity and account information. Send
`Authorization: Bearer <auth-service JWT>`. Success returns `200 OK` with user
UUID, email, verification state, approval status, and account UUID when one is
active.

Email remains auth-service data. API providers use the stable account UUID.

### `GET /api/v1/auth/check`

Validates a bearer JWT and returns parsed claims. Send
`Authorization: Bearer <JWT>`. Success returns `200 OK` with `sub`, `aud`,
`scope`, `iat`, and `exp`. Invalid signatures, wrong audience, missing expiry,
or revoked tokens return `401 Unauthorized`.

This is a diagnostic auth-service endpoint. Domain API providers still enforce
their own audience, scope, account ownership, and billing rules.

### `GET /api/v1/auth/admin/waitlist`

Lists waitlisted users for an authorized operator. Send
`Authorization: Bearer <auth-service admin JWT>`. Requires
`waitlist:read`; deployments often mint this through `bus operator token issue`
or an internal operator secret store. Success returns `200 OK` with a list of
emails, verification state, status, and timestamps.

### `POST /api/v1/auth/admin/approve`

Approves a verified waitlisted user. Send
`Authorization: Bearer <auth-service admin JWT>` with
`{"email":"user@example.com"}`. Requires `waitlist:approve` or
`admin:manage`. Success returns `200 OK` with the stable `account_id`.

Approval creates or activates the stable account UUID used as API token `sub`.

### `POST /api/v1/auth/admin/reject`

Rejects a waitlisted user. Send
`Authorization: Bearer <auth-service admin JWT>` with
`{"email":"user@example.com","reason":"optional operator note"}`. Requires
`waitlist:approve` or `admin:manage`. Success returns `200 OK` with status
`rejected`.

Rejected users cannot request paid feature API tokens.

### `POST /api/internal/auth/token`

Issues trusted internal service tokens.

This endpoint is separate from the public user flow and is protected by the
configured internal shared key. Send `X-Bus-Internal-Key:
<BUS_AUTH_INTERNAL_SHARED_KEY>` and `Content-Type: application/json`.

The JSON body accepts `subject`, `audience`, and `scope`. `subject` defaults to
`auth-admin` when omitted. `audience` defaults to the auth-service audience,
usually `ai.hg.fi/auth`; set it to `ai.hg.fi/api` for scoped service tokens
that call normal Bus APIs. `scope` is a space-separated scope list such as
`waitlist:read waitlist:approve` or `billing:entitlement:check`. Success
returns `200 OK` with an access token, token type, expiry, audience, subject,
and scope. Missing or wrong internal key, invalid subject, or an invalid
audience returns `403 Forbidden`; malformed JSON returns `400 Bad Request`.

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
