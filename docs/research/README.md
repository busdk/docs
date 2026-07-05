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
- [QEMU migration stream compatibility](qemu-migration-stream-compatibility.md) - local QEMU docs/code constraints for VMState, machine type, device feature compatibility, and native/browser snapshot restore
- [Browser VM persistence APIs](browser-vm-persistence-apis.md) - local Bus/QEMU browser-storage facts plus explicit browser API gaps pending supervisor spec notes
- [VM snapshot entropy reseed](vm-snapshot-entropy-reseed.md) - local kernel, QEMU, and systemd evidence for virtio-rng, random-seed hygiene, and every-resume entropy gates
- [Bus Worker capabilities (task-11926d75e393)](bus-worker-capabilities.md) - thread tool availability, shell/web goal/MCP capabilities, and qemu.org web-access verdict
- [wasm-store-commit-strategies.md](wasm-store-commit-strategies.md) - threads memory-model ground truth for the store-commit design: unaligned atomics trap normatively; fences publish nothing to plain readers; hybrid alignment-checked plain-store + helper + seqcst doorbell recommended (2026-07-05)
