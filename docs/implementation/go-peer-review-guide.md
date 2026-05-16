---
title: Go peer review guide
description: Human review criteria for Go source code that complement normal formatters, static analyzers, and linters.
---

## Go peer review guide

Good Go code in BusDK should be easy to understand, easy to test, and hard to misuse. A peer review should therefore look past formatting and obvious static-analysis findings. It should ask whether the code has the right owner, whether behavior is expressed through clear package boundaries, whether failures are deterministic, and whether the tests prove the actual user-visible contract.

This guide is written so the same checks can later become prompts or rules for an LLM-assisted review tool. A finding should name the code location, explain why the current shape is risky, and suggest the smallest design improvement that would make the code clearer or safer.

Each section below explains the review rule in plain terms and shows small examples. The examples are intentionally short. In real code, prefer names from the domain and the existing package, not names copied from these snippets.

## Review Order

Start with the intended product boundary before reading individual functions. Identify the module, package, command, service endpoint, or runtime layer that owns the behavior. Then review the public contract, the package design, the implementation details, and finally the tests and documentation. Code that is locally tidy can still be wrong when it puts behavior in the wrong module, duplicates a data contract, or hides domain logic inside a presentation layer.

Prefer concrete findings over taste. A good review comment says what behavior becomes harder to prove, maintain, or extend. Avoid asking for abstraction only because a function is long, or for inlining only because a helper is small. The question is whether the current shape makes the next correct change obvious.

## Ownership and Architecture

Each package should have one clear responsibility. A command entrypoint should parse arguments, wire dependencies, and render output; it should not own validation, domain rules, storage mutation, or business workflow. A service handler should translate HTTP or event input into typed calls; it should not become the only place where invariants are enforced. Library packages should expose structured behavior that can be unit-tested without shelling out, opening the full CLI, or requiring a live external service.

For Go CLIs, `main()` should be the only place that calls `os.Exit`. Prefer a testable run function that accepts arguments, working directory, streams, and explicit dependencies, then returns an exit code. This keeps command behavior reviewable without spawning a process and prevents package logic from terminating tests or callers.

Bad:

```go
func SaveInvoice(path string) {
	if err := writeInvoice(path); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
```

Better:

```go
func SaveInvoice(path string) error {
	if err := writeInvoice(path); err != nil {
		return fmt.Errorf("save invoice %q: %w", path, err)
	}
	return nil
}

func main() {
	if err := SaveInvoice(os.Args[1]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
```

The better version lets tests call `SaveInvoice` directly and leaves process termination at the command boundary.

Look for code that crosses ownership boundaries for convenience. BusDK modules integrate through documented datasets, schemas, shared mechanical libraries, and explicit API/provider boundaries. They should not call another `bus-*` CLI for core behavior, hardcode another module's data paths when a path accessor exists, or duplicate business logic owned by another module. A review should flag code whose imports, file access, or runtime calls make a module depend on another module's internals.

Layering should be predictable. Lower layers provide primitives and contracts; higher layers compose them. If two packages both validate the same rule, both choose storage paths, or both translate the same event shape, there is probably a missing owner. Suggest moving the rule to the package that owns the concept and keeping other packages as callers.

Bad:

```go
func handleCreate(w http.ResponseWriter, r *http.Request) {
	req := decodeCreate(r)
	if req.AmountCents <= 0 {
		http.Error(w, "amount must be positive", http.StatusBadRequest)
		return
	}
	// Store directly from the handler.
}
```

Better:

```go
func handleCreate(w http.ResponseWriter, r *http.Request) {
	req := decodeCreate(r)
	invoice, err := invoice.New(req.CustomerID, req.AmountCents)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// Store the validated invoice value.
	_ = invoice
}
```

The handler still owns HTTP translation, but the invoice package owns invoice rules.

## API and Type Design

Prefer typed data over stringly contracts once a shape is known. Boundary code may decode JSON, CLI flags, CSV rows, or event payloads from loose input, but it should normalize that input into typed internal values before domain logic runs. Repeated `map[string]any`, `map[string]string`, raw string switches, or unstructured option bags inside core logic are review signals that the real contract is not visible in the type system.

Bad:

```go
func Apply(row map[string]string) error {
	if row["status"] == "posted" && row["amount"] == "" {
		return errors.New("missing amount")
	}
	return nil
}
```

Better:

