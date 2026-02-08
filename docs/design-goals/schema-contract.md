## Schema-driven data contract (Frictionless Table Schema)

BusDK modules interoperate through shared tabular datasets: rows plus an explicit, machine-readable schema that defines the table’s field names, types, and constraints. The schema is part of the canonical dataset and travels with the data so that independent modules — and external tools — can validate and process tables consistently without sharing code.

Schemas are expressed using [Frictionless Data Table Schema](https://frictionlessdata.io/specs/table-schema/) (JSON). BusDK follows the upstream specification as closely as possible; any BusDK-specific semantics must be implemented as optional, namespaced extensions (for example, custom properties under a `busdk:*` key) that do not break compatibility with standard Table Schema tooling.

Frictionless Table Schema is a preferred implementation, not the goal itself. In BusDK terms, the data contract is \((table, schema)\): each table must have a clear contract that can be validated, diffed, and evolved over time while keeping older revisions interpretable and exportable.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./plaintext-csv-longevity">Plain-text CSV for longevity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./unix-composability">Unix-style composability (micro-tools)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
