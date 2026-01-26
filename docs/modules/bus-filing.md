# bus-filing

Bus Filing produces deterministic filing bundles from workspace data, assembles
manifests, checksums, and version metadata, and delegates target-specific
formats to filing target modules.

## How to run

Run `bus filing` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads validated datasets and reports from the workspace and writes filing
bundle directories or archives.

## Outputs and side effects

It writes export bundles suitable for authority submission and emits
diagnostics for missing prerequisites or invalid bundles.

## Integrations

It requires validated, closed periods from
[`bus validate`](./bus-validate) and
[`bus period`](./bus-period), and uses
[`bus filing prh`](./bus-filing-prh) and
[`bus filing vero`](./bus-filing-vero) for target-specific
exports.

## See also

Repository: ./modules/bus-filing
