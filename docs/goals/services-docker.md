# Services Docker Single-Image Deployment Goal

## Goal

Implement Docker support for running the repository's full Bus services stack
from one Ubuntu-based container image.

The required product result is a single Docker image that contains the working
`services.yml` from this BusDK repository, the profile directories referenced
by that stack, PostgreSQL, and every Bus service binary needed by the stack.
The container entrypoint runs:

```bash
bus services up
```

inside the container. `bus services` is the supervisor for PostgreSQL and all
Bus services in that same container.

The image must use Bus binary release artifacts only. It must not contain the
BusDK source tree, module checkouts, `.git` directories, Go source, or a Go
toolchain in the runtime image.

This goal is the Docker packaging sibling of
`systemd-user-deployment.md`, but it is not blocked by that goal. The systemd
goal installs Bus services onto a host supervisor. This goal packages the full
working stack into one container image and uses Docker or Compose only as the
outer lifecycle boundary.

## Operator Direction Captured

The operator forked this from the systemd goal and requested:

```text
docs/docs/goals/services-docker.md from the BusDK superproject root
```

The active requirement is narrower and more concrete than the first draft of
this goal:

- build one Docker image from an Ubuntu base image;
- include the repository's full working `services.yml`;
- include all services referenced by that stack in the same container,
  including PostgreSQL;
- run the stack with `bus services`;
- use Bus binary release artifacts, not source builds, inside the runtime
  image;
- keep source code out of the container;
- use Docker proof on `coding-agent@dev.hg.fi`;
- use worker-owned Git worktrees and feature branches before making
  implementation changes.

An earlier docs-only review/update pass used this local coordination branch and
worktree:

```text
branch:   codex/services-docker-single-image-goal
worktree: /Users/jhh/git/busdk/agent-supervisor/worktrees/docs-services-docker-single-image-goal
```

No product implementation is part of this goal-file update.
Product implementation must not use supervisor-created worktrees. Bus Workers
must create and own their implementation worktrees and branches.

## Current Repository Stack

The image target is the current BusDK root `services.yml`, not a reduced demo
stack. At the time of this review, that file defines these default services
and groups:

```text
default_services:
  api
  events-relay

groups:
  infrastructure: postgres, events, events-relay
  integrations: repos, workers, tasks
  gateways: api
```

The service profiles referenced by the stack are:

```text
postgres/native
bus/events/postgres
bus-events-relay
bus/repos/local
bus/workers/direct
bus/tasks/local
bus/api/local
```

The Docker image must therefore prove the complete repository stack, including
PostgreSQL and the Bus API/events/repos/workers/tasks/relay services, unless
the repository `services.yml` itself changes.

## Target Image Contract

The implementation must create a runtime image with this shape:

- base image: a pinned supported Ubuntu LTS tag or digest, such as
  `ubuntu:24.04` plus the resolved image digest in proof output;
- PostgreSQL server and client installed in the image from Ubuntu packages or
  another explicit release package source;
- the Bus dispatcher and all Bus service binaries installed from verified Bus
  binary release artifacts;
- the repository `services.yml` copied into the image at
  `/opt/bus/services.yml`;
- the repository profile tree copied into the image at `/opt/bus/profiles`;
- no BusDK source checkout, module checkout, `.git` directory, Go source tree,
  or Go compiler in the runtime filesystem;
- runtime state under `/var/lib/bus/services`;
- PostgreSQL data under `/var/lib/postgresql/data` or another explicit mounted
  data directory;
- logs under `/var/log/bus`;
- transient runtime files under `/run/bus` and `/tmp`;
- no raw credentials, provider tokens, private keys, broad `.env` files, or
  process-global secret defaults baked into the image.

The runtime command should be recognizable as Bus:

```bash
/usr/local/bin/bus services up \
  --file /opt/bus/services.yml \
  --profile-dir /opt/bus/profiles \
  --state-dir /var/lib/bus/services \
  --foreground \
  --all
```

The `--state-dir` flag is part of the container contract. If the current
`bus-services` CLI rejects it, implement and test that flag before treating the
image entrypoint as valid.

If `bus services up` needs a container-specific flag or PID 1 detection, that
behavior belongs in `bus-services` and `bus-integration-services`, not in a
shell script that becomes a second supervisor.

## Binary Release Requirement

The Docker build must consume released Bus binaries. It may use a separate
builder or download stage to fetch and verify artifacts, but the final runtime
stage must contain only the runtime OS packages, verified binary artifacts,
stack configuration, profiles, and runtime entrypoint assets.

Required release handling:

- release artifact identity is explicit in the Docker build inputs;
- checksums or signatures are verified during the build;
- the image records the Bus release identity in labels or a release metadata
  file;
- `bus version` or equivalent inside the container reports the installed
  release identity;
- implementation proof confirms that the binary launched by Docker is the
  release binary inside the image, not a source checkout or stale local build.

If the repository cannot yet produce the needed release bundle, implement that
release packaging first as a dependency of this goal. Do not satisfy this goal
by copying local build outputs from a dirty source tree into the runtime image.

