---
title: bus-integration-repos
description: "bus-integration-repos will own repository storage, mirroring, and sync integration."
---

## `bus-integration-repos` — repository integration

`bus-integration-repos` is the planned Bus integration module for repository
storage and sync behavior.

Its expected ownership includes:

- local repository registry/provisioning
- Git-backed mirroring and sync orchestration
- repository health and sync projections
- repository hooks needed by worker-home and task-context flows

This module should keep repository implementation details out of product
modules such as `bus-task` and `bus-worker`, while still providing the storage
speed needed by autonomous workers.

The first repo kinds it needs to understand are `source`, `worker-home`,
`task-context`, and `shared-content`, using non-secret logical refs such as
`repos://workers/<worker-id>` from the `bus-repos` contract.

Current status: skeleton module. There is no stable end-user command here and
no finished integration contract yet.
