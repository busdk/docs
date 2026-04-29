---
title: bus-api-provider-books
description: Bus API books provider owns accounting and bookkeeping-domain API provider behavior.
---

## Books Provider For Bus API

`bus-api-provider-books` is the provider module for accounting and
bookkeeping-domain behavior in the provider-based Bus API architecture. The
core `bus-api` service owns HTTP transport, route dispatch, OpenAPI generation,
and capability URL handling; this provider owns books-specific API contracts.

The standalone command is for operator discovery:

```bash
bus-api-provider-books --help
bus-api-provider-books --version
```

The provider is normally loaded by `bus-api` through explicit provider
configuration. It should not be used as a separate end-user accounting CLI.
User-facing accounting workflows remain in their owning Bus modules and portal
frontends consume these provider APIs instead of reading workspace files
directly.

### Help And Quality

The `--help` output follows Git-style sections: name, synopsis, description,
options, examples, and related documentation. The module exposes `make
help-check`, and the superproject `make quality` runs that target when the
module is selected.

### Accounting Portal API

`GET /api/v1/accounting/workspace` returns the active accounting workspace
identity for dashboards.

`GET /api/v1/accounting/accounts` returns `accounts.csv` rows as deterministic
JSON sorted by account code.

`GET /api/v1/accounting/submissions` returns customer submission metadata from
`attachments.csv`; a workspace without submissions returns an empty list.

`POST /api/v1/accounting/submissions/upload` accepts multipart field `files`,
stores files in the workspace attachments area, updates `attachments.csv`, and
enforces configurable total request, per-file, and file-count limits.

`GET /api/v1/accounting/evidence-pack` returns the latest evidence-pack status
and artifact metadata.

`POST /api/v1/accounting/evidence-pack/start` invokes the configured provider
evidence runner. The provider does not shell out to `bus-reports`; production
wiring must use Go library integration.

`GET /api/v1/accounting/evidence-pack/artifact` downloads one generated artifact
as an attachment after validating that the path stays inside the provider
evidence-pack output directory.

`GET /api/v1/accounting/evidence-pack/artifact/preview` renders artifact bytes
as escaped text so active HTML or SVG cannot run in the portal origin.

### Sources

- [bus-api](./bus-api)
- SDD: `sdd/docs/modules/bus-api-provider-books.md`
