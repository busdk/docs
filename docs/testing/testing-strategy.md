## Testing strategy

Each module is tested using standard unit testing rules for its implementation language. Go modules use `go test` and idiomatic Go test structure by default. Unit tests focus on deterministic behavior for parsing, validation, schema enforcement, and dataset transformations, and they must be runnable without network dependencies or external services so they remain stable across local runs and CI.

Every command exposed by a module is also covered by a simple end-to-end bash test that executes the command against a fixture workspace, asserts on standard output and standard error, and verifies repository data changes on disk. These end-to-end tests live alongside the module they verify, but they run in an isolated Git repository per command so each test is independent and does not share state or side effects with other tests. The test harness initializes a fresh repository, applies only the fixtures required for the command under test, and verifies exit codes and outputs deterministically.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">BusDK Design Spec: Testing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../compliance/fi-bookkeeping-and-tax-audit">Finnish bookkeeping and tax-audit compliance</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