## Source Exclusion Requirement

The runtime image must not contain source code. Minimum checks:

```bash
docker run --rm "$BUS_SERVICES_IMAGE" sh -lc \
  'found="$(find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o \
    \( -name .git -o -name "*.go" -o -name go.mod -o -name go.sum \) -print -quit)"; \
    test -z "$found"'

docker run --rm "$BUS_SERVICES_IMAGE" sh -lc '! command -v go'
```

The exact checks may be refined to avoid scanning virtual filesystems, but the
proof must demonstrate that the runtime image is not a disguised source
checkout.

## Required Runtime Behavior

`bus services up` inside Docker must:

- load the baked `/opt/bus/services.yml` and `/opt/bus/profiles`;
- start PostgreSQL as the `postgres/native` service inside the same container;
- initialize or reuse the mounted PostgreSQL data directory safely;
- start the Bus services in dependency order;
- freeze the resolved stack into the state directory before starting children;
- keep only explicitly declared environment variables for child processes;
- keep token values out of command arguments, status output, logs, and frozen
  stack files;
- remain in the foreground while required services are healthy;
- forward `SIGTERM` and `SIGINT` to child processes;
- shut down children in dependency order with a bounded graceful timeout;
- reap exited children while running as PID 1;
- exit non-zero if a required child exits unexpectedly or readiness fails;
- allow `bus services ps --format json` inside the container to report service
  state without secrets;
- allow `bus services down` to use the frozen stack when available.

PostgreSQL must be treated as a first-class service in the stack, not as a
sidecar Compose service. Compose may provide volumes, environment references,
ports, and health checks, but not the database process.

## Compose Fixture

This goal includes a goal-facing Compose fixture:

```text
docs/docs/goals/services-docker/compose.yml
```

The implementation may also expose a repository-root Compose profile for CI
and local image-build smoke checks:

```text
compose.yaml --profile services-runtime
```

These two files have distinct purposes. The docs fixture is the operator-facing
proof fixture for this goal. The root Compose profile is the implementation
fixture used by CI and release-image packaging. They must stay aligned on the
same product contract, and both must parse successfully.

Both Compose paths must model the final product contract:

- one service container;
- one image containing the full repository stack;
- no bind mount for `services.yml`;
- no bind mount for `profiles`;
- persistent volumes for Bus service state, PostgreSQL data, runtime files,
  and logs. A single `/var/lib/bus` runtime volume is acceptable when it
  contains the service state, PostgreSQL data, token files, and worker runtime
  state;
- an entrypoint or command that invokes `bus services up` against
  `/opt/bus/services.yml` and `/opt/bus/profiles`;
- a health check based on `bus services ps --format json`;
- localhost-bound ports for the Bus API, Events relay, and related local
  service surfaces. The docs fixture may make host-side ports configurable with
  defaults so it can be proved on a busy Docker host without changing the
  container ports.

The docs fixture is allowed to be a goal artifact before implementation
exists, but it must not drift from the implementation profile once the product
slice exists.

## Affected Bus Modules

Primary implementation owners:

- `bus-services`: user-facing `bus services up`, flags, help, status UX,
  foreground/container mode, release identity display, and health-checkable
  command behavior.
- `bus-integration-services`: stack loading, process supervision, dependency
  order, PID 1 signal handling, child reaping, frozen stack state, status,
  logs, and PostgreSQL native runtime integration.
- `bus-operator-deploy`: image build/install/refresh workflow, release
  artifact selection, remote Docker proof orchestration, and deployment
  metadata.

Supporting or profile-owned modules:

- `bus-integration-postgres`: PostgreSQL command discovery, initialization,
  readiness, shutdown, and data directory behavior when reused by the native
  service profile.
- `bus-events`, `bus-integration-events`, and `bus-api-provider-events`:
  events service behavior under the baked Docker profile.
- `bus-api`, `bus-api-provider-services`, and the API provider modules for
  repos, workers, and tasks: service surfaces started by the repository stack.
- `bus-integration-repos`, `bus-integration-worker`, and
  `bus-integration-task`: local service behavior started by the repository
  profiles.
- `bus-integration-docker` or `bus-integration-containers`: only if the image
  build or future nested container runtime integration needs module-owned
  Docker mechanics.

Do not implement the Docker supervisor inside unrelated service modules. They
should remain ordinary services launched by the Services stack.

## Dependencies And Non-Dependencies

This goal is not blocked by `systemd-user-deployment.md`.

This goal is blocked by release packaging if no Bus binary release artifact
exists that contains the dispatcher and all binaries required by the repository
`services.yml`. That release artifact work must be completed first or as the
first slice of this goal.

This goal is also blocked by the current `services.yml` and profile tree being
self-consistent. If the repository stack cannot run on a normal host, fix the
stack/profile issue before treating Docker failures as container-specific.

Remote proof must use Docker on:

```text
coding-agent@dev.hg.fi
```

The supervisor host should not be treated as the Docker proof environment.

## Historical Implementation Dispatch

