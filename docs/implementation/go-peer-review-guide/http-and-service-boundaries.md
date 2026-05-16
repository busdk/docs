---
title: Go HTTP and service boundary review
description: Review bounded request decoding, explicit servers and clients, workspace paths, capability endpoints, TLS, and sensitive logs.
---

## Request and Server Boundaries

HTTP handlers should decode into typed request DTOs at the boundary, enforce
request body limits, and reject unknown JSON fields unless the API contract
explicitly allows extension fields. A handler that decodes directly from an
unbounded body or accepts arbitrary JSON shape makes abuse cases and client
mistakes harder to detect.

Bad:

```go
var body map[string]any
if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
	http.Error(w, err.Error(), http.StatusBadRequest)
	return
}
```

Better:

```go
type CreateRequest struct {
	Name string `json:"name"`
}

dec := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20))
dec.DisallowUnknownFields()
var req CreateRequest
if err := dec.Decode(&req); err != nil {
	http.Error(w, err.Error(), http.StatusBadRequest)
	return
}
```

The better version documents the accepted shape and bounds the input.

Services should own explicit server and mux values. Avoid package-level
`http.ListenAndServe`, default `http.HandleFunc`, and default-client shortcuts
such as `http.Get` in production paths. Use an `http.Server` with explicit
read, write, idle, header, and body limits, and use shared `http.Client` values
with owned transports rather than creating clients per request. Server timeouts
and header limits belong on `http.Server`; request body limits belong at the
handler decode boundary, for example with `http.MaxBytesReader`.

## Paths, Capabilities, and Secrets

Local service boundaries need path and capability review. Workspace roots,
mounted module bases, token prefixes, read-only gates, and provider allowlists
are security boundaries, not string conveniences. Review path normalization for
traversal outside the workspace or mount, ensure capability URLs and tokenized
prefixes are required consistently, and check that provider or module loading
is deny-by-default unless explicit wildcard discovery is part of the documented
contract.

Bad:

```go
func Open(root, name string) (*os.File, error) {
	return os.Open(filepath.Join(root, name))
}
```

Better:

```go
func Open(root, name string) (*os.File, error) {
	clean := filepath.Clean(name)
	if filepath.IsAbs(clean) || clean == ".." || strings.HasPrefix(clean, ".."+string(filepath.Separator)) {
		return nil, fmt.Errorf("path escapes workspace: %q", name)
	}
	return os.Open(filepath.Join(root, clean))
}
```

The better version treats the workspace root as a boundary. In production code,
also account for symlink policy when it matters.

Capability, tool, and metadata endpoints need exposure review. Generated or
discovered tools should be capability-driven, deny or confirm unknown writes by
default, and never bypass authorization, tenancy, policy, or environment
checks. Metadata endpoints should not wake expensive backends or expose internal
provider topology unless the endpoint is explicitly an execution or operator
surface.

TLS shortcuts are security findings. `InsecureSkipVerify: true` should be
rejected unless there is a narrow, documented verification replacement and tests
for the trust boundary.

Sensitive data must not be logged. Email addresses, OTPs, JWTs, refresh tokens,
API keys, remote-access credentials, secrets, and raw delivery payloads require
redaction or omission. Review logs, errors, test fixtures, examples, and debug
output for accidental credential disclosure.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./workflows-and-backends">Workflows and backends</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./browser-and-ui-boundaries">Browser and UI boundaries</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [API JWT audiences and scopes](../../architecture/api-jwt-audiences-and-scopes)
- [Workspace scope and multi-workspace](../../architecture/workspace-scope-and-multi-workspace)
- [LLM finding patterns](./llm-finding-patterns)
