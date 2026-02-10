## Workspace scope and multi-workspace workflows

A BusDK workspace directory is intentionally single-entity: one workspace represents exactly one internal business entity, and all datasets in that workspace belong to that entity by construction. This keeps posting, period close, reconciliation, and validation rules local to one entity, so cross-entity constraints do not leak into the operational data model.

Multi-company workflows such as company groups, consolidation, shared reporting, or parallel bookkeeping are handled by higher-level commands that accept multiple workspace directories as inputs. Those commands produce outputs that remain separated per input workspace unless an explicit consolidation output is requested, so the boundary between entities stays reviewable and script-friendly.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./independent-modules">Independent modules (integration through shared datasets)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./shared-validation-layer">Shared validation layer (schema + logical validation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting entity](../master-data/accounting-entity/index)
- [Workspace configuration (`bus.yml`)](../data/workspace-configuration)
- [Initialize a new repository](../workflow/initialize-repo)
- [Git-backed data repository (the data store)](./git-backed-data-store)

