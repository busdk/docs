---
title: bus remote-control - Codex remote-control wrapper
description: Start Codex remote control through the Bus dispatcher with an explicit working-directory boundary and pass-through Codex options.
---

## `bus remote-control` - start Codex remote control from a Bus workspace

`bus remote-control` starts the external Codex remote-control runtime through
the Bus dispatcher. Use it when you want a remote Codex session to start from
the same effective working directory selected by Bus commands.

The wrapper has a small boundary. It resolves the Bus working directory, starts
`codex --cd <effective-workdir> remote-control` without a shell, sets the
Codex process working directory to that same directory, and passes Codex
remote-control options through unchanged after wrapper flag parsing. It does
not manage Codex sign-in, remote-control transport, model selection, approval
policy, or the remote client UI.

### Try it first

Before starting a session, install the Codex CLI, sign in with the account you
intend to use for remote control, and choose the repository directory that
should become the session boundary. The examples below use
`~/work/acme-books` as a non-secret sample path.

Start from an explicit project directory so the command boundary is visible:

```bash
bus remote-control -C ~/work/acme-books
```

Show the Codex remote-control help instead of starting a session:

```bash
bus remote-control -C ~/work/acme-books -- --help
```

The `--` separator ends Bus wrapper flag parsing. Arguments after it are sent
to `codex remote-control` as Codex options.

### Working directory behavior

`-C <dir>` and `--chdir <dir>` select the effective Bus working directory. If
you omit them, the wrapper uses the current directory.

The wrapper guarantees the local launch boundary: the Codex process starts in
the effective Bus working directory and Codex receives the same value through
its top-level `--cd` option. The remote-session working directory is guaranteed
only when the installed Codex remote-control runtime and controlling client map
that value into the session and turn `cwd` fields. If a remote client lets you
choose or override the session directory, keep it aligned with the repository
you passed to `-C`.

Use one repository per session when the task will read or modify files. Start
from the repository root that contains the relevant `AGENTS.md` instructions,
and avoid launching from a parent directory that contains unrelated customer or
personal data.

### Safe usage

`bus remote-control` inherits stdin, stderr, and the process environment so
Codex behaves like a direct CLI invocation. Do not put API tokens, passwords,
or private customer data in command-line arguments, `.bus` files, or wrapper
output paths. Use the normal Codex sign-in flow and Bus secret-reference
tooling where a workflow needs credentials.

If you redirect normal output with `--output <file>`, store it in a project
log location that is appropriate for the content and review it before sharing.
Use `--quiet` when an automation wrapper should suppress normal Codex stdout.

### Examples

Start remote control from a repository:

```bash
bus remote-control -C ~/work/acme-books
```

Pass a Codex remote-control option after the wrapper separator:

```bash
bus remote-control -C ~/work/acme-books -- --help
```

Write normal Codex stdout to a local log file while diagnostics remain on
stderr:

```bash
bus remote-control -C ~/work/acme-books \
  --output logs/codex-remote-control-2026-05-18.txt
```

Use the standalone binary only when you are intentionally bypassing the Bus
dispatcher:

```bash
bus-remote-control -C ~/work/acme-books -- --help
```

### Files and data

`bus remote-control` does not read or write workspace accounting datasets,
schemas, `datapackage.json`, or repository-local secrets. It may read the
current process environment and whatever files Codex reads after the remote
session starts. The selected repository data remains the boundary you should
review before granting remote-control access.

### Exit status and errors

Exit code `0` means the wrapper and Codex process completed successfully.
Exit code `1` means execution failed, such as a missing `codex` executable or
a Codex process failure. Exit code `2` means invalid wrapper usage, such as an
unknown wrapper flag or an inaccessible working directory.

Run `bus remote-control --help` for the wrapper help. Run
`bus remote-control -- --help` for the installed Codex remote-control help.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix. Keep
the working directory explicit so the remote-control boundary is clear during
script review.

```bus
# same as: bus remote-control -C ~/work/acme-books -- --help
remote-control -C ~/work/acme-books -- --help

# same as: bus remote-control -C ~/work/acme-books
remote-control -C ~/work/acme-books
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-run">bus-run</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-secrets">bus-secrets</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-run CLI reference](./bus-run)
- [bus-agent CLI reference](./bus-agent)
- [bus-secrets CLI reference](./bus-secrets)
- [CLI command structure](../cli/command-structure)
- [Standard global flags](../cli/global-flags)
- [OpenAI Codex CLI documentation](https://developers.openai.com/codex/cli/)
