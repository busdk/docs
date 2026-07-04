# Research Notes

Durable findings from deep-research passes the agent runs while working on
problems. Each note is authoritative-source-backed (searches are restricted to
the strict allowlist in `agent-supervisor/config/research-allowed-domains.txt`;
GitHub only via exact `WebFetch` URLs). Save a note here whenever a research
pass produces reusable knowledge, and reference it from the nearest `AGENTS.md`
so it is discoverable and reused instead of re-researched.

## Conventions

- One topic per file: `research/<area>-<topic>.md` (e.g.
  `wasm-unaligned-memory-atomics.md`, `riscv64-atomics-a-extension.md`).
- Start each note with: the question, the date, and the exact sources (URLs)
  it is built from. Then the findings, then "how this applies to us".
- Prefer primary sources (specs, vendor docs). Mark anything uncertain.
- When a note informs a code decision, link it from the relevant `AGENTS.md`.

## Index

<!-- Add one line per note: - [Title](file.md) - one-line hook -->
- [WASM alignment & atomics](wasm-alignment-and-atomics.md) - plain loads/stores never trap on misalignment; WASM atomics require natural alignment and trap otherwise (= V8 'unaligned accesses' error)
- [RISC-V64 atomics & alignment](riscv64-atomics-alignment.md) - RV64 A-ext atomics require natural alignment; only aligned guest atomics are safe to lower to WASM atomics, else fall back
