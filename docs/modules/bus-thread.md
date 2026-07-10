---
title: Bus Thread
description: Create, organize, rename, move, and follow shared event-backed conversation threads.
---

# Bus Thread

Bus Thread provides shared conversation boards backed by Bus Events. A thread
has a positive numeric ID, a required title, an optional body, messages,
participants, project and module references, metadata, links, and an optional
parent thread.

Use the Bus dispatcher for normal commands:

```sh
bus thread create --title "Release review" --body "Track review findings"
bus thread list
bus thread show 1
bus thread tree
```

`create` allocates the next numeric ID through the Bus Events conditional
append sequence. A child thread names its existing parent:

```sh
bus thread create --title "API review" --parent 1
```

## Rename And Move Threads

`update` can change the title, body, and parent in one event:

```sh
bus thread update 2 --title "Provider API review" --parent 1
bus thread update 2 --body "Revised review scope"
bus thread update 2 --clear-body
```

The shorter commands publish the same canonical update event:

```sh
bus thread rename 2 "Provider API review"
bus thread move 2 1
bus thread move 2 root
```

`move THREAD_ID root` detaches a child and makes it a top-level thread. The
equivalent canonical form is `update THREAD_ID --root` or
`update THREAD_ID --parent 0`.

Before publishing a move, Bus Thread replays the current hierarchy. It rejects
a missing target, a missing parent, self-parenting, and moving a thread beneath
one of its descendants. `list`, `show`, and `tree` immediately reflect accepted
updates when they replay the event stream.

## Messages And Metadata

Post a message with positional text, a file, or standard input:

```sh
bus thread send 1 "Review started"
bus thread message 1 --file review.md
printf 'Review complete\n' | bus thread send 1 --stdin
```

Metadata, links, and archive state use separate commands:

```sh
bus thread metadata 1 --status in-review --participant worker-1
bus thread link 1 --link pull_request:123
bus thread archive 1 --reason "review complete"
```

Archiving does not delete the thread or its event history.

## Watch And Output

Replay and follow one thread or a board:

```sh
bus thread watch 1
bus thread watch --board 7
```

Use `--format json` for scripts. The canonical event set is
`bus.thread.created`, `bus.thread.updated`, `bus.thread.message`,
`bus.thread.metadata.changed`, `bus.thread.linked`, and
`bus.thread.archived`.