Implementation work must use Bus Workers and worker-owned worktrees. The
following Services Docker lanes are historical context, not the current source
of truth. Use the `Current Supervisor Review` section below for the active
worker-owned lane, resolved proof evidence, and promotion status:

- foreground/container Services contract:
  `services-docker-foreground-20260606f`, task `task-3df4d92bf1d3`, branch
  `codex/services-docker-foreground-20260606-worker`, worktree
  `.bus/services/workers/runtime/services-docker-foreground-20260606f/product-worktree`.
  Worker commits `7e2ea320`, `9130aaef`, `fed66919`, and `b05fb11f` pin
  `bus-integration-services` commits `4946cda`, `67ddbb1`, `2c2ed4e`, and
  `378c4f3`, and `bus-services` commits `d0ef5c9` and `f4fd8fc`. The lane now
  has useful prerequisite work for provider-owned start/stop dispatch,
  provider-aware unsupported container operation errors, foreground waiting,
  signal forwarding, required child failure detection, JSON `ps`, sanitized
  frozen stack state, a real `--foreground` flag in `bus-services`, and a
  bounded command healthcheck. Supervisor review reran
  `go -C bus-services test ./cmd/bus-services`,
  `go -C bus-integration-services test ./cmd/bus-integration-services
  ./pkg/servicesintegration`, and diff checks for the touched superproject and
  submodules; they passed. This lane is now a review-ready foreground Services
  slice, but it is not full goal completion until it is combined with the image
  packaging slice and proven with Docker on dev-hg;
- Ubuntu single-image packaging:
  `services-docker-image-20260606f`, original task `task-e65711d74825`,
  replacement task `task-ebada7d4e135`, branch
  `codex/services-docker-ubuntu-image-20260606-worker`, worktree
  `.bus/services/workers/runtime/services-docker-image-20260606f/product-worktree`.
  Worker commits `4532bc90` and `4d228a89` are not accepted as the image
  solution because they changed the Codex/dev-task worker image path rather
  than producing a clean dedicated Ubuntu Bus services runtime image. Follow-up
  commits `089492be`, `73f98ee7`, `51d83b45`, and `880ef548` add useful
  dedicated Services runtime image packaging and restore the dev-task image
  files to the branch base:
  `deploy/local-ai-platform/services/Dockerfile`,
  `deploy/local-ai-platform/services/bus-services-entrypoint.sh`,
  `scripts/build-ssh-docker-services-image.sh`, a `services-runtime` Compose
  profile, and a `publish-bus-services-image` workflow job. Supervisor review
  verified the full branch diff from base `ea14c3b0..HEAD` now contains only
  `.github/workflows/release.yml`, `compose.yaml`, the dedicated services
  Dockerfile and entrypoint, and the dedicated services image build script.
  `880ef548` expands the release-artifact, Dockerfile, workflow, and runtime
  payload checks to fail closed unless the image contains `bus`, `bus-api`,
  `bus-integration`, `bus-services`, `bus-integration-services`, and
  `bus-integration-events`. Supervisor review reran
  `sh -n scripts/build-ssh-docker-services-image.sh` and
  `docker compose -f compose.yaml --profile services-runtime config`; both
  passed. This lane is now a review-ready deterministic packaging slice, but it
  is not full goal completion until the docs Compose fixture is checked against
  the same contract and a live dev-hg Docker proof verifies the complete
  single-container stack;
- worker-create/materialization issue:
  replacement worker create requests for
  `services-docker-runtime-image-20260606a` and
  `services-docker-runtime-image-20260606b` returned initial create/requested
  success but did not persist in the worker registry and did not create runtime
  directories. The existing worker-infrastructure lane has been asked to
  diagnose this create/assign/message delivery issue. Until that is fixed or a
  known-good worker creation path is identified, use existing worker-owned
  lanes only and do not create supervisor-owned product worktrees;
