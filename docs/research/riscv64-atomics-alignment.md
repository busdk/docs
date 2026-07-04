# RISC-V RV64 Atomics (A Extension): Memory-Access and Alignment Rules

**Date:** 2026-07-04

## Question

For the RV64 -> WASM lowering in the qemu `wasm64` accelerator, we need the authoritative RISC-V rules for:

1. What alignment do A-extension atomics (LR/SC, AMO*) require? Do misaligned AMOs raise an exception, and what does the spec say about atomicity of misaligned accesses?
2. How do LR/SC and AMO instructions work at a high level?
3. What are the alignment requirements for ordinary RV64 loads/stores, and how is misaligned access handled (hardware trap vs emulation)?
4. Which guest atomic forms are safe to lower to WASM atomics vs must fall back?

## Sources

- "A" Extension for Atomic Instructions, Version 2.1 (Zaamo / Zalrsc) — https://docs.riscv.org/reference/isa/v20240411/unpriv/a-st-ext.html
- RV32I Base Integer Instruction Set, Version 2.1 (base load/store alignment rules; same wording applies to RV64I loads/stores) — https://docs.riscv.org/reference/isa/v20240411/unpriv/rv32.html
- RVWMO — RISC-V Weak Memory Ordering — https://docs.riscv.org/reference/isa/unpriv/rvwmo.html
- Machine-Level ISA, Version 1.13 (MPRV/MXR, misaligned emulation, exception priority) — https://docs.riscv.org/reference/isa/v20260120/priv/machine.html
- Supervisor-Level ISA, Version 1.13 (stval faulting-address reporting) — https://docs.riscv.org/reference/isa/v20260120/priv/supervisor.html
- RISC-V Unprivileged ISA Manual (PDF, consolidated) — https://docs.riscv.org/reference/isa/v20250508/_attachments/riscv-unprivileged.pdf

## Findings

### 1. Atomic (A-extension) alignment and misalignment

- **AMOs (Zaamo):** "the Zaamo extension requires that the address held in rs1 be naturally aligned to the size of the operand (i.e., eight-byte aligned for doublewords and four-byte aligned for words)."
- **LR/SC (Zalrsc):** "the Zalrsc extension requires that the address held in rs1 be naturally aligned to the size of the operand" — same eight-byte/four-byte rule.
- **Misalignment is an exception, not a slow-but-works path.** If the atomic address is not naturally aligned, "an address-misaligned exception or an access-fault exception will be generated. The access-fault exception can be generated for a memory access that would otherwise be able to complete except for the misalignment, if the misaligned access should not be emulated."
- **Atomicity of misaligned atomics:** The base A extension does **not** require execution environments to support misaligned atomics at all. Support is only possible via the optional **misaligned atomicity granule PMA**: when present and the access fits within one granule, "the instruction will not raise an exception for reasons of address alignment, and the instruction will give rise to only one memory operation for the purposes of RVWMO — i.e., it will execute atomically." Outside that granule there is no atomicity guarantee. Net: unless the platform advertises the misaligned atomicity granule PMA, a misaligned atomic is architecturally a trap, and there is no portable guarantee of atomicity for a misaligned atomic.

### 2. How LR/SC and AMO work

- **LR (load-reserved):** "LR loads a word [RV64: word or doubleword] from the address in rs1, places the sign-extended value in rd, and registers a reservation set — a set of bytes that subsumes the bytes in the addressed word."
- **SC (store-conditional):** writes rs2 to the address only if the reservation is still valid; writes success/failure (0/nonzero) into rd. "An SC can only pair with the most recent LR in program order" (LR precedes SC, no intervening LR/SC). The spec guarantees eventual forward progress for a properly constructed LR/SC constrained loop.
- **AMO (atomic memory operation):** "These AMO instructions atomically load a data value from the address in rs1, place the value into register rd, apply a binary operator to the loaded value and the original value in rs2, then store the result back to the original address in rs1." Operators: AMOSWAP, AMOADD, AMOAND, AMOOR, AMOXOR, AMOMIN(U), AMOMAX(U), widths .W and .D on RV64.
- **Ordering bits (`aq`/`rl`):** with `aq`, no later memory ops in this hart are observed before the AMO; with `rl`, other harts do not observe the AMO before this hart's preceding memory accesses. `aqrl` gives a sequentially-consistent point. Ordering is defined under RVWMO (weak memory model).

