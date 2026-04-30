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
Enable it in the Bus API route/provider configuration by allowing provider
`books` and mounting the accounting routes for the workspace. A minimal local
serve command is `bus-api serve --provider books --enable-module books -C
<workspace>`. Verify loading with `bus-api-provider-books --help` for provider
metadata and by requesting `/api/v1/accounting/workspace` from the running API.

### Help And Quality

The `--help` output follows Git-style sections: name, synopsis, description,
options, examples, and related documentation. The module exposes `make
help-check`, and the superproject `make quality` runs that target when the
module is selected.

### Accounting Portal API

`GET /api/v1/accounting/workspace` returns the active accounting workspace
identity for dashboards.
It requires the same bearer or capability authority as the mounted Bus API
deployment. Success returns `200 OK` with workspace identity and display fields.

`GET /api/v1/accounting/accounts` returns `accounts.csv` rows as deterministic
JSON sorted by account code.
Success returns `200 OK` with an array of account rows.

`GET /api/v1/accounting/submissions` returns customer submission metadata from
`attachments.csv`; a workspace without submissions returns an empty list.
Success returns `200 OK` with `items`.

`POST /api/v1/accounting/submissions/upload` accepts multipart field `files`,
stores files in the workspace attachments area, updates `attachments.csv`, and
enforces configurable total request, per-file, and file-count limits.
Success returns `201 Created` or `200 OK` with stored attachment metadata.
Oversized or unsupported uploads return `400` or `413`.

`GET /api/v1/accounting/evidence-pack` returns the latest evidence-pack status
and artifact metadata.
Success returns `200 OK` with status and artifact fields.

`POST /api/v1/accounting/evidence-pack/start` invokes the configured provider
evidence runner for the deployment.
The request body may be empty for the default run. Success returns an accepted
status and run metadata.

`GET /api/v1/accounting/evidence-pack/artifact` downloads one generated artifact
as an attachment after validating that the path stays inside the provider
evidence-pack output directory.
Pass the artifact identifier or relative artifact path expected by the
provider. Path traversal and missing artifacts return deterministic errors.

`GET /api/v1/accounting/evidence-pack/artifact/preview` renders artifact bytes
as escaped text so active HTML or SVG cannot run in the portal origin.
Success returns safe preview text and metadata for browser display.

### Sources

- [bus-api](./bus-api)