```go
type Entry struct {
	Status Status
	Amount decimal.Amount
}

func Apply(entry Entry) error {
	if entry.Status == StatusPosted && entry.Amount.IsZero() {
		return errors.New("posted entry amount is required")
	}
	return nil
}
```

The better version makes the contract visible. Parsing code can still accept CSV or JSON, but core logic receives a value it can reason about.

Keep exported surface area intentional. Exported identifiers need clear names, comments, and stable semantics. Internal helpers should stay unexported until another package truly needs them. Interfaces are valuable when they express a real boundary such as storage, clock, process execution, HTTP transport, validation, or event delivery. An interface that only mirrors one concrete type in the same package usually adds indirection without ownership clarity.

Constructors and functions should make dependencies explicit. Hidden reads from environment variables, mutable package globals, implicit default clients, or background initialization make tests and reviews less reliable. When process-global behavior is truly required, isolate it at the boundary and pass explicit values into the rest of the code.

Source transformation code needs structural review. Parsers, formatters, compilers, code generators, and linters should parse the source language deliberately instead of scanning with brittle string rules. They should preserve surrounding source shape where that is part of the contract, fail closed on unsupported constructs, produce stable diagnostics, write no partial output on source errors, generate `gofmt`-clean Go, and keep golden plus command-surface tests for generated output.

Expression, query, and rule evaluators need safety review. User-provided expressions should be parsed and evaluated by side-effect-free libraries with explicit dialects, typed errors, stable source spans, and limits for source length, AST size, recursion depth, evaluation steps, collection sizes, and numeric overflow or division behavior. Reviewers should reject evaluators that can reach the filesystem, environment, network, reflection, time, or unbounded loops unless those effects are the documented product contract.

Bad:

```go
func Eval(expr string) (any, error) {
	return runJavaScript(expr) // Can loop forever and access host APIs.
}
```

Better:

```go
type Limits struct {
	MaxSourceBytes int
	MaxEvalSteps   int
}

func Eval(expr string, vars Vars, limits Limits) (Value, error) {
	ast, err := parseFormula(expr, limits.MaxSourceBytes)
	if err != nil {
		return Value{}, err
	}
	return evalSideEffectFree(ast, vars, limits.MaxEvalSteps)
}
```

The better version names the dialect and limits. A reviewer can ask whether each limit has tests.

Import, extraction, and mapping code should make user intent explicit. Prefer canonical domain keys when source data already has them. When a source uses non-canonical headers, aliases, prior-year inputs, or external workspace data, require a versioned profile, schema metadata, flag, or other configured mapping with documented override order. Unknown, missing, or ambiguous mappings should fail with deterministic diagnostics rather than silently guessing.

Bad:

```go
func mapColumn(name string) string {
	if strings.Contains(strings.ToLower(name), "date") {
		return "posting_date"
	}
	return name
}
```

Better:

```go
func mapColumn(profile Profile, name string) (FieldID, error) {
	field, ok := profile.Columns[name]
	if !ok {
		return "", fmt.Errorf("profile %q: unknown column %q", profile.Name, name)
	}
	return field, nil
}
```

Guessing can silently import the wrong data. A configured mapping makes the user's intent reviewable.

## Control Flow and Readability

Review whether a reader can follow the main path without holding too much state in memory. Deep nesting, long functions that mix parsing, validation, mutation, and output, boolean parameters whose meaning is unclear at the call site, and helpers named after implementation details are signs that responsibilities are tangled.

Split code when the split names a real concept. Good helper extraction makes invariants, error paths, or side effects easier to see. Bad helper extraction hides simple code behind vague names such as `handle`, `process`, `doThing`, or `runInternal`. A review should prefer small, meaningful units over both giant functions and ornamental abstraction.

Data mutation should be visibly staged. For commands that change repository data, reviewers should be able to see validation before mutation, deterministic ordering before write, and rollback or no-partial-write behavior on failure. If a function writes as it validates, or appends data before all preconditions are known, flag it.

Bad:

```go
for _, row := range rows {
	item, err := parse(row)
	if err != nil {
		return err // Earlier rows may already be written.
	}
	if err := store.Append(item); err != nil {
		return err
	}
}
```

Better:

```go
items, err := parseAll(rows)
if err != nil {
	return err
}
sort.Slice(items, func(i, j int) bool { return items[i].ID < items[j].ID })
return store.ReplaceAll(items)
```

The better version proves validation happens before mutation and writes in a deterministic order.

