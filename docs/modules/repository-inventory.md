---
title: BusDK repository inventory
description: Cross-repository map of BusDK modules, support repositories, usual use cases, and internal dependencies.
---

## BusDK repository inventory

BusDK is maintained as a superproject with 133 tracked Git repositories. This
inventory maps those repositories by purpose, usual use case, and internal
BusDK dependencies. "Deps" names direct internal BusDK module imports when
declared; many command-line modules also depend operationally on the top-level
`bus` dispatcher and on installed sibling binaries even when they do not import
them as Go packages.

## Architecture map

BusDK is a modular CLI-first system. The root `bus` binary is intentionally a
minimal dispatcher that runs `bus-<command>` binaries from `PATH`. Most domain
modules own one human-editable workspace dataset or deterministic workflow and
use `bus-data`, `bus-config`, `bus-help`, and `bus-update` as the common data,
configuration, help, and packaging substrate.

The service/runtime side is layered as HTTP API providers, Events contracts,
and integration workers. `bus-api` hosts provider-backed HTTP routes.
`bus-events` is the event envelope and pub/listen/sync CLI. `bus-integration`
is the shared worker runtime for consuming request events and publishing
correlated responses. `bus-api-provider-*` modules validate HTTP requests and
publish/observe events; `bus-integration-*` modules own provider-neutral or
provider-specific execution; `bus-operator-*` modules expose trusted operator
control surfaces.

The browser-facing side is split between shared UI primitives and feature
frontends. `bus-gx` provides a low-level Go/WASM render framework, `bus-ui`
provides reusable deterministic components, `bus-portal` hosts portal modules,
and modules such as `bus-books`, `bus-ledger`, `bus-inspection`, and
`bus-portal-*` compose user-facing workflows while keeping business behavior in
domain modules or API providers.

## Repository summaries

### Entrypoint, docs, identity

- `bus`: top-level BusDK dispatcher. Use it for `bus <command>` routing,
  busfile execution, global flags, `.env` loading, and command discovery.
  Deps: `bus-help`.
- `docs`: generated/public documentation content for docs.busdk.com. Use it to
  publish module docs and references. Deps: none declared.
- `busdk.com`: website repository for the BusDK web presence. Use it for the
  public site separate from module docs. Deps: none declared.
- `sdd`: private/system design document site. Use it for architectural source
  of truth and module SDDs. Deps: none declared.
- `agents/worker`: persistent worker identity repository for BusDK agent
  workers. Use it as the guidance/persona checkout mounted into workers.
  Deps: none declared.
- `aiz`: AI-assisted lossless compression toolchain modeled after gzip/gunzip.
  It is adjacent support tooling rather than a core Bus accounting module.
  Deps: none declared.

### Shared substrate

- `bus-data`: deterministic dataset I/O for CSV, Frictionless Table Schema,
  datapackage metadata, and optional storage backends. Use it as the data layer
  for workspace modules. Deps: `bus-bfl`, `bus-help`, `bus-update`.
- `bus-config`: workspace-level configuration in `datapackage.json`, including
  entity, VAT, fiscal year, reporting, source policy, and metadata profiles.
  Use it for `bus config ...` setup and validation. Deps: `bus-data`,
  `bus-help`, `bus-update`.
- `bus-help`: shared human and machine-readable command help/metadata renderer.
  Use it for `bus help` and module help surfaces. Deps: none declared.
- `bus-update`: installer, package, and version/update surface for BusDK
  components. Use it for workspace/package installation and freshness checks.
  Deps: `bus-help`.
- `bus-configure`: `.env` creation, editing, validation, and diagnostics from
  live module metadata. Use it for local service/worker configuration. Deps:
  `bus-help`.
- `bus-preferences`: user-level namespaced preferences stored outside any
  workspace repository. Use it for defaults such as agent runtime/model. Deps:
  `bus-help`, `bus-update`.
- `bus-secrets`: repository-local encrypted secret references and resolution
  through SOPS envelopes. Use it for `secret:name` workflow values. Deps:
  `bus-help`, `bus-update`.
