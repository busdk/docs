---
title: Go optimization guide
description: Practical Go performance guide for production services: anti-pattern fixes with bad-vs-better code, pprof/trace/bench workflows, and reproducible build/runtime tuning flags.
---

## Practical optimization workflow

Go optimization work is most reliable when each change has one measurable target, one code change, and one rollback path. Use profiling to pick the target first, then keep the change set small and verify with benchmarks and production-safe rollout checks.

### Profiling-first loop

Use this loop for every optimization: collect profiles from realistic load, apply one change, then compare before and after. This avoids shipping “faster-looking” refactors that only move cost from CPU to memory or from throughput to tail latency.

```bash
curl -sS 'http://127.0.0.1:6060/debug/pprof/profile?seconds=30' -o cpu.pprof
curl -sS 'http://127.0.0.1:6060/debug/pprof/allocs' -o allocs.pprof
go tool pprof cpu.pprof
```

## Concrete code examples

The sections below are intentionally grep-friendly. Each one shows code that often appears in reviews as a performance anti-pattern, followed by a safer replacement.

### Preallocation in hot loops

When row counts are known or bounded, preallocating slices and maps usually removes a large amount of allocation churn.

```go
// Bad: repeated growth and reallocation.
func collectBad(ids []int) map[int]struct{} {
	m := map[int]struct{}{}
	for _, id := range ids {
		m[id] = struct{}{}
	}
	return m
}
```

When a function must allocate its own output, reserve capacity once.

```go
// Better: reserve capacity once.
func collectBetter(ids []int) map[int]struct{} {
	m := make(map[int]struct{}, len(ids))
	for _, id := range ids {
		m[id] = struct{}{}
	}
	return m
}
```

In tight loops, caller-managed reuse is usually the strongest pattern.

```go
// Best when feasible: caller owns allocation and reuse.
func collectInto(dst map[int]struct{}, ids []int) map[int]struct{} {
	clear(dst)
	for _, id := range ids {
		dst[id] = struct{}{}
	}
	return dst
}
```

### String building without `fmt` on hot paths

`fmt.Sprintf` is great for readability, but repeated formatting in request-critical loops often adds avoidable CPU and allocations.

Before replacing `fmt` with a faster formatter, confirm the value is needed at all. In many paths the best optimization is to delete unused string construction completely.

If the next layer can consume structured values, pass typed fields (for example `user` and `count`) through the call boundary instead of formatting text.

```go
// Bad: formatting work on every call.
func lineBad(user string, n int) string {
	return fmt.Sprintf("user=%s count=%d", user, n)
}
```

When the formatted string is still required, a builder-based implementation is often cheaper on hot paths.

```go
// Better: explicit builder and strconv.
func lineBetter(user string, n int) string {
	var b strings.Builder
	b.Grow(len(user) + 24)
	b.WriteString("user=")
	b.WriteString(user)
	b.WriteString(" count=")
	b.WriteString(strconv.Itoa(n))
	return b.String()
}
```

Another common win is to move reusable formatting outside loops or helper calls. If the message is static, create it once and reuse it instead of formatting each failure path.

```go
// Bad: allocates and formats a new error each time.
func parseBad(tokens []string) error {
	for _, t := range tokens {
		if t == "" {
			return fmt.Errorf("bad token")
		}
	}
	return nil
}
```

For static messages, define the error once and reuse it.

This keeps allocation and formatting out of failure-heavy loops and makes the reuse intent explicit in reviews.

```go
var ErrBadToken = errors.New("bad token")

// Better: reuse a sentinel error when context is static.
func parseBetter(tokens []string) error {
	for _, t := range tokens {
		if t == "" {
			return ErrBadToken
		}
	}
	return nil
}
```

### Avoid interface boxing on hot paths

Unnecessary `any` and interface boxing can add allocation and dispatch overhead in tight loops.

```go
// Bad: boxes to any on return path.
func sumBad(xs []int) any {
	var s int
	for _, x := range xs {
		s += x
	}
	return any(s)
}
```

Keep hot paths strongly typed unless dynamic behavior is required.

```go
func sumBetter(xs []int) int {
	var s int
	for _, x := range xs {
		s += x
	}
	return s
}
```

### Reuse `http.Client` and `http.Transport`

A shared client and transport keep connection reuse effective and reduce handshake and socket churn.