- dev-hg Docker proof:
  task `task-d3a8df35767f`. After the foreground and image-packaging lanes
  became review-ready, worker messages `workers-message-1780738990358966975`
  and `workers-message-1780739061977666205` assigned the Docker-capable
  `services-docker-image-20260606f` worker to use its existing worker-owned
  worktree for an integration proof branch, suggested
  `codex/services-docker-full-stack-proof-20260606-worker`. The second message
  routes the proof request on the worker's currently active image task ref so
  it is not missed by task routing. The proof branch must combine the
  review-ready image branch with the review-ready foreground Services submodule
  pointers, consume an accepted checksum-verified Linux amd64 Bus release
  artifact with explicit release identity, build the Ubuntu services image from
  that artifact, run the single-container stack on dev-hg with the root
  `compose.yaml --profile services-runtime` implementation fixture, and report
  exact evidence for process identity, PostgreSQL plus Bus services in one
  container, `bus services ps --format json`, source exclusion, Docker
  stop/SIGTERM behavior, and post-stop status. Supervisor review found the
  first image-worker proof branch attempt invalid: commit `bd58dc08` reset the
  `bus-services` submodule pointer from the required foreground commit
  `f4fd8fc` back to `f0b946d`, and the submodule worktree was not initialized
  well enough for `git -C bus-integration-services rev-parse HEAD` to prove
  the submodule checkout. Worker message `workers-message-1780739187130301060`
  requires a proof-branch fix before any Docker runtime evidence from that
  worker can count. Because the image worker remained stuck, the proof was
  reassigned to the responsive foreground worker with messages
  `workers-message-1780739418983703065`,
  `workers-message-1780739468796838145`, and
  `workers-message-1780739564838661896`. That worker created branch
  `codex/services-docker-full-stack-proof-20260606-foreground-worker` at
  commit `4f707f42`, combining the image packaging slice with
  `bus-services` `f4fd8fc` and `bus-integration-services` `378c4f3`.
  Initial supervisor review verified those two service submodule pointers, but
  a later poll found the proof worktree is not clean: the `bus` submodule tree
  expects `1ba26c5`, the checkout is at `a17beff`, and the submodule contains
  deleted files. No release artifact, image build, Compose run, or runtime
  proof has been accepted yet. The worker did attempt a proof and built image
  `bus-services:proof`, but runtime review found concrete product blockers:
  the entrypoint passes `--state-dir` while `bus-services` rejects that flag,
  the baked `services.yml` declares `.env` but the runtime image does not create
  `/opt/bus/.env`, and the stack requires runtime-only
  `BUS_EVENTS_JWT_SECRET` plus `BUS_EVENTS_POSTGRES_DSN` values. Manual
  container logs showed `bus-services: unknown flag: --state-dir`, `read env
  file /opt/bus/.env: no such file or directory`, and `service events:
  runtime.env BUS_EVENTS_JWT_SECRET references missing .env key
  BUS_EVENTS_JWT_SECRET`. The worker-created proof tarball was also malformed:
  `scripts/build-ssh-docker-services-image.sh` reported `release artifact is
  missing executable bus`, so the artifact does not extract the required
  binaries at archive root. Worker messages `workers-message-1780740190188150065`,
  `workers-message-1780740274247094666`, and
  `workers-message-1780740410325673381` ask the foreground proof worker to
  restore the dirty submodule state, implement `--state-dir`, generate or
  provide runtime-only container env without baking secrets, fix release
  artifact layout, and rerun the release-artifact/image/Compose proof. A later
  supervisor review found uncommitted worker progress in that worktree:
  `bus-services` parses and plumbs `--state-dir`, the entrypoint generates
  `/opt/bus/.env`, and a locally created
  `release-artifacts/busdk-services-linux-amd64.tar.gz` extracts the six
  required binaries at archive root with a passing checksum. The patch is not
  accepted because it remains uncommitted, the image built from it still lacks
  the final `BUS_SERVICES_BUS_DIR`/secret-file permission fix, and no live
  Compose runtime proof has been reported. After the supervisor stopped and
  resumed `services-docker-foreground-20260606f` to refresh its stale App
  Server process, the worker entered `failed`/`resume` with `last_error`:
  `direct runtime process is not visible: 1761411`;
- fresh proof-fix worker:
  `services-docker-proof-fix-20260606h`, task `task-d3a8df35767f`, branch
  `codex/services-docker-proof-fix-20260606h`, worktree
  `.bus/services/workers/runtime/services-docker-proof-fix-20260606h/product-worktree`.
  This worker was created by the worker infrastructure after the earlier
  materialization failures and did create a worker-owned worktree and direct
  App Server. However, two turns completed without assistant output or diffs.
  The worker session file records the precise reason: the configured worker
  model `gpt-5.3-codex-spark` hit its primary rate limit at 100% usage, with
  reset at `2026-06-06 13:39:32 UTC` (`2026-06-06 16:39:32 EEST`). The remote
  config currently defines `codex-spark` as the worker profile for dev-hg, so
  there is no accepted alternate worker model in this goal state. Resume the
  proof through this worker or another worker-owned lane after model capacity
  is available, or first add an approved alternate worker profile.

Worker infrastructure repair is tracked on `coding-agent@dev.hg.fi` as task
`task-2a0f290b4e81` and worker `worker-websocket-policy-20260606a`, branch
`codex/worker-websocket-policy-20260606`, worktree
`.bus/services/workers/runtime/worker-websocket-policy-20260606a/product-worktree`.
That worker proved direct-exec shell tool calls can run in a worker-owned
worktree and now has review-ready superproject commit `57fe2cfe`, pinning
`bus-agent` commit `c305b14` and `bus-integration-worker` commit `28e919a`.
The reviewed patch propagates writable roots, sandbox mode, and approval policy
into direct App Server WebSocket turns. Targeted `go test` runs passed for the
affected `bus-agent/appserver` and
`bus-integration-worker/pkg/workersintegration` tests. The branch is not merged
or promoted; merge requires operator confirmation. Follow-up infrastructure task
`task-91b6d590140a` was created and assigned to
`worker-websocket-policy-20260606a` as
`workers-message-1780739722732731619` to diagnose why accepted worker proof
messages are not reliably visible in `bus workers messages` output or driving
turn execution, and to identify the safest worker-owned path to resume the
Docker proof. Because that infrastructure worker also remained on its earlier
active task, the same diagnosis was routed to its active task as
`workers-message-1780739906160505104`, including the dirty `bus` submodule
evidence from the foreground proof branch.

