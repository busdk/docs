# Documentation update instructions for docs.busdk.com

This file tells maintainers of the BusDK design documentation (docs.busdk.com) how the published docs relate to the bus-filing-prh module and what to update if they drift.

## Current state (as of 2026-02-18)

The docs at docs.busdk.com have been updated to match the implementation:

- **Module SDD ([docs.busdk.com/sdd/bus-filing-prh](https://docs.busdk.com/sdd/bus-filing-prh)):** Open Questions is "None at this time"; OQ-PRH-001 appears under "Resolved open questions" with the resolution text. Component Design (IF-PRH-001) states that the parameter set is defined by the tool's `--help` for a pinned version and is stable, with a link to the module CLI reference. Document control shows version/last updated 2026-02-18.
- **Module CLI reference ([docs.busdk.com/modules/bus-filing-prh](https://docs.busdk.com/modules/bus-filing-prh)):** Development state shows Completeness and Use case readiness as "High"; Current notes OQ-PRH-001 closed and FR-PRH-002 and full PRH SBR iXBRL implemented and covered by e2e; Planned next describes extended bundle metadata, README/doc links, and bus-filing contract follow-ups, with FR-PRH-002 and SBR iXBRL stated as implemented.

No further changes are required for the current implementation.

---

## If docs need to be updated again

When this repo adds features, changes behaviour, or closes further open questions, update the docs source as follows.

### Module SDD (bus-filing-prh)

- **Open Questions:** Keep as "None at this time" unless a new open question is added. For any new resolved question, add it under "Resolved open questions" with **Resolved.** and the resolution text.
- **Component Design (IF-PRH-001):** Keep in sync with the actual CLI: parameter set defined by `--help` for a pinned version, link to [module CLI reference](https://docs.busdk.com/modules/bus-filing-prh).
- **Document control:** Bump "Last updated" and version when making edits.

### Module CLI reference (bus-filing-prh)

- **Completeness / Use case readiness:** Use "High" (or the site's equivalent) when FR-PRH-002 and full PRH SBR iXBRL are implemented; avoid "50%" or "would complete" for that state.
- **Current:** Mention closed open questions and implemented requirements (e2e coverage) so it matches the module's real state.
- **Planned next:** List only future work; move completed items (e.g. FR-PRH-002, SBR iXBRL) out of "Planned next" and into "Current" or the completeness line.

### Cross-check

- SDD: no open question still asking for the parameter set; OQ-PRH-001 remains resolved/closed.
- Module page: completeness and planned next match the bus-filing-prh module repo's CHANGELOG and README (Roadmap).
- Links to module CLI reference, SDD, and [development status](https://docs.busdk.com/implementation/development-status) still work.

---

## Reference (bus-filing-prh module repo)

- **OQ-PRH-001 closure:** [CHANGELOG.md](CHANGELOG.md), [README.md](README.md) (Roadmap), [AGENTS.md](AGENTS.md).
- **FR-PRH-002 and SBR iXBRL:** [CHANGELOG.md](CHANGELOG.md), E2E script `tests/e2e.sh`.
- **Implementation plan:** [PLAN.md](PLAN.md).
