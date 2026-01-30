# Append-only discipline and security model

Historical financial data is append-only. Modules add lines, mark records inactive where appropriate, and avoid destructive updates. If scrubbing sensitive data is ever required, it is handled via an explicit redaction commit that flags the redaction rather than silently excising history.

In single-user operation on a local machine, security is primarily OS-level control. In collaborative scenarios, Git permissions and workflows are used to control who can propose and approve changes. Branch protections, pull requests, and reviews can enforce separation of duties such as preparer-versus-approver. The architecture is designed so these workflows are natural extensions of the Git data store rather than special cases.

---

<!-- busdk-docs-nav start -->
**Prev:** [BusDK Design Spec: System architecture](../02-architecture) · **Next:** [Architectural overview](./architectural-overview)
<!-- busdk-docs-nav end -->
