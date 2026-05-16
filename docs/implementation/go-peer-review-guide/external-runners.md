---
title: Go external runner review
description: Review runtime selection, model choice, timeouts, sandbox policy, template rendering, and typed runner outcomes.
---

## Runner Boundaries

Use this page when reviewing Go code that starts an external CLI, model
runner, sandboxed tool process, or other out-of-process automation.

External runner integrations should not hide policy decisions. Runtime
selection, model choice, timeout, sandbox policy, and output mode should be
explicit inputs or stored preferences with deterministic fallback diagnostics.
Prompt or template rendering should fail before external execution when
required variables are missing.

The runner layer should return typed outcomes such as usage error, execution
failure, and timeout. A usage error preserves the invalid arguments or missing
configuration without starting the runner. An execution failure preserves the
runner name, exit status, and bounded stderr or structured diagnostic. A timeout
preserves the configured deadline and confirms the process was canceled or left
under a documented owner. The runner layer should not smuggle in workflow
semantics, Git operations, provider SDK calls, hidden network access, or
workspace dataset I/O. Those concerns need explicit owners and tests at their
own boundaries.

Subprocess execution details are part of
[determinism and side-effect review](./determinism-and-side-effects). Runner
findings should therefore focus on policy visibility, typed failure reporting,
and whether the runner stays mechanical instead of owning product workflow
rules.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./authentication-and-credentials">Authentication and credentials</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./performance-review">Performance review</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AI assistants, automation, and safety](../../faq/ai-automation-and-safety)
- [Developer module workflow](../developer-module-workflow)
- [LLM finding patterns](./llm-finding-patterns)