Do not treat the Services Docker product implementation as blocked on systemd.
Do not mark the worker implementation lanes complete until their review
findings are resolved and a dev-hg Docker proof verifies the single-image
runtime.

## Current Supervisor Review

As of 2026-06-06, the active implementation lane is worker-owned:

```text
worker:   services-docker-proof-fix-20260606i
task:     task-d3a8df35767f
branch:   codex/services-docker-proof-fix-20260606i
worktree: coding-agent@dev.hg.fi:.bus/services/workers/runtime/services-docker-proof-fix-20260606i/product-worktree
model:    gpt-5.4
```

That worker produced superproject commits `7fdf04c4`, `eba3b997`,
`465bb317`, `b91e33ac`, `479a651c`, `163f7879`, and `3af5f8ac`;
`bus-services` commits `6ef942d`, `3ea30b1`, and `323d991`;
`bus-integration-services` commits `3bfe04d`, `7441bff`, and `5995871`; and
`bus` commit `b1ed66d`.
Supervisor review has independently verified:

- the worker-created branch exists and is the only product implementation lane
  currently under review;
- the worker-owned superproject worktree and the affected submodule checkouts
  are clean after superproject commit `3af5f8ac`;
- `go test ./cmd/bus-services` passes in the worker-owned `bus-services`
  checkout;
- `sh -n` passes for the services entrypoint and image build script;
- `tests/superproject/test_services_runtime_image_config.sh` passes on
  `coding-agent@dev.hg.fi`;
- `git diff --check HEAD~1..HEAD`, `docker compose -f compose.yaml --profile
  services-runtime config`, and
  `tests/superproject/test_services_runtime_image_config.sh` pass in the
  worker-owned worktree after commit `163f7879`;
- the docs fixture
  `docs/docs/goals/services-docker/compose.yml` parses successfully on
  `coding-agent@dev.hg.fi` when copied to
  `/tmp/services-docker-goal-compose.yml`;
- Docker on `coding-agent@dev.hg.fi` reports Docker `29.5.2` and Compose
  `5.1.4`;
- the accepted final release artifact in the worker proof is
  `busdk-v0.0.80+task.d3a8df35767f-Linux-amd64.tar.gz`, checksum
  `c6c668fe247062bb8c93970d31f65b138e63ba8ad8a82a98235e0413abbbc406`;
- the accepted final proof image `bus-services:task-d3a8df35767f` exists on
  `coding-agent@dev.hg.fi` with image id
  `sha256:299b7ce8d056dd579779d99cdaba03d27001e531e2892737d73ad22b45261436`;
- the image labels include
  `org.opencontainers.image.version=v0.0.80+task.d3a8df35767f` and
  `io.busdk.release.sha256=c6c668fe247062bb8c93970d31f65b138e63ba8ad8a82a98235e0413abbbc406`;
- `/usr/local/bin/bus --version` and
  `/usr/local/bin/bus-services --version` inside the image both report
  `v0.0.80+task.d3a8df35767f`;
- the root Compose proof starts a single container that runs PostgreSQL plus
  `events`, `tasks`, `repos`, `workers`, `api`, and `events-relay`;
- `bus services ps --file /opt/bus/services.yml --profile-dir
  /opt/bus/profiles --state-dir /var/lib/bus/services --format json` reports
  all seven services running while the container is up and all seven services
  exited after Docker stop;
- source/toolchain exclusion checks pass for the runtime image;
- cleanup removed the proof containers and `bus-services-proof` volumes.
- commit `163f7879` fixes the previously reopened release workflow and root
  Compose profile gaps by passing `RELEASE_VERSION` and `RELEASE_SHA256` to
  the final publish-image build, and by aligning `compose.yaml --profile
  services-runtime` with the documented single-image runtime contract;
- the goal-facing docs fixture live proof succeeded on `coding-agent@dev.hg.fi`
  with the existing proved image and override host ports:
  `BUS_SERVICES_IMAGE=bus-services:task-d3a8df35767f`,
  `BUS_SERVICES_HTTP_PORT=18080`, `BUS_SERVICES_EVENTS_PORT=18081`, and
  `BUS_SERVICES_API_PORT=18090`;
- the docs fixture `docker compose config` rendered the expected container
  targets `8080`, `8081`, and `8090`, and rendered the healthcheck as
  `/usr/local/bin/bus services ps --file /opt/bus/services.yml --profile-dir
  /opt/bus/profiles --state-dir /var/lib/bus/services --format json`;
- the earlier docs fixture `up -d --no-build` proof started one container from
  `bus-services:task-d3a8df35767f`; `docker inspect` reported image id
  `sha256:4c148724f5b41f8bac2a8147805db605f2b54ded4fbdebc4d4d8f9742c56a351`,
  which is now superseded by accepted final image
  `sha256:299b7ce8d056dd579779d99cdaba03d27001e531e2892737d73ad22b45261436`;
