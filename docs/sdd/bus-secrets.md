---
title: "bus-secrets — secret reference storage and resolution (SDD)"
description: "Software Design Document for bus-secrets: deterministic user/repository scope secret references and resolution for BusDK workflow modules."
---

## bus-secrets — secret reference storage and resolution

### Introduction and Overview

`bus-secrets` provides deterministic storage and lookup of secret references used by BusDK workflow modules. It supports two scopes, user and repository, and a predictable `auto` lookup order that checks repository scope before user scope.

The module is designed so workflow steps can use values like `secret:openai_api_key` instead of hardcoded credentials. End-user tooling such as `bus dev` and `bus run` resolves these references through the shared `bus-secrets` Go package.

Scope boundaries are explicit. User scope uses `bus-preferences` keys under `secrets.<name>`. Repository scope uses workspace `datapackage.json` under `busdk.secrets.<name>`.

### Requirements

FR-SEC-001 Command surface. The module exposes `set`, `get`, `list`, and `resolve` commands through `bus secrets`.

FR-SEC-002 Secret name validation. Secret names must be non-empty lowercase names containing only lowercase letters, digits, `.`, `-`, and `_`.

FR-SEC-003 Scope behavior. `set` requires explicit `user` or `repo` scope and defaults to `user` when omitted. `get`, `list`, and `resolve` support `auto`, `user`, and `repo`.

FR-SEC-004 Auto precedence. `auto` lookup order is repository scope first, then user scope.

FR-SEC-005 Reference resolution. `resolve` returns plain values unchanged and resolves values prefixed with `secret:` by lookup name.

FR-SEC-006 Deterministic listing. `list` outputs names in deterministic sorted order.

NFR-SEC-001 Determinism. For the same inputs and workspace state, command outputs and exit behavior are deterministic.

NFR-SEC-002 No implicit external services. Secret operations do not require network access.

### System Architecture

The module has a small CLI layer and a reusable package layer. The CLI parses global flags, command tokens, and optional scope, then delegates to `pkg/secrets`. The package layer handles validation, scope-specific read and write behavior, and `secret:` reference resolution.

User-scope storage is delegated to the `bus-preferences` Go library. Repository-scope storage is delegated to workspace config path resolution via `bus-config` path helpers and `datapackage.json` data.

### Component Design and Interfaces

The primary interface is the package API in `bus-secrets/pkg/secrets`:

- `Set(ctx, workdir, scope, name, value)`
- `Get(ctx, workdir, scope, name)`
- `List(ctx, workdir, scope)`
- `ResolveValue(ctx, workdir, scope, value)`

CLI commands map directly to these package operations and keep stdout/stderr and exit-code behavior script friendly.

### Data Design

User scope persists key-value data under user preferences keys with prefix `secrets.`.

Repository scope persists key-value data in `datapackage.json` under the `busdk.secrets` object. Keys are secret names and values are string values.

`auto` scope combines both sources with repository values overriding user values for the same name.

### Assumptions and Dependencies

`bus-secrets` depends on `bus-preferences` for user-level persistence and on `bus-config` path ownership for repository configuration file location.

Repository-scope secrets are workspace-visible configuration. Real credentials are expected to be stored primarily in user scope.

### Glossary and Terminology

Secret reference means a value using the `secret:<name>` syntax that is resolved at runtime.

User scope means secret values stored in user preferences under `secrets.<name>`.

Repository scope means secret values stored in workspace `datapackage.json` under `busdk.secrets.<name>`.

Auto scope means lookup order that checks repository scope first and user scope second.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-shell">bus-shell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-secrets module CLI reference](../modules/bus-secrets)
- [bus-run SDD](./bus-run)
- [bus-dev SDD](./bus-dev)
- [bus-preferences SDD](./bus-preferences)
- [Workspace configuration](../data/workspace-configuration)