- `bus-pdf`: deterministic template-based PDF rendering from JSON. Use it for
  audit-friendly document generation without domain logic. Deps: `bus-help`,
  `bus-update`.
- `bus-bfl`: BusDK Formula Language parser, formatter, validator, evaluator,
  and developer CLI. Use it for deterministic computed fields. Deps:
  `bus-data`, `bus-help`, `bus-update`.
- `bus-gx`: low-level GX render tree, source tools, compiler, and Go/WASM DOM
  runtime. Use it to build deterministic Bus frontends. Deps: none declared.
- `bus-ui`: reusable deterministic UI primitives, CSS tokens, form controls,
  sidebar shell, and AI UI components. Use it from WASM/front-end modules.
  Deps: `bus-help`, `bus-update`.
- `bus-lint`: AI-backed linting for docs, READMEs, Go/GX source, guidance, and
  command help. Use it for quality review workflows. Deps: `bus-agent`,
  `bus-help`.
- `bus-faq`: deterministic host-partitioned FAQ serving/generation backed by
  filesystem storage. Use it for cached/auditable FAQ answers. Deps:
  `bus-help`.

### Accounting and workspace domain modules

- `bus-accounts`: chart of accounts as schema-validated CSV, plus
  filing-grade account reports and balance summaries. Use it for account
  master data. Deps: `bus-data`, `bus-help`, `bus-journal`, `bus-update`.
- `bus-attachments`: evidence file storage and attachment metadata. Use it to
  link stable attachment ids into accounting workflows. Deps: `bus-config`,
  `bus-data`, `bus-help`, `bus-update`.
- `bus-assets`: fixed-asset register, depreciation schedules, and
  journal-ready postings. Use it for asset accounting. Deps: `bus-data`,
  `bus-help`, `bus-update`.
- `bus-bank`: bank statement import and deterministic transaction listing. Use
  it before reconciliation or manual journal posting. Deps: `bus-attachments`,
  `bus-config`, `bus-data`, `bus-help`, `bus-update`.
- `bus-balances`: external/manual balance snapshots and conversion into one
  balanced journal transaction. Use it for opening balances or cutover. Deps:
  `bus-accounts`, `bus-config`, `bus-data`, `bus-help`, `bus-journal`,
  `bus-period`, `bus-update`.
- `bus-budget`: budget CSV validation and budget-vs-actual variance from the
  journal. Use it for planning and variance review. Deps: `bus-data`,
  `bus-help`, `bus-update`.
- `bus-customers`: customer registry linked to canonical juridical entities.
  Use it for customer master data. Deps: `bus-data`, `bus-entities`,
  `bus-help`, `bus-update`.
- `bus-debts`: debt-support register for bookkeeping workflows where one
  receipt contains multiple topics/detail lines. Use it for debt evidence
  tracking. Deps: `bus-data`, `bus-help`.
- `bus-entities`: canonical juridical entity registry with stable entity ids.
  Use it as the base registry for customers/vendors and counterparties. Deps:
  `bus-data`, `bus-help`, `bus-update`.
- `bus-files`: filesystem evidence parsing, row extraction, duplicate scans,
  and file assertions. Use it for local evidence-file checks. Deps: `bus-help`.
- `bus-inventory`: inventory items and stock movements as schema-validated
  workspace data. Use it for stock tracking and inventory reports. Deps:
  `bus-config`, `bus-data`, `bus-help`, `bus-update`.
- `bus-invoices`: sales/purchase invoice datasets, import mappings, postings,
  and recurring purchase classification. Use it for invoice management and
  journal posting suggestions. Deps: `bus-config`, `bus-data`, `bus-help`,
  `bus-update`.
- `bus-journal`: authoritative double-entry journal with balanced transaction
  invariants. Use it for postings, opening entries, balances, matching, and
  templates. Deps: `bus-accounts`, `bus-config`, `bus-data`, `bus-help`,
  `bus-period`, `bus-update`.
