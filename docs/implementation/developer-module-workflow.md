---
title: Developer module workflow
description: Scaffold BusDK modules, run commit/work/spec/e2e, and set agent and run-config with Cursor, Gemini, Claude, or Codex CLI.
---

## Developer module workflow

This use case covers the workflow for contributors developing BusDK modules: scaffolding a new module, running commit/work/spec/e2e operations, and setting agent and run-config. The same [bus-dev](../modules/bus-dev) CLI supports multiple agent runtimes; each runtime has its own integration details and test coverage.

For reproducible Go build/test defaults and performance-oriented tuning choices used by module repositories, see the [Go optimization guide](./go-optimization-guide).

Module readiness per runtime is summarised in [Development status — BusDK modules](./development-status) under the sections below.

### Developer module workflow with Cursor CLI

Cursor runs from the repository root so its native AGENTS.md loading applies. This is the only developer runtime with e2e coverage today (init, flags, set, agent detect and run stub). Readiness table: [Development status — Developer module workflow with Cursor CLI](./development-status#developer-module-workflow-with-cursor-cli).

### Developer module workflow with Gemini CLI

Gemini may rely on repo-local `.gemini/settings.json` and `.geminiignore` so AGENTS.md is discovered as intended. Run/work/spec/e2e with Gemini are not exercised in e2e, so this runtime path is in-progress and not yet fully verified. Readiness table: [Development status — Developer module workflow with Gemini CLI](./development-status#developer-module-workflow-with-gemini-cli).

### Developer module workflow with Claude CLI

Claude prefers per-run injection of AGENTS.md with a clearly marked, additive repo-local shim as fallback. Run/work/spec/e2e with Claude are not exercised in e2e, so this runtime path is in-progress and not yet fully verified. Readiness table: [Development status — Developer module workflow with Claude CLI](./development-status#developer-module-workflow-with-claude-cli).

### Developer module workflow with Codex CLI

From **BusDK v0.0.26** onward, Codex is supported as a bus-agent runtime in this workflow (`bus dev --agent codex`, `bus dev set agent codex`, or `BUS_DEV_AGENT=codex`). Codex runs with repo-local state (e.g. CODEX_HOME set to a repo-local directory); AGENTS.md is discovered natively when the workdir is the repo root. Codex CLI sign-in works with a ChatGPT Plus subscription (and other eligible ChatGPT plans). Run/work/spec/e2e with Codex are not exercised in e2e. Readiness table: [Development status — Developer module workflow with Codex CLI](./development-status#developer-module-workflow-with-codex-cli).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./module-repository-structure">Module repository structure and dependency rules</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./development-status">Development status — BusDK modules</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-dev](../modules/bus-dev)
- [bus-agent](../modules/bus-agent)
- [Go optimization guide](./go-optimization-guide)
- [Development status — BusDK modules](./development-status)
- [OpenAI Help Center: Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan)
