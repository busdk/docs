## bus-init

### Introduction and Overview

Bus Init bootstraps a new BusDK workspace by orchestrating module-owned `init` commands so each module remains the sole owner of its datasets and schemas.

### Requirements

FR-INIT-001 Workspace bootstrap. The module MUST orchestrate a deterministic sequence of module `init` commands. Acceptance criteria: the resulting workspace contains the minimal baseline datasets and schemas for the standard BusDK workspace layout.

FR-INIT-002 Non-invasive initialization. The module MUST not perform Git or network operations. Acceptance criteria: initialization only affects workspace datasets and metadata.

NFR-INIT-001 Deterministic output. The module MUST emit deterministic diagnostics and stop on the first failure. Acceptance criteria: failures identify the module command that failed.

### System Architecture

Bus Init is an orchestrator that invokes module `init` commands and verifies the resulting workspace baseline. It does not own domain datasets beyond optional workspace metadata.

### Key Decisions

KD-INIT-001 Module-owned initialization. The bootstrap workflow delegates dataset creation to each module to preserve ownership boundaries.

### Component Design and Interfaces

Interface IF-INIT-001 (module CLI). The module is invoked as `bus init` and follows BusDK CLI conventions for deterministic output and diagnostics. The command does not accept layout selection flags and always initializes the standard workspace layout with deterministic dataset and schema filenames.

The pinned module version defines no module-specific parameters. `bus init` accepts no positional arguments and no module-level flags beyond the shared global flags, so its deterministic CLI help lists only the single `bus init` invocation with the global options described in the shared CLI conventions.

Usage example:

```bash
bus init
```

### Data Design

The module may create or update workspace-level metadata such as `datapackage.json` at the repository root. All other datasets are created by module `init` commands it invokes.

### Assumptions and Dependencies

Bus Init depends on the presence of module CLIs for each required area and on the standard workspace layout conventions. Missing module commands result in deterministic diagnostics.

### Security Considerations

Initialization only creates baseline datasets and does not perform network or version control operations. Access controls are handled at the repository level.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to the module command that failed.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Module failures are surfaced directly without partial completion.

### Testing Strategy

Command-level tests exercise `bus init` against fixture workspaces and verify that required baseline datasets and schemas are created.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Changes to the bootstrap baseline are handled by updating module `init` behavior and documentation.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and repeatable initialization.

### Glossary and Terminology

Workspace bootstrap: the initial creation of baseline datasets and schemas in a new repository.  
Module-owned initialization: each module creates its own datasets during bootstrap.

### See also

End user documentation: [bus-init CLI reference](../modules/bus-init)  
Repository: https://github.com/busdk/bus-init

For workspace layout choices and the initialization workflow, see [Layout principles](../layout/layout-principles) and [Initialize repo](../workflow/initialize-repo).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./modules">Modules (SDD)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-init module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-INIT`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
