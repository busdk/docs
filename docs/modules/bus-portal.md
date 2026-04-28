---
title: bus-portal
description: Customer portal for sending files and starting evidence-pack generation in a BusDK workspace.
---

## Overview

`bus-portal` is being refactored into the generic modular web portal host for
`bus-portal-*` UI modules. The host owns token-gated serving, module mounting,
theme CSS variables, browser/session concerns, and shared static assets.

The current built-in accounting customer view remains available during the
split. It opens a local customer view for the current BusDK workspace. The
page groups `Yleiskuva`, `Tilikartta`, `Aineisto`, and `Tilinpäätös` behind a
collapsible left sidebar and shows workspace business details, the full chart
of accounts, customer upload controls, and the latest evidence-pack outputs in
those separate views.

Portal modules are UI modules only. They use `bus-api-*` /
`bus-api-provider-*` APIs for backend behavior and must not integrate directly
with `bus-integration-*` workers.

When the user presses `Aloita`, the portal runs `bus-reports evidence-pack`
for the same workspace. Uploaded files are saved through `bus-attachments`
(`attachments.csv` plus `attachments/yyyy/mm/...`) and the latest evidence-pack
run metadata is saved under `.bus/bus-portal/evidence-pack/`. On small screens
the sidebar starts collapsed and opens from the portal app icon.

After a successful evidence-pack run, the `Tilinpäätös` view shows explicit
`Avaa` and `Lataa` controls for each generated document. `Avaa` opens the
selected token-gated artifact in an inline preview inside the portal when the
file type supports previewing, and `Lataa` requests the same artifact with
attachment download headers.

### Sources

- [bus-portal module page](/Users/jhh/git/busdk/busdk/docs/docs/modules/bus-portal.md)
- [bus-portal README](/Users/jhh/git/busdk/busdk/bus-portal/README.md)