Destructive mutation should be opt-in and policy-backed. Review delete, rename, overwrite, schema-field removal, and type-change paths for explicit force flags or schema policy, compatibility checks before writes, preservation of unknown descriptor fields, and canonical serialization after mutation. Code that rewrites unrelated rows, reorders schema fields by accident, drops extension metadata, or deletes referenced resources by default is not just risky; it changes the data contract.

Batch command runners need preflight review. A runner that executes command files, migration plans, or generated operation batches should tokenize and validate the whole batch before running the first mutating command, expose check-only and trace modes where useful, and document the transaction scope honestly. If it accepts a command language rather than a shell, reviewers should verify that shell features such as pipes, redirection, variable expansion, command substitution, and separators are not interpreted accidentally.

Bad:

```go
for scanner.Scan() {
	if err := executeLine(scanner.Text()); err != nil {
		return err
	}
}
```

Better:

```go
plan, err := ParseBatch(r)
if err != nil {
	return err
}
if err := plan.Validate(catalog); err != nil {
	return err
}
if checkOnly {
	return plan.Trace(w)
}
return runner.Apply(plan)
```

The better version lets the reviewer see the parse, validate, trace, and mutate phases.

## Errors and Diagnostics

Expected failures should return errors, not panic. Panic is appropriate only for programmer errors or impossible states where continuing would hide corruption. User input, missing files, validation failures, bad flags, denied permissions, unavailable local services, and malformed external payloads are ordinary errors.

Bad:

```go
func LoadConfig(path string) Config {
	b, err := os.ReadFile(path)
	if err != nil {
		panic(err)
	}
	return mustParseConfig(b)
}
```

Better:

```go
func LoadConfig(path string) (Config, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return Config{}, fmt.Errorf("read config %q: %w", path, err)
	}
	cfg, err := parseConfig(b)
	if err != nil {
		return Config{}, fmt.Errorf("parse config %q: %w", path, err)
	}
	return cfg, nil
}
```

The better version reports the failing operation and keeps the caller in control.

Errors should carry enough context for the caller to produce deterministic diagnostics. Review error messages for stable identifiers: dataset, field, primary key, command, route, event type, or workspace-relative path. Avoid diagnostics that depend only on incidental row numbers, temporary absolute paths, map iteration order, or host-specific wording when a stable domain identifier is available.

CLI behavior is part of the API. Normal results go to stdout or `--output`; diagnostics, warnings, and errors go to stderr. Invalid usage should be distinguishable from runtime failure. Help and version output should be deterministic. A review should flag code that mixes human diagnostics into structured output or hides failure detail behind a generic `failed` message.

When output is fixed text, prefer direct writer methods or `io.WriteString` over formatting calls. Formatting APIs are appropriate when formatting is actually needed; otherwise they add noise and can blur whether the code is producing structured results or diagnostics.

Bad:

```go
fmt.Fprintf(w, "ok\n")
```

Better:

```go
_, _ = io.WriteString(w, "ok\n")
```

Use `fmt.Fprintf` when there is real formatting, such as `fmt.Fprintf(w, "created %s\n", id)`.

New user-visible flags and modes need coupled-surface review. A flag is not complete when parsing works; help text, validation, README or docs examples, OpenAPI/OpenCLI or other machine-readable metadata, unit tests, and e2e coverage must move together.

## Context, Resources, and Concurrency

Cancelable work should accept and pass `context.Context`. This includes HTTP calls, event listeners, long-running validation, subprocesses, server loops, and work that may block on I/O. Do not store ordinary business values in context; pass them as typed parameters.

Resource ownership must be visible. Files, response bodies, locks, temporary directories, subprocess handles, tickers, and goroutines need clear lifetime management. Reviewers should look for cleanup immediately after successful acquisition, response bodies that are drained and closed when reuse matters, goroutines with cancellation paths, and channels with an obvious owner.

Bad:

```go
resp, err := client.Get(url)
if err != nil {
	return err
}
return decode(resp.Body) // Body is never closed.
```

Better:

```go
resp, err := client.Get(url)
if err != nil {
	return err
}
defer resp.Body.Close()
return decode(resp.Body)
```

When HTTP connection reuse matters, also drain the body according to the package's transport policy.

Post-response work needs an intentional context. Request context cancellation should stop request-scoped work, but it must not silently erase billing, audit, usage, cleanup, or publication records that the system is required to keep after a response is sent. Use a short, bounded background context or durable queue for those obligations, and test cancellation behavior explicitly.