- `bus services ps --file /opt/bus/services.yml --profile-dir
  /opt/bus/profiles --state-dir /var/lib/bus/services --format json` inside
  the docs-fixture container reported `count: 7`, with `postgres`, `events`,
  `tasks`, `repos`, `workers`, `api`, and `events-relay` all running;
- process inspection inside the docs-fixture container showed PostgreSQL,
  `/usr/local/bin/bus services up ... --foreground --all`,
  `/usr/local/bin/bus-services up ... --foreground --all`,
  `bus-integration-services serve`, the Bus API services, task/repos/workers
  integrations, and the events relay in the same container;
- `docker compose stop` for the docs fixture left the container `exited 143`;
  a persisted-volume `docker run --entrypoint sh` status check reported the
  same seven services all `exited`;
- `docker compose down -v --remove-orphans` for the docs fixture completed,
  `docker compose ps -a` returned empty, and no
  `services-docker-docs-proof_` volumes remained.

A stricter completion audit then reopened two product gaps. A focused
`services-docker-audit-proof` run on `coding-agent@dev.hg.fi` used the same
proved image and override host ports, reached Docker `healthy`, and reported
all seven services running. After PostgreSQL was terminated inside the
container without stopping Compose, later status evidence showed `tasks` as
`exited`, but Docker health remained `healthy` because the configured
healthcheck command, `bus services ps --format json`, still exited `0`.
Worker message `workers-message-1780745861471919519` reopened the active
worker branch to fix the healthcheck contract.

The worker fixed that specific healthcheck defect in `bus-services` commit
`323d991` by making JSON `ps` return non-zero when the stack is degraded. A
superseded intermediate proof image proved the health transition: after
PostgreSQL was killed, Docker health moved from `healthy` to `unhealthy` while
the container stayed `running`, and `bus services ps --format json` returned
exit code `1` while preserving the JSON payload. That image is not the accepted
final artifact because the later secret-safety audit found another defect.

The same audit found a separate secret-safety defect: the runtime marker value
appeared in the frozen env snapshot under `/var/lib/bus/services`. The worker
then committed `bus-integration-services` commit `3bfe04d` to redact secrets
from frozen services env snapshots. Two superseded intermediate rebuilds did
not prove completion: before any intentional service kill, Docker health
remained in startup failure and `bus services ps --format json` reported
`tasks`, `repos`, and `workers` as `exited` while `postgres`, `events`, `api`,
and `events-relay` were still running. Process inspection showed the exited
services as defunct child processes. Non-secret child logs showed Events
returning `503` because connection information contained a redacted value, and
`config-source.json` inside the container showed `frozen_file` still pointing
at `/var/lib/bus/services/config-snapshot/services.yml` with no private
`runtime_path`. Worker messages `workers-message-1780746663646240071` and
`workers-message-1780747083938632255` reopened the branch again to launch from
an unredacted private runtime copy while keeping the persisted
`config-snapshot` redacted for public/status/log inspection.

The final accepted worker candidate adds a focused
`TestPrepareStackConfigUsesPrivateRuntimeCopyAndRedactedSnapshot` assertion in
`bus-integration-services` and produced the accepted final image and release
artifact listed above. Supervisor review has verified the candidate baseline on
`coding-agent@dev.hg.fi`: Docker health reached `healthy`, `bus services ps
--format json` reported all seven services running, `config-source.json`
reported `frozen_file` and `runtime_path` under a private
`/tmp/bus-services-runtime-config-*` directory, `snapshot_path` remained
`/var/lib/bus/services/config-snapshot`, and the persisted public/status/log
marker scan returned `marker-not-found`.

The worker then completed the reopened degraded-health proof. A clean
`services-docker-audit-proof` Compose run reached a healthy seven-service
baseline, then `kill -KILL 57` terminated the PostgreSQL master. Docker health
transitioned from `healthy running` to `unhealthy running` on the twelfth
5-second check while the container stayed up. `bus services ps --format json`
returned exit code `1` and preserved degraded JSON: `postgres`, `tasks`,
`repos`, and `workers` were `exited`, while `events`, `api`, and
`events-relay` remained `running`. Raw Docker health reported
`Status: unhealthy`, `FailingStreak: 7`, healthcheck `ExitCode: 1`, and output
including `bus-services: services stack is degraded`. Post-fault public-surface
marker scan again returned `marker-not-found`.

The worker cleaned proof resources after the fault proof:
`docker compose -p services-docker-audit-proof -f /tmp/services-docker-goal-compose.yml
ps -a` returned empty, and no `services-docker-audit-proof_` volumes remained.
The worker moved generated `release-artifacts/` and `dist-bin/` out of the
worktree to `/tmp/task-d3a8df35767f-artifacts/` and committed the final
`bus-integration-services` assertion plus the superproject gitlinks.

The implementation and proof branch is review-accepted for this goal's product
contract, but it is not merged, promoted, or released. Do not merge or promote
it without operator confirmation.

## Requirement Audit

