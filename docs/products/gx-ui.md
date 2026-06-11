---
title: Bus GX/UI Library
description: Product documentation entry point for BusDK's Go-native UI library product line.
---

Bus GX/UI Library is the BusDK product line for Go-native frontend interfaces.
It combines TSX-like `.gx` authoring, compiled Go render roots, reusable UI
component families, runtime bridges, CSS hooks, portal integration surfaces,
and deterministic tests.

Use this product when frontend code should remain close to Go ownership:
typed props, generated Go, deterministic HTML, reusable components, and tests
that prove rendering, runtime actions, and resource handoff.

## Start Here

1. Read the [UI framework overview](../ui/).
2. Read [GX foundation](../ui/v0.1.1/) for the low-level source and render-tree
   model.
3. Read [component functions](../ui/v0.1.4/component-functions) and
   [callback props](../ui/v0.1.6/callback-props) for typed component authoring.
4. Read [Bus UI design system](../ui/v0.2.0/design-system), [controls](../ui/v0.2.2/controls),
   [layouts](../ui/v0.2.5/layouts), [shells](../ui/v0.2.6/shells),
   [forms](../ui/v0.3.1/forms), [tables](../ui/v0.3.5/tables), and
   [status surfaces](../ui/v0.3.8/status-surfaces) for reusable component
   families.

## Product Modules

[`bus-gx`](../modules/bus-gx) owns the GX source syntax, compiler, render tree,
HTML rendering, browser runtime primitives, and low-level test utilities.
[`bus-ui`](../modules/bus-ui) owns reusable components, compatibility
adapters, CSS hooks, mount/runtime helpers, portal integration surfaces, and UI
test harnesses.

Product routes, authorization, provider behavior, business object meaning,
billing, usage policy, secrets, and model execution stay in owning product
modules.
