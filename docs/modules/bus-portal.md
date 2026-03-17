---
title: bus-portal
description: Customer portal for sending files and starting evidence-pack generation in a BusDK workspace.
---

## Overview

`bus-portal` opens a local customer view for the current BusDK workspace. The
page groups `Yleiskuva`, `Tilikartta`, `Aineisto`, and `Tilinpäätös` behind a
collapsible left sidebar and shows workspace business details, the full chart
of accounts, customer upload controls, and the latest evidence-pack outputs in
those separate views.

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
