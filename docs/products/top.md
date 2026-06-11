---
title: Bus Top
description: Product documentation entry point for BusDK's local process monitor product line.
---

Bus Top is the BusDK product line for understanding local process and system
behavior. It shows deterministic process facts, groups related processes,
exports snapshots, supports host diagnosis, and can add optional
privacy-aware AI explanations when configured.

Bus Top remains useful without AI. AI explanations are an annotation layer over
local process facts, redacted prompts, and cached process-family records.

## Start Here

1. Read [`bus-top`](../modules/bus-top) for the process monitor command.
2. Read [`bus-status`](../modules/bus-status) for related status/readiness
   workflows.
3. Use snapshots when you need deterministic support evidence.
4. Use AI explanations only when the configured model boundary is acceptable
   for the process information being summarized.

## Product Modules

The product is centered on [`bus-top`](../modules/bus-top).
[`bus-status`](../modules/bus-status) is grouped with it where status and
readiness workflows help the operator.
