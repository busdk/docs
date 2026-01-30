# Auditability and append-only discipline

Auditability and append-only discipline are non-negotiable. BusDK enforces an append-only approach to financial records. Once a transaction is recorded and committed via external Git tooling, it is not erased or rewritten; corrections are performed through explicit new entries such as reversals, and metadata changes are tracked through commits. Git history ensures that even manual edits become visible as diffs, but user-facing tools are expected to discourage or disallow destructive edits and to prefer explicit corrective actions.

---

<!-- busdk-docs-nav start -->
**Prev:** [AI-readiness (objective, not dependency)](./ai-readiness) · **Next:** [CLI-first and human-friendly interfaces](./cli-first)
<!-- busdk-docs-nav end -->