Concurrency should make state ownership explicit. Shared mutable state should have clear synchronization. Background work should report errors or have an intentional failure policy. A goroutine launched from a request, command, or test without a stop path is a review finding unless the surrounding lifecycle proves it cannot leak. Prefer bounded worker pools and bounded queues over unbounded goroutine creation, and do not hold locks while doing network or disk I/O.

Bad:

```go
func handle(w http.ResponseWriter, r *http.Request) {
	go publishAudit(r.Context(), eventFrom(r))
	w.WriteHeader(http.StatusAccepted)
}
```

Better:

```go
func handle(w http.ResponseWriter, r *http.Request) {
	event := eventFrom(r)
	if err := auditQueue.Enqueue(r.Context(), event); err != nil {
		http.Error(w, err.Error(), http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusAccepted)
}
```

The better version gives the work an owned queue and a visible error path.

Repeated timers and tickers need review. `time.After` inside loops allocates repeatedly and can hide lifecycle problems; prefer a reused timer or ticker with explicit stop behavior.

## Determinism and Side Effects

For the same inputs and environment, code should produce the same outputs. Review map iteration used for user-visible ordering, timestamps created without injection in testable logic, random identifiers without deterministic seeds where repeatability matters, and diagnostics that depend on local absolute paths.

Build and runtime defaults are part of determinism when they affect released artifacts or CI evidence. Review whether builds use reproducible settings such as trimmed paths, read-only module resolution in tests, intentional VCS metadata handling, and documented CGO or runtime tuning choices. Advanced knobs such as PGO, `GOAMD64`, `GOGC`, `GOMEMLIMIT`, and `GOMAXPROCS` need realistic workload evidence rather than local guesswork.

When code supports multiple storage or delivery backends, review semantic parity across every supported mode. Filesystem, PCSV, SQL, memory, Redis, PostgreSQL, broadcast, and work-queue paths should preserve the same logical contract unless a difference is explicitly documented. Security filtering, account isolation, ordering, acknowledgement, retry, dead-letter, schema validation, and canonical export/import behavior must not exist only on the easiest backend.

Storage and event backends should keep mechanical concerns separate from domain policy. A backend may persist deterministic tables, schemas, events, cursors, and operational state, but domain modules still own business rules, destructive-change policy, and user-facing invariants. Schema evolution and migrations should be transparent, versioned, and reviewable rather than hidden in ad hoc compatibility code.

Stateful workflows need idempotency review. Replay logs, import plans, provider events, and migration steps should have stable operation identifiers, explicit guards or idempotency keys, deterministic ordering, and clear applied, skipped, and failed outcomes. Dry-run paths must not mutate state. A review should flag workflow code that cannot safely retry after partial failure, treats duplicate external events as new work, or lets inactive, canceled, or failed states retain privileges such as paid entitlements.

Event-backed and delegated operations need correlation review. When an HTTP provider or CLI delegates work through events, queues, workers, or runtime integrations, the request and response should carry stable correlation identifiers, caller or account identity should be derived from verified context, and lifecycle ownership should be clear. Reviewers should flag code that publishes work without a way to match the response, exposes internal runner controls through end-user routes, or lets provider-specific runtime details leak into a provider-neutral API layer.

Network, Git, Docker, browser, and filesystem side effects should be explicit parts of the command or test contract. Core library code should not unexpectedly shell out, mutate unrelated files, read global configuration, or reach the network. If such behavior is required, it belongs behind a small boundary that tests can replace.

Subprocesses should use explicit binaries and argument lists. Shell-based `exec.Command("sh", "-c", ...)` or equivalent command strings are harder to quote, audit, and test than direct `exec.CommandContext` calls.

Bad:

```go
cmd := exec.Command("sh", "-c", "bus export "+workspace)
```

Better:

```go
cmd := exec.CommandContext(ctx, "bus", "export", workspace)
```

The better version avoids accidental shell expansion and makes arguments unambiguous.

Environment and configuration reads should be localized. `os.Getenv` and `os.LookupEnv` belong in configuration loading or process-boundary code, not scattered through business logic. Pass the resolved configuration into packages as typed values.

Bad:

```go
func Send(msg Message) error {
	baseURL := os.Getenv("BUS_API_URL")
	return post(baseURL, msg)
}
```

Better:

```go
type Client struct {
	BaseURL string
	HTTP    *http.Client
}

func (c Client) Send(ctx context.Context, msg Message) error {
	return post(ctx, c.HTTP, c.BaseURL, msg)
}
```

The better version is easier to test and makes the configuration dependency visible.

