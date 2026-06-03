# Remote Credential Source Selection Goal

## Current Goal

Remote worker operation should not depend on whichever `BUS_API_TOKEN` happens
to be inherited by an operator shell or service process. Every credential
plane must choose credentials from explicit non-secret configuration and token
files first, then use process-global tokens only as compatibility fallbacks
when no configured source exists.

The current target is open again because the Bus implementation has moved since
the historical credential-source closeout. The earlier work proved important
behavior in the old `bus-dev` / `bus-integration-dev-task` path, but current
task and worker operation now flows through task API, workers API, Events relay,
and worker integration services.

The required end state is:

- Task API clients, worker API clients, Events relay/sync, task services,
  worker API providers, worker integration services, and SSH runner services
  use explicit token-file or configured credential-source inputs before
  inherited `BUS_API_TOKEN` values.
- `BUS_API_TOKEN` and related env-token aliases remain compatibility fallbacks,
  not the normal remote-worker credential path.
- Missing, unreadable, empty, unsupported, or locally detectable expired
  credentials fail before expensive worker/model/runtime startup.
- Diagnostics name safe source labels, selected remote id/kind, environment id,
  service name, and remediation path when available, but never token values,
  JWT fragments, or private token-file paths.
- Task Events, worker Events, logs, status snapshots, API payloads, relay state,
  and diagnostics carry non-secret credential-source kind/label metadata only.

## Worktree And Branch

This goal refinement is being edited in a separate docs worktree as requested:

- Branch: `codex/remote-credential-source-goal-refine`
- Worktree:
  `/Users/jhh/git/busdk/agent-supervisor/worktrees/docs-remote-credential-source-goal-refine`
- Repository: `projects/busdk/docs`

No Bus module implementation changes are part of this goal-file refinement.
Future product implementation must use module-owned worktrees and branches
before changing module code.

## Current Implementation Review

The current module ownership is different from the historical handoff:

- `bus-remote` owns non-secret remote metadata, including
  `credential_source` references and worker-profile credential-source
  references. It validates that config does not contain secret-looking values.
- `bus-events` owns generic Events sync and relay. Its CLI already separates
  local, remote, source, and destination token-file boundaries and reports
  credential-source labels.
- `bus-task` is now the task API client. It creates, lists, reads, messages,
  assigns, and updates task threads through `bus-api`; it does not launch
  workers or select runtime models. Its current API credential inputs are
  `--token-file`, `BUS_TASK_API_TOKEN_FILE`, `BUS_API_TOKEN_FILE`,
  `BUS_TASK_API_TOKEN`, and `BUS_API_TOKEN`.
- `bus-worker` / `bus-workers` is the worker-control API client. Its API mode
  currently uses `--token-file` or `BUS_WORKERS_API_TOKEN_FILE` for the workers
  API bearer token and exposes non-secret credential-source fields in worker
  status metadata.
- `bus-api-provider-worker` / `bus-api-provider-workers` publishes and projects
  canonical `bus.workers.*` Events. It currently accepts
  `--events-token-file` / `BUS_API_PROVIDER_WORKERS_EVENTS_TOKEN_FILE` and
  env-token input for the Events API.
- `bus-integration-worker` / `bus-integration-workers` is the current worker
  integration/service owner for worker control, scheduling, claim/start
  helpers, lifecycle planning/execution, and worker status snapshots. It
  already carries non-secret `credential_source_kind` and
  `credential_source_label` metadata from selected remote/profile config, but
  service Events credentials still need the same token-file/source precedence
  and diagnostics as the rest of the path.
- `bus-integration-task` is now the task service/provider. It consumes
  canonical `bus.task.*.request` Events, stores task state, and emits accepted
  worker assignment requests. It does not own worker launchers, App Server
  control, model selection, containers, VMs, remote transport, repositories, or
  worktree materialization. It still needs service-token handling that matches
  the credential-source contract for its Events API client.
- `bus-integration-ssh-runner` owns generic SSH script execution and already
  has managed-service token-file support through `--api-token-file` /
  `BUS_API_TOKEN_FILE` before inherited `BUS_API_TOKEN`.

