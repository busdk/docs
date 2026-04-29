---
title: bus-api-provider-session
description: Bus API session provider owns session lifecycle and token introspection behavior.
---

## Session Provider For Bus API

`bus-api-provider-session` owns session lifecycle and token introspection
behavior for the provider-based Bus API architecture. A session is policy and
execution context; it is not the same thing as an authenticated identity.

The standalone command is for operator discovery:

```bash
bus-api-provider-session --help
bus-api-provider-session --version
```

The provider is normally loaded by `bus-api` through explicit provider
configuration. It exposes session operations such as create, refresh, revoke,
and introspect to other providers through the provider boundary. Identity,
auth, entitlement, and billing providers can consume session context without
owning session lifecycle transitions.

### Help And Quality

The `--help` output follows Git-style sections: name, synopsis, description,
options, examples, and related documentation. The module exposes `make
help-check`, and the superproject `make quality` runs that target when the
module is selected.

### Sources

- [bus-api](./bus-api)
