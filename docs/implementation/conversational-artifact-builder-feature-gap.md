---
title: "Conversational artifact builder feature gap"
description: "Concrete BusDK software features needed to turn a chat request into a paid, public-safe runnable web or binary artifact."
---

## Conversational artifact builder feature gap

The target product is a public web experience where a visitor describes a
small software tool in chat, BusDK turns that request into a runnable web app
or downloadable binary, and the customer receives the artifact without seeing
or receiving source code. The product does not need access to a customer Git
repository. The first implementation can use one Bus-controlled template
repository, create one branch per customer build run, assign Bus workers to
that branch, verify the produced artifact, and publish only the runnable
artifact and safe evidence.

BusDK already has most of the underlying infrastructure. The missing work is a
product-specific build-run layer that connects the existing modules end to end.

## Existing module fit

| Module family | Existing useful capability | Product gap |
| --- | --- | --- |
| `busdk.com` | Public static site with product positioning, pricing/contact sections, and commercial page ownership. | Add the public entry point for the artifact builder offer and link it to the chat/build application. |
| `bus-portal` | Frontend host for portal modules, browser-facing configuration, module mounting, and safe separation from backend business logic. | Host a simple chat module, but keep build orchestration, artifacts, billing, and worker control in API providers. |
| `bus-portal-ai` | Existing browser AI module with chat and terminal surfaces backed by LLM, billing, container, terminal, and theme API URLs. | Current chat is generic LLM chat, not a build-run conversation. It lacks run status, artifact delivery, build messages, and public-safe evidence. |
| `bus-api` | Provider host, route configuration, OpenAPI shape, and capability-aware API boundary. | Mount build-run, artifact, task, worker, repo, billing, and auth providers as one product API. |
| `bus-task` and `bus-api-provider-task` | Generic task threads, task messages, task status, replay, and HTTP routes. | Use as the internal conversation/task substrate, but add customer-facing build-run semantics above it. |
| `bus-worker`, `bus-api-provider-worker`, `bus-integration-worker` | Worker creation, assignment, messages, status, worktree refs, direct-plan, direct-exec, branch selection, and Codex App Server execution. | Add a product worker profile and orchestration policy that turns a build spec into a verified artifact, not just a worker conversation. |
| `bus-repos`, `bus-api-provider-repos`, `bus-integration-repos` | Repo plan/ensure/status contracts and Git-backed worktree creation for preconfigured local repositories. | Configure one controlled template repository and enforce branch-per-run naming, cleanup, and no-source delivery policy. |
| `bus-events` | Durable event substrate, replay/follow, export/import/sync, scoped metadata, and evidence streams. | Define build-domain events and a public-safe progress projection. |
| `bus-api-provider-billing`, `bus-integration-billing`, `bus-integration-stripe` | Billing status, checkout session, portal session, entitlement checks, quotas, Stripe checkout, Stripe webhooks, and usage export. | Map a paid build run to checkout metadata, webhook fulfillment, run activation, and optional credits or quotas. |
| `bus-api-provider-auth` | Registration, OTP, waitlist approval, scoped JWTs, and internal service tokens. | Add or configure a low-friction visitor session and email capture flow for public build conversations. |
| `bus-services` | Starts service stacks from `services.yml` and can group Events, API, Repos, Workers, Tasks, and billing services. | Add a named artifact-builder stack with readiness checks and documented local/demo deployment. |
| `bus-api-provider-llm` and `bus-integration-codex` | OpenAI-compatible model API and Codex-backed LLM execution behind Bus APIs. | Support the chat/intake assistant, but do not let generic chat be the product boundary. |
| `bus-attachments` | Evidence file metadata, checksums, and attachment records. | Useful as an internal evidence reference, but public artifact download needs a dedicated artifact delivery contract. |

## Required software features

### 1. Build-run domain module

Owner: new `bus-build` module or equivalent shared package.

Add a shared build-run contract used by the portal module, API provider,
integration worker, tests, and CLI/debug tooling. The contract should define
the build run id, customer/session identity, requested artifact type, lifecycle
phase, linked task ref, linked worker id, repo id, branch, artifact manifest,
checkout/payment status, and public-safe status message.

Required lifecycle phases:

| Phase | Meaning |
| --- | --- |
| `drafting` | Visitor is still describing the requested tool. |
| `quoted` | The system has enough information to explain scope, price, and delivery expectation. |
| `authorized` | Free trial, manual approval, or paid checkout allows work to start. |
| `repo_ready` | The template repository branch/worktree exists. |
| `worker_running` | A worker has accepted the build task. |
| `artifact_pending` | Worker claims implementation is complete and artifact verification is running. |
| `artifact_ready` | Verified artifact is available for preview or download. |
| `delivered` | Customer received the artifact link. |
| `failed` | Run stopped with a customer-safe reason and internal evidence. |