Historical names such as `bus-integration-dev-task`, `bus dev task`,
`bus dev work`, `bus.dev.task.*`, `bus.work.*`, and singular
`bus.worker.*` should be treated as compatibility or historical evidence only.
New goal work should use `bus-task`, `bus-workers`,
`bus-api-provider-workers`, `bus-integration-workers`, canonical
`bus.task.*`, and canonical `bus.workers.*` where those surfaces exist.

## Open Work Needed Now

The old credential-source work should be treated as a baseline, not as current
acceptance. The current implementation still needs these product slices:

- Normalize task and worker API client credential lookup so file-backed sources
  and configured safe sources beat inherited env tokens consistently, with
  empty-file and locally detectable expiry diagnostics where the token format
  supports it.
- Normalize Events service credential lookup in `bus-integration-task`,
  `bus-api-provider-workers`, and `bus-integration-workers` so explicit
  token-file or deployment credential-source configuration beats
  `BUS_API_TOKEN`, with source-labelled diagnostics.
- Decide which credential-source kinds each service can resolve locally
  (`token-file`, deployment-secret, user-config key, OS credential label) and
  fail early for unsupported selected kinds instead of silently falling back to
  a global token.
- Preserve ssh-docker boundaries: remote-side token-file references and
  deployment secret labels must not be opened or serialized by the local task
  or worker API client.
- Carry only non-secret credential-source kind/label metadata through
  `bus.task.*`, `bus.workers.*`, worker status snapshots, relay status, and API
  responses. Token values, JWT fragments, and private token-file paths must be
  excluded from Events and logs.
- Add focused tests for stale inherited env tokens, missing/empty/unreadable
  token files, expired JWTs where locally detectable, unsupported selected
  credential-source kinds, and safe redaction.
- Run one end-to-end current-path proof using two configured remotes or
  environments with different credential sources while the inherited
  `BUS_API_TOKEN` is intentionally stale. The proof must cover task creation or
  assignment through `bus-task`, worker create/status/control through
  `bus-workers` / `bus-api-provider-workers`, Events relay/sync boundaries,
  and worker lifecycle/status through `bus-integration-workers`, without manual
  shell token export as the normal path.

## Dependencies

This goal depends on the current task/worker ownership being stable enough for
the proof to mean something:

- Finish or explicitly scope the current `bus-task` task API client contract so
  the proof uses the new task surface rather than reviving `bus dev task`.
- Finish or explicitly scope the `bus-integration-workers` service-loop and
  lifecycle path enough to start or plan workers from `bus.workers.*` Events.
- Use the service-owned Events relay goal for normal local-to-remote and
  remote-to-local evidence movement; manual export/import or ad hoc sync loops
  are recovery paths, not acceptance proof.

The goal can be implemented in parallel with broader worker lifecycle work only
when the slices are module-owned and independently testable. A service-profile
or remote-worker proof that starts a worker without this credential-source
proof must record the credential handling as incomplete.

## Historical Baseline

The original credential-source conversation implemented an earlier version of
this goal for the then-current development task path. The requested historical
end state was:

- Controller commands, remote Events sync/relay, and worker runtime processes
  select credentials from explicit remote configuration or token files as the
  normal path.
- `BUS_API_TOKEN` remains only a compatibility fallback after configured
  sources.
- Expired, unreadable, unsupported, or missing credentials fail early with
  actionable diagnostics.
- Diagnostics name safe source labels, remote id/kind when available, and the
  remediation path, but never token values.
- Task Events, logs, task payloads, and diagnostics do not leak token values,
  JWT fragments, or token-file references.

The rest of this handoff preserves the old completion evidence so future work
can reuse it without mistaking it for current-path acceptance.

## Operator Direction Captured

During this goal the operator tightened the execution model:

- Do not do development work directly on the macOS host.
- Local work should run inside Docker containers.
- Remote work may run on `coding-agent@dev.hg.fi`.
- Do not use `m3`. An earlier accidental clone existed at
  `/home/jhh/tmp/busdk-credential-work`, but the operator explicitly said to
  do nothing on `m3`.
