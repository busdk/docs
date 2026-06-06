# bus-agent-runtime

`bus-agent-runtime` is the Bus-owned Go runtime module for App
Server-compatible worker execution. It is intended for local GPU providers and
OpenAI API-compatible providers while preserving existing upstream Codex
integration modules.

The implementation plan lives in the BusDK-root module checkout:

[`bus-agent-runtime/PLAN.md`](../../../bus-agent-runtime/PLAN.md)

The feasibility and scope goal is:

[`docs/goals/codex-fork.md`](../goals/codex-fork.md)