- `bus-ledger`: read-only deterministic ledger projections over journal and
  metadata. Use it for day book/general ledger views, diagnostics, VAT
  analysis, subledger monitoring, and auditor workflows. Deps:
  `bus-accounts`, `bus-agent`, `bus-attachments`, `bus-config`, `bus-data`,
  `bus-help`, `bus-journal`, `bus-ui`, `bus-update`.
- `bus-loans`: loan master data, event logs, balances, amortization schedules,
  and posting suggestions. Use it for loan support accounting. Deps:
  `bus-config`, `bus-data`, `bus-help`, `bus-update`.
- `bus-memo`: accountant memorandum workflow with MU voucher numbering layered
  over balanced journal rows. Use it for memo vouchers and reviewable
  accounting notes. Deps: `bus-accounts`, `bus-config`, `bus-data`,
  `bus-help`, `bus-journal`, `bus-period`, `bus-update`.
- `bus-payroll`: payroll CSV validation and deterministic double-entry posting
  exports for payruns. Use it for payroll-to-journal workflows. Deps:
  `bus-data`, `bus-help`, `bus-update`.
- `bus-period`: accounting period metadata, close/finalization, carry-forward
  artifacts, and opening-entry support. Use it for fiscal-period lifecycle.
  Deps: `bus-accounts`, `bus-config`, `bus-data`, `bus-help`, `bus-journal`,
  `bus-update`.
- `bus-reconcile`: append-only reconciliation allocations linking bank
  transactions to invoices or journal entries. Use it after bank import. Deps:
  `bus-bank`, `bus-config`, `bus-data`, `bus-help`, `bus-invoices`,
  `bus-journal`, `bus-update`.
- `bus-reports`: trial balance, balance sheet, P&L, and account ledger report
  generation from workspace CSV data. Use it for deterministic accounting
  reports and review. Deps: `bus-accounts`, `bus-agent`, `bus-config`,
  `bus-data`, `bus-help`, `bus-journal`, `bus-period`, `bus-update`.
- `bus-validate`: workspace validator for schemas, CSV constraints, keys, and
  double-entry balance. Use it before reporting, filing, and automation. Deps:
  `bus-accounts`, `bus-attachments`, `bus-bank`, `bus-config`, `bus-data`,
  `bus-help`, `bus-invoices`, `bus-journal`, `bus-update`.
- `bus-vat`: VAT code/rate validation, VAT totals, invoice VAT reconciliation,
  summaries, and export files. Use it for VAT reporting workflows. Deps:
  `bus-data`, `bus-help`, `bus-update`.
- `bus-vendors`: vendor registry linked to canonical juridical entities. Use it
  for vendor master data. Deps: `bus-data`, `bus-entities`, `bus-help`,
  `bus-update`.

### Filing, initialization, replay

- `bus-init`: orchestrates workspace initialization by delegating to
  `bus config init` and domain module `init` commands. Use it for baseline
  workspace creation. Deps: `bus-help`, `bus-update`.
- `bus-filing`: filing-target dispatcher that runs `bus-filing-<target>`.
  Use it as `bus filing <target> ...`; authority-specific logic lives in
  target modules. Deps: `bus-help`, `bus-update`.
- `bus-filing-prh`: deterministic PRH filing bundles from a BusDK workspace.
  Use it for Finnish register filing packages. Deps: `bus-help`, `bus-update`.
- `bus-filing-vero`: deterministic Vero tax filing bundles with manifests and
  checksums. Use it for Finnish tax exports. Deps: `bus-help`, `bus-update`.
- `bus-replay`: deterministic append-only replay logs that reconstruct a
  workspace through CLI operations. Use it for migration, parity testing, and
  reproducibility. Deps: `bus-data`, `bus-help`, `bus-update`.

### Local apps and browser frontends

- `bus-books`: local bookkeeping web UI for periods, journal, VAT, bank,
  attachments, inbox, and optional agent chat. Use it for browser-based books
  management over embedded Bus API. Deps: `bus-agent`, `bus-api`,
  `bus-api-provider-books`, `bus-help`, `bus-update`.
- `bus-sheets`: spreadsheet-style web UI over workspace CSV resources and
  schemas. Use it for browser row/schema editing through embedded `bus-api`.
  Deps: `bus-help`, `bus-update`.