Definition of done: one package exposes typed request, response, lifecycle,
artifact, and event structures; every build run can be serialized as JSON
without exposing source paths or secrets.

### 2. Build API provider

Owner: new `bus-api-provider-builds`.

Add customer-facing HTTP routes for the chat product. The provider should own
the public build-run API and call or publish to Tasks, Workers, Repos, Billing,
Artifacts, and Events behind that boundary.

Minimum routes:

| Route | Purpose |
| --- | --- |
| `POST /api/v1/build-runs` | Start a new visitor/customer build run. |
| `GET /api/v1/build-runs/{run_id}` | Return the public-safe build-run state. |
| `POST /api/v1/build-runs/{run_id}/messages` | Add a customer chat message. |
| `GET /api/v1/build-runs/{run_id}/events` | Stream or poll public-safe progress events. |
| `POST /api/v1/build-runs/{run_id}/checkout` | Create a checkout session or payment authorization for the run. |
| `GET /api/v1/build-runs/{run_id}/artifacts` | List verified artifacts. |
| `GET /api/v1/build-runs/{run_id}/artifacts/{artifact_id}/download` | Download a verified artifact. |

Definition of done: a browser client can create a run, chat, receive progress,
pay or receive manual authorization, and download an artifact using only this
API surface.

### 3. Build integration worker

Owner: new `bus-integration-builds`.

Add the event-driven orchestrator that turns a build run into internal Bus
work. It should subscribe to build-run events, create or update a task thread,
ensure the template repo branch, create a worker, send the worker assignment,
watch worker messages/status, run artifact verification, publish public-safe
progress, and close or fail the run.

The integration should publish build-domain events such as:

| Event | Purpose |
| --- | --- |
| `bus.build.run.requested` | New run created. |
| `bus.build.message.added` | Customer supplied more requirements. |
| `bus.build.quote.ready` | Scope and price can be shown. |
| `bus.build.run.authorized` | Payment/manual approval permits work. |
| `bus.build.repo.ready` | Branch/worktree prepared. |
| `bus.build.worker.assigned` | Worker id and task ref attached. |
| `bus.build.progress.updated` | Customer-safe progress update. |
| `bus.build.artifact.submitted` | Worker produced a candidate artifact manifest. |
| `bus.build.artifact.verified` | Artifact passed verification. |
| `bus.build.run.failed` | Run failed with customer-safe reason. |

Definition of done: a build run can proceed from chat to verified artifact
without the portal directly calling worker, repo, or task internals.

### 4. Conversational build portal module

Owner: new `bus-portal-build` module, or a build-specific submodule inside
`bus-portal-ai` if speed is more important than separation.

Create a simple public chat surface. It should not expose terminal access,
source code, raw worker logs, branch paths, or complex controls. The UI should
show the conversation, a concise scope summary, payment/authorization state,
progress messages, preview links, and download links.

Definition of done: the first screen is chat; a visitor can describe the tool,
answer clarifying questions, approve scope, pay or request approval, and later
receive a working preview/download without leaving the conversation.

### 5. Template repository and branch policy

Owner: `bus-repos`, `bus-integration-repos`, `bus-integration-worker`, and the
new build orchestrator.

Configure one Bus-controlled template repository for the first product. The
template should contain a small Go web/binary application skeleton, build
commands, artifact manifest rules, and worker instructions. Each customer run
creates a branch from a stable base ref.

Recommended branch shape:

`build/{YYYYMMDD}/{run_id}`

Required policy:

- one branch per build run;
- branch names are generated by the build orchestrator, not by the customer;
- the public API never returns worktree paths or source URLs;
- failed runs keep internal evidence but do not publish source;
- cleanup/pruning policy is explicit before production use.

Definition of done: `bus-integration-repos` can ensure the configured template
repository branch, and `bus-integration-worker` can run a direct-exec worker
against that branch without assuming a customer repository.

### 6. Worker build profile

Owner: `bus-integration-worker`, worker identity repository, and the template
repository.

Add a persistent worker profile for artifact building. The worker profile must
translate the chat-derived build spec into an implementation, run the template
build commands, create an artifact manifest, and report only safe progress.

The worker assignment should include:

- build run id;
- task ref;
- branch;
- requested artifact type: web app, binary, or both;
- required build commands;
- artifact manifest path;
- verification commands;
- explicit rule that source code is not returned to the customer;
- concise customer-facing progress style.