Do not hide portability assumptions. Code that depends on Unix-only syscall shapes, localhost reachability from containers, executable architecture, filesystem case behavior, shell quoting, or platform-specific paths needs a portability review. The improvement is usually to use a standard library abstraction, isolate the platform-specific piece, or add a deterministic capability probe and skip path in tests.

External runner integrations should not hide policy decisions. Runtime selection, model choice, timeout, sandbox policy, and output mode should be explicit inputs or stored preferences with deterministic fallback diagnostics. Prompt or template rendering should fail before external execution when required variables are missing. The runner layer should return typed outcomes such as usage error, execution failure, and timeout, and it should not smuggle in workflow semantics, Git operations, provider SDK calls, hidden network access, or workspace dataset I/O.

## HTTP and Service Boundaries

HTTP handlers should decode into typed request DTOs at the boundary, enforce request body limits, and reject unknown JSON fields unless the API contract explicitly allows extension fields. A handler that decodes directly from an unbounded body or accepts arbitrary JSON shape makes abuse cases and client mistakes harder to detect.

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

Services should own explicit server and mux values. Avoid package-level `http.ListenAndServe`, default `http.HandleFunc`, and default-client shortcuts such as `http.Get` in production paths. Use an `http.Server` with explicit read, write, idle, header, and body limits, and use shared `http.Client` values with owned transports rather than creating clients per request.

Local service boundaries need path and capability review. Workspace roots, mounted module bases, token prefixes, read-only gates, and provider allowlists are security boundaries, not string conveniences. Review path normalization for traversal outside the workspace or mount, ensure capability URLs and tokenized prefixes are required consistently, and check that provider or module loading is deny-by-default unless explicit wildcard discovery is part of the documented contract.

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

The better version treats the workspace root as a boundary. In production code, also account for symlink policy when it matters.

Capability, tool, and metadata endpoints need exposure review. Generated or discovered tools should be capability-driven, deny or confirm unknown writes by default, and never bypass authorization, tenancy, policy, or environment checks. Metadata endpoints should not wake expensive backends or expose internal provider topology unless the endpoint is explicitly an execution or operator surface.

TLS shortcuts are security findings. `InsecureSkipVerify: true` should be rejected unless there is a narrow, documented verification replacement and tests for the trust boundary.

Sensitive data must not be logged. Email addresses, OTPs, JWTs, refresh tokens, API keys, remote-access credentials, secrets, and raw delivery payloads require redaction or omission. Review logs, errors, test fixtures, examples, and debug output for accidental credential disclosure.

Browser-adjacent Go should keep host APIs behind narrow adapters. Direct browser globals, JavaScript callbacks, DOM mutation, raw HTML, and runtime diagnostics should be owned by a small testable boundary. Rendering code must validate before serializing, escape text and attribute values, keep deterministic attribute ordering, and avoid serializing callback functions, secrets, or diagnostic metadata into DOM attributes. URL-bearing fields should accept only same-origin paths, host-resolved resources, or explicitly allowlisted HTTPS origins; reject `javascript:`, `data:`, path traversal, credential-bearing URLs, and sensitive-looking public runtime config keys before rendering or request execution.

Bad:

```go
fmt.Fprintf(w, `<a href="%s">%s</a>`, link.URL, link.Label)
```

Better:

```go
type LinkView struct {
	URL   SafeURL
	Label string
}

func NewLinkView(link Link) (LinkView, error) {
	url, err := ValidatePublicURL(link.URL)
	if err != nil {
		return LinkView{}, err
	}
	return LinkView{URL: url, Label: link.Label}, nil
}
```

Prefer `html/template` or the project's renderer helpers for output. The review point is that URLs and text are validated before they reach markup.

UI-producing Go should project before it renders. Provider DTOs, raw provider errors, authorization checks, and permission policy belong in provider or product projection code, not in generic renderers. View models should contain the visible labels, controls, events, errors, loading and empty states, links, and permissions needed by the renderer. Review generated or server-rendered UI for accessible names, form labels, text status changes, table headers, safe external-link attributes, and an audited sanitizer before any rich text or raw HTML reaches the tree.

## Validation and Domain Safety

Validation should be centralized around the owned contract. Schema validation checks shape, required fields, types, keys, and referential integrity. Logical validation enforces domain invariants such as balanced entries, allowed period state, idempotency, authorization scope, or append-only audit rules. A review should flag duplicated validators with different behavior, validation that happens only in the CLI but not the library, or mutation paths that bypass validation.