- The only normally accepted host-side script is
  `./scripts/pull-submodules.sh` for fetching remote git changes.

The operator later asked for this handoff to be written locally on this system,
not on dev-hg. This file was therefore authored in the local checkout.

## Historical Final Status

The goal was completed and the root `PLAN.md` credential-source coordination
item was checked off.

Final local root commit reported at goal closeout:

- `d4de6e7` `Pin credential startup diagnostics`

Relevant submodule commits created during the goal:

- `bus-dev` `d4569bf` `Test multi-remote credential source selection`
- `bus-dev` `592ea3d` `Prove two-remote credential routing`
- `bus-events` `02940a0` `Respect configured event token sources`
- `bus-integration-dev-task` `fa582dd` `Validate Events token sources`
- `bus-integration-dev-task` `8f4cb5d` `Require resolved Events credentials
  before startup`
- `logs` `a417765` `Record credential source work memo`
- `logs` `b91532d` `Record credential proof closure`
- `logs` `da93b93` `Record credential lint closure`
- `logs` `77ca41a` `Record credential completion audit`

Root commits that pinned the work:

- `a21a764` `Pin credential source updates`
- `e8bc6b1` `Close credential source coordination plan`
- `0ac55f8` `Pin credential lint memo`
- `d4de6e7` `Pin credential startup diagnostics`

At closeout, the only unrelated local root status entry reported was a
pre-existing staged file:

```text
A  scripts/prune-submodules.sh
```

That file predated this goal work and was deliberately left untouched and out
of the credential-source commits.

## Historical Remote State

The dev-hg checkout at `coding-agent@dev.hg.fi:~/git/busdk/busdk` was used as
a verification workspace. Because the local commits were not pushed during the
goal, dev-hg received copied/patched files for testing and may still have
uncommitted changes in these submodules:

- `bus-dev`
- `bus-events`
- `bus-integration-dev-task`

A later thread should treat dev-hg as a dirty verification workspace until it
is reconciled intentionally. Do not reset or clean it without operator
approval. Prefer pushing/fetching the completed local commits or making a
deliberate cleanup plan.

## Historical Changes

### Remote Metadata And Non-Secret Credential References

Remote config stores non-secret credential source references, not token values.
The relevant shape is a `credential_source` such as:

```json
{
  "kind": "token-file",
  "ref": "dev-hg.token"
}
```

The `bus-remote` module already had schema and validation support for
credential-source metadata. This goal verified that slice with
`go -C bus-remote test ./...` in Docker and on dev-hg.

### Controller Credential Precedence In `bus-dev`

Controller-side `bus dev work` and `bus dev task` behavior now follows this
credential precedence:

1. Explicit `--token-file`
2. Selected controller-local remote `credential_source` token file when
   applicable
3. Local Compose/config/user token files
4. Inherited `BUS_API_TOKEN` as compatibility fallback only

This prevents a stale process-global `BUS_API_TOKEN` from overriding valid
configured token files.

Key behaviors covered:

- Two configured `bus-events` remotes can select different token files while
  `BUS_API_TOKEN` is an expired JWT.
- Direct controller status/start/sync command paths preserve token-file
  boundaries.
- ssh-docker remote-side token-file references are not opened by the local
  controller.
- Sync construction passes token-file paths/source labels, not token values.
- Help text now describes configured token files before the `BUS_API_TOKEN`
  fallback.

Primary files:

- `bus-dev/run/run.go`
- `bus-dev/run/run_test.go`
- `bus-dev/PLAN.md`

Main proof test:

```text
TestRunWorkCredentialSourcesTwoRemoteStatusStartSyncProof
```

That test configures two remotes, `dev-hg` and `local-docker`, gives them
distinct token files, sets `BUS_API_TOKEN` to an expired JWT, then runs the
controller command surface for start, status, and sync routing. It asserts the
local controller token file is used, the selected remote token-file boundary is
carried into sync routing, and task Events do not leak token values, JWT
fragments, or token-file refs.

### Events Sync And Relay Credential Boundaries In `bus-events`

`bus-events` now resolves credentials in a way that keeps local, remote, and
destination auth separate.

Implemented behavior:

- Global token resolution prefers explicit `--token-file`, then the Bus auth
  API token file under the user config root, then `BUS_API_TOKEN` fallback.
- Explicit token files are checked for readability, emptiness, and locally
  detectable JWT expiry.
- `sync` labels remote token-file errors as `--remote-token-file <path>`.
- `relay` labels destination token-file errors as
  `--destination-token-file <path>`.
- Relay status reports safe credential-source labels for local and destination
  credentials.
- Tests that intentionally exercise `BUS_API_TOKEN` fallback now isolate
  `BUS_CONFIG_DIR` so a real user token on dev-hg does not accidentally win.

Primary files:

- `bus-events/internal/cli/cli.go`
- `bus-events/internal/cli/sync.go`
- `bus-events/internal/cli/cli_test.go`
- `bus-events/internal/cli/relay_test.go`
- `bus-events/PLAN.md`

Important tests added or repaired:

- `TestRunUsesUserConfigBusAuthTokenBeforeExpiredEnvironment`
- `TestRunRejectsExpiredExplicitTokenFile`
- `TestRunSyncRejectsExpiredRemoteTokenFile`
- `TestRunRelayUsesUserConfigTokenBeforeExpiredEnvironment`
- `TestRunRelayReportsMissingDestinationTokenFile`
- `TestRunRelayRejectsExpiredDestinationTokenFile`
- shared test helper `setTestBusAPIToken`

### Worker Runtime Credential Selection In `bus-integration-dev-task`

Worker runtime Events credentials now prefer `--events-token-file`,
`--token-file`, or `BUS_EVENTS_TOKEN_FILE` before inherited `BUS_API_TOKEN`.
The selected credential is used for worker startup, supervisor helper
environments, App Server child environments, closeout/promotion helpers, and
status command paths.

Implemented behavior:

- Explicit Events token files override inherited `BUS_API_TOKEN`.
- Missing/unreadable explicit token files fail with
  `read --events-token-file <path>: ...` diagnostics.
- Empty explicit token files fail clearly.
- Locally detectable expired JWTs fail for both explicit token files and
  inherited `BUS_API_TOKEN`.
- Supervisor mode fails immediately if no Events token is resolved.
- Normal worker startup fails after recipient/remote metadata validation but
  before worker-start consumers, backend validation, App Server setup, or
  model work if no Events token is resolved.
- Missing-token diagnostics name safe remote id/kind when available and tell
  the operator to set `--events-token-file`, `BUS_EVENTS_TOKEN_FILE`, or
  `BUS_API_TOKEN`.

Primary files:

- `bus-integration-dev-task/cmd/bus-integration-dev-task/main.go`
- `bus-integration-dev-task/cmd/bus-integration-dev-task/main_test.go`
- `bus-integration-dev-task/PLAN.md`

Important tests added or updated:

- `TestResolveEventsAPITokenFileOverridesInheritedToken`
- `TestResolveEventsAPITokenRejectsExpiredTokenFile`
- `TestResolveEventsAPITokenReportsMissingTokenFile`
- `TestResolveEventsAPITokenRejectsExpiredInheritedToken`
- `TestRunWorkerReportsMissingEventsTokenBeforeBackendStartup`
- `TestRunSupervisorReportsMissingEventsToken`

### Managed SSH Runner Token-File Fallback

`bus-integration-ssh-runner` already had token-file credential support for
managed services, with `BUS_API_TOKEN_FILE` / `--api-token-file` preferred and
`BUS_API_TOKEN` treated as fallback. This goal verified that slice with:

```bash
go -C bus-integration-ssh-runner test ./...
```

run in Docker and on dev-hg.

## Historical Verification Performed

All implementation verification was run either inside Docker or on
`coding-agent@dev.hg.fi`.

### Docker Verification

```bash
go test ./...
```

passed in:

- `bus-dev`
- `bus-events`
- `bus-integration-dev-task`

Additional Docker checks passed:

```bash
go -C bus-remote test ./...
go -C bus-integration-ssh-runner test ./...
```

Focused Docker proof commands passed:

```bash
go test ./run -run TestRunWorkCredentialSourcesTwoRemoteStatusStartSyncProof -count=1 -v
```