Definition of done: creating a worker with this profile on a run branch
produces either a manifest-valid artifact or a specific failure reason.

### 7. Artifact manifest and public artifact delivery

Owner: new artifact surface inside `bus-api-provider-builds`, or a separate
`bus-api-provider-artifacts` if artifact delivery will be reused broadly.

Add a manifest format that the worker writes and the build orchestrator
verifies. The manifest is the boundary between source work and customer
delivery.

Minimum manifest fields:

| Field | Purpose |
| --- | --- |
| `artifact_id` | Stable id within the build run. |
| `kind` | `web`, `binary`, `archive`, `evidence`, or `log`. |
| `name` | Customer-facing name. |
| `path` | Internal artifact path, never returned directly to public clients. |
| `sha256` | Content hash. |
| `size_bytes` | Download size. |
| `platform` | Optional binary platform, such as `darwin-arm64` or `linux-amd64`. |
| `entrypoint` | Optional web entry file or binary name. |
| `source_included` | Must be `false` for customer-delivered artifacts in this product. |

Definition of done: the API serves immutable artifact downloads by run id and
artifact id, validates checksums, blocks source archives, and avoids directory
listing or arbitrary file reads.

### 8. Web preview hosting

Owner: `bus-api-provider-builds`, `bus-portal-build`, and optionally existing
container/static hosting providers.

For web artifacts, add a preview URL that loads the built app in the browser
without showing source. The fastest first version can serve a static build
directory under a signed or session-protected preview URL. A later version can
run containerized previews when the artifact needs a backend process.

Definition of done: a verified web artifact can be opened from the chat
transcript, renders in a browser, uses correct MIME types, and cannot browse
outside the artifact directory.

### 9. Binary build and download path

Owner: template repository, build orchestrator, and artifact provider.

Add template build targets for downloadable binaries. The first version can
support one platform, then expand to multiple platforms. Each binary must be
listed in the artifact manifest with platform, size, hash, and customer-facing
filename.

Definition of done: a build run can produce at least one downloadable binary
artifact, and the customer can download it without receiving source code.

### 10. Verification and acceptance gate

Owner: new `bus-build` or `bus-integration-builds`, with optional CLI command
for local review.

Do not let a worker directly publish artifacts. Add a verification step that
checks the manifest, file existence, checksums, source-exclusion policy, build
logs, and basic runtime smoke proof. For web previews, verification should
open or request the built page and confirm it returns a non-empty response. For
binaries, verification should run a safe `--help`, `version`, or smoke command
when available.

Definition of done: only artifacts that pass verification become visible to
the customer. Failed verification produces a new worker message or a failed
build-run event with an internal reason and a customer-safe summary.

### 11. Billing and run activation

Owner: `bus-api-provider-billing`, `bus-integration-billing`,
`bus-integration-stripe`, and `bus-api-provider-builds`.

Use the existing billing system, but add build-run fulfillment semantics. The
checkout request must carry the build run id in metadata or a provider-neutral
fulfillment reference. Stripe webhook handling must publish or trigger a Bus
event that marks the run as authorized. The build provider should also support
manual approval for the first pilots, so a human can authorize a run without
pretending that the full billing automation is finished.

Definition of done: payment or manual approval causes exactly one build run to
move from `quoted` to `authorized`, and duplicate webhooks do not start
duplicate workers.

### 12. Visitor session and lead capture

Owner: `bus-api-provider-auth`, `bus-portal-build`, and
`bus-api-provider-builds`.

The product starts with no leads, so the chat must create value before asking
for heavy registration. Use an anonymous or lightweight session for the first
messages, then request email when the system can show a concrete scope summary
or preview quote.

Definition of done: the system can resume a run by signed session or email
login, and every paid/authorized run has a contact address without exposing
private customer data in public events.

### 13. Public-safe progress projection

Owner: `bus-integration-builds` and `bus-api-provider-builds`.

Workers and repositories produce internal details that customers should not
see. Add a build-run projection that converts internal Events, task messages,
worker messages, and verification results into safe progress updates.

Allowed public progress examples:

- "I have enough detail to create the first version."
- "The build worker is implementing the web app."
- "The artifact is being verified."
- "The preview is ready."
- "The build failed during verification; the run has been returned for repair."

Definition of done: the public API never emits raw terminal output, source
diffs, worktree paths, internal branch paths beyond a harmless run id, secrets,
model traces, or unreviewed worker logs.

### 14. Artifact-builder service profile

Owner: `bus-services`.