```go
// Bad: new client/transport for each call.
func fetchBad(url string) (*http.Response, error) {
	c := &http.Client{Timeout: 2 * time.Second}
	return c.Get(url)
}
```

Prefer one shared transport and one shared client for the process lifetime.

```go
// Better: one shared transport/client with tuned pool settings.
var sharedTransport = func() *http.Transport {
	t := http.DefaultTransport.(*http.Transport).Clone()
	t.MaxIdleConns = 200
	t.MaxIdleConnsPerHost = 100
	t.MaxConnsPerHost = 100
	return t
}()

var sharedClient = &http.Client{
	Timeout:   2 * time.Second,
	Transport: sharedTransport,
}

func fetchBetter(url string) (*http.Response, error) {
	return sharedClient.Get(url)
}
```

### Reuse and tune `http.Transport` explicitly

Transport reuse is mandatory for connection pooling behavior. Per-request transport construction defeats keep-alive and raises dial and TLS overhead.

```go
// Bad: allocates a fresh transport repeatedly.
func newTransportBad() *http.Transport { return &http.Transport{} }
```

Clone and tune a shared transport once for process lifetime.

```go
var tunedTransport = func() *http.Transport {
	t := http.DefaultTransport.(*http.Transport).Clone()
	t.MaxIdleConns = 256
	t.MaxIdleConnsPerHost = 128
	t.MaxConnsPerHost = 128
	return t
}()
```

### Always drain and close response bodies

Closing without draining can reduce keep-alive reuse on call paths that do not fully consume the body.

```go
resp, err := sharedClient.Get(url)
if err != nil {
	return err
}
defer resp.Body.Close()

if _, err := io.Copy(io.Discard, resp.Body); err != nil {
	return err
}
```

### Bounded goroutines with backpressure

Unbounded goroutine creation often hides queueing problems until memory and tail latency spike.

```go
// Bad: unbounded worker creation.
for _, job := range jobs {
	go process(job)
}
```

Use fixed workers and a bounded queue to cap concurrency and apply backpressure.

```go
// Better: fixed workers + bounded queue.
jobsCh := make(chan Job, 256)
var wg sync.WaitGroup
for i := 0; i < 16; i++ {
	wg.Add(1)
	go func() {
		defer wg.Done()
		for job := range jobsCh {
			process(job)
		}
	}()
}

for _, job := range jobs {
	select {
	case jobsCh <- job:
	default:
		return errors.New("queue full")
	}
}
close(jobsCh)
wg.Wait()
```

### Avoid unbounded queue growth

Queueing without explicit limits converts load spikes into memory growth and tail-latency failures.

```go
// Bad: producer can enqueue indefinitely.
go func() {
	for {
		jobs <- Job{}
	}
}()
```

Use bounded queues and explicit overload behavior.

```go
select {
case jobs <- Job{}:
default:
	return errors.New("overloaded")
}
```

### `sync.Pool` usage with reset discipline

`sync.Pool` is useful for temporary objects under load, but pooled buffers must be reset before reuse.

```go
var bufPool = sync.Pool{New: func() any { return new(bytes.Buffer) }}

// Bad: old content and capacity behavior leak across uses.
func writeBad(w io.Writer, s string) {
	b := bufPool.Get().(*bytes.Buffer)
	b.WriteString(s)
	_, _ = w.Write(b.Bytes())
	bufPool.Put(b)
}
```

Reset pooled buffers before reuse.

```go
// Better: reset before use.
func writeBetter(w io.Writer, s string) {
	b := bufPool.Get().(*bytes.Buffer)
	b.Reset()
	b.WriteString(s)
	_, _ = w.Write(b.Bytes())
	bufPool.Put(b)
}
```

### Typed JSON decode instead of `map[string]any`

Typed decode avoids repeated dynamic type assertions and typically reduces allocation pressure in high-volume paths.

```go
// Bad: dynamic map decoding.
func decodeBad(r io.Reader) (map[string]any, error) {
	var v map[string]any
	err := json.NewDecoder(r).Decode(&v)
	return v, err
}
```

Prefer typed decode for stable request and response contracts.

```go
type payload struct {
	User  string `json:"user"`
	Count int    `json:"count"`
}

// Better: typed struct decode.
func decodeBetter(r io.Reader) (payload, error) {
	var p payload
	dec := json.NewDecoder(r)
	dec.DisallowUnknownFields()
	if err := dec.Decode(&p); err != nil {
		return payload{}, err
	}
	return p, nil
}
```

