---
title: bus-portal-auth — portal auth UI module
description: bus-portal-auth provides reusable registration and login UI for the modular Bus portal host.
---

## `bus-portal-auth` — portal auth UI module

`bus-portal-auth` provides browser UI for account registration, email OTP login,
logout, and waitlist/approval status. Auth business logic remains in
`bus-api-provider-auth`.

Portal hosts mount the module under `/modules/auth/`. The module calls Bus auth
APIs such as `/api/v1/auth/register`, `/api/v1/auth/otp/request`, and
`/api/v1/auth/otp/verify`.
It is the normal account entry point for portal deployments that need browser
registration or login.

The module serves external JavaScript and exposes `window.BusPortalAuth`
helpers for session discovery, authenticated fetches, OTP request/verify,
token refresh, API-token request, billing setup, and logout. Browser state is
kept in `sessionStorage` by default; token validation, waitlist state, approval
state, and account decisions remain in `bus-api-provider-auth`.

### User Flow

Users enter an email address, request an OTP, verify the OTP, and then see
their waitlist or approval status. Registration and OTP verification prove
email ownership, but they do not grant paid feature access by themselves.
Approved accounts can request API tokens with the scopes allowed by the auth
provider policy.

When a paid feature requires billing, the auth UI can guide the user to the
billing setup flow exposed by `bus-api-provider-billing`. The payment setup
decision still belongs to the Billing API and billing integration, not the
frontend.

### Browser Session

The module stores browser session data in session storage so a browser tab can
call Bus APIs without asking for OTP on every request. Hosted deployments
should use HTTPS and should keep token lifetimes short. Logout clears the local
browser session and calls the auth API logout endpoint when configured.

Portal modules that need authenticated API calls should use the shared
`window.BusPortalAuth` helpers instead of implementing their own token storage
or refresh logic.

### Security Notes

The auth module is frontend code. It does not approve users, issue arbitrary
scopes, validate payment state, or enforce quotas. Those decisions are made by
`bus-api-provider-auth`, `bus-api-provider-billing`, and the domain API
providers.

### Sources

- [bus-portal](./bus-portal)
- [bus-api-provider-auth](./bus-api-provider-auth)
- [bus-billing](./bus-billing)