Current audit result: the worker branch satisfies the product and proof
requirements for the single-container Docker runtime, but the goal is not
complete in the main line because the accepted branch has not been merged,
promoted, or released.

Verified satisfied on worker branch `codex/services-docker-proof-fix-20260606i`:

- single Ubuntu-based image: proved by the Services runtime image build and
  final image id
  `sha256:299b7ce8d056dd579779d99cdaba03d27001e531e2892737d73ad22b45261436`;
- full repository `services.yml` stack: proved by live `bus services ps
  --format json` reporting all seven stack services, `postgres`, `events`,
  `tasks`, `repos`, `workers`, `api`, and `events-relay`;
- PostgreSQL in the same container, not a Compose sidecar: proved by process
  inspection and the `postgres/native` service status in the same container;
- Bus Services as supervisor: proved by the container command path
  `/usr/local/bin/bus services up --file /opt/bus/services.yml --profile-dir
  /opt/bus/profiles --state-dir /var/lib/bus/services --foreground --all`;
- binary-release runtime: proved by release artifact
  `busdk-v0.0.80+task.d3a8df35767f-Linux-amd64.tar.gz`, checksum
  `c6c668fe247062bb8c93970d31f65b138e63ba8ad8a82a98235e0413abbbc406`, image
  labels, and in-container binary version output;
- no source/runtime toolchain payload: proved by source/toolchain exclusion
  checks recorded in supervisor review;
- root Compose implementation profile and docs Compose fixture: both parse and
  have live proof against the single-image contract;
- foreground and Docker stop behavior: proved by Docker stop leaving the
  container exited and persisted status reporting the seven services exited;
- required-service failure health behavior: proved by SIGKILL of PostgreSQL
  causing `bus services ps --format json` to exit `1` with degraded JSON and
  Docker health to become `unhealthy` while the container stayed running;
- secret safety for runtime snapshots and public surfaces: proved by the
  private runtime config path, redacted state-dir snapshot path, and repeated
  `marker-not-found` scans after baseline and fault proof;
- worker-owned branch/worktree requirement: satisfied by worker
  `services-docker-proof-fix-20260606i`, task `task-d3a8df35767f`, branch
  `codex/services-docker-proof-fix-20260606i`, and its worker-owned worktree on
  `coding-agent@dev.hg.fi`.

Remaining completion step:

- operator confirmation is required before merging, promoting, or releasing
  the review-accepted worker branch and submodule pins.

Promotion checklist after operator confirmation:

1. Recheck the worker-owned superproject and affected module worktrees are
   clean:

   ```bash
   git status --short --branch
   git -C bus status --short --branch
   git -C bus-services status --short --branch
   git -C bus-integration-services status --short --branch
   ```

2. Push or otherwise make reviewable the accepted local worker branch refs
   before merging. Current worker-local refs are:

   ```text
   busdk superproject:       codex/services-docker-proof-fix-20260606i -> 3af5f8ac
   bus:                      codex/services-docker-proof-fix-20260606i -> b1ed66d
   bus-services:             codex/services-docker-proof-fix-20260606i -> 323d991
   bus-integration-services: codex/services-docker-proof-fix-20260606i -> 5995871
   ```

3. Promote in dependency order: merge or fast-forward the affected module
   branches first, then update and merge the BusDK superproject pin commit
   `3af5f8ac`, then update any outer supervisor submodule pointer if required
   by the repository hierarchy.

4. Rerun the goal-level smoke after promotion using the promoted branch or
   release image: Compose config for both fixtures, image release-label check,
   seven-service healthy baseline, source/toolchain exclusion, Docker stop
   status, required-service degraded-health check, and Docker resource cleanup.

5. Only after those promoted-state checks pass, mark this goal complete.

## Completed Implementation Slices

The accepted worker branch completed the implementation slices originally
planned for this goal:

1. Release bundle definition and build support for the repository stack,
   including the dispatcher, `bus-services`, `bus-integration-services`, and
   service binaries required by the current profiles.

2. Ubuntu single-image runtime packaging that installs PostgreSQL, copies
   verified Bus release binaries, copies `services.yml`, copies `profiles/`,
   sets runtime directories, and defines the `bus services up` entrypoint.

3. Foreground Services behavior for container execution, including state-dir
   support, required-service degraded status, JSON healthcheck behavior, Docker
   stop handling, and status after shutdown.

4. Container-safe `postgres/native` runtime behavior that starts PostgreSQL in
   the same container and uses mounted state/data paths rather than host
   systemd.

5. Deterministic image and fixture checks for release checksum identity, source
   exclusion, binary identity, stack/profile presence, and Compose config
   parsing.

6. Live dev-hg proof from a worker-owned implementation worktree and branch,
   including healthy baseline, process inspection, `bus services ps`, Docker
   stop, required-service degraded-health behavior, secret-safety scan, and
   Docker resource cleanup.

## Verification Requirements

Minimum deterministic coverage:

