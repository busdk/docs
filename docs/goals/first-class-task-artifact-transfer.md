# First-Class Task Artifact Transfer Handoff

## Goal

This goal is to make `bus dev task` the normal transfer path for patches, log
bundles, and evidence files produced by local or remote development workers.

The intended end state is that a worker can attach review artifacts to the task
stream, the local supervisor can retrieve them with `bus dev task extract`, and
review or promotion can proceed without `scp`, shared filesystem paths, or
one-off side channels.

This handoff is written so a future conversation can resume the work without
reconstructing the earlier discussion.

## Why This Exists

The immediate trigger was a remote promotion workflow where a worker produced a
patch on H100, the supervisor copied it back with `scp`, and then applied it
locally with `git am --3way`. That proved the Git review/promotion shape, but
the file transfer escaped the task system.

The durable product direction is that task streams should carry bounded review
artifacts directly. A supervisor should be able to inspect a task, extract its
attached patch and evidence files, run normal local review commands, and decide
whether to accept, reopen, or reject the work.

## Current Baseline

The small-file attachment primitive already exists in `bus-dev`.

The completed baseline item is in `bus-dev/PLAN.md` under:

```text
Make `bus dev task` file attachments first-class transferable artifacts.
```

That baseline means:

- `bus dev task new --attach PATH` can embed a bounded repo-relative file in a
  task creation event.
- `bus dev task say --attach PATH REF MESSAGE` can attach files in later
  guidance or closeout messages.
- Attachment envelopes include path, size, checksum, checksum algorithm,
  content encoding, embedded content, media type, and producer metadata.
- `bus dev task show -f json REF` replays attachment evidence.
- `bus dev task extract REF DEST [PATH...]` materializes attachments locally.
- Extraction verifies checksums and rejects absolute paths, path traversal, and
  symlink escape paths.
- The default limit is 1 MiB per attachment and 4 MiB total per task or
  guidance event.

The relevant implementation areas are:

- `bus-dev/run/task.go`
- `bus-dev/run/run_test.go`
- `bus-dev/cmd/bus-dev/metadata.go`
- `bus-dev/README.md`
- `bus-dev/PLAN.md`

The earlier verification recorded in `bus-dev/PLAN.md` includes focused tests
for attaching small file content, replaying attachments in JSON, extracting
attachments safely, rejecting path traversal, rejecting path escapes, and
rejecting oversize attachments.

## Remaining Product Gap

The primitive existing is not enough. The remaining goal is to make it the
normal remote review path.

The current open item in `bus-dev/PLAN.md` is:

```text
Prove and operationalize first-class task artifact transfer for remote worker
promotion.
```

That item separates the implemented primitive from the still-required product
proof. The work is incomplete until a local or remote lane demonstrates that
patches, logs, and evidence move through task Events and are reviewed locally
without `scp` or other side channels.

## Required Behavior

The final workflow should support this operator path:

```bash
git format-patch -1 --stdout > changes.patch
bus dev task say --attach changes.patch TASK_REF "Patch attached for review"
bus dev task show -f json TASK_REF
bus dev task extract TASK_REF tmp/task-artifacts changes.patch
git am --3way tmp/task-artifacts/changes.patch
```

For log and evidence files, the same transfer path should be used:

```bash
bus dev task say --attach logs/test-output.txt TASK_REF "Test evidence attached"
bus dev task extract TASK_REF tmp/task-artifacts logs/test-output.txt
```

The supervisor should not need remote shell access to retrieve review files
after the worker has attached them to the task stream.

## Plan

1. Document the operator recipe.

   Add or update `bus-dev` documentation so the patch/log/evidence transfer
   workflow is copyable and uses the dispatcher form. The docs should name the
   key commands: `bus dev task say --attach`, `bus dev task show -f json`, and
   `bus dev task extract`.

2. Update worker prompt and closeout guidance.

   Remote workers should be instructed to attach patches, logs, and evidence
   through the task stream when those files are needed for review. Structured
   closeout should report attachment paths or IDs instead of only mentioning
   remote-only file paths.

