---
title: Supporting BusDK platform
description: Shared platform areas that support BusDK product lines without usually being standalone public products.
---

The supporting BusDK platform contains infrastructure that users, operators,
and developers may need to understand, but that usually supports the product
lines rather than being sold as a standalone product page.

## Platform Areas

- [Bus CLI and Busfiles](../cli/): deterministic command dispatch and `.bus`
  automation files.
- [Bus Workspace](../data/): workspace initialization, configuration,
  preferences, secret references, and inspectable workspace datasets.
- [Bus API Host](../modules/bus-api): provider-hosting API shell,
  OpenAPI/gateway contract, and token-gated local/service APIs.
- [Bus Integration Runtime](../modules/bus-integration): event-worker host and
  runtime for integration modules.
- [Bus Events](../modules/bus-events): publish, listen, replay, sync, and
  request/reply event substrate.
- [Bus Operator](../modules/bus-operator): trusted deployment, admin, and
  service automation command shell.
- [Bus Portal Host](../modules/bus-portal): frontend module shell and
  dispatcher for Bus application modules.

For the Go-native UI product line, use [Bus GX/UI Library](gx-ui).
