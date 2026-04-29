---
title: bus-portal-accounting — accounting portal UI module
description: bus-portal-accounting is the accounting-specific UI module for the modular Bus portal host.
---

## `bus-portal-accounting` — accounting portal UI module

`bus-portal-accounting` is the accounting/customer portal UI module for
workspace summary, attachment upload/listing, evidence package generation, and
artifact preview/download.

Portal hosts mount the module under `/modules/accounting/`. It is a UI module
that calls Bus API/provider APIs for server behavior.

Enable the module from the portal host when you want to expose accounting
workspace views in the browser:

```bash
bus portal serve --print-url --experimental --enable-module accounting
```

The customer-facing navigation is Finnish: `Yleiskuva`, `Aineistot`, and
`Tilinpäätös`.

The module serves external JavaScript and reads the shared portal auth session.
It calls provider-backed workspace, account, upload, evidence-package status,
and evidence-package start APIs. Artifact rendering uses provider-returned
`preview_url` and `download_url` links and does not embed active
generated/customer content same-origin.

Server-side workspace mutation, report generation, and artifact serving are
provided by APIs such as `bus-api-provider-books`.

### Sources

- [bus-portal](./bus-portal)
- [bus-api-provider-books](./bus-api-provider-books)
