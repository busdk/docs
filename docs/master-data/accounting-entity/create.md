## Create an accounting entity

Create a new bookkeeping scope so journals and VAT never mix across companies.

Owner: [bus init](../../modules/bus-init).

Create an accounting entity by creating a new BusDK workspace directory and initializing it. In BusDK, the workspace directory boundary is the accounting entity boundary — datasets and postings cannot mix across business entities because they live in different workspaces.

From an empty directory (or a new Git repository directory), run:

```bash
bus init
```

This creates the baseline workspace layout and writes the workspace-level accounting entity settings in [`bus.yml`](../../data/workspace-configuration). If you later need multi-company workflows such as consolidation or shared reporting, they are handled by higher-level commands that accept multiple workspace directories as inputs rather than by placing multiple accounting entities into one workspace. The design note [Workspace scope and multi-workspace workflows](../../architecture/workspace-scope-and-multi-workspace) explains the rationale and expectations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./configure">Configure accounting entity settings</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Initialize repo](../../workflow/initialize-repo)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)

