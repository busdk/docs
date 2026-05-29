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

- `source` repos for mirrored third-party or project source repositories
- `worker-home` repos for per-worker `AGENTS.md`, memo logs, memory, and links
  to source/task repos
- `task-context` repos for task-local notes, artifacts, and links back to
  source and worker-home repos
- `shared-content` repos for shared wiki/content stores

The provisional non-secret logical reference shape is
`repos://<collection>/<id>`. The current collections are `sources`, `workers`,
`tasks`, and `content`. Product modules can store these references, but local
path allocation, remotes, credentials, provisioning, and sync stay in the repo
module family rather than in task or worker metadata.

Current status: skeleton module. No stable `bus repos` command contract is
implemented yet, but the repo-kind contract above is the current
task/worker-refactor contract.
