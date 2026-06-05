# bus-api-provider-update

`bus-api-provider-update` exposes read-only Bus Update API surfaces for update
status, component identity, freshness verdicts, and supporting evidence.

The provider belongs to the update/version-detection domain. It should not
build, install, restart, or roll back components directly. Execution-oriented
update behavior must be designed separately after the read-only identity and
freshness contracts are stable.

See also:

- [Update Version Detection Goal](../goals/update.md)
- [bus-update](bus-update.md)
- [bus-integration-update](bus-integration-update.md)