- `bus-chat`: standalone local AI chat UI that hosts the shared `bus-ui` AI
  panel. Use it for workspace-aware chat without ledger/factory panes. Deps:
  `bus-agent`, `bus-help`, `bus-ui`.
- `bus-factory`: local development UI for BusDK module engineering. Use it for
  module authoring/debugging workflows. Deps: `bus-agent`, `bus-help`,
  `bus-run`, `bus-ui`, `bus-update`.
- `bus-gateway`: local auth and module-entry gateway for browser-facing Bus
  modules, including login, sessions, app launcher, proxying, and trusted
  child identity handoff. Use it in front of local web modules. Deps:
  `bus-data`, `bus-help`, `bus-ui`.
- `bus-inspection`: local-first inspection/reporting workflow with customer,
  site, observation, export, photo, and AI config flows. Use it for Finnish
  inspection/customer workflows behind the gateway. Deps: `bus-data`,
  `bus-gateway`, `bus-help`, `bus-ui`, `bus-update`.
- `bus-portal`: generic modular frontend portal host. Use it to mount
  `bus-portal-*` UI modules and serve shared browser configuration. Deps:
  `bus-accounts`, `bus-attachments`, `bus-data`, `bus-help`, `bus-journal`,
  `bus-portal-accounting`, `bus-portal-ai`, `bus-portal-auth`, `bus-ui`,
  `bus-update`.
- `bus-portal-accounting`: accounting-specific portal UI for Finnish customer
  navigation, uploads, evidence packages, and artifact preview/download. Deps:
  `bus-help`, `bus-portal`, `bus-ui`.
- `bus-portal-ai`: portal UI for AI Platform chat and Codex/container terminal
  modes. Deps: `bus-help`, `bus-portal`, `bus-ui`.
- `bus-portal-auth`: portal UI for registration, email OTP login, logout, and
  waitlist/approval status. Deps: `bus-help`, `bus-portal`, `bus-ui`.
- `bus-portal-notes`: Bus Portal UI for browsing, searching, reviewing,
  editing, publishing, and archiving notes. Deps: `bus-help`, `bus-ui`.

### CLI workflow and AI modules

- `bus-agent`: provider-agnostic agent runner and App Server helper for Codex,
  Cursor, Gemini, Claude, and local model workflows. Use it as the shared AI
  runtime library and diagnostic CLI. Deps: `bus-help`, `bus-update`.
- `bus-run`: end-user prompts, pipelines, and scripts through `bus-agent`.
  Use it for user-defined AI workflows. Deps: `bus-agent`, `bus-help`,
  `bus-update`.
- `bus-dev`: developer-only repository helpers, including AI/dev actions. Use
  it for BusDK engineering workflows, not end-user business flows. Deps:
  `bus-agent`, `bus-events`, `bus-help`, `bus-remote`, `bus-update`.
- `bus-shell`: interactive command loop for BusDK. Use it for REPL-style Bus
  command sessions. Deps: `bus-help`, `bus-update`.
- `bus-status`: deterministic workspace readiness and close-state reporting.
  Use it for readiness/status checks. Deps: `bus-containers`, `bus-help`,
  `bus-update`, `bus-vm`.
- `bus-remote-control`: wrapper for starting Codex remote control from the Bus
  dispatcher. Use it for remote-control launch integration. Deps: none
  declared.
- `bus-remote`: non-secret remote platform definitions. Use it for configured
  remote environments and worker targets. Deps: none declared.

### Bus API core and providers

- `bus-api`: local REST JSON API gateway, OpenAPI host, provider loader, and
  event-route bridge. Use it to expose workspace and service operations over
  token-gated HTTP. Deps: many domain/provider modules, including
  `bus-data`, `bus-events`, `bus-integration`, `bus-api-provider-*`, and
  accounting modules.
- `bus-api-provider-auth`: AI Platform auth provider for registration, OTP,
  waitlist/admin approval, and JWT issuance. Use it as the backend auth
  service. Deps: `bus-help`, `bus-update`.
