---
title: UI design system
description: Visual, interaction, and content design rules for BusDK UI applications.
---

## Product Character

BusDK UIs are operational tools. They should feel calm, dense, readable, and
repeatable rather than promotional. A user often opens a BusDK UI to review
evidence, inspect data, approve work, correct a workflow, or supervise an AI
assistant. The design should make those tasks fast and trustworthy.

The default screen should be the working surface. Avoid marketing-style hero
sections, decorative card grids, oversized headlines, atmospheric backgrounds,
and large explanatory blocks inside the app. Use navigation, filters, tables,
forms, side panels, and status surfaces that support repeated use.

## Layout

Use full-page shells for applications and reusable panels for bounded tools.
Panels should organize work, not decorate it. Do not nest UI cards inside other
cards. Prefer full-width bands or split panes for page sections, and reserve
cards for repeated items, modals, summaries, and genuinely framed tool
surfaces.

Common layouts include:

- sidebar shell for multi-view apps;
- top or side navigation for module sections;
- split layout for list/detail and detail/evidence workflows;
- assistant shell with a business pane and a toggleable AI pane;
- terminal session panel for command-like interaction;
- data table plus filter toolbar for dense records.

Fixed-format elements such as toolbars, icon buttons, counters, table rows, and
tiles should have stable dimensions or responsive constraints. Hover states,
loading labels, icons, and dynamic text must not resize the surrounding layout.

## Density And Typography

Use compact text inside operational surfaces. Hero-scale type belongs only to
true public entry pages, not forms, sidebars, dashboards, panels, or workbench
views. Labels should be short and precise. Long explanations belong in
documentation, not inside the main app flow.

Letter spacing should be normal. Do not scale font size directly with viewport
width. Use responsive layout changes, wrapping, and constrained containers
instead. Text in buttons and table cells must fit without overlapping adjacent
controls.

## Color And Status

Use semantic color sparingly. Primary actions should be visually clear but not
dominant across the entire page. Danger actions should be reserved for
destructive or risky operations. Muted text should support scanning without
becoming unreadable.

Status surfaces should use consistent meanings:

- neutral for informational or idle state;
- working for active background work;
- success for completed work;
- warning for blocked or attention-needed state;
- danger for errors, destructive actions, or failed checks.

Color must not be the only signal. Status labels, titles, icons, and text must
carry the same meaning.

## Controls

Use familiar controls for the job:

- icon buttons for compact tools such as open, download, archive, close, send,
  stop, rename, and toggle;
- text buttons for primary commands with clear labels;
- segmented controls, tabs, or sidebar nav for modes and views;
- checkboxes or toggles for binary settings;
- select menus for bounded option sets;
- inputs, textareas, sliders, or steppers for numeric and free-form values;
- tooltips or `title` text for icon-only controls.

Actions must have stable tokens. A rendered button should expose a deterministic
action name through a shared attribute, and the Go/WASM action router should map
that token to a typed handler.

## Content Style

App copy should be direct and operational. Prefer "Approval required",
"No notes match the current filters", or "Upload failed" over vague messages.
Avoid in-app teaching text about the framework itself, implementation details,
keyboard shortcuts, or visual design. The UI should reveal possible actions
through structure and controls.

Error messages should name the failed operation and the next useful action when
that is known. Do not show secrets, raw tokens, private customer data, or
unfiltered provider payloads in UI diagnostics.

## Accessibility And Safety

All interactive controls need accessible names. Icon-only buttons need
`aria-label` or equivalent text. Status changes should be represented in text.
Form fields need labels. Tables need header cells where the data is tabular.
Links that open external resources should use safe target and referrer
attributes.

Unsafe HTML must be explicit and rare. User or provider text should be escaped
by default. Markdown, document previews, and artifact links need product-owned
safety rules before being passed to generic renderers.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./architecture">Architecture</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./rendering">Rendering model</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../modules/bus-ui)
- [bus-portal module reference](../modules/bus-portal)
