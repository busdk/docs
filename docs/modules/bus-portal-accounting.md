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
