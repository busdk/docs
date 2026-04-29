---
title: bus-portal-accounting — accounting portal UI module
description: bus-portal-accounting is the accounting-specific UI module for the modular Bus portal host.
---

## `bus-portal-accounting` — accounting portal UI module

`bus-portal-accounting` is the target module for the accounting/customer portal
features currently being separated from the generic `bus-portal` host:
workspace summary, attachment upload/listing, evidence package generation,
and artifact preview/download.

Portal hosts mount the module under `/modules/accounting/`. It is a UI module
and should use Bus API/provider APIs for server behavior instead of calling
integration workers directly.

The module serves external JavaScript and reads the shared portal auth session.
It calls provider-backed workspace, account, upload, evidence-package status,
and evidence-package start APIs. Artifact rendering uses provider-returned
`preview_url` and `download_url` links and does not embed active
generated/customer content same-origin.

The exact legacy Finnish accounting workflow is still being migrated from the
generic `bus-portal` host. That migration must stay API-backed; server-side
workspace mutation, report generation, and artifact serving do not belong in
this UI module.
