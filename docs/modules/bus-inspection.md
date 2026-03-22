# bus-inspection

`bus-inspection` is a local BusDK portal for käytönjohtaja inspection
work, rolling action lists, customer follow-up, and document delivery.

The app runs as a token-gated local web UI. It stores structured workspace
state in the root-level managed table `inspection_state.csv` with schema
`inspection_state.schema.json`, keeps file artifacts under
`.bus/bus-inspection/`, and uses the same `bus-portal`-style shell with shared
`bus-ui` components. Login, form fields, selectors, metric summaries,
observation cards, event timelines, photo galleries, download actions, and
semantic form wrappers all come from shared `bus-ui` surfaces so the
module-specific code stays focused on inspection behavior. The module keeps its
own visual atmosphere, but it inherits `bus-ui` theme tokens so system dark
mode and shared contrast rules stay consistent.

Admins can create customers, sites, contacts, users, report packages, and
site-level access grants. Managers see only the sites they have been granted
and can create inspections with report metadata, edit dossier and inspection
sections, create observations directly from section context, add follow-up
events, and generate exports. Customers see only their own sites, can review
the action list, comment on observations, and acknowledge completed work.
The admin area is split into separate subviews for customers, sites,
contacts, report packages, and users so setup flows stay readable. Draft admin
form values stay visible when validation fails and when the user moves between
those subviews. The shared form surface also means Enter in a field submits the
active data-entry form without requiring a separate module-local key handler.

The inspection workflow is versioned. New inspections are pinned to the current
published config version, while older inspections keep the version that was
active when they were created. The form view shows previous-inspection values
for comparison, and the action list tracks categories `0` through `6`, status
history, due dates, resolution details, comments, and image attachments.
Inside `Kohteet`, the selected site is now organized into focused local
subviews for overview, inspections, rounds, observations, and exports so the
operator does not need to scroll through every workflow at once. The dossier
and static site summary stay in the overview subview, while inspection editing,
round capture, observation handling, and export work each have their own
clearer surface.

Exports are snapshot-based. The app can generate PDF for the inspection report
and the action list, and DOCX for the inspection report. Download links are
visible only to authorized roles for the site in question. The workspace also
stores an audit trail for observation changes, acknowledgements, exports, and
config publications.

`ai_config` users have a dedicated configuration view where they can submit a
natural-language config request, review the deterministic local diff proposal,
and publish a new version. After publication, the new structure appears in
subsequent inspections and in the current dossier rendering without rewriting
older inspection records.

Use `bus-gateway --print-url` for normal operation, sign in there, and launch
`bus-inspection` from the gateway tool list. The gateway owns credentials and
passes a trusted signed user identity into the inspection module, so
`bus-inspection` no longer provides its own login form. Fresh workspaces still
bootstrap the baseline inspection authorization profiles `admin`, `manager`,
`asiakas`, `asiakas2`, and `konfiguroija`, but those profiles are matched to
gateway accounts rather than carrying module-local passwords. New workspaces
start without sample customers or sites; the admin role sets up the live
workspace structure. For local verification, use `make build`, `make test`,
and `make test-e2e`.