Audit, evidence, and other durable records need stable identity. Prefer stable IDs, canonical path forms, content hashes where integrity matters, immutable metadata for captured artifacts, and append-only or soft-delete workflows when history is part of the contract. Reviewers should flag code that links durable records by incidental filenames, rewrites audit metadata casually, or removes historical evidence instead of recording an explicit state change.

Money and other exact business quantities must not use `float32` or `float64`. Use decimal-safe representations such as scaled integers, exact decimals, or rational values according to the module contract. Reviewers should also watch for lossy string formatting, implicit timezone conversion, and parsing that accepts ambiguous dates or amounts without a documented rule.

Bad:

```go
total := 0.0
for _, line := range lines {
	total += line.Price * float64(line.Quantity)
}
```

Better:

```go
var total cents.Amount
for _, line := range lines {
	total = total.Add(line.Price.Mul(line.Quantity))
}
```

The better version uses an exact domain type, so rounding rules are explicit.

Security and access-control checks should be matrix-based, not one happy path. Protected APIs need coverage for no credential, malformed or wrong-audience credential where relevant, valid credential with insufficient scope, and valid credential with the exact required scope. A review should reject code that treats "any valid token" as sufficient for a protected endpoint family.

Example test shape:

```go
tests := []struct {
	name  string
	token string
	want  int
}{
	{"no token", "", http.StatusUnauthorized},
	{"wrong scope", tokenWith("events:read"), http.StatusForbidden},
	{"required scope", tokenWith("billing:write"), http.StatusAccepted},
}
```

The important part is the matrix. A single happy-path token does not prove authorization.

Authentication code needs extra review beyond ordinary request validation. OTPs and refresh tokens should be short-lived, one-time-use where applicable, and stored hashed or otherwise non-recoverable. Login and verification paths should rate-limit by stable normalized keys such as normalized email and client address. Account identity should come from provider-issued stable IDs or verified JWT claims, not email addresses or caller-supplied account metadata. Admin powers should be represented by scopes rather than boolean flags, and internal-token issuing must stay on a protected internal boundary.

Credential clients should not synthesize tokens or infer approval state locally. They should request tokens from the provider, store credentials only in explicit user or configured paths with restrictive permissions, avoid repository-local token files by default, and keep token storage, API base URL, timeout, and output format injectable for tests.

Cryptographic and authentication components should be replaceable at clear interfaces. Signers, verifiers, random sources, clocks, token stores, OTP senders, rate limiters, and internal-token authorizers are review points because hardcoding them makes rotation, migration, and deterministic security tests harder.

## Performance Review

Performance review starts with clarity and measurement. Do not request cleverness because code looks simple. Do flag obvious repeated work in measured or likely hot paths: compiling the same regexp inside a row loop, reparsing a whole dataset for every lookup, rebuilding row maps when indexed access would be clearer, creating HTTP clients per request, or allocating temporary structures whose size is known.

Bad:

```go
for _, row := range rows {
	if regexp.MustCompile(`^[A-Z0-9]+$`).MatchString(row.Code) {
		out = append(out, row)
	}
}
```

Better:

```go
var codeRE = regexp.MustCompile(`^[A-Z0-9]+$`)

for _, row := range rows {
	if codeRE.MatchString(row.Code) {
		out = append(out, row)
	}
}
```

This is worth flagging when the loop is on a hot path or the input can be large. For subtle changes, ask for a benchmark instead of guessing.

Optimization should preserve behavior first. A good performance finding states the repeated work, the expected scope of a cache or precomputed value, and the invariants that must not change. Avoid global caches across workspaces unless invalidation and ownership are obvious. Prefer per-schema, per-command, per-request, or per-validation-pass state when that matches the data lifetime.

Prefer streaming over full read-all patterns when full materialization is unnecessary. Buffer small repeated writes, avoid reflection or caller/stack capture in hot paths, reset pooled objects before reuse, and avoid `unsafe` unless measurement clearly justifies the risk.

Benchmarks should measure the hot path, not fixture setup. Review benchmark code for timers around setup and teardown, stable inputs, allocation reporting when relevant, and names that explain the compared shapes.

## Tests and Evidence

Every production behavior change needs automated tests. Unit tests should prove the library or package behavior directly. End-to-end tests should prove the command, service, browser, or integration surface that users or automation actually exercise. Bug fixes need a reproducing test for the defect path and a protecting test for the user-visible failure.

Example review comment:

> The unit test proves `ParsePlan` rejects duplicate IDs, but the CLI still needs an e2e test showing `bus plan apply` exits non-zero and writes the diagnostic to stderr. Otherwise the user-visible contract is not protected.

This kind of comment is specific: it says which layer is already covered and which layer is missing.

Prefer test-first or tight test-and-code lockstep for behavior changes. During review, a regression fix without a failing test that would have caught the defect is incomplete even if the patch looks correct.

Good tests are deterministic, isolated, and specific about the contract. They assert exit codes, stdout, stderr, response bodies, events, generated files, and repository state where those are part of behavior. They should avoid external network services and shared mutable state. When a strictly local host capability is optional, tests should probe it and skip with a precise reason rather than failing with an unrelated low-level error.

End-to-end suites should be quiet on success and detailed on failure. User-facing formatted output tests should pin locale or be explicitly locale-tolerant. If an e2e suite needs helper binaries, build them once through the module's normal build path instead of repeatedly paying `go run` compilation inside the suite.

A review should flag tests that only check "no error", depend on test execution order, use sleeps instead of synchronization, rely on the developer's machine state, or exercise only the CLI when the core behavior would be easier to prove through a package test. It should also flag code that is hard to test, because that usually means dependencies are hidden or responsibilities are mixed.

Quality evidence should include the repository's normal gates, not only a local package run. For Go changes, review whether formatting, vet/lint, security checks, race tests where relevant, fuzz tests for parsers or security-sensitive input, benchmarks for measured paths, module e2e, and root integration gates were run or intentionally scoped.

## Documentation and Traceability

Behavior changes need matching documentation. Review code comments, help text, README material, module docs, and public reference pages when the change alters user-visible behavior, CLI flags, API responses, validation rules, file formats, or architecture boundaries. Documentation can be concise, but it must not describe a shape the code no longer has.

Comments should preserve intent and invariants. They should explain ownership, safety constraints, non-obvious ordering, compatibility requirements, or why a simpler-looking change would be wrong. Every top-level production-code unit should have a short purpose comment, and non-obvious integration points should keep concise `Used by:` notes accurate during refactors. Comments that restate syntax should be removed or replaced with a better name.

Bad:

```go
// Loop over users.
for _, user := range users {
	process(user)
}
```

Better:

```go
// Process users in stable ID order so audit output is reproducible.
sort.Slice(users, func(i, j int) bool { return users[i].ID < users[j].ID })
for _, user := range users {
	process(user)
}
```

The better comment explains the invariant a future edit must preserve.

## Finding Patterns for LLM Review

An automated reviewer should prefer these finding shapes:

