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

### Sources

- [bus-portal](./bus-portal)
- [bus-api-provider-auth](./bus-api-provider-auth)
