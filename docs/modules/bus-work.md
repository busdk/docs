---
title: bus-work
description: "bus work is the generic CLI for durable asynchronous work streams over Bus Events: create work, claim the next item, read/watch/wait, reply, and close/fail/block work without tying the protocol to Codex or any one worker."
---

## `bus-work` — durable work streams over Bus Events

`bus work` is the generic Bus command for asynchronous work. It is
for work that may be handled somewhere else or later: by a human, script, LLM
agent, service, or future container worker.

This is different from [`bus run`](./bus-run), which executes local user-defined
prompts, pipelines, and scripts now. `bus work` creates durable work streams
through Bus Events so the sender and worker can read progress, exchange
messages, wait for new events, and close or block work without keeping one
terminal session alive.

### Commands

```bash
bus work new [@recipient ...] [message...] [--to recipient ...] [--file path] [--attach path ...]
bus work list [recipient] [--all]
bus work next [recipient] [--json]
bus work show [--replay|--no-replay] [--follow|--no-follow] <id...>
bus work watch [--replay|--no-replay] [--follow|--no-follow] <id...>
bus work wait [--replay|--no-replay] [--follow|--no-follow] <id...> [--until event|message|done|failed|closed|terminal] [--timeout D]
bus work say <id> <message...>
bus work close <id> [message...]
bus work fail <id> <message...>
bus work block <id> <message...>
```

Create work for the current project or context:

```bash
bus work new "Review this document"
bus work new @ "Check the current project status"
```

Send work to one or more recipients:

```bash
bus work new @accounting "Reconcile March transactions"
bus work new @team-a @team-b "Review this change from both sides"
bus work new --to acme/payroll --file request.md
bus work new @support "Investigate this failure" --attach repro.log
```

Recipient syntax is explicit. Leading `@recipient` tokens are recipients, `@`
means the current project or context, and repeatable `--to <recipient>` is the
flag form for scripts. If no recipient is provided, the current project or
context is the recipient. The rest of the command is the message. `--file`
provides the main work body, and repeatable `--attach` adds supporting files.

Multi-recipient work fans out like email. Every recipient gets its own
recipient-specific work item and can send its own messages and close its own
item. One recipient cannot claim or consume work on behalf of another.

### Reading And Replying

Work ids are meant to be short for humans. A group id such as `123` identifies
one logical request. Recipient-specific work ids use suffixes such as `123.1`
and `123.2`. Canonical cross-context references include the owner, for example
`acme/payroll#123` or `acme/payroll#123.1`.

```bash
bus work show 123
bus work watch --no-follow 123
bus work wait --no-replay 123 --until event --timeout 5m
bus work say 123 "Use the attached statement."
bus work say 123.1 "This note is only for the first recipient."
```

`show` prints current status and readable event history, then exits. `watch`
replays existing events and follows new events. `wait` blocks until a matching
event or requested state transition arrives. Saying something to a group fans
the message out to all non-terminal child work items; saying something to a
work id targets that recipient-specific stream.

For scripts, `--replay`, `--no-replay`, `--follow`, and `--no-follow` make
stream behavior explicit. `show` defaults to `--replay --no-follow`, `watch`
defaults to `--replay --follow`, and `wait` defaults to replaying existing
events before following live events until the requested condition is found.

### Receiving Work

Workers decide how to do the work. Bus provides the inbox and event stream.

```bash
bus work list
bus work next
bus work next --json
bus work close 123.1 "Done."
bus work fail 123.1 "Missing input file."
bus work block 123.1 "Need approval before continuing."
```

`next` returns and claims the next available work item for the current context
or explicit recipient. JSON output is intended for scripts and agent wrappers.
Automatic Codex or container execution can be added later as separate worker
adapters; the work protocol itself stays generic.

Lifecycle commands target one item when the id includes a child suffix such as
`123.1`. When `close`, `fail`, or `block` targets a group id such as `123`, the
CLI replays current group state and fans the lifecycle event out only to
non-terminal child items.

### Config And Auth

Repo/project-local config is command-managed, non-secret JSON:

```text
.bus/work/config.json
```

It may contain the current project/context identity, default Bus API host,
recipient aliases, and the local human id counter. The accepted JSON fields are
`project`, `api_url`, `aliases`, and `next_group_id`. The API URL must be an
absolute `http` or `https` URL. Project and alias values must be non-empty Bus
identities without whitespace, `@` prefixes, `#`, or control characters.

The file must not contain JWTs, refresh tokens, API tokens, or account-specific
secrets. Unknown fields are rejected, so accidentally adding `token` or
`api_token` fails before any Events API call is made. Credentials use normal
Bus user config and auth storage, not repository-local `.bus/` files.

The default host is `ai.hg.fi`, normalized to the Events API endpoint
`https://ai.hg.fi/api/v1/events`. The generic event namespace is `bus.work.*`,
protected by dedicated scopes: `work:send`, `work:read`, `work:reply`,
`work:claim`, and `work:admin`.

### Developer Tasks

`bus dev task ...` is a separate development feature. It preserves
`bus dev work` as the local LLM workflow and uses development-specific task
events instead of acting as a `bus work` alias.

```bash
bus dev task new @bus-ledger "Fix the failing test"
bus dev task next --json
bus dev task close 1.1 "Done"
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-events](./bus-events)
- [Module reference: bus-api-provider-events](./bus-api-provider-events)
- [Module reference: bus-auth](./bus-auth)
- [Module reference: bus-run](./bus-run)
- [Module reference: bus-dev](./bus-dev)