- `wrong owner`: behavior lives in a package, module, handler, or CLI layer that does not own the concept.
- `boundary bypass`: code shells out, hardcodes paths, imports internals, or reaches another module through an unstable route.
- `untyped core contract`: known data shapes stay as generic maps, strings, or `any` after boundary parsing.
- `hidden dependency`: code reads environment, globals, time, randomness, network, filesystem, or process state without an explicit boundary.
- `brittle source transform`: parser, formatter, compiler, generator, or linter logic scans text loosely, loses surrounding code shape, writes partial output after diagnostics, or lacks golden and command-surface coverage.
- `unsafe expression evaluator`: user-provided formulas, queries, or rules can perform hidden side effects, panic, run unbounded, overflow silently, or fail without typed source-span diagnostics.
- `implicit data mapping`: import, extract, migration, or carry-forward code guesses column aliases, domain keys, prior-year inputs, or external workspace state instead of requiring explicit mapped configuration.
- `process exit leak`: package or library code calls `os.Exit` instead of returning an error or exit code to `main`.
- `mixed responsibilities`: one function or type combines parsing, validation, mutation, output, and transport concerns.
- `non-deterministic output`: user-visible ordering, diagnostics, IDs, timestamps, or paths can vary without a documented reason.
- `non-reproducible build path`: build flags, module resolution, VCS metadata, or runtime tuning make artifacts or CI evidence vary without justification.
- `non-idempotent workflow`: replay, import, migration, provider-event, or state-transition code lacks stable operation IDs, retry guards, duplicate-event protection, or dry-run no-mutation proof.
- `backend parity gap`: one storage or delivery backend enforces different validation, authorization, ordering, acknowledgement, retry, migration, or export semantics without a documented contract.
- `weak error context`: an error loses the dataset, field, operation, identifier, route, or event type needed to act on it.
- `state transition leak`: canceled, inactive, failed, or unauthorized state can still retain capabilities, entitlements, or publication effects.
- `uncorrelated delegation`: HTTP, CLI, event, queue, or worker code publishes delegated work without stable request/response correlation, caller identity, lifecycle ownership, or provider-neutral boundaries.
- `destructive default`: delete, rename, overwrite, schema removal, or type-change behavior proceeds without explicit policy, compatibility checks, or no-partial-write guarantees.
- `schema clobber`: data or descriptor rewrites drop unknown metadata, reorder fields unexpectedly, or serialize non-canonically.
- `batch preflight gap`: script, replay, migration, or command-file execution starts mutating before validating the full batch, misstates transaction scope, or accidentally interprets shell features.
- `validation bypass`: one mutation path can write data without the same schema and logical checks as the normal path.
- `weak audit identity`: durable records use incidental filenames or mutable metadata instead of stable IDs, canonical paths, hashes, or append-only state changes.
- `auth boundary bypass`: code trusts caller-supplied account identity, boolean admin flags, synthesized tokens, recoverable OTPs, or unrate-limited auth paths.
- `hardcoded security primitive`: signer, verifier, clock, random source, credential store, or rate limiter is baked into core logic instead of sitting behind a replaceable boundary.
- `ambiguous external runner`: runtime or model selection silently chooses a detected tool, renders templates after starting execution, returns untyped failures, or mixes runner mechanics with workflow, Git, provider, or dataset policy.
- `side-effect leak`: files, response bodies, goroutines, subprocesses, locks, or temporary resources have unclear cleanup.
- `request-context write loss`: required billing, audit, usage, cleanup, or publication records depend on a request context that may be canceled after the client response.
- `unsafe service default`: HTTP code uses unbounded JSON decoding, default clients, default muxes, missing server timeouts, or disabled TLS verification.
- `unsafe tool exposure`: generated tools, MCP resources, or metadata endpoints expose write operations, internal topology, sensitive fields, or provider-specific behavior without capability policy, confirmation, and authorization checks.
- `path boundary escape`: workspace, module, artifact, or capability-token path handling can traverse outside its intended root or bypass a read-only, token, or allowlist gate.
- `secret disclosure`: logs, diagnostics, fixtures, examples, or debug output include credentials or security-sensitive payloads.
- `unsafe browser boundary`: rendering or WASM code reaches browser globals directly, accepts unsafe URLs, serializes callbacks/secrets into markup, skips escaping, or exposes unredacted runtime diagnostics.
- `raw provider UI`: renderers consume provider DTOs, raw provider errors, or authorization policy directly instead of receiving a projected safe view model.
- `inaccessible rendered output`: generated or server-rendered UI lacks accessible names, labels, text status, table headers, safe external-link attributes, or sanitizer-backed rich text handling.
- `missing contract test`: changed behavior lacks direct unit coverage or user-visible end-to-end coverage.
- `weak test harness`: tests are noisy on success, locale-sensitive by accident, sleep-based, order-dependent, or repeatedly compile helpers instead of using the normal build path.
- `performance trap`: a hot path repeats parsing, regex compilation, dataset scans, allocation-heavy row hydration, or client construction.
- `stale contract docs`: docs, help, examples, or comments describe a different behavior than the implementation.

Each finding should include a concrete improvement. For example, "move this validation into the library and call it from both CLI and API paths", "normalize the decoded map into a typed struct before domain logic", "sort by stable identifier before rendering", or "inject a clock so tests can assert deterministic timestamps".

A useful automated finding should read like this:

```text
wrong owner: cmd/bus-invoice/create.go validates invoice balance in the HTTP
handler. Move the balance check into the invoice package and call it from both
CLI and API paths so every mutation path enforces the same invariant.
```

Avoid vague findings such as "make this cleaner" or "refactor this function". They do not tell the developer what behavior is at risk.

## Compact Checklist

Before approving Go code, confirm that the owner and layer are right, the public contract is typed and small, errors are explicit and deterministic, side effects are visible, resources have lifetimes, validation happens before mutation, tests prove both package behavior and user-visible behavior, and documentation matches the code. If any of those are unclear, the review is not done.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./developer-module-workflow">Developer module workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./go-optimization-guide">Go optimization guide</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Testing strategy](../testing/testing-strategy)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Independent modules](../architecture/independent-modules)
- [Shared validation layer](../architecture/shared-validation-layer)
- [Module CLI reference index](../modules/)
