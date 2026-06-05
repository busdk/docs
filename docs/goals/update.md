# Update Version Detection Goal

## Goal

This goal is about giving Bus a reliable way to know which Bus components are
installed or running, which version each component reports, and which Git
commit or build identity produced it. The immediate purpose is detection only:
Bus should be able to report which services, API providers, integrations, and
CLI tools are not at the desired component identity.

This goal does not cover building software, publishing artifacts, installing
binaries, applying updates, restarting services, or rolling back changes. Those
actions can be designed as later goals after Bus has a trustworthy version
detection foundation.

## Scope

Bus needs a common component identity model. Each observable component should
be able to report, or be associated with, enough non-secret information to make
freshness decisions:

- component name, such as `bus-api`, `bus-events`, or `bus-update`;
- component kind, such as CLI tool, service, API provider, integration, or
  dispatcher;
- version string or channel label when available;
- Git commit for the module source that produced the binary;
- BusDK superproject commit or release identity when known;
- build profile or build identity when known;
- binary path or service executable path;
- platform and architecture;
- running process identity for services when available;
- observed time and source of the observation.

The identity model should tolerate partial information. A component with only a
binary path and version string is still useful, but the freshness result should
say which identity fields are missing.

## Desired Component Identity

Version detection needs a desired baseline. The first desired baseline can come
from Git-versioned Bus service configuration, especially `services.yml`, and
from explicit operator-selected versions or commits.

`services.yml` can grow service and CLI tool declarations that describe the
expected component identity without saying how to build or install it. The
Services module family should own this configuration because it already owns
service orchestration and service/tool observation.

The exact schema still needs design, but the goal needs enough room for
services and tools:

```yaml
tools:
  bus-update:
    version: 2026.06.05
    git_commit: 0ec9abc

services:
  bus-api:
    version: 2026.06.05
    git_commit: 0ec9abc
```

The desired identity can later come from release manifests, artifact indexes,
or development branch manifests. Those sources are out of scope for the first
version detection goal unless they are only read as identity inputs.

## Observed Component Identity

The Services module family should collect observed identity for services and
tools on a host.

`bus-services` should expose CLI commands that show desired and observed
component identity from `services.yml`, installed binaries, and running
services.

`bus-api-provider-services` should expose HTTP/REST endpoints for service and
tool identity, including installed executable paths, running versions, service
health references, and missing identity fields.

`bus-integration-services` should perform the service/tool observation work. It
can inspect configured services, running processes, binary paths, service
metadata, and standard Bus version commands. It should emit service/tool
identity observations over Bus Events API.

Each Bus binary should eventually provide a script-friendly identity command.
The exact spelling can be refined, but the contract should support JSON output
for tools and services:

```bash
bus update version --format json
bus services version --format json
bus api version --format json
```

The dispatcher can help normalize environment and `.bus` file handling, but
the reported identity must describe the actual component binary or service
being observed.

## Freshness Detection

Freshness detection compares desired component identity with observed component
identity. It should produce clear verdicts:

- `current` when the observed component matches the desired version and Git
  commit;
- `stale` when the observed component is older or different from the desired
  identity;
- `ahead` when the observed component appears newer or different in the other
  direction;
- `missing` when the desired component is not installed or not running where it
  should be;
- `unknown` when the component exists but does not report enough identity to
  compare;
- `conflict` when different observation sources disagree.

The verdict should explain the exact mismatch. For example, a useful report
should say that `bus-api` is running Git commit `abc123` while `services.yml`
requires `0ec9abc`, rather than only saying that `bus-api` is outdated.

## Candidate Modules

`bus-update` should provide the CLI UX for checking component freshness. In
this smaller goal, `bus update` should report status and evidence only. It
should not apply updates.

`bus-api-provider-update` should expose the HTTP/REST surface for update
status, desired identity, observed identity, freshness verdicts, and evidence.
It should not expose build or install execution in this goal.

`bus-integration-update` should own the event-driven freshness workflow. It can
consume service/tool identity observations, compare them with desired identity,
emit freshness verdicts, and retain the latest non-secret evidence.

`bus-services`, `bus-api-provider-services`, and
`bus-integration-services` should own service and tool identity observation
because they already own the service/tool runtime domain.

## Command Shape

The first operator-facing commands should be read-only:

```bash
bus update status
bus update check
bus update evidence
bus services status
bus services ps
```

Human output should be concise enough for operators. JSON output should be
stable enough for supervisors, scripts, and API providers:

```bash
bus update check --format json
bus services status --format json
```

The output should include desired identity, observed identity, verdicts, and
the observation source. It must not include secrets, token values, broad
environment dumps, or private configuration contents.

## Evidence Contract

Version detection evidence should be non-secret and reproducible. A useful
freshness report includes:

- host or environment label;
- component name and kind;
- desired version and Git commit;
- observed version and Git commit;
- binary path or service executable path;
- platform and architecture;
- observation method;
- comparison verdict;
- missing fields or conflicting observations;
- time of observation.

For development releases, the Git commit is more important than a human version
string. A component can be marked stale when the version string matches but the
Git commit differs.

## Open Questions

The first open question is the exact identity command contract for each Bus
binary. The system needs a stable JSON shape, but the command spelling can be
decided alongside existing dispatcher conventions.

The second open question is the `services.yml` schema for CLI tools. Services
and tools may need separate sections, but both should use the same component
identity model.

The third open question is how much freshness history should be retained. The
first version can keep the latest observation and verdict. Later versions may
need a change history for audit and troubleshooting.

The fourth open question is how to represent components that are compiled into
combined runners, such as a `bus-api` process hosting multiple API providers or
a `bus-integration` process hosting multiple integrations. The reported
identity may need to include both the host binary and the compiled-in component
registrations.

## Acceptance Shape

The goal is complete when a Bus host can report desired and observed identity
for its configured Bus services and CLI tools, compare version strings and Git
commits, identify stale, missing, unknown, ahead, and conflicting components,
and expose the result through read-only Bus CLI and API surfaces without
building, installing, restarting, or applying updates.
