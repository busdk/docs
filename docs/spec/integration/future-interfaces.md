## Future interfaces (APIs, dashboards, wrappers)

Although CLI is the initial interface, the architecture is designed for future APIs, dashboards, or external integrations. Because modules already parse inputs, validate, and produce outputs, they can be wrapped by a RESTful server or web interface without moving business logic into a monolith. The Git repository and CSV resources are treated as a contract that any interface can operate on, including static reporting sites and BI tools that read CSV directly.

---

<!-- busdk-docs-nav start -->
**Prev:** [External system integration patterns](./external-system-integration) · **Index:** [BusDK Design Spec: Integration and future interfaces](../integration/) · **Next:** [BusDK Design Spec: Extensibility model](../extensibility/)
<!-- busdk-docs-nav end -->