If profiles still show JSON as a dominant hotspot after typed decoding, benchmark a faster JSON library with your real payloads. Keep the swap behind a small package boundary so you can revert quickly and keep behavior deterministic.

```go
// Keep call sites stable behind a small adapter.
type JSONCodec interface {
	Unmarshal([]byte, any) error
	Marshal(any) ([]byte, error)
}

// Default implementation can wrap encoding/json.
type StdJSONCodec struct{}

func (StdJSONCodec) Unmarshal(b []byte, v any) error { return json.Unmarshal(b, v) }
func (StdJSONCodec) Marshal(v any) ([]byte, error)   { return json.Marshal(v) }
```

When evaluating alternatives, benchmark both speed and compatibility behavior, especially number handling, unknown fields, and HTML escaping defaults.

### Keep reflection out of hot paths

Reflection is useful for tooling and generic wiring, but repeated runtime field lookup in request paths is expensive.

```go
// Bad: field lookup by name for each call.
func getFieldBad(v any, name string) (any, bool) {
	rv := reflect.ValueOf(v)
	f := rv.FieldByName(name)
	if !f.IsValid() {
		return nil, false
	}
	return f.Interface(), true
}
```

Prefer typed dispatch or generated mapping in hot paths.

```go
type userRow struct{ ID int; Name string }

func getFieldBetter(u userRow, name string) (any, bool) {
	switch name {
	case "ID":
		return u.ID, true
	case "Name":
		return u.Name, true
	default:
		return nil, false
	}
}
```

### Avoid reflection-heavy ORM mapping on hot endpoints

Row-by-row reflection mappers can dominate CPU on large list and report endpoints.

```go
// Bad: reflective row mapping in request path.
func mapRowBad(dst any, row map[string]any) {}
```

Prefer typed scan/mapping for high-volume paths.

```go
type accountRow struct {
	ID   string
	Name string
}
```

### Avoid holding locks during I/O

Contention climbs quickly when locks cover network or disk operations.

```go
var mu sync.Mutex
var cfg Config

// Bad: lock held during network I/O.
func callBad() error {
	mu.Lock()
	defer mu.Unlock()
	_, err := sharedClient.Get(cfg.URL)
	return err
}
```

Take a local snapshot, then release the lock before external I/O.

```go
// Better: copy needed state, then unlock before I/O.
func callBetter() error {
	mu.Lock()
	url := cfg.URL
	mu.Unlock()
	_, err := sharedClient.Get(url)
	return err
}
```

### Keep logging lazy on request paths

Compute expensive log values only when the selected log level will emit the record.

```go
// Bad: expensive value always computed.
logger.Debug("request", "summary", summarizeLargeObject(obj))
```

Use lazy value construction so work happens only when the log line is emitted.

```go
type lazySummary struct{ v LargeObject }

func (l lazySummary) LogValue() slog.Value {
	return slog.StringValue(summarizeLargeObject(l.v))
}

// Better: value computed only when emitted.
logger.Debug("request", "summary", lazySummary{v: obj})
```

### Avoid expensive caller or stack capture in hot logs

Source and stack metadata is useful, but collecting it on high-frequency paths can become a measurable CPU tax.

```go
// Bad: computes expensive diagnostics regardless of level policy.
logger.Debug("request", "stack", debug.Stack())
```

Gate expensive diagnostics behind level checks or slower paths.

```go
if logger.Enabled(context.Background(), slog.LevelDebug) {
	logger.Debug("request", "stack", string(debug.Stack()))
}
```

### Keep log volume bounded with levels and sampling

Per-request info-level logs can become dominant CPU and I/O cost at scale.

```go
// Bad: logs every request with expensive attributes.
slog.Info("request", "url", r.URL.String(), "headers", r.Header)
```

Prefer structured fields with strict level policy and sampling at hot edges.

```go
slog.Debug("request", "url", &r.URL)
```

### Avoid `defer` resource cleanup across long loops

`defer` is usually fine, but deferring close in a long loop delays cleanup until function return.

```go
// Bad: files remain open until the end.
for _, name := range files {
	f, err := os.Open(name)
	if err != nil {
		return err
	}
	defer f.Close()
}
```

Use a per-iteration scope so each resource closes promptly.

