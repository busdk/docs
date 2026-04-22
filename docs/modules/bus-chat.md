---
title: bus-chat
description: Standalone BusDK AI chat UI using shared bus-ui panel components, bus-agent runtime defaults, and optional local OpenAI-compatible models.
---

## Overview

`bus chat` starts a token-gated local web UI that contains only the BusDK AI
chat panel. It is useful when you want the same assistant surface used by
`bus-ledger` and `bus-factory` without opening a ledger browser or development
factory view.

The default backend is `bus-agent`, so runtime and model defaults follow the
same preferences used by `bus agent`. A local backend is available for
OpenAI-compatible HTTP servers running on localhost, including Gemma-style model
servers, and does not require a ChatGPT login.

## Usage

Build and start the standalone chat UI:

```sh
bus chat serve --print-url
```

To force a `bus-agent` runtime for this invocation, pass `--agent` and
optionally `--model`:

```sh
bus chat serve --print-url --backend bus-agent --agent codex:local --model gpt-oss
```

To use a local OpenAI-compatible endpoint:

```sh
bus chat serve --print-url \
  --backend local \
  --local-base-url http://127.0.0.1:11434 \
  --model gemma-4
```

The local endpoint may be the server root, `/v1`, or the full
`/v1/chat/completions` URL. If the endpoint requires an API token, pass
`--local-api-key`; the value is sent as a bearer token.

## State

`bus chat` stores thread metadata and message history under
`.bus/bus-chat/ai-state.json` in the selected workspace root. Dropped files are
copied under `.bus/bus-chat/drops/` and referenced from the next chat turn.

## Flags

The `serve` command supports workspace and listener flags (`--root`, `--listen`,
`--port`, `--token`, `--print-url`, `--webview`, `--no-webview`), AI enablement
flags (`--enable-ai`, `--disable-ai`), backend flags (`--backend`, `--agent`,
`--model`, `--local-base-url`, `--local-api-key`, `--local-timeout`), and prompt
configuration flags (`--system-prompt`, `--system-prompt-file`).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-agent">bus-agent</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-ledger">bus-ledger</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-agent](./bus-agent)
- [bus-ui](./bus-ui)
- [bus-ledger](./bus-ledger)
- [bus-factory](./bus-factory)