- `bus-api-provider-billing`: provider-neutral Billing API. Use it for billing
  status, setup, portal, entitlements, quotas, and account-scoped billing
  state. Deps: `bus-events`, `bus-help`.
- `bus-api-provider-books`: books/accounting-domain API provider. Use it to
  keep bookkeeping API contracts out of `bus-api` core. Deps: `bus-agent`,
  `bus-help`, `bus-update`.
- `bus-api-provider-cloud`: REST controller for provider-neutral cloud
  operations. Deps: `bus-api-provider-auth`, `bus-help`,
  `bus-integration-cloud`.
- `bus-api-provider-containers`: cloud-neutral container status/run/delete API
  provider. Deps: `bus-api-provider-auth`, `bus-api-provider-usage`,
  `bus-events`, `bus-help`, `bus-integration`, `bus-integration-billing`,
  `bus-integration-usage`.
- `bus-api-provider-data`: reusable data-facing API provider contracts. Deps:
  `bus-help`, `bus-update`.
- `bus-api-provider-database`: REST controller for database provisioning and
  verification. Deps: `bus-api-provider-auth`, `bus-help`,
  `bus-integration-database`, `bus-services`.
- `bus-api-provider-events`: public Bus Events HTTP provider for publish/listen
  APIs. Deps: `bus-api-provider-auth`, `bus-events`, `bus-help`.
- `bus-api-provider-inference`: REST controller for provider-neutral inference
  runtime operations. Deps: `bus-api-provider-auth`, `bus-help`,
  `bus-integration-inference`.
- `bus-api-provider-llm`: OpenAI-compatible `/v1/*` model API with Bus JWT
  verification, backend forwarding, lifecycle events, and usage recording.
  Deps: `bus-api-provider-auth`, `bus-api-provider-usage`,
  `bus-api-provider-vm`, `bus-events`, `bus-help`, `bus-integration`,
  `bus-integration-billing`, `bus-integration-usage`.
- `bus-api-provider-mcp`: MCP-facing capability discovery provider over Bus
  API/files/injected capability documents. Deps: `bus-api-provider-auth`,
  `bus-events`, `bus-help`, `bus-mcp`.
- `bus-api-provider-node`: REST controller for generic node
  bootstrap/status/hardening/verification. Deps: `bus-api-provider-auth`,
  `bus-help`, `bus-integration-node`.
- `bus-api-provider-notes`: Bus Notes API provider, authenticated routes, and
  metadata, delegating business behavior to notes integration. Deps:
  `bus-api-provider-auth`, `bus-data`, `bus-events`, `bus-integration`,
  `bus-integration-notes`, `bus-notes`.
- `bus-api-provider-repos`: HTTP controller for repository workspaces. It
  validates requests, publishes `bus.repos.*` events, and serves projected
  reads; it does not execute Git. Deps: `bus-repos`.
- `bus-api-provider-services`: local API/controller provider for Bus-managed
  Services. Deps: `bus-services`.
- `bus-api-provider-session`: session lifecycle and token introspection
  provider. Use it for provider-managed session context. Deps: `bus-help`,
  `bus-update`.
- `bus-api-provider-task`: mountable HTTP handler/helpers for bidirectional
  task-thread events. Deps: `bus-events`.
- `bus-api-provider-terminal`: cloud-neutral API provider for user-owned web
  terminal sessions. Deps: `bus-help`.
- `bus-api-provider-update`: API provider for update/version-detection,
  desired/observed identity, freshness verdicts, and non-secret evidence.
  Deps: none declared.
- `bus-api-provider-usage`: internal usage-events API provider for trusted
  backend collectors. Deps: `bus-api-provider-auth`, `bus-help`.
- `bus-api-provider-vm`: cloud-neutral VM/runtime status/start/stop HTTP
  endpoints. Deps: `bus-api-provider-auth`, `bus-api-provider-usage`,
  `bus-events`, `bus-help`, `bus-integration`, `bus-integration-billing`,
  `bus-integration-usage`.