```go
// Better: close per-iteration.
for _, name := range files {
	f, err := os.Open(name)
	if err != nil {
		return err
	}
	func() {
		defer f.Close()
		_ = useFile(f)
	}()
}
```

### Prefer values over slices of pointers when mutation is not needed

Slices of pointers add indirection and can reduce cache locality on tight iteration.

```go
type item struct{ X, Y int }

// Bad: allocates one object per element.
func makePtrsBad(n int) []*item {
	out := make([]*item, 0, n)
	for i := 0; i < n; i++ {
		out = append(out, &item{X: i})
	}
	return out
}
```

Prefer contiguous value slices when ownership allows it.

```go
func makeValsBetter(n int) []item {
	out := make([]item, n)
	for i := 0; i < n; i++ {
		out[i] = item{X: i}
	}
	return out
}
```

### Prefer streaming over read-all copy chains

Repeated full-buffer reads and conversions create avoidable allocations on request paths.

```go
// Bad: full body + extra copy to string.
b, _ := io.ReadAll(r.Body)
s := string(b)
_ = s
```

Stream decode or transform whenever full materialization is unnecessary.

```go
var p payload
_ = json.NewDecoder(r.Body).Decode(&p)
```

### Validate escape behavior for hot packages

Unexpected heap escapes can increase allocation and GC pressure.

```bash
go build -gcflags='all=-m' ./...
```

Use escape analysis as a diagnostics step and then validate with alloc profiles.

### Avoid `context.WithValue` as an option bag

Large config values in context hide dependencies and can increase memory retention.

```go
// Bad: opaque option transport via context.
ctx = context.WithValue(ctx, cfgKey, hugeConfig)
```

Prefer explicit parameters or a typed request struct.

```go
type requestCtx struct {
	Ctx context.Context
	Cfg *Config
}
```

### GC latency from large live heap

GC pain is often a live-heap retention problem, not only an allocation-rate problem. Unbounded caches and long-lived references keep memory alive and increase GC work.

```go
// Bad: unbounded cache growth.
var blobCache = map[string][]byte{}

func loadBad(k string) []byte {
	if v, ok := blobCache[k]; ok {
		return v
	}
	v := expensiveFetch(k)
	blobCache[k] = v
	return v
}
```

Prefer bounded retention so stale objects can be collected.

```go
type boundedCache struct {
	max int
	q   []string
	m   map[string][]byte
}

func (c *boundedCache) put(k string, v []byte) {
	if _, ok := c.m[k]; !ok && len(c.q) == c.max {
		evict := c.q[0]
		c.q = c.q[1:]
		delete(c.m, evict)
	}
	if _, ok := c.m[k]; !ok {
		c.q = append(c.q, k)
	}
	c.m[k] = v
}
```

### Reduce syscall volume with buffered I/O

Frequent small reads and writes increase syscall overhead and can dominate throughput-sensitive paths.

```go
// Bad: one write syscall per line.
func writeLinesBad(f *os.File, lines []string) error {
	for _, s := range lines {
		if _, err := f.WriteString(s + "\n"); err != nil {
			return err
		}
	}
	return nil
}
```

Batch writes with buffering to reduce kernel crossings.

```go
func writeLinesBetter(f *os.File, lines []string) error {
	w := bufio.NewWriter(f)
	for _, s := range lines {
		if _, err := w.WriteString(s); err != nil {
			return err
		}
		if err := w.WriteByte('\n'); err != nil {
			return err
		}
	}
	return w.Flush()
}
```

### Fix algorithmic complexity before micro-optimizing

An `O(n²)` hot path will dominate runtime regardless of low-level tuning.

```go
// Bad: O(n²) duplicate check.
func hasDupBad(xs []string) bool {
	for i := range xs {
		for j := i + 1; j < len(xs); j++ {
			if xs[i] == xs[j] {
				return true
			}
		}
	}
	return false
}
```

Use a better data structure first.

```go
func hasDupBetter(xs []string) bool {
	seen := make(map[string]struct{}, len(xs))
	for _, x := range xs {
		if _, ok := seen[x]; ok {
			return true
		}
		seen[x] = struct{}{}
	}
	return false
}
```

### Improve cache locality and reduce false sharing

Memory layout can limit throughput even when locks and allocations look fine.