3. Add deterministic fixture or local integration proof.

   A test or smoke should prove a patch-shaped attachment and a log/evidence
   attachment survive Events replay and can be extracted for local review
   without SSH file copy.

4. Run a live remote proof when a remote lane is available.

   The remote worker should emit patch, log, and evidence attachments through
   Events. The local supervisor should extract them and apply or review the
   patch without `scp`. The proof should record the task ref, remote id/kind,
   attached paths or IDs, extraction command, review/apply result, and the fact
   that no side-channel file copy was used.

5. Keep large artifacts separate.

   Large binaries, images, archives, or multi-megabyte logs should not be forced
   into Events payloads. If a real workflow hits the current size limit, record a
   separate block/object-store transfer follow-up.

## Acceptance Criteria

This goal is complete only when all of these are true:

- `bus-dev` docs include the operator-facing artifact transfer recipe.
- Worker prompt or closeout guidance tells workers to attach review artifacts
  through the task stream.
- A deterministic fixture or smoke covers patch, log, and evidence extraction
  from task replay.
- A live remote/dev-hg/H100 proof, when remote capacity is available, shows the
  workflow working without `scp` or ad hoc shared paths.
- The proof records task ref, remote id/kind, attached artifact paths or IDs,
  extraction command, and review/apply outcome.
- Large artifact handling is explicitly deferred to a separate storage or
  object-transfer path if needed.

## Current Planning State

Root `PLAN.md` includes this finish-line checklist item:

```text
Confirm first-class task artifact transfer is the normal remote review path:
the worker attaches patch/log/evidence files through `bus dev task`, the local
supervisor extracts them with `bus dev task extract`, and review or
`git am --3way` happens without `scp` or ad hoc shared paths.
```

`bus-dev/PLAN.md` contains the owning module item with scope and verification
details. In the earlier planning pass, the current `bus-dev` submodule HEAD was
recorded as `22f3a23` with the item present, while the superproject had not yet
pinned that submodule commit. A future thread should re-check current Git state
instead of assuming that exact pin is still current.

## Files To Read First

Start with these files:

1. `PLAN.md`
2. `bus-dev/PLAN.md`
3. `bus-dev/run/task.go`
4. `bus-dev/run/run_test.go`
5. `bus-dev/cmd/bus-dev/metadata.go`
6. `bus-dev/README.md`
7. `logs/20260527-17-agent-memo.md`

Use current worktree state as authoritative. The memo is supporting context,
not proof by itself.

## Suggested First Commands

Run these before continuing:

```bash
git status --short
git -C bus-dev status --short
rg -n "Prove and operationalize first-class task artifact transfer|task extract|--attach|scp" PLAN.md bus-dev/PLAN.md bus-dev/README.md bus-dev/run bus-dev/cmd
```

Then inspect the current attachment implementation and tests:

```bash
go -C bus-dev test ./run
bus lint bus-dev/PLAN.md
```

If only docs are changed, at minimum run:

```bash
git diff --check -- docs/docs/goals/first-class-task-artifact-transfer.md
bus lint docs/docs/goals/first-class-task-artifact-transfer.md
```

## Known Boundaries

Do not solve this by adding a new file-copy side channel. The purpose is to
make the Bus task stream carry bounded review artifacts.

Do not increase the Events payload limit just to handle large binaries or
archives. That is a separate artifact-storage problem.

Do not treat a local unit test of the primitive as the full goal. The primitive
is already implemented; the remaining work is adoption, documentation, closeout
guidance, and live or fixture proof that the remote review path no longer needs
`scp`.

Do not put secrets, tokens, private keys, raw environment dumps, or private
customer data into task attachments. Logs and evidence should be redacted before
being attached.

## Handoff Summary

The goal is planned but not implemented end to end.

The `bus-dev` attachment primitive exists. The missing work is to make it the
standard operational workflow for remote task review and promotion, prove it
with patch/log/evidence artifacts, document it, and keep large artifacts on a
separate future storage path.
