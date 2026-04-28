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
`/api/v1/auth/otp/verify`; it does not call integration workers directly.
