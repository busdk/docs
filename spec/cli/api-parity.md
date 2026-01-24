# Extensible CLI surface and API parity

As new modules are added, they introduce new subcommands without breaking existing behavior. The CLI should correspond to underlying library functions where feasible so that future API layers can wrap the same logic. The eventual architecture anticipates an “API parity” model where CLI operations map cleanly to callable functions or REST endpoints.

