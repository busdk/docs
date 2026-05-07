# bus-integration-notes

`bus-integration-notes` provides event-driven Bus Notes business logic. It
validates note operations, coordinates persistence, maintains search/list
projections, publishes lifecycle events, and applies redaction, visibility,
retention, and publication workflow rules.

It is used by `bus-api-provider-notes` and builds on `bus-integration`.
