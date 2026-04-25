---
title: bus-api-provider-data
description: Bus API data provider owns reusable data-facing API provider contracts.
---

## Data Provider For Bus API

`bus-api-provider-data` is the provider module for reusable data-facing
provider contracts in the provider-based Bus API architecture. The core
`bus-api` service owns HTTP transport, route dispatch, OpenAPI generation, and
capability URL handling; this provider owns generic data-provider behavior.

The standalone command is for operator discovery:

```bash
bus-api-provider-data --help
bus-api-provider-data --version
```

The provider is normally loaded by `bus-api` through explicit provider
configuration. It should not replace the core `bus-api` workspace CRUD surface
or the `bus-data` library; those remain the authority for generic workspace
tables, schemas, and packages.

### Help And Quality

The `--help` output follows Git-style sections: name, synopsis, description,
options, examples, and related documentation. The module exposes `make
help-check`, and the superproject `make quality` runs that target when the
module is selected.

### Sources

- [bus-api](./bus-api)
- [bus-data](./bus-data)
- SDD: `sdd/docs/modules/bus-api-provider-data.md`