```go
// Bad: adjacent atomics can contend on the same cache line.
type counter struct{ n uint64 }

var ctrs = make([]counter, 64)

func incBad(i int) { atomic.AddUint64(&ctrs[i].n, 1) }
```

Pad independent hot counters when profiling points to false sharing.

```go
type paddedCounter struct {
	n uint64
	_ [56]byte // 64-byte cache line on common amd64 systems
}

var ctrsPadded = make([]paddedCounter, 64)

func incBetter(i int) { atomic.AddUint64(&ctrsPadded[i].n, 1) }
```

### Avoid large value copies on hot paths

Passing large structs by value can add hidden copy cost in frequently called code.

```go
type big struct {
	a [1024]byte
	b [1024]byte
}

// Bad: value copy each call.
func scoreBad(x big) int { return int(x.a[0]) + int(x.b[0]) }
```

Use pointer parameters where measurement shows copy cost is meaningful.

```go
func scoreBetter(x *big) int { return int(x.a[0]) + int(x.b[0]) }
```

### Prevent goroutine leaks with cancellation

Background goroutines need a clear stop path. Without cancellation, blocked receives and sends can leak indefinitely.

```go
// Bad: no cancellation path.
func watchBad(ch <-chan string) {
	go func() {
		msg := <-ch
		_ = msg
	}()
}
```

Use context or done channels to guarantee shutdown behavior.

```go
func watchBetter(ctx context.Context, ch <-chan string) {
	go func() {
		select {
		case msg := <-ch:
			_ = msg
		case <-ctx.Done():
			return
		}
	}()
}
```

### Avoid channel busy loops and partial deadlocks

`select` with a `default` branch can create CPU spin loops when no work is available.

```go
// Bad: spins at 100% CPU when channel is empty.
func runBad(ch <-chan Job) {
	for {
		select {
		case j := <-ch:
			process(j)
		default:
		}
	}
}
```

Prefer blocking receives with explicit shutdown conditions.

```go
func runBetter(ch <-chan Job, done <-chan struct{}) {
	for {
		select {
		case j, ok := <-ch:
			if !ok {
				return
			}
			process(j)
		case <-done:
			return
		}
	}
}
```

### Keep startup paths light

Heavy `init` work can slow cold start and autoscaling responsiveness.

```go
// Bad: expensive eager startup.
var reBad = regexp.MustCompile(veryLargePattern)

func init() {
	loadBigDictionary()
}
```

Move non-critical setup to lazy or background initialization.

```go
var (
	reOnce sync.Once
	reGood *regexp.Regexp
)

func getRegexp() *regexp.Regexp {
	reOnce.Do(func() { reGood = regexp.MustCompile(veryLargePattern) })
	return reGood
}
```

### Use string primitives before regex in hot paths

Regex engines are powerful but expensive compared to direct string operations for simple prefix, suffix, or containment checks.

```go
// Bad
if re.MatchString(s) {
	handle()
}
```

Prefer `strings` helpers when they express the same rule.

```go
if strings.HasPrefix(s, "acct:") {
	handle()
}
```

## Build and runtime defaults

These defaults keep artifacts reproducible and predictable across developer machines and CI. Apply them as release defaults, then use explicit debug overrides for investigation builds.

### `-trimpath` for reproducible paths

Use `-trimpath` to remove machine-local paths from build artifacts. This reduces environment-specific differences between developer and CI outputs.

```bash
go build -trimpath ./cmd/myservice
```

### `-buildvcs=false` for deterministic build metadata

Use `-buildvcs=false` when you want deterministic binaries across detached checkouts and CI metadata variations.

```bash
go build -buildvcs=false ./cmd/myservice
```

### `-ldflags='-s -w'` for release binary size

Use `-ldflags='-s -w'` for release builds to strip symbol and DWARF data and reduce artifact size.

```bash
go build -ldflags='-s -w' ./cmd/myservice
```

### Keep optimized and debug builds separate

Keep release defaults optimized and reproducible. Use a separate debug target for investigation flags such as disabled inlining and extra compiler diagnostics.

```bash
make build
make build-debug DEBUG_GCFLAGS='all=-N -l -m'
```

### `-pgo` for profile-guided optimization

Enable `-pgo` only with representative production-like profiles and keep a non-PGO fallback build available.

```bash
go build -pgo=default.pgo ./cmd/myservice
```

### `GOAMD64` for CPU baseline tuning

