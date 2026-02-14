---
title: Plain-text CSV for longevity
description: BusDK treats business and accounting data as durable records that must remain accessible decades into the future.
---

## Plain-text CSV for longevity

BusDK treats business and accounting data as durable records that must remain accessible decades into the future. The core design constraint is that the canonical dataset should stay readable with common, general-purpose tooling and should not depend on proprietary application storage or vendor-controlled file formats.

The preferred default representation is UTF-8 CSV paired with explicit schemas. CSV is plain text, ubiquitous across operating systems and languages, and straightforward to inspect, diff, and transform; it fits a longevity-oriented approach where a repository should remain intelligible even if BusDK itself is not available.

CSV is a delivery convention rather than the goal. BusDK should be able to adopt other storage or serialization approaches over time as long as the system preserves long-term accessibility — in the sense of open documentation, broad tool support, and predictable export back to simple, tabular text formats — consistent with [National Archives guidance on selecting sustainable formats for electronic records](https://www.archives.gov/records-mgmt/initiatives/sustainable-faq.html).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./modularity">Modularity as a first-class requirement</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./schema-contract">Schema-driven data contract (Frictionless Table Schema)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