- `bus-api-provider-worker`: HTTP worker control provider that publishes
  `bus.workers.*` events and serves bounded worker status projections. Deps:
  `bus-agent`, `bus-events`, `bus-integration`, `bus-integration-worker`.

### Events, integrations, and providers

- `bus-events`: CLI and library for Bus event envelopes: publish, listen,
  export, import, and sync. Use it as the event contract substrate. Deps:
  `bus-help`.
- `bus-integration`: shared integration worker runtime and combined host. Use
  it to run event consumers, publish correlated responses, and host compiled
  worker registrations. Deps: `bus-agent`, `bus-events`,
  `bus-integration-repos`, `bus-integration-task`, `bus-integration-worker`.
- `bus-integration-billing`: provider-neutral billing worker answering billing
  status/setup/portal/entitlement/subscription/usage-export events. Deps:
  `bus-events`, `bus-help`, `bus-integration`.
- `bus-integration-cloud`: provider-neutral cloud Events contracts and routing.
  Deps: `bus-help`.
- `bus-integration-codex`: Codex App Server backed LLM execution worker for
  provider-neutral `bus.llm.*` requests. Deps: `bus-agent`,
  `bus-api-provider-auth`, `bus-api-provider-llm`,
  `bus-api-provider-usage`, `bus-api-provider-vm`, `bus-events`,
  `bus-help`, `bus-integration`, `bus-integration-billing`.
- `bus-integration-containers`: provider-neutral container integration router
  forwarding public `bus.containers.*` events to runtime backends. Deps:
  `bus-events`, `bus-help`, `bus-integration`.
- `bus-integration-database`: provider-neutral database Events contracts and
  routing. Deps: `bus-help`, `bus-services`.
- `bus-integration-docker`: Docker Engine integration worker for container
  workflows. Deps: `bus-events`, `bus-help`, `bus-integration`.
- `bus-integration-events`: background Events relay for configured
  environments, copying only targeted routed events. Deps: `bus-events`,
  `bus-integration`, `bus-integration-ssh-runner`, `bus-remote`.
- `bus-integration-inference`: provider-neutral inference Events contracts and
  routing. Deps: `bus-help`.
- `bus-integration-node`: node bootstrap/hardening/status/verify logic and
  `bus.node.*` Events contracts. Deps: `bus-help`.
- `bus-integration-notes`: event-driven Bus Notes business logic, persistence,
  projections, retention, and publication/redaction workflows. Deps:
  `bus-data`, `bus-events`, `bus-integration`, `bus-notes`.
- `bus-integration-ollama`: Ollama-specific inference provider. Deps:
  `bus-help`, `bus-integration-inference`.
- `bus-integration-podman`: Podman runtime integration and rootless bootstrap
  helpers for container workflows. Deps: `bus-events`, `bus-help`,
  `bus-integration`.
- `bus-integration-postgres`: PostgreSQL-specific database provider. Deps:
  `bus-help`, `bus-integration-database`, `bus-services`.
- `bus-integration-repos`: Git-backed repository/worktree integration state
  for repo workspace requests. Deps: `bus-events`, `bus-integration`.
- `bus-integration-services`: runtime planner/runner/status integration for
  `services.yml` stacks. Deps: `bus-services`.
- `bus-integration-ssh-runner`: generic SSH script execution helper for
  integration modules. Deps: `bus-events`, `bus-help`, `bus-integration`.
- `bus-integration-stripe`: Stripe-specific billing integration behind the
  provider-neutral billing boundary. Deps: `bus-events`, `bus-help`,
  `bus-integration`, `bus-integration-billing`.
- `bus-integration-task`: generic task-thread integration with Bus Events.
  Deps: `bus-events`, `bus-integration`.
- `bus-integration-upcloud`: UpCloud worker for Bus VM and container
  workflows. Deps: `bus-events`, `bus-help`, `bus-integration`,
  `bus-integration-podman`, `bus-integration-ssh-runner`.
- `bus-integration-update`: event-driven update/version-detection layer for
  observed identity, desired identity, freshness verdicts, and evidence
  events. Deps: none declared.
