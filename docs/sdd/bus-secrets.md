---
title: "bus-secrets — secret reference storage and resolution (SDD)"
description: "Software Design Document for bus-secrets: deterministic repository-local secret references and resolution for BusDK workflow modules."
---

## bus-secrets — secret reference storage and resolution

### Introduction and Overview

`bus-secrets` provides deterministic storage and lookup of secret references used by BusDK workflow modules. Secrets are stored in repository-local `.bus/secrets` files and resolved deterministically for workflow execution.

The module is designed so workflow steps can use values like `secret:openai_api_key` instead of hardcoded credentials. End-user tooling such as `bus dev` and `bus run` resolves these references through the shared `bus-secrets` Go package.

Public recipients are stored in `.bus/secrets/recipients.txt`. Secret blobs are stored in `.bus/secrets/<name>.sops.json`. Private key sources are local only through preferences or environment variables.

### Requirements

FR-SEC-001 Command surface. The module exposes `set`, `get`, `list`, and `resolve` commands through `bus secrets`.
The module also exposes `init`, `uninit`, and `doctor` commands for SOPS configuration bootstrap, reset, and validation.

FR-SEC-002 Secret name validation. Secret names must be non-empty lowercase names containing only lowercase letters, digits, `.`, `-`, and `_`.

FR-SEC-003 Scope behavior. `set`, `get`, `list`, and `resolve` accept `auto`, `repo`, and `user` scope values for compatibility. Current behavior resolves all scopes through repository-local storage.

FR-SEC-004 Scope determinism. Scope parsing is deterministic; compatibility alias `user` maps to repository-local behavior.

FR-SEC-005 Reference resolution. `resolve` returns plain values unchanged and resolves values prefixed with `secret:` by lookup name.

FR-SEC-006 Deterministic listing. `list` outputs names in deterministic sorted order.

FR-SEC-007 Encrypted at rest enforcement. Secret values persisted in repository-local storage must be SOPS-encrypted envelopes; plaintext stored values are invalid and must cause deterministic command failure until migrated.

FR-SEC-008 Recipient configuration precedence. Encryption recipient resolution must use `.bus/secrets/recipients.txt` first and fall back to `SOPS_AGE_RECIPIENTS` when repository recipients are absent.

NFR-SEC-001 Determinism. For the same inputs and workspace state, command outputs and exit behavior are deterministic.

NFR-SEC-002 No implicit external services. Secret operations do not require network access.

NFR-SEC-003 SOPS runtime requirement. Encrypt/decrypt operations require a working `sops` executable in `PATH` and valid SOPS key configuration.

### System Architecture

The module has a small CLI layer and a reusable package layer. The CLI parses global flags, command tokens, and optional scope, then delegates to `pkg/secrets`. The package layer handles validation, repository-local read/write behavior, SOPS encrypt/decrypt enforcement, and `secret:` reference resolution.

Repository-local storage is file-based under `.bus/secrets`. Local key-source preferences use `bus-preferences`.

### Component Design and Interfaces

The primary interface is the package API in `bus-secrets/pkg/secrets`:

- `Set(ctx, workdir, scope, name, value)`
- `Get(ctx, workdir, scope, name)`
- `List(ctx, workdir, scope)`
- `ResolveValue(ctx, workdir, scope, value)`

CLI commands map directly to these package operations and keep stdout/stderr and exit-code behavior script friendly.
`init` persists the discovered/generated recipient to `.bus/secrets/recipients.txt` and can print shell exports for key source settings.

### Data Design

Repository-local scope persists key-value data in `.bus/secrets/<name>.sops.json`. Values are SOPS-encrypted envelope strings.

Repository recipient configuration persists in `.bus/secrets/recipients.txt`.

### Assumptions and Dependencies

`bus-secrets` depends on `bus-preferences` for local key-source preferences. Repository-local secret files and recipient files are workspace-visible and should be handled according to repository policy.

### Glossary and Terminology

Secret reference means a value using the `secret:<name>` syntax that is resolved at runtime.

Repository-local scope means secret values stored in `.bus/secrets/<name>.sops.json`.

Compatibility `user` scope means accepted input alias currently mapped to repository-local behavior.

Auto scope means deterministic default scope, currently repository-local behavior.

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
