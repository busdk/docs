---
title: "Bus Engine software and source licensing"
description: Source-delivery and licensing boundaries for Bus Engine OS releases, open-source components, source-access Bus modules, proprietary BusDK modules, and customer release areas.
---

# Bus Engine software and source licensing

Bus Engine OS combines components under multiple licenses. Open-source
components remain under their respective licenses. Bus-owned operating-system
integration modules are provided under their published source-access terms.
Proprietary BusDK userspace products remain subject to their commercial
licenses.

This page is a technical summary and does not replace the applicable license
texts, checkout terms, written agreements, or legal review.

## No public source-code promise

Bus Engine does not offer source code publicly by default. When a customer-only
downloadable release includes GPL, LGPL, MPL, or similar covered binaries, the
release process must provide the required corresponding source to those binary
recipients through the same customer release area at no extra charge.

## Release materials

A release area for GPL, LGPL, MPL, or similar covered binaries must provide the
materials required for that release, or mark an item not applicable when the
release does not contain that class of component:

- binary artifacts;
- checksums;
- package manifests;
- corresponding source archives;
- local patches and modified files;
- package and image build definitions;
- scripts needed to compile, link, and install covered binaries;
- license texts and copyright notices;
- third-party notices;
- source-access instructions for Bus-owned source-access modules.

Providing only an upstream link is not enough when the distributed binary
differs from upstream. The materials must correspond to the binary actually
delivered to the recipient.

## Component families

| Component family | Source and binary boundary |
| --- | --- |
| Third-party open-source software | Distributed under the applicable upstream licenses with notices, license texts, and corresponding source where required. |
| Bus-owned OS integration modules | May be distributed with source access under published source-access terms, including the [Functional Source License](https://fsl.software/) where applicable. |
| Proprietary BusDK userspace products | May remain binary-only where legally permitted and where no combined-work license requires source disclosure. |

Do not call Functional Source License software open source during its restricted
term. Use source-access, source-available, or Fair Source wording.

## Aggregate and combined-work review

A Linux installation image is usually an aggregate of separate programs, so
placing open-source and proprietary programs in one image does not automatically
put every independent program under the GPL. Actual linking, incorporation,
plugins, shared libraries, generated code, and kernel module boundaries require
release-specific review.

Customers receiving GPL-covered components receive the GPL rights for those
components, including rights to copy, modify, and redistribute them. Commercial
terms must not restrict rights that the open-source component licenses preserve.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./status">Status and roadmap</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bus Engine</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./faq">FAQ</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
