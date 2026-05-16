---
title: UI framework
description: BusDK UI framework implemented patches and feature candidate review order.
---

## Implemented patches

Implemented UI framework patches use semver directories. The current cutoff is
derived from module implementation evidence and module docs; at this point the
implemented sequence includes the `bus-gx` foundation through `v0.1.16`, then
the shared `bus-ui` runtime and library patches from `v0.1.17` through
`v0.3.6`. Each listed version has its own compact index and keeps links inside
that version or to earlier prerequisites.

- [v0.1.1 Core node foundation](v0.1.1/)
- [v0.1.2 GX source tools](v0.1.2/)
- [v0.1.3 GX compiler](v0.1.3/)
- [v0.1.4 Component calls](v0.1.4/)
- [v0.1.5 Component composition](v0.1.5/)
- [v0.1.6 Callback props](v0.1.6/)
- [v0.1.7 Go WASM frontend runtime](v0.1.7/)
- [v0.1.8 Runtime diagnostics](v0.1.8/)
- [v0.1.9 Browser API boundaries](v0.1.9/)
- [v0.1.10 Core test helpers](v0.1.10/)
- [v0.1.11 WASM app acceptance](v0.1.11/)
- [v0.1.12 Intrinsic callback naming](v0.1.12/)
- [v0.1.13 Handle render scheduling](v0.1.13/)
- [v0.1.14 Expanded intrinsic elements](v0.1.14/)
- [v0.1.15 Typed event payloads](v0.1.15/)
- [v0.1.16 Minimal browser adapters](v0.1.16/)
- [v0.1.17 State runtime](v0.1.17/)
- [v0.1.18 Effect runtime](v0.1.18/)
- [v0.1.19 Event and form helpers](v0.1.19/)
- [v0.1.20 UI testkit renderer](v0.1.20/)
- [v0.1.21 UI testkit browser parity](v0.1.21/)
- [v0.1.22 Action primitives](v0.1.22/)
- [v0.1.23 Resource primitives](v0.1.23/)
- [v0.1.24 Session primitives](v0.1.24/)
- [v0.1.25 Portal context consumption](v0.1.25/)
- [v0.1.26 Streaming ownership](v0.1.26/)
- [v0.2.0 Bus UI module baseline](v0.2.0/)
- [v0.2.1 Icons](v0.2.1/)
- [v0.2.2 Buttons and links](v0.2.2/)
- [v0.2.3 Menus and tabs](v0.2.3/)
- [v0.2.4 Panels and cards](v0.2.4/)
- [v0.2.5 Layout helpers](v0.2.5/)
- [v0.2.6 Shells](v0.2.6/)
- [v0.3.1 Forms](v0.3.1/)
- [v0.3.2 Form fields](v0.3.2/)
- [v0.3.3 Input controls](v0.3.3/)
- [v0.3.4 Submit state](v0.3.4/)
- [v0.3.5 Tables](v0.3.5/)
- [v0.3.6 Lists](v0.3.6/)

## Feature candidates

Unimplemented UI work uses feature candidate directories named
`fc-<order>-<identifier>`, such as `fc-001-runtime-state`. The numeric order is
only the deterministic review order for public docs; it is not a promise that
unrelated candidates must be implemented as one strict sequence.

When a feature candidate is finished, reviewed, implemented, and accepted, it
receives the next actual semver patch number and is renamed from
`docs/ui/fc-<order>-<identifier>/` to `docs/ui/v0.X.Y/`. The promoted patch is
then added to the implemented list and sidebar. Earlier implemented pages do
not link forward to feature candidates.

- [fc-001 Timelines](fc-001-timelines/)
- [fc-002 Status surfaces](fc-002-status-surfaces/)
- [fc-003 Resources](fc-003-resources/)
- [fc-004 Runtime config and API URLs](fc-004-runtime-config-api-urls/)
- [fc-005 Sessions](fc-005-sessions/)
- [fc-006 Credentials](fc-006-credentials/)
- [fc-007 Provider errors](fc-007-provider-errors/)
- [fc-008 Assets and host tools](fc-008-assets-host-tools/)
- [fc-009 Assistant workbench shell](fc-009-assistant-workbench-shell/)
- [fc-010 Assistant threads and messages](fc-010-assistant-threads-messages/)
- [fc-011 Assistant composer and attachments](fc-011-assistant-composer-attachments/)
- [fc-012 Assistant model selection](fc-012-assistant-model-selection/)
- [fc-013 Assistant review controls](fc-013-assistant-review-controls/)
- [fc-014 Terminal sessions](fc-014-terminal-sessions/)
- [fc-015 Terminal IO](fc-015-terminal-io/)
- [fc-016 Terminal approvals](fc-016-terminal-approvals/)
- [fc-017 Terminal adapter](fc-017-terminal-adapter/)
- [fc-018 Evidence URLs and links](fc-018-evidence-urls-links/)
- [fc-019 Evidence previews](fc-019-evidence-previews/)
- [fc-020 Projection details](fc-020-projection-details/)
- [fc-021 File drops](fc-021-file-drops/)
- [fc-022 Image galleries](fc-022-image-galleries/)
- [fc-023 Component catalog](fc-023-component-catalog/)
- [fc-024 Declarative artifacts](fc-024-declarative-artifacts/)
- [fc-025 Product module integration](fc-025-product-module-integration/)
- [fc-026 Examples, testing, and release review](fc-026-examples-testing-release-review/)

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">Documentation index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-gx module reference](../modules/bus-gx)
- [bus-ui module reference](../modules/bus-ui)
