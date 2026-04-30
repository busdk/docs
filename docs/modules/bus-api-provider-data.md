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
Enable it by adding provider `data` to the Bus API provider allowlist and
serving the intended workspace root. A minimal local command is
`bus-api serve --provider data --enable-module data -C <workspace>`. Verify the
provider is available with `bus-api-provider-data --help` and the running
`bus-api` provider/module listing for that deployment.

### Help And Quality

The `--help` output follows Git-style sections: name, synopsis, description,
options, examples, and related documentation. The module exposes `make
help-check`, and the superproject `make quality` runs that target when the
module is selected.

### Sources

- [bus-api](./bus-api)
- [bus-data](./bus-data)
