---
title: Bus Agentic Development
description: Product documentation entry point for BusDK's semi-autonomous software development product line.
---

Bus Agentic Development is the BusDK product line for semi-autonomous software
development. It gives supervisor agents and worker agents durable task threads,
repository workspaces, terminal state, notes, review loops, MCP capability
exposure, and local or SSH-accessible development environments.

Use this product when the work is not just a one-off chat answer. The product
is meant for project work that needs a task record, an isolated workspace, a
worker, evidence, a review decision, and a path to reopen or accept the result.

## Start Here

1. Read the [task workflow notes](../goals/tasks) to understand task threads.
2. Read the [worker workflow notes](../goals/workers) to understand worker
   creation, control, and review.
3. Read [Bus Agent Runtime workers](../goals/bus-agent-runtime-workers) when
   evaluating the lightweight Bus-owned runtime direction.
4. Use [repository workspaces](../goals/repos), [remote worker lane](../goals/trustworthy-remote-worker-lane),
   and [MCP/repository modules](../modules/bus-mcp) when work needs external
   capability exposure or remote capacity.

## Product Modules

Primary modules include [`bus task`](../modules/bus-task), [`bus worker`](../modules/bus-worker),
[`bus-agent-runtime`](../modules/bus-agent-runtime), [`bus run`](../modules/bus-run),
[`bus agent`](../modules/bus-agent), [`bus chat`](../modules/bus-chat),
[`bus dev`](../modules/bus-dev), [`bus remote`](../modules/bus-remote),
[`bus remote-control`](../modules/bus-remote-control), [`bus mcp`](../modules/bus-mcp),
[`bus repos`](../modules/bus-repos), [`bus notes`](../modules/bus-notes),
[`bus portal notes`](../modules/bus-portal-notes), and [`bus portal ai`](../modules/bus-portal-ai).

Deployment/runtime infrastructure used primarily for hosting environments
belongs under [Bus AI Platform](ai-platform).
