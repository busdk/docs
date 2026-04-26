---
title: bus-vm — AI Platform VM status client
description: bus vm reads the AI Platform VM/runtime lifecycle status with a Bus auth token.
---

## `bus-vm` — AI Platform VM status client

`bus vm` is the domain client for the AI Platform VM/runtime API. It owns the
client library for `GET /api/v1/vm/status`. Use it when you need the GPU
runtime lifecycle state directly.

### Common task

```bash
bus vm status
```

The token must be an AI Platform bearer JWT, usually obtained through
`bus-auth`. By default the CLI reads the normal Bus API token from
`~/.config/bus/auth/api-token` or `${BUS_CONFIG_DIR}/auth/api-token`; explicit
`--token`, `--token-file`, `BUS_AI_TOKEN`, and `BUS_API_TOKEN` override that
default. The token subject is the account UUID used by the AI Platform.

### API ownership

`bus-vm` owns the VM API client. `bus-status` may show VM state as part of an
aggregate status view, but it should call the `bus-vm` Go library instead of
owning this HTTP endpoint.

### Options

Use `--api-url` to target another AI Platform deployment. Use `--token` for an
inline bearer token or `--token-file` for a token stored by local tooling. Use
`--format json`, `--format text`, or `--format tsv` to select output.

### Examples

```bash
bus vm --api-url https://ai.hg.fi --token "$BUS_AI_TOKEN" status
bus vm status --format text
```
