# bus-inspection

`bus-inspection` is a local BusDK demo portal for käytönjohtaja inspection
work, rolling action lists, customer follow-up, and document delivery.

The app runs as a token-gated local web UI. It stores demo data under
`.bus/bus-inspection/` in the active workspace and uses the same
`bus-portal`-style shell with shared `bus-ui` components.

Admins can create customers, sites, contacts, users, report packages, and
site-level access grants. Managers see only the sites they have been granted
and can create inspections with report metadata, edit dossier and inspection
sections, create observations directly from section context, add follow-up
events, and generate exports. Customers see only their own sites, can review
the action list, comment on observations, and acknowledge completed work.

The inspection workflow is versioned. New inspections are pinned to the current
published config version, while older inspections keep the version that was
active when they were created. The form view shows previous-inspection values
for comparison, and the action list tracks categories `0` through `6`, status
history, due dates, resolution details, comments, and image attachments.

Exports are snapshot-based. The demo can generate PDF for the inspection report
and the action list, and DOCX for the inspection report. Download links are
visible only to authorized roles for the site in question. The workspace also
stores an audit trail for logins, observation changes, acknowledgements,
exports, and config publications.

`ai_config` users have a dedicated configuration view where they can submit a
natural-language config request, review the deterministic local diff proposal,
and publish a new version. After publication, the new structure appears in
subsequent inspections and in the current dossier rendering without rewriting
older inspection records.

Use `bus-inspection --print-url` to start the local server and print the signed
browser URL. The seeded demo password is `demo123` for every account. For
local verification, use `make build`, `make test`, and `make test-e2e`.
