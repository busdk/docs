---
title: bus-repos
description: "bus-repos will provide the user-facing Bus repository CLI and library surface."
---

## `bus-repos` — repository UX

`bus-repos` is the planned Bus module for repository management. The user-facing
term is "repos": Git is the likely storage technology, but the product surface
should describe Bus-managed repositories rather than exposing storage internals
as the product identity.

The current design direction is:

- `bus repos` for operator and UI workflows such as list, show, create, clone,
  and sync
- `bus-integration-repos` for actual repository storage/runtime integration
- `bus-api-provider-repos` for API/controller surfaces

Repository kinds expected by the current task/worker refactor include:

- mirrored source repositories for third-party development sources
- worker-home repositories
- task-context repositories
- shared wiki/content repositories

Current status: skeleton module. No stable `bus repos` command contract is
implemented yet.
