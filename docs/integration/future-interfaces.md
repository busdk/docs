## Future interfaces (APIs, dashboards, wrappers)

Although CLI is the initial interface, the architecture is designed for future APIs, dashboards, or external integrations. Because modules already parse inputs, validate, and produce outputs, they can be wrapped by a RESTful server or web interface without moving business logic into a monolith. The Git repository and CSV resources are treated as a contract that any interface can operate on, including static reporting sites and BI tools that read CSV directly.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./external-system-integration">External system integration patterns</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../integration/index">BusDK Design Spec: Integration and future interfaces</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../extensibility/index">BusDK Design Spec: Extensibility model</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