Add a named service stack for this product. The stack should include Events,
API, Tasks, Workers, Repos, Billing, Auth, the build provider, the build
integration, the portal, and the configured template repository path.

Definition of done: one documented command starts the local/demo stack, one
status command reports readiness, and missing prerequisites are named without
printing secrets.

### 15. Internal operator review surface

Owner: first CLI/debug command in `bus-build` or a small internal portal view.

The public UI should remain chat-only, but BusDK operators need a way to see
run state, internal worker evidence, artifact verification results, and manual
approval controls. This can be a CLI first.

Minimum commands:

| Command | Purpose |
| --- | --- |
| `bus build runs` | List build runs by phase. |
| `bus build show <run_id>` | Show full internal state and linked refs. |
| `bus build approve <run_id>` | Manually authorize a pilot run. |
| `bus build artifacts <run_id>` | Inspect artifact manifests and verification. |
| `bus build retry <run_id>` | Reassign or reopen a failed run. |

Definition of done: the operator can manage the first paid pilot without
inspecting raw databases, event streams, or worktree folders.

## Recommended MVP order

The smallest working path is:

1. Create `bus-build` contracts and `bus-api-provider-builds`.
2. Create one template repository with build commands and artifact manifest.
3. Add `bus-integration-builds` orchestration for manual authorization.
4. Add a build worker profile that can modify the template branch and produce
   a manifest.
5. Add artifact verification and download routes.
6. Add the chat-only `bus-portal-build` module.
7. Add static web preview support.
8. Add a `bus-services` artifact-builder profile.
9. Connect Stripe checkout metadata and webhook activation.
10. Publish the `busdk.com` entry page that links to the chat product.

This order gives a demoable artifact builder before full billing automation.
The first sellable pilot can use manual approval after payment/contact while
the same build-run lifecycle remains the future automated path.

## Feature ownership summary

| Feature | Primary owner | Existing dependencies |
| --- | --- | --- |
| Build-run contracts | `bus-build` | `bus-events`, `bus-task` |
| Customer build API | `bus-api-provider-builds` | `bus-api`, auth, billing, tasks, workers, repos |
| Build orchestration | `bus-integration-builds` | Events, tasks, repos, workers, billing |
| Chat UI | `bus-portal-build` | `bus-portal`, `bus-ui`, build API |
| Marketing entry | `busdk.com` | Build portal URL |
| Template repo branch/worktree | Template repository, `bus-repos`, `bus-integration-repos` | Git repo config |
| Worker execution | `bus-integration-worker`, worker identity repo | Template repo, task ref, branch |
| Artifact manifest and downloads | `bus-api-provider-builds` or `bus-api-provider-artifacts` | Build verification, artifact storage |
| Web preview | Build provider or preview service | Artifact manifest |
| Billing activation | Billing and Stripe modules, build provider | Checkout metadata, webhooks |
| Service stack | `bus-services` | Events, API, providers, integrations |
| Operator controls | `bus-build` CLI or internal portal | Build events/projections |

## What should not be built first

Do not start with a general sales agent. BusDK has no lead database yet, and
the immediate proof problem is not outbound selling. The highest-leverage
agentic feature is the build orchestrator plus worker profile: it lets a
visitor experience BusDK building something useful from chat, then creates a
concrete artifact that can be sold, previewed, and delivered.

Do not expose terminals, source archives, raw worker logs, or customer Git
repository access in the public product. Those are internal operator and
worker concerns. The public proof is the working artifact, the progress
transcript, and the verified download or preview.

## First acceptance test

A credible first acceptance test is:

1. A visitor opens the public chat product and asks for a tiny Go web tool.
2. The system creates a build run and asks one clarifying question.
3. The visitor approves the scope; an operator manually authorizes the run.
4. The build integration creates a branch in the template repository.
5. A worker is created on that branch and receives the build task.
6. The worker produces a web artifact manifest.
7. Verification checks the manifest, checksum, source-exclusion policy, and
   preview response.
8. The visitor receives a preview URL and a downloadable artifact.
9. No source code, worktree path, secret, or raw worker log appears in the
   public UI or artifact download.

Passing this test proves the commercially important claim: BusDK can supervise
agent workers to produce a working software artifact from a conversation,
without needing customer repository access and without exposing source code.

### Sources

- [Developer module workflow](./developer-module-workflow)
- [Repository inventory](../modules/repository-inventory)
- [Workers goal](../goals/workers)
- [Tasks goal](../goals/tasks)
- [Repos goal](../goals/repos)
- [UpCloud and Stripe setup](../integration/upcloud-stripe-setup)
