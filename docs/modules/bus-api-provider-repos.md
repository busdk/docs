---
title: bus-api-provider-repos
description: "bus-api-provider-repos will expose repository metadata and sync status through the Bus API layer."
---

## `bus-api-provider-repos` — repository API provider

`bus-api-provider-repos` is the planned Bus API provider module for repository
surfaces.

It is expected to expose:

- repository list/show/status resources
- repository kind and sync/health metadata
- API/controller request handling for repo creation and sync actions
- bridges to `bus-repos` and `bus-integration-repos`

The first API contract should follow the `bus-repos` repo kinds: `source`,
`worker-home`, `task-context`, and `shared-content`, using non-secret logical
refs such as `repos://workers/<worker-id>`.

Current status: skeleton module. This page is a scope marker; no stable API
contract is implemented yet.
