---
title: bus-integration-ssh-runner — SSH script runner
description: bus-integration-ssh-runner provides generic SSH script execution for Bus integration modules.
---

## `bus-integration-ssh-runner` — SSH script runner

`bus-integration-ssh-runner` provides reusable SSH script execution for Bus
integration modules. It owns private-key loading, known_hosts validation,
host/user candidate selection, command timeouts, and bounded stdout/stderr
capture.

The module does not own Podman, container, cloud, or REST API behavior. Callers
provide the target and the script to execute. For example,
`bus-integration-upcloud` provisions or discovers a runner and supplies its
container bootstrap or Podman script as input to this SSH runner.

Run it as a standalone worker when you want a separate process:

```sh
bus-integration-ssh-runner \
  --events-url "$BUS_EVENTS_API_URL" \
  --api-token "$BUS_API_TOKEN" \
  --ssh-private-key "$BUS_SSH_RUNNER_PRIVATE_KEY" \
  --ssh-known-hosts "$BUS_SSH_RUNNER_KNOWN_HOSTS"
```

`BUS_API_TOKEN` is a normal Bus API JWT with audience `ai.hg.fi/api`. It
must include the domain scope for SSH runner events, currently `ssh:run`.

It can also be registered into a shared `bus-integration` host process through
the Go `sshrunner.Registration(...)` function.

Go callers use the DTOs in `pkg/sshrunner`, including `ScriptRequest`,
`Target`, and `ScriptResult`. The same DTOs are used by the Bus Events worker
mode with `bus.ssh.script.run.request` and `bus.ssh.script.run.response`
events. `Request` and `Result` remain compatibility aliases for the initial
library API.

End users usually do not call this module directly. Operators configure SSH
keys and known_hosts paths on the SSH runner process or shared integration
host. No real SSH keys, hostnames, or credentials should be committed to the
BusDK repository.

### Sources

- [bus-integration-ssh-runner README](../../../bus-integration-ssh-runner/README.md)
- [bus-integration-upcloud](./bus-integration-upcloud.md)