- `bus-integration-usage`: usage worker for billing and lifecycle usage
  records. Deps: `bus-api-provider-auth`, `bus-api-provider-usage`,
  `bus-events`, `bus-help`, `bus-integration`, `bus-integration-billing`.
- `bus-integration-worker`: worker-control event service that lists workers
  and publishes worker status snapshots through Bus Events. Deps:
  `bus-agent`, `bus-events`, `bus-integration`, `bus-remote`.

### Operator, platform, and client modules

- `bus-operator`: umbrella dispatcher for admin, service, and installation
  automation. Use it as `bus operator ...`. Deps: many operator/integration
  modules including auth, billing, cloud, database, deploy, inference, node,
  token, and services.
- `bus-operator-auth`: operator client for auth-service waitlist/admin
  administration. Deps: `bus-help`.
- `bus-operator-billing`: provider-neutral billing administration and
  diagnostics. Deps: `bus-help`.
- `bus-operator-cloud`: provider-neutral cloud lifecycle operator surface.
  Deps: `bus-help`, `bus-integration-cloud`.
- `bus-operator-database`: database provisioning and verification operator
  surface. Deps: `bus-help`, `bus-integration-database`, `bus-services`.
- `bus-operator-deploy`: complete Bus deployment orchestration controller.
  Deps: `bus-events`, `bus-help`, `bus-integration`,
  `bus-integration-cloud`, `bus-integration-database`,
  `bus-integration-inference`, `bus-integration-node`,
  `bus-integration-ssh-runner`, `bus-services`.
- `bus-operator-inference`: provider-neutral inference runtime setup operator
  surface. Deps: `bus-help`, `bus-integration-inference`.
- `bus-operator-node`: inside-machine bootstrap and verification operator
  surface. Deps: `bus-help`, `bus-integration-node`.
- `bus-operator-stripe`: Stripe-specific diagnostics and catalog sync behind
  Bus billing. Deps: `bus-help`.
- `bus-operator-token`: trusted operator JWT issuer for services, automation,
  and local development. Deps: `bus-help`.
- `bus-auth`: CLI client for the Bus auth provider. Use it for auth flows from
  the command line; service logic lives in `bus-api-provider-auth`. Deps:
  `bus-help`, `bus-update`.
- `bus-billing`: end-user billing CLI, a thin client for provider-neutral Bus
  Billing APIs. Deps: `bus-help`.
- `bus-containers`: client library and CLI for AI Platform user-owned
  container runs. Deps: `bus-help`.
- `bus-vm`: client library and CLI for AI Platform VM/runtime APIs. Deps:
  `bus-help`.

### Tasks, work, workers, repositories, services, notes, MCP

- `bus-task`: generic bidirectional task threads over Bus Events. Use it for
  task creation, replies, and task-thread coordination. Deps: `bus-events`.
- `bus-work`: deprecated generic work streams over Bus Events, including
  create, claim, watch, reply, and finish flows. Keep it only for historical
  `bus.work.*` compatibility; current task and worker workflows use
  `bus-task` and `bus-worker`. Deps: `bus-events`, `bus-help`, `bus-remote`.
- `bus-worker`: CLI client for creating, controlling, observing, and attaching
  to Bus-managed workers. Deps: none declared.
- `bus-repos`: shared Go client and API contract package for repository
  workspaces. It does not execute Git itself. Deps: none declared.
- `bus-services`: `bus services` dispatcher for starting, stopping, and
  checking Bus-managed Services stacks from a project directory. Deps: none
  declared.
- `bus-notes`: Bus Notes CLI and data model for durable project notes humans
  and agents can read, write, review, search, and publish. Deps: none
  declared.
- `bus-mcp`: shared mapper, policy types, and CLI that expose Bus capabilities
  as MCP tools/resources. Deps: `bus-api-provider-mcp`, `bus-events`,
  `bus-help`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./features">Module capabilities</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./aiz">aiz</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference](./index)
- [BusDK module feature table](./features)
- [Independent modules](../architecture/independent-modules)
- [Modularity](../design-goals/modularity)
