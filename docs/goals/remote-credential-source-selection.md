# Remote Credential Source Selection Handoff

## Goal

This conversation thread implemented the remote credential-source selection
goal for BusDK.

The requested end state was:

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

This handoff exists so a later conversation can resume from the completed
state without relying on chat history.

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

## Final Status

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

## Important Remote State

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

## What Changed

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

## Verification Performed

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

## Completion Audit

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

## What To Watch Next

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