`GOAMD64` can improve throughput on newer hardware, but it also raises minimum CPU requirements. Match the level to your oldest deployment target.

```bash
GOAMD64=v3 go build ./cmd/myservice
```

### `CGO_ENABLED=0` with `netgo,osusergo` for portable static behavior

Use pure-Go DNS and user lookup behavior when portability and minimal runtime dependencies matter more than libc-specific resolver behavior.

```bash
CGO_ENABLED=0 go build -tags='netgo,osusergo' ./cmd/myservice
```

### Tune `GOGC` for GC CPU vs memory tradeoff

`GOGC` changes GC frequency. Lower values reduce peak heap at the cost of more GC CPU; higher values trade memory for fewer collections.

```bash
GOGC=50 ./myservice
GOGC=150 ./myservice
```

### `-mod=readonly` for dependency stability

Keep dependency updates explicit. Use `-mod=readonly` in normal build and test flows, then run `go mod tidy` only when intentionally updating dependencies.

```bash
go test -mod=readonly ./...
go mod tidy
go test -mod=readonly ./...
```

### `GOMEMLIMIT` and `GOMAXPROCS` for container runtime behavior

Validate runtime memory and CPU settings in staging with realistic load. Go 1.25+ adjusts `GOMAXPROCS` from container CPU limits by default, but services should still verify effective runtime values and tail-latency behavior.

```bash
GOMEMLIMIT=1GiB ./myservice
GOMAXPROCS=4 ./myservice
```

## Benchmark and comparison workflow

Use repeated benchmark runs and compare with `benchstat` rather than relying on a single benchmark output.

```bash
go test ./... -run=^$ -bench=BenchmarkHotPath -benchmem -count=10 > old.txt
go test ./... -run=^$ -bench=BenchmarkHotPath -benchmem -count=10 > new.txt
benchstat old.txt new.txt
```

### Trace for blocking, network, and syscall analysis

Use trace when CPU or alloc profiles do not fully explain tail latency, blocking behavior, or scheduler delays.

```bash
curl -sS 'http://127.0.0.1:6060/debug/pprof/trace?seconds=5' -o trace.out
go tool trace trace.out
go tool trace -pprof=sync trace.out > sync.pprof
go tool trace -pprof=net trace.out > net.pprof
go tool trace -pprof=syscall trace.out > syscall.pprof
```

### Runtime metrics and CI guardrails

Track runtime metrics continuously and gate regressions in CI. At minimum, track goroutine count, heap growth, allocation rate, and GC CPU pressure, then pair those with benchmark trend checks.

Use canary rollout plus profile comparison for high-impact performance changes.

```yaml
# Example: minimal Prometheus alert ideas for Go runtime behavior.
groups:
  - name: go-runtime
    rules:
      - alert: GoGoroutinesHigh
        expr: go_goroutines > 2000
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High goroutine count"
      - alert: GoHeapGrowing
        expr: increase(go_memstats_heap_inuse_bytes[15m]) > 200000000
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Heap in-use growth trend"
```

```bash
# Example: CI perf gate step (baseline artifact + new run).
go test ./... -run=^$ -bench='BenchmarkHotPath$' -benchmem -count=10 > new.txt
benchstat old.txt new.txt
```

```bash
# Example: canary verification loop.
curl -sS 'http://127.0.0.1:6060/debug/pprof/profile?seconds=20' -o canary-cpu.pprof
curl -sS 'http://127.0.0.1:6060/debug/pprof/heap?gc=1' -o canary-heap.pprof
go tool pprof -top canary-cpu.pprof
```

### Continuous profiling in production

Point-in-time profiling is useful for incidents, but recurring regressions are easier to catch with continuous profiling.

Use a pprof-compatible pipeline (for example Pyroscope or Parca) and verify two properties before broad rollout: overhead on representative load and strict access control for collected profiling data.

```go
// Example: keep net/http/pprof on an internal-only admin listener.
func startDebugServer() {
	mux := http.NewServeMux()
	mux.HandleFunc("/debug/pprof/", pprof.Index)
	mux.HandleFunc("/debug/pprof/cmdline", pprof.Cmdline)
	mux.HandleFunc("/debug/pprof/profile", pprof.Profile)
	mux.HandleFunc("/debug/pprof/symbol", pprof.Symbol)
	mux.HandleFunc("/debug/pprof/trace", pprof.Trace)

	go func() {
		_ = http.ListenAndServe("127.0.0.1:6060", mux)
	}()
}
```

