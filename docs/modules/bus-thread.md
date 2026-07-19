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

## List Order and Activity

With no `--depth`, `list` shows the complete visible thread hierarchy. Select a
subtree by passing its parent ID positionally or with `--parent`:

```sh
bus thread list
bus thread list 229
bus thread list --parent 229
bus thread list 229 --depth 0
bus thread list --parent 229 --depth 1
```

The two parent forms produce the same text and JSON output. Selecting parent
`229` changes the subtree root, but omitting `--depth` still shows all visible
descendants. `--depth 0` shows only the direct level: root threads for an
unscoped list or the selected parent's direct children. Positive depths keep
the hierarchy bounded. Use `--roots` for a root-only list.

Use `bus thread list --order activity[:asc|desc]` to sort by last activity.
`activity` and `activity:asc` are least-recently-active first.
`activity:desc` is newest-first.
If you repeat the same `--order` term, the first term is used and later terms
are ignored, for example `--order activity:desc --order activity`.
Filtering is applied before ordering, and ordering is applied before `--limit`.

```sh
bus thread list --archived --order activity:desc --limit 25
```

## List Completion Progress

Bus Thread computes a completion aggregate for every thread that has at least
one descendant, and folds it into the same status marker already shown on
that thread's `list` row. If thread 10 has four descendants and two of them
carry the exact stored status `completed`, its row reads
`#10 Launch checklist [active, 2/4 complete (50%)]` instead of a bare
`[active]`. A descendant that is itself a parent aggregates only its own
subtree, for example `#12 Support runbook [active, 1/2 complete (50%)]`.
Threads with no descendants, such as `#11 Update changelog [completed]` or
`#14 Rollback drill [deferred]`, keep the plain status marker and never gain
a synthetic `0/0` aggregate.

Only the exact stored metadata status `completed` counts toward the
numerator. Every other status, including `active`, `tracking`, `deferred`,
and `reference`, stays in the denominator without counting as done.

The aggregate is calculated once over the complete replayed hierarchy, before
`--archived` filtering, `--depth` scoping, `--order`, or `--limit` are
applied, and the same totals then travel with each surviving parent row.
Thread 12's other descendant, thread 13, is archived and stays hidden from
the default view, yet it still counts toward thread 12's total: thread 12
reads `[active, 1/2 complete (50%)]` in both the default list and the
selected-parent header printed by `bus thread list --parent 12`:

```text
THREADS
#12 Support runbook [active, 1/2 complete (50%)]
└─ #14 Rollback drill [deferred]
```

Explicit ordering and limiting keep the same marker on whichever parent row
survives:

```sh
bus thread list --parent 10 --depth 1 --order activity:desc --limit 1
```

```text
THREADS
#10 Launch checklist [active, 2/4 complete (50%)]
  • #12  Support runbook [active, 1/2 complete (50%)] activity: 2026-03-05T00:00:00Z
```

`--format json` exposes the same totals as an optional `progress` object on
each parent thread. `completed` and `total` are integers; `percent` is the
unrounded percentage of completed over total:

```json
{
  "thread_id": 10,
  "title": "Launch checklist",
  "progress": { "completed": 2, "total": 4, "percent": 50 }
}
```

Leaf threads omit `progress` entirely; treat a missing field, not `null` or a
zero-valued object, as "no descendants."

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
