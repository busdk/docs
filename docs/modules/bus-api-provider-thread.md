---
title: Bus API Provider Thread
description: Mounted REST API routes for reading and changing Bus threads.
---

# Bus API Provider Thread

Bus API Provider Thread exposes Bus threads through the Bus API host. Bus
Events remains the source of truth; the provider replays canonical thread
events rather than maintaining a separate thread database.

The mounted routes are:

```text
GET   /api/v1/threads
POST  /api/v1/threads
GET   /api/v1/threads/stats
GET   /api/v1/threads/tree
GET   /api/v1/threads/{thread_id}
PATCH /api/v1/threads/{thread_id}
POST  /api/v1/threads/{thread_id}/messages
POST  /api/v1/threads/{thread_id}/metadata
POST  /api/v1/threads/{thread_id}/links
POST  /api/v1/threads/{thread_id}/archive
```

Create requests require `title` and may include `parent_thread_id`, `body`,
owner, participants, project and module references, metadata, links, and
provider references.

## Structural Updates

`PATCH /api/v1/threads/{thread_id}` accepts any non-empty combination of
`title`, `parent_thread_id`, and `body`:

```json
{
  "title": "Renamed thread",
  "parent_thread_id": 4,
  "body": "Replacement body"
}
```

Set `parent_thread_id` to `0` to move the thread to the root:

```json
{
  "parent_thread_id": 0
}
```

Set `body` to an empty string to clear the body. Omitted fields are unchanged.
The provider returns `202 Accepted` with the published structural payload.

The provider returns `400 Bad Request` for an empty update, a blank title,
self-parenting, or moving beneath a descendant. A missing target or parent
returns `404 Not Found`. Accepted changes publish `bus.thread.updated` and are
included in subsequent list, show, tree, and stats replay.

The provider publishes route metadata, OpenAPI operations, public route
prefixes, and Bus Events capabilities for discovery by the Bus API host.