### 3. Ordinary RV64 load/store alignment

- **Naturally aligned always works:** "loads and stores whose effective addresses are naturally aligned shall not raise an address-misaligned exception" — regardless of EEI.
- **Misaligned is EEI-dependent:** "Loads and stores whose effective address is not naturally aligned to the referenced datatype have behavior dependent on the EEI." Two cases:
  - **Guaranteed:** the EEI may fully support misaligned access "in hardware, or via an invisible trap into the execution environment implementation" (e.g. M-mode emulation using MPRV/MXR). Such accesses "might run extremely slowly."
  - **Not guaranteed:** misaligned access "may either complete execution successfully or raise an exception"; the EEI must define whether that exception is a *contained* trap (software can handle it) or a *fatal* trap.
- On a trap, `stval`/`mtval` holds the faulting virtual address. Note the key asymmetry vs. atomics: an ordinary misaligned load/store may be transparently emulated as multiple sub-accesses, but a misaligned **atomic** generally cannot be, because emulation via decomposition breaks atomicity.

### 4. Emulator lowering guidance (RV64 guest -> WASM target)

WASM has `i32.atomic.*` / `i64.atomic.*` (load/store/rmw/cmpxchg) and `memory.atomic.wait/notify`, but WASM **traps on a misaligned atomic access** — the alignment contract is essentially identical to RISC-V's for atomics.

- **Naturally aligned LR/SC and AMO.W/AMO.D** map cleanly:
  - `AMOSWAP/ADD/AND/OR/XOR` -> the corresponding `i32/i64.atomic.rmw.*`.
  - `AMOMIN/MAX/MINU/MAXU` -> WASM has no atomic min/max rmw; emulate with an `atomic.rmw.cmpxchg` retry loop.
  - `LR/SC` -> emulate with `atomic.rmw.cmpxchg` (or a reservation-address + value compare loop); WASM has no native reservation, so LR/SC becomes a CAS loop, which preserves the required atomicity for aligned addresses.
  - Honor `aq`/`rl` by keeping the WASM atomic (which is seq-cst) or inserting the appropriate ordering; using seq-cst WASM atomics is always a safe over-approximation of RVWMO ordering.
- **Misaligned atomics must fall back**, not be lowered to a WASM atomic (which would trap):
  - Architecturally the guest is entitled to take an address-misaligned/access-fault trap. The faithful behavior is to raise the guest exception (deliver to the guest trap handler with the faulting address), unless the emulated platform advertises the misaligned atomicity granule PMA.
  - If, for compatibility, misaligned atomics are executed rather than trapped, they cannot be decomposed into multiple sub-accesses and still claim atomicity; the only correct options are a global lock / helper (serialize via a runtime "cmpxchg helper" holding a mutex) or refusing the operation. Do **not** silently lower a misaligned guest atomic to a naive multi-op sequence.
- **Ordinary (non-atomic) misaligned RV64 loads/stores** may be safely emulated by splitting into byte/sub-word accesses in the WASM lowering (no atomicity requirement), or by raising the guest misaligned trap — a policy choice matching the emulated EEI. This is exactly the case where decomposition is legal, and it is the dividing line from the atomic case above.

## How this applies to us

For the qemu `wasm64` accelerator lowering RV64 guest atomics to WASM: lower only **naturally aligned** guest atomics (LR/SC and AMO.W/.D) to WASM atomic ops — AMO arithmetic/swap map to `atomic.rmw.*`, and AMO min/max plus LR/SC lower to `atomic.rmw.cmpxchg` retry loops, with seq-cst WASM atomics as a safe over-approximation of RVWMO `aq`/`rl` ordering. **Misaligned** guest atomics must not be lowered to WASM atomics (WASM traps on them and their atomicity cannot be preserved by decomposition): either deliver the guest address-misaligned/access-fault exception or serialize through a locked runtime helper, while ordinary misaligned non-atomic loads/stores remain safe to split into sub-accesses or trap per the emulated EEI policy.