in `bus-dev`, and:

```bash
go test ./cmd/bus-integration-dev-task -run 'TestRun(WorkerReportsMissingEventsTokenBeforeBackendStartup|SupervisorReportsMissingEventsToken)|TestResolveEventsAPIToken' -count=1 -v
```

in `bus-integration-dev-task`.

`git diff --check` passed for the touched files before commits.

### dev-hg Verification

On `coding-agent@dev.hg.fi`, these full test suites passed:

```bash
go test ./...
```

in:

- `bus-dev`
- `bus-events`
- `bus-integration-dev-task`

These additional checks passed on dev-hg:

```bash
go -C bus-remote test ./...
go -C bus-integration-ssh-runner test ./...
```

Focused dev-hg proof commands passed:

```bash
go test ./run -run TestRunWorkCredentialSourcesTwoRemoteStatusStartSyncProof -count=1 -v
```

and:

```bash
go test ./cmd/bus-integration-dev-task -run 'TestRun(WorkerReportsMissingEventsTokenBeforeBackendStartup|SupervisorReportsMissingEventsToken)|TestResolveEventsAPIToken' -count=1 -v
```

### Lint And Review Gate

A true AI-backed `bus lint` run could not be completed:

- Docker Codex runtime failed with OpenAI API HTTP 401.
- dev-hg had `bus-lint`, but no AI agent runtime was configured.

The deterministic worker-safe `bus lint` mode did pass on dev-hg for all eight
changed Go files:

```bash
PATH="$PWD/bus-lint/bin:$PWD/bus/bin:$PATH" \
BUS_LINT_WORKER_SAFE=1 \
./bus/bin/bus lint \
  bus-dev/run/run.go \
  bus-dev/run/run_test.go \
  bus-events/internal/cli/cli.go \
  bus-events/internal/cli/sync.go \
  bus-events/internal/cli/cli_test.go \
  bus-events/internal/cli/relay_test.go \
  bus-integration-dev-task/cmd/bus-integration-dev-task/main.go \
  bus-integration-dev-task/cmd/bus-integration-dev-task/main_test.go
```

It reported all files clean.

## Historical Completion Audit

The completion audit checked the root objective against current implementation
evidence:

- Controller credentials are selected from explicit token files/configured
  sources before inherited `BUS_API_TOKEN`.
- Remote Events sync/relay credentials keep local, remote, and destination
  token-file boundaries distinct.
- Worker runtime credentials use selected Events token files before inherited
  env tokens.
- Explicit missing/unreadable token files fail with source-labeled
  diagnostics.
- Locally detectable expired JWTs fail with expiry timestamps.
- Missing resolved worker/supervisor Events credentials fail before
  backend/model startup.
- ssh-docker remote-side token-file refs are not opened by the local
  controller.
- Token values, JWT fragments, and token-file refs do not leak into task Events
  in the proof tests.
- Root `PLAN.md` marks the credential-source coordination item complete and
  records proof evidence.

The goal was marked complete with the goal tracker. Tracker output reported
`993346` tokens used and about 1 hour 57 minutes elapsed.

## Historical Watch Items

1. Reconcile dev-hg dirty verification changes intentionally before using that
   checkout for unrelated work.
2. If a true AI-backed `bus lint` runtime becomes available, rerun it on the
   changed Go files for an additional peer-review pass.
3. If these commits need publication, push the root and submodule commits
   deliberately; do not assume dev-hg already has them as commits.
4. Keep `BUS_API_TOKEN` as fallback compatibility only. Do not reintroduce it
   as the normal credential path for controller, relay/sync, or worker runtime
   flows.
5. For future remote-worker work, preserve safe credential-source labels and
   avoid serializing token values or token-file refs into Events, logs, task
   payloads, or diagnostics.

## Related But Separate Discussion

The thread also discussed the service-owned task scheduler for remote workers.
That is a separate goal. The scheduler work means building a service that
consumes queued Bus dev task work, starts App Server workers up to configured
capacity, avoids replaying stale claims, and exposes queue/worker status. It
was not implemented as part of this credential-source goal.
