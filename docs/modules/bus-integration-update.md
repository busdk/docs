# bus-integration-update

`bus-integration-update` owns event-driven integration behavior for update
status and component freshness detection.

The integration consumes non-secret component identity observations, compares
them with desired identity, emits freshness verdicts, and retains the latest
evidence needed by CLI/API surfaces. It should not build, install, restart, or
roll back components in the first update-detection goal.

See also:

- [Update Version Detection Goal](../goals/update.md)
- [bus-update](bus-update.md)
- [bus-api-provider-update](bus-api-provider-update.md)
