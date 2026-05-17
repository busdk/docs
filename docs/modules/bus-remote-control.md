---
title: bus remote-control - Codex remote control wrapper
description: End-user reference for starting Codex remote control through the BusDK dispatcher.
---

## `bus remote-control` - Codex remote control wrapper

`bus remote-control` starts Codex remote control from the BusDK command
surface. The command is intentionally thin: it resolves the effective Bus
working directory, starts the external `codex remote-control` runtime without a
shell, and passes Codex options through unchanged.

The wrapper is useful when you want remote Codex sessions to start from the
same repository directory selected by other Bus commands. Use `-C` or
`--chdir` to choose that directory explicitly:

```bash
bus remote-control -C ~/work/acme-books -- --enable remote_control
```

The wrapper starts Codex with both the process working directory and the Codex
top-level `--cd` value set to the resolved Bus directory. Stdin, stdout,
stderr, and environment variables are inherited so Codex behaves like a direct
CLI invocation. If the `codex` executable is not available on `PATH`, the
wrapper exits with a concise setup diagnostic.

## Current Limit

Local wrapper tests cover argument passing, `-C` handling, environment
inheritance, and Codex exit-code propagation with a fake Codex executable. The
remaining release question is the Codex remote-session working-directory
contract itself. The Codex app-server protocol exposes `cwd` on session
startup messages, while the current `codex remote-control` CLI also accepts a
top-level `--cd` flag. Bus uses the available process-launch hints now; if a
remote client overrides the app-server `cwd`, that must be handled in the
Codex remote-control protocol path rather than in this wrapper alone.

## Related Modules

`bus-remote-control` is part of the developer tooling surface with
[`bus dev`](./bus-dev), [`bus agent`](./bus-agent), [`bus run`](./bus-run), and
[`bus shell`](./bus-shell). It does not implement Codex authentication,
app-server transport, approval handling, model routing, or session UI.
