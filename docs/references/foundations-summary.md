---
title: References and external foundations (summary)
description: BusDK’s modular CLI philosophy aligns with the Unix notion of composable tools and clear interfaces, where programs do one thing well and cooperate through…
---

## References and external foundations (summary)

BusDK’s modular CLI philosophy aligns with the Unix notion of composable tools and clear interfaces, where programs do one thing well and cooperate through simple formats. See [The Art of Unix Programming: Basics of the Unix Philosophy](https://www.catb.org/esr/writings/taoup/html/ch01s06.html).

The longevity rationale for storing records in widely supported, documented formats is aligned with guidance on sustainable electronic record formats and long-term accessibility. See [National Archives guidance on selecting sustainable formats for electronic records](https://www.archives.gov/records-mgmt/initiatives/sustainable-faq.html).

The tabular schema contract is based on Frictionless Data Table Schema, with an optional Frictionless Data Package manifest to bind repository datasets together. See [Frictionless Data Table Schema](https://frictionlessdata.io/specs/table-schema/) and [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/).

The archival document preference for invoices is consistent with PDF/A’s long-term preservation purpose and conformance constraints. See [The Library of Congress: PDF/A Family, PDF for Long-term Preservation](https://www.loc.gov/preservation/digital/formats/fdd/fdd000318.shtml).

When Git is used for the canonical change history, the tamper-evident audit model relies on Git’s content-addressed object model and parent-linked commit structure. See [Git Internals: Git Objects](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../references/index">BusDK Design Spec: References and external foundations</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../references/index">BusDK Design Spec: References and external foundations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./link-list">Sources</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
