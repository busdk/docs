---
title: bus-portal-accounting — accounting portal UI module
description: bus-portal-accounting is the accounting-specific UI module for the modular Bus portal host.
---

## `bus-portal-accounting` — accounting portal UI module

`bus-portal-accounting` is the accounting/customer portal UI module for
workspace summary, attachment upload/listing, evidence package generation, and
artifact preview/download.

Portal hosts mount the module under `/modules/accounting/`. It is a UI module
and should use Bus API/provider APIs for server behavior instead of calling
integration workers directly.
The module currently declares itself experimental and not default-enabled, so
`bus-portal` requires an explicit `--experimental --enable-module accounting`
opt-in before mounting it.

The customer-facing navigation is Finnish: `Yleiskuva`, `Aineistot`, and
`Tilinpäätös`.

The module serves external JavaScript and reads the shared portal auth session.
It calls provider-backed workspace, account, upload, evidence-package status,
and evidence-package start APIs. Artifact rendering uses provider-returned
`preview_url` and `download_url` links and does not embed active
generated/customer content same-origin.

Server-side workspace mutation, report generation, and artifact serving do not
belong in this UI module. Those behaviors belong behind provider APIs such as
`bus-api-provider-books`.
