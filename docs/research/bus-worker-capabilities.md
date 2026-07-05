# Bus Worker Capabilities

Date: 2026-07-05

## Tools

- `shell_command` (verified): run shell commands in a sandboxed environment.
- `parallel` via `multi_tool_use.parallel` (verified): orchestrate multiple tool calls in one request.
- `web` tools (`open` endpoint, etc.) (verified): fetch remote web pages.
- `get_goal` (verified): query current work goal object.
- MCP resource tools `list_mcp_resources`, `list_mcp_resource_templates`, `read_mcp_resource` (verified).
- `tool_search_tool` (verified): discover tools by query string.

## How to invoke

- `shell_command`: use JSON `{"command": "...", "workdir": "..."}`; optionally add `timeout_ms`.
- `multi_tool_use.parallel`: pass `tool_uses` with recipient names like `functions.shell_command`.
- `web`:
  - `web.run` with `open` and a URL, or `search_query` for web results.
- `get_goal`: call with no arguments and inspect returned `goal`.
- MCP read loop: call `list_mcp_resources` first, then `read_mcp_resource` for `server` + `uri`.
- `tool_search_tool`: call with `query` and optional `limit`.

## Limits

- `shell_command` calls default to `timeout_ms=10000` when not provided in this session.
- `shell_command` is under sandbox restrictions (workspace-write). In this environment, write verification was confirmed in normal workspace paths; do not assume unrestricted host access.
- `web.run` has explicit rate/text extraction limits and short snippets in tool output.
- `multi_tool_use.parallel` only accepts `functions.*` tool calls.
- Goal query currently returns either a goal object or `null`.

## Web access verdict

- Prioritized test: `web.run` with `open` on `https://qemu.org`.
- Exact result: success with redirect.
- Returned URL: `https://www.qemu.org/`.
- Evidence: page parsed (`QEMU` home page) with release links and product overview; no network fetch error.

## Patterns for supervisors

- Use `shell_command` for filesystem checks (`pwd`, `ls`, `cat`) and command-level evidence.
- Use `multi_tool_use.parallel` to run independent shell actions at once and reduce latency.
- Use `get_goal` to verify whether a thread has an active assignment before additional steps.
- Use `tool_search_tool` to discover additional deferred tools when needed.
- For MCP-backed inspectors, first enumerate `list_mcp_resources`, then open a `server/uri` with `read_mcp_resource`.
- Prefer `web.open` when you need exact URL evidence; in this session, `qemu.org` was reachable from the web tool.
