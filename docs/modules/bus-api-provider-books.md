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
User-facing accounting workflows remain in their owning Bus modules.

### Help And Quality

The `--help` output follows Git-style sections: name, synopsis, description,
options, examples, and related documentation. The module exposes `make
help-check`, and the superproject `make quality` runs that target when the
module is selected.

### Sources

- [bus-api](./bus-api)
- SDD: `sdd/docs/modules/bus-api-provider-books.md`