```bash
# Example: periodic profile capture job.
while true; do
  ts=$(date +%Y%m%d-%H%M%S)
  curl -sS "http://127.0.0.1:6060/debug/pprof/profile?seconds=20" -o "cpu-$ts.pprof"
  sleep 300
done
```

### Avoid unnecessary cgo in request-critical paths

cgo can be the right choice for specific capabilities, but boundary crossings and operational complexity can outweigh benefits on hot paths.

Prefer pure Go implementations unless profiling and benchmark data justify cgo.

### Avoid unsafe micro-optimizations without evidence

`unsafe` may reduce copies in narrow cases, but it increases correctness and maintenance risk.

```go
// Bad: unsafe conversion couples code to runtime representation details.
func bytesToStringBad(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}
```

Prefer safe conversions unless performance evidence and safety constraints are both explicit.

```go
func bytesToStringBetter(b []byte) string { return string(b) }
```

### Validate monetary CLI inputs without per-item `big.Rat` churn

Command validation can become a measurable cost when large `.bus` batches are preflighted before dispatch. In `bus/internal/dispatch`, the journal and bank validators currently parse monetary strings with fresh `big.Rat` values on each posting or `--set amount=...` field. That preserves exactness, but it also introduces high allocation rates when repeated across hundreds of commands.

Benchmarks in `bus/internal/dispatch/run_bench_test.go` show this pattern clearly on a representative development machine: `BenchmarkValidateJournalAddSingle` is about `859 ns/op` with `28 allocs/op`, `BenchmarkValidateBankAddTransactionsSingle` is about `314 ns/op` with `7 allocs/op`, and batch-level validation scales that overhead linearly (`BenchmarkValidateBusfileCommandsJournalAdd` about `214641 ns/op` with `7168 allocs/op` for 256 commands).

Use this benchmark loop to verify baseline and any optimization candidate before changing parser behavior:

```bash
go test ./internal/dispatch -run '^$' \
  -bench 'BenchmarkValidate(JournalAddSingle|BankAddTransactionsSingle|BusfileCommandsJournalAdd|BusfileCommandsBankAddTransactions)$' \
  -benchmem
```

The safer optimization direction is to keep exact decimal semantics while reducing temporary object churn, for example by using a lower-allocation decimal parser for validation-only checks and reusing parse buffers where possible. Keep error messages and accepted input formats stable, and rerun the same benchmarks plus command-level tests after each parser change.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./developer-module-workflow">Developer module workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./development-status">Development status — BusDK modules</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Implementation and development status](./index)
- [Module repository structure and dependency rules](./module-repository-structure)
- [Go command: build](https://pkg.go.dev/cmd/go#hdr-Compile_packages_and_dependencies)
- [Go diagnostics](https://go.dev/doc/diagnostics)
- [Go package: net/http/pprof](https://pkg.go.dev/net/http/pprof)
- [Go command: trace](https://pkg.go.dev/cmd/trace)
- [Go blog: Profile-guided optimization in Go 1.21](https://go.dev/blog/pgo)
- [Go 1.18 release notes (`GOAMD64`)](https://go.dev/doc/go1.18#amd64)
- [Go package: runtime/metrics](https://pkg.go.dev/runtime/metrics)
- [Go package: runtime/debug](https://pkg.go.dev/runtime/debug)
- [Go package: bufio](https://pkg.go.dev/bufio)
- [Go package: context](https://pkg.go.dev/context)
- [Go package: reflect](https://pkg.go.dev/reflect)
- [Go package: regexp](https://pkg.go.dev/regexp)
- [Go package: sync/atomic](https://pkg.go.dev/sync/atomic)
- [Go package: unsafe](https://pkg.go.dev/unsafe)
- [Go package: net](https://pkg.go.dev/net)
- [Go package: net/http](https://pkg.go.dev/net/http)
- [Go package: encoding/json](https://pkg.go.dev/encoding/json)
- [Go package: log/slog](https://pkg.go.dev/log/slog)
- [Go package: math/big](https://pkg.go.dev/math/big)
- [benchstat](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat)
- [json-iterator/go](https://github.com/json-iterator/go)
- [Pyroscope documentation](https://grafana.com/docs/pyroscope/latest/)
- [Parca documentation](https://www.parca.dev/docs/)
