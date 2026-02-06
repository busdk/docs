## Interactive use and scripting parity

Every command must be usable interactively and non-interactively. Interactive prompts are used when the user omits parameters, enabling a guided experience. Non-interactive flags and arguments must allow full scripting and automation. This includes workflows such as nightly cron-driven bank imports or scripted ledger entries produced by external systems.

Interactive prompting must never block automation. In non-interactive contexts, commands must not prompt for missing inputs; they must instead fail with a concise diagnostic and a usage error exit code. In interactive contexts, prompts must be avoidable by providing explicit flags and arguments so the same operation can be expressed as a deterministic command line.

When an operation has both a “guided” interactive mode and an explicit non-interactive mode, the resulting repository data must be equivalent. Interactive mode is an implementation choice for user experience, not a different behavioral contract.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./error-handling-dry-run-diagnostics">Error handling, dry-run, and diagnostics</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./reporting-and-queries">Reporting and query commands</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
