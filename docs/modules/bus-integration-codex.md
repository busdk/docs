---
title: bus-integration-codex — Codex App Server event integration
description: bus-integration-codex runs provider-neutral Bus LLM execution events through the shared bus-agent Codex App Server library.
---

## `bus-integration-codex` — Codex App Server event integration

`bus-integration-codex` is the Bus Events worker that runs provider-neutral LLM
execution requests through Codex App Server. It uses the shared
[`bus-agent`](./bus-agent) Go library for Codex App Server lifecycle, session,
turn, and event handling.

It does not own the public OpenAI-compatible REST API. That API remains in
[`bus-api-provider-llm`](./bus-api-provider-llm), which validates JWTs, checks
billing entitlement, records usage, and maps `/v1/*` requests to `bus.llm.*`
events when started with `--execution-backend events`.

### Event Flow

```text
client -> /v1/* -> bus-api-provider-llm -> Bus Events
       -> bus-integration-codex -> bus-agent Codex App Server helper
       -> Bus Events response -> bus-api-provider-llm -> client
```

### Events

The worker listens for:

| Request event                       | Response event                       | Scope       |
| ----------------------------------- | ------------------------------------ | ----------- |
| `bus.llm.chat.completions.request`  | `bus.llm.chat.completions.response`  | `llm:proxy` |
| `bus.llm.responses.request`         | `bus.llm.responses.response`         | `llm:proxy` |
| `bus.llm.completions.request`       | `bus.llm.completions.response`       | `llm:proxy` |

The request payload is
`bus-api-provider-llm/pkg/llmapi.ExecutionEventRequest`. The response payload
is `llmapi.ExecutionEventResponse`, with an OpenAI-compatible JSON body.

### CLI

Run a deterministic self-test:

```sh
bus-integration-codex --self-test
```

Run against a Bus Events API after these prerequisites are true:

- `bus-api-provider-events` is running at the `--events-url` address.
- `bus operator token issue --local` is available for creating the local
  service token.
- The `codex` executable and its authentication material are configured for
  the process that runs `--provider codex`.

```sh
BUS_API_TOKEN="$(bus operator token issue --local --scope llm:proxy --format token)" \
bus-integration-codex \
  --provider codex \
  --events-url http://127.0.0.1:8081 \
  --workdir /workspace
```

The command is connected when it stays running without printing a startup
error. In another shell, prove the event contract is visible before sending
model traffic:

```sh
bus-integration-codex --events --format text | grep bus.llm.chat.completions.request
```

Print declared event capabilities:

```sh
bus-integration-codex --events --format text
bus-integration-codex --events --format asyncapi
bus-integration-codex --event-help codex.chat_completions.receive
```

### Options

| Option                    | Environment variable | Purpose                                                    |
| ------------------------- | -------------------- | ---------------------------------------------------------- |
| `--events-url`            | `BUS_EVENTS_API_URL` | Bus Events API base URL.                                   |
| `--provider codex|static` | `BUS_CODEX_PROVIDER` | `codex` starts Codex App Server; `static` is for tests.    |
| `--workdir`               | `BUS_CODEX_WORKDIR`  | Working directory passed to Codex App Server.              |
| `--model`                 | `BUS_CODEX_MODEL`    | Optional Codex model setting.                              |
| `--codex-command`         | `BUS_CODEX_COMMAND`  | Codex executable path, defaulting to `codex`.              |
| `--timeout`               | `BUS_CODEX_TIMEOUT`  | Request and turn timeout.                                  |

### Local Compose

The BusDK superproject root `compose.yaml` starts `bus-integration-codex`
behind `bus-api-provider-llm --execution-backend events`. The stack verifies
the OpenAI-compatible route and model catalog without requiring real Codex
credentials.

Live chat completion through Codex is opt-in because the `bus-codex` container
must be able to run the `codex` executable and access the operator's Codex
authentication material. The checked-in Compose file intentionally does not
mount `~/.codex` by default. Create an untracked local override named
`compose.codex.local.yaml`:

```yaml
services:
  bus-codex:
    environment:
      BUS_CODEX_COMMAND: /usr/local/bin/codex
      CODEX_HOME: /root/.codex
    volumes:
      - ${BUS_CODEX_BINARY:?set BUS_CODEX_BINARY to the Codex executable path}:/usr/local/bin/codex:ro
      - ${BUS_CODEX_HOME:?set BUS_CODEX_HOME to the Codex config directory}:/root/.codex:ro
```

Then start the stack with both files and run the live check:

```sh
docker compose --env-file .env.example -f compose.yaml -f compose.codex.local.yaml up -d
BUS_LOCAL_AI_PLATFORM_LIVE_CODEX=1 \
bash tests/superproject/test_local_ai_platform_compose_smoke.sh
```

Do not commit Codex credentials, session files, JWTs, or API keys to the
repository. Keep them in local untracked configuration or deployment secrets.

### Safety

The Codex App Server helper denies approval requests by default unless a caller
explicitly configures a safe approval policy. The integration should be used
only with the normal Bus Events API authorization path; do not expose the
worker directly to untrusted callers.