- Dockerfile or image build definition uses a pinned Ubuntu base image;
- build consumes verified Bus binary release artifacts;
- runtime image does not contain source code, `.git`, or the Go toolchain;
- runtime image contains `/opt/bus/services.yml`;
- runtime image contains `/opt/bus/profiles`;
- baked stack matches the repository `services.yml` used for the release;
- `docker compose -f docs/docs/goals/services-docker/compose.yml config`
  succeeds for the goal-facing fixture;
- `docker compose -f compose.yaml --profile services-runtime config` succeeds
  for the implementation/CI fixture;
- `bus services up` stays in the foreground when used as the container command;
- PostgreSQL starts inside the same container and uses the mounted data volume;
- Bus services start in dependency order from the baked stack;
- `bus services ps --format json` reports all required services;
- Docker health check fails on required-service failure;
- `SIGTERM` from Docker stop causes graceful shutdown;
- stale pid/status files do not claim running services after shutdown;
- logs and frozen stack state do not contain secrets.

Minimum live proof on `coding-agent@dev.hg.fi`:

- create a worker-owned implementation worktree and feature branch before
  remote mutation;
- record Docker and Compose versions;
- build the Ubuntu runtime image from release artifacts;
- run `docker compose -f docs/docs/goals/services-docker/compose.yml up` for
  the goal-facing fixture. A root-profile run such as
  `docker compose -f compose.yaml --profile services-runtime up
  bus-services-runtime` is useful packaging evidence, but it is not sufficient
  for goal completion unless the docs fixture is also run or explicitly updated
  to the same contract and then run;
- confirm the container command is `bus services up`;
- confirm PostgreSQL and all Bus services from repository `services.yml` run
  as processes inside the same container;
- confirm `bus version` reports the expected binary release identity;
- confirm no source checkout, `.git`, Go source files, or Go toolchain exist
  in the runtime container;
- confirm `bus services ps --format json` reports running required services;
- stop the Compose project through Docker;
- confirm child processes are stopped and status is clean;
- record every manual workaround as a defect or follow-up.

## Suggested Commands For A Future Implementation Thread

Inspect module state from the BusDK superproject root:

```bash
git status --short
git -C bus-services status --short
git -C bus-integration-services status --short
git -C bus-integration-postgres status --short
git -C bus-operator-deploy status --short
git -C docs status --short
```

Check the baked-stack inputs:

```bash
test -f services.yml
test -d profiles
bus services stack validate --file services.yml --profile-dir profiles --all
```

Check Docker availability on the proof host:

```bash
ssh coding-agent@dev.hg.fi \
  'docker version --format "client={{.Client.Version}} server={{.Server.Version}}"; docker compose version --short'
```

Check the Compose fixture:

```bash
docker compose -f docs/docs/goals/services-docker/compose.yml config
docker compose -f compose.yaml --profile services-runtime config
```

Run live proof only after implementation and deterministic tests pass. Do not
run a mutating remote proof from the primary checkout. Create or use a Bus
Worker-owned worktree and branch first, then record the worker id, branch,
worktree path, and task ref in this goal or in the implementation handoff.

## Current State At Handoff

The active implementation lane is `services-docker-proof-fix-20260606i` on
`coding-agent@dev.hg.fi`, task `task-d3a8df35767f`, branch
`codex/services-docker-proof-fix-20260606i`, with a worker-owned worktree under
`.bus/services/workers/runtime/services-docker-proof-fix-20260606i/product-worktree`.
The worker has proved a single Ubuntu image running the full repository
`services.yml` stack with PostgreSQL and Bus services in one container, using a
checksum-verified release artifact whose `bus` and `bus-services` binaries
report `v0.0.80+task.d3a8df35767f`.

The previously open release workflow, root Compose alignment, and live
docs-fixture proof gaps are resolved on the worker branch. A stricter
completion audit reopened the Docker healthcheck failure requirement, and the
worker fixed that specific defect in `bus-services` commit `323d991`. The same
audit then found a secret persistence defect in the frozen env snapshot. The
worker's first redaction fix, `bus-integration-services` commit `3bfe04d`, and
its first runtime/snapshot split follow-up, commit `7441bff`, broke baseline
startup in rebuilt images by leaving `tasks`, `repos`, and `workers` exited
before any intentional kill. A later candidate image
`sha256:299b7ce8d056dd579779d99cdaba03d27001e531e2892737d73ad22b45261436`
fixes that startup/redaction split in live proof: the stack reaches healthy
with all seven services running, `config-source.json` points runtime launch at
a private `/tmp/bus-services-runtime-config-*` copy, and the redacted
state-dir snapshot no longer persists the audit marker. The worker completed
the remaining degraded-health proof on the same image: after SIGKILL of the
PostgreSQL master, `bus services ps --format json` exited `1` with degraded
JSON, Docker health became `unhealthy` while the container remained `running`,
and a second marker scan still returned `marker-not-found`. Docker proof
resources were cleaned, generated build artifacts were moved out of the
worktree, and the superproject is clean at commit `3af5f8ac`, pinning
`bus-integration-services` `5995871` and `bus-services` `323d991`.

The branch is not merged, promoted, or released; do not merge or promote it
without operator confirmation.
