---
title: Testing UI apps
description: Unit-first testing strategy for BusDK UI framework components and product modules.
---

## Testing Goal

The UI framework exists so product modules can be tested mostly without broad
browser e2e tests. A module should prove its business projection, rendered
states, callback behavior, provider requests, and safety rules with fast unit tests.
E2e tests then verify that the real host, auth gate, browser runtime, and
mounted module path work together.

## Design References

- [UI design system](../v0.2.0/design-system)
- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Unit Tests

View-model tests are the first layer. They should feed provider DTOs, request
context, permissions, route/query input, and error payloads into product
projection functions. Assertions should cover visible labels, status, disabled
events, selected rows, safe links, redaction, and error messages.

Renderer tests are the second layer. They should render small fixture states
through `bus-ui` components and `bus-gx` nodes, then assert deterministic HTML
or `VNode` output.

Run the default checks from the owning module root. A normal Go-backed UI
module should make `go test ./...` pass for unit and renderer tests, should
make `bus gx fmt --check testdata/*.gx` and `bus gx lint --format json
testdata/*.gx` pass for committed GX fixtures, and should expose a module e2e
target such as `make e2e` or `make test-e2e` for host wiring. The `--format
json` flag is for machine-readable diagnostics from GX tools; it is not a UI
source format. Successful commands exit `0`; JSON lint output for valid
fixtures is an empty diagnostics array.

Useful assertions include:

- user text is escaped;
- important labels and empty states are visible;
- callback props are wired to the expected controls;
- links use expected safe attributes;
- form fields have labels and names;
- status tags match view-model state;
- no inline script or unsafe raw HTML appears where forbidden;
- class names and ARIA labels are present for shared controls.

Runtime tests are the third layer. They should use fake resources, fake AI
clients, fake provider responses, and explicit app state to verify callback
behavior, update scheduling, browser helper boundaries, terminal approvals,
and error reporting.

## Snapshot Tests

Snapshots are useful when they are narrow. A good snapshot covers one component
or one compact fixture state, such as a notes list with filters, an auth login
form, a terminal approval card, or an accounting evidence panel.

GX template fixtures are preferred for reusable states. A test can render
`testdata/notes-review.gx` with matching Go data and callbacks through Bus UI
test helpers, then compare the normalized component tree or deterministic HTML.
That makes the fixture useful for humans, agents, docs, and tests at the same
time.

Keep the fixture files module-relative and explicit. For example,
`testdata/notes-review.gx` contains the markup and component functions,
`testdata/notes-review_data_test.go` contains typed Go fixture values and
callbacks, and `testdata/notes-review.golden.html` contains the expected
normalized output. Formatting and linting the `.gx` file must succeed before
the render comparison runs.

GX fixture checks should run before render assertions. Use
`bus gx fmt --check testdata/notes-review.gx` to prove the committed GX source
is canonical, `bus gx lint --format json testdata/notes-review.gx` to catch
source-level GX problems with machine-readable diagnostics, then run the
module's Go fixture test that compiles the generated Go and compares the
golden output. `bus gx inspect --format inventory` gives agents a stable map
of entries, local components, Go values, and callbacks before they edit a
fixture; it does not replace the `.gx` source or the Go fixture code.

Avoid snapshots that freeze an entire app for many unrelated states. Those
snapshots make refactoring expensive and hide the business assertion. Prefer
semantic assertions for important fields and one stable snapshot for layout
shape.

## Go WebAssembly Tests

Go WebAssembly behavior should expose pure helpers wherever possible. Parsing a route,
building an API URL, normalizing draft input, running a callback, applying a
provider response, or deriving terminal session state should be tested as
normal Go code.

Browser-bound helpers should have small adapters. Tests can use WASM test
helpers for JavaScript values when needed, but product modules should avoid
large browser-only test fixtures for ordinary business behavior.

## E2e Tests

E2e tests should stay thin but real. They should cover:

- the portal host serves shared assets and security headers;
- the module appears in deterministic metadata;
- mounted routes work under the host path and token gate;
- unauthorized or under-scoped access is rejected where applicable;
- the Go WebAssembly app mounts and handles one representative callback;
- forms or API calls reach a fake provider through the expected route;
- browser-only bridges such as file drops, close guards, or terminal input work
  when the module depends on them.

Do not re-test every generic component in every product module e2e. The shared
component suite should own generic behavior; product e2e should only prove the
module wiring and one or two critical workflows.

Portal modules should keep a fast default host/module smoke path for normal
verification: metadata, mounted route, token/frontend-auth gate, theme asset,
and one representative fake-provider event. Browser, Docker, full provider, or
long-running checks can be opt-in when they exercise runtime behavior that unit
tests cannot cover cheaply.

## Accessibility And Security Checks

UI tests should include accessibility and safety checks when the component
touches controls, links, forms, or untrusted content. Verify labels, ARIA names,
keyboard-friendly native controls, safe link attributes, escaped provider text,
and absence of secrets in runtime config or diagnostic output.

For protected APIs, UI tests do not replace API scope-matrix tests. The UI may
hide a callback-driven control, but provider/API tests must still prove that missing,
malformed, wrong-audience, insufficient-scope, and correct-scope credentials
behave as expected.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Testing](./testing-guide)
- [Source-tool integration](../v0.1.3/source-tool-integration)
- [bus-ui module reference](../../modules/bus-ui)
- [bus-portal module reference](../../modules/bus-portal)
