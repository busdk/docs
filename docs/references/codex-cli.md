---
title: Codex CLI reference and argument patterns
description: Background reference for Codex CLI usage, common argument patterns, and practical command examples for terminal workflows.
---

## Overview

This page is a background reference for Codex CLI usage in terminal-based coding workflows. It focuses on argument patterns that are useful in non-interactive runs and automation scripts.

Codex evolves over time, so treat `codex --help` and `codex exec --help` as the authoritative source for the exact flags and defaults available in your installed version.

### Install and authenticate

Install Codex CLI using the official install path and sign in before running repository tasks. The official documentation and repository are listed in Sources at the end of this page.

### Non-interactive run pattern

A common automation shape is:

```text
codex exec --skip-git-repo-check --sandbox workspace-write --cd <workdir> --add-dir <workdir> -
```

In this pattern, `-` is used as stdin input so prompt content can be piped safely without shell-escaping long multi-line text.

### Common arguments

The following flags are commonly used in script-driven Codex runs:

| Argument | Purpose |
|---|---|
| `exec` | Run Codex in command mode for a single task. |
| `--cd <dir>` | Set working directory for the run. |
| `--sandbox workspace-write` | Run with writable workspace sandbox policy. |
| `--add-dir <dir>` | Allow additional directories when project context spans multiple paths. |
| `--model <model>` | Pin a specific model instead of runtime default selection. |
| `--oss` | Enable OSS/local mode where applicable. |
| `-c <key=value>` | Pass low-level runtime config overrides. |
| `-` | Read prompt from stdin. |

### Model and reasoning tuning

When your version supports it, model-level tuning can be provided through `-c` overrides. Common examples include reasoning effort, reasoning summary behavior, and verbosity.

```bash
codex exec \
  --sandbox workspace-write \
  --cd /path/to/repo \
  --model gpt-5-codex \
  -c 'model_reasoning_effort="high"' \
  -c 'model_verbosity="low"' \
  -
```

Use the exact value set accepted by your installed Codex version (`codex exec --help`).

### Prompt input patterns

For one-line tasks, inline prompt text is usually enough. For multi-line prompts, stdin is generally safer and easier to review in shell history.

```bash
printf '%s\n' "Review this repository and propose the next three tasks." | \
  codex exec --sandbox workspace-write --cd /path/to/repo -
```

For longer prompts:

```bash
cat prompt.txt | codex exec --sandbox workspace-write --cd /path/to/repo -
```

### Repository and multi-directory access

When a task needs files outside the primary working directory, pass explicit `--add-dir` flags. This is common with monorepos, nested repositories, and setups that rely on external build or dependency directories.

```bash
codex exec \
  --sandbox workspace-write \
  --cd /path/to/repo \
  --add-dir /path/to/repo \
  --add-dir /path/to/shared \
  -
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./foundations-summary">References and external foundations (summary)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">References and external foundations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./link-list">Sources</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Codex CLI — install](https://developers.openai.com/codex/cli/)
- [Codex (OpenAI for Developers)](https://developers.openai.com/codex/)
- [OpenAI Codex GitHub repository](https://github.com/openai/codex)
