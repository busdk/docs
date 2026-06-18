---
title: bus-top - friendly local process monitor
description: bus top helps developers and operators understand local process families, system pressure, snapshots, and optional privacy-aware AI explanations.
---

## `bus-top` - friendly local process monitor

`bus top` is a local process monitor for developers and operators who want to
understand what is running without decoding every process name manually. It
shows deterministic process and system facts, groups related processes into
families, and can add optional AI explanations when a backend is configured.

The monitor remains useful without AI. AI explanations are an annotation layer
over sampled process facts, cached process-family records, and redacted prompt
inputs.

### Common tasks

Open the live process monitor:

```bash
bus top
```

Disable AI and use only deterministic local facts:

```bash
bus top --ai off
```

Write one machine-readable process snapshot:

```bash
bus top --snapshot --format json
```

Warm the explanation cache when an AI backend is configured:

```bash
bus top --ai on --warm-ai
```

Run a bounded self-check for Bus Top's own resource use:

```bash
bus top --self-check --self-check-duration 5s
```

Collect bounded host diagnosis evidence:

```bash
bus top --diagnose host --ai auto
```

### Synopsis

```text
bus top [--ai <auto|off|on>] [--sample-interval <duration>] [--privacy <redacted|local>] [global flags]
bus top --snapshot --format json [global flags]
bus top --explain <pid> [--ai <auto|off|on>] [global flags]
bus top --warm-ai [--ai <auto|on>] [global flags]
bus top --self-check --self-check-duration <duration> [global flags]
bus top --diagnose host [--ai <auto|off|on>] [global flags]
```

### What the output tells you

The live view focuses on system pressure, ranked processes, process-family
grouping, and selected-process details. Process families let repeated helpers,
browser workers, language servers, dev servers, databases, agents, and BusDK
tools share one explanation instead of producing repeated noise.

Snapshot mode emits deterministic data for scripts, tests, support handoffs, or
bug reports. Diagnosis and self-check modes are bounded command runs rather
than live monitor loops.

### AI and privacy

`--ai auto` is cache-first. It can use cached explanations and request new
summaries only when a backend is configured. `--ai off` disables new AI calls.
`--privacy redacted` is the default and avoids sending full local command
arguments to the model.

Bus Top is inspect-only. It can explain what to inspect next, but it does not
kill, renice, or signal processes.

### Related pages

- [bus-status](./bus-status)
- [bus-api-provider-llm](./bus-api-provider-llm)
- [AI and external service integration](../extensibility/ai-and-external-services)
