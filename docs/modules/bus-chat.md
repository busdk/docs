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

Run these commands after BusDK is installed and from the workspace root you
want the chat state to use. For `--backend bus-agent`, the selected
`bus-agent` runtime must be available and authenticated when that runtime
requires login. For `--backend local`, the local OpenAI-compatible endpoint
must already be reachable.

Build and start the standalone chat UI:

```sh
bus chat serve --print-url
```

Success prints a tokenized local URL. Open that URL in a browser to reach the
chat panel; the token gates the local browser session.

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

When the selected `bus-agent` runtime resolves to a Codex app-server host,
`bus chat` also exposes the richer shared agent workflow instead of waiting for
only a final assistant message. The standalone host publishes streamed event
state through the same `v1/ai/*` routes used by the larger BusDK UI hosts.

## State

`bus chat` stores thread metadata and message history under
`.bus/bus-chat/ai-state.json` in the selected workspace root. Dropped files are
copied under `.bus/bus-chat/drops/` and referenced from the next chat turn.
The panel uses the shared `bus-ui` drag-and-drop attachment flow, so dropped
files appear as removable composer attachments before they are sent. When a
turn starts, the same shared panel responding indicator is shown while the
backend is still producing the assistant response.

When a Codex-backed session requests command approval, the standalone panel
shows the approval card and the derived terminal timeline from `v1/ai/poll` and
`v1/ai/render`. Approval decisions are sent through `v1/ai/approval/respond`.
If another thread already owns the workspace lock, the panel reports the
conflict instead of hiding it behind a generic failure. Workspace lock metadata
is stored under `.bus/bus-chat/workspace-lock.json`.

ChatGPT-style login is only needed when the selected `bus-agent` runtime
requires it. In that case `v1/ai/login/start` opens the backend login URL and
the panel refreshes auth status from the runtime. Local OpenAI-compatible
backends remain login-free and report as authenticated immediately.

## Flags

The `serve` command supports workspace and listener flags. `--root <dir>`
selects the workspace root and defaults to the current directory.
`--listen <addr>` selects the bind address, usually `127.0.0.1`.
`--port <n>` selects the port; `0` means choose a free local port.
`--token <value>` overrides the generated browser capability token and should
only be used with non-secret local smoke values. `--print-url` prints the
tokenized URL, `--webview` opens the local app window, and `--no-webview`
disables auto-open.

AI flags control the backend. `--enable-ai` and `--disable-ai` toggle the panel
integration. `--backend <bus-agent|local>` chooses the runtime family.
`--agent <runtime>` and `--model <name>` apply to the `bus-agent` backend.
`--local-base-url <url>`, `--local-api-key <env-or-local-token>`,
`--local-timeout <duration>`, and `--model <name>` apply to local
OpenAI-compatible servers. Prompt flags `--system-prompt <text>` and
`--system-prompt-file <path>` override the assistant instructions.

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
