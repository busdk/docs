---
title: Bus Integration Thread
description: Replay and follow canonical Bus thread events through the shared integration host.
---

# Bus Integration Thread

Bus Integration Thread is the passive thread event registration used by the
shared `bus-integration` host. It reads existing events from the Bus Events API
and does not allocate thread IDs, publish mutations, or maintain local thread
state.

The registration consumes:

```text
bus.thread.created
bus.thread.updated
bus.thread.message
bus.thread.metadata.changed
bus.thread.linked
bus.thread.archived
```

Structural updates preserve optional title, parent, and body fields. A parent
value of `0` represents root detachment.

Check the registration through the combined host:

```sh
bus integration --list-integrations
bus integration \
  --events-url "$BUS_EVENTS_API_URL" \
  --token-file "$BUS_EVENTS_TOKEN_FILE" \
  --provider thread \
  --check-config
```

The low-level module command can replay the full board or one numeric thread as
JSON lines:

```sh
bus integration thread --events-url "$BUS_EVENTS_API_URL"
bus integration thread --events-url "$BUS_EVENTS_API_URL" 12
bus integration thread --events-url "$BUS_EVENTS_API_URL" --follow 12
```

Use `--token-file` when the Events API requires a bearer token. Without a
thread ID, replay includes every valid canonical thread event. With a thread
ID, events for other threads are filtered out after payload validation.
