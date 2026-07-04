# WebAssembly Memory-Access Alignment and Atomics Rules

2026-07-04

## Question

For a QEMU-to-WebAssembly JIT that emits guest memory operations, we need the exact
WebAssembly rules on memory-access alignment and atomics:

1. Which memory instructions trap on a misaligned address, and which tolerate misalignment?
   Do plain `i32`/`i64` `.load`/`.store` trap on misalignment, or is the alignment immediate
   only a hint? Do the atomic ops (`i32`/`i64.atomic.*`) require natural alignment and trap otherwise?
2. What does the V8 runtime error "operation does not support unaligned accesses" correspond to
   (which instruction class)?
3. Do WASM atomics require shared memory? What are the alignment constraints in the threads/atomics
   proposal?
4. Emscripten specifics: how does Emscripten expose unaligned access, and how should a JIT emitting
   generated WASM avoid a misalignment trap for guest memory ops that may be unaligned?

## Sources

- https://webassembly.org/docs/portability/
- https://webassembly.org/docs/rationale/
- https://github.com/WebAssembly/threads/blob/main/proposals/threads/Overview.md
- https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Understanding_the_text_format
- https://emscripten.org/docs/porting/Debugging.html
- https://emscripten.org/docs/porting/guidelines/portability_guidelines.html
- https://emscripten.org/docs/porting/pthreads.html

## Findings

### Plain (non-atomic) load/store: alignment is a HINT, never traps on misalignment

For ordinary `i32.load`, `i64.load`, `f32.load`, `i32.store`, etc., the `align=` immediate is
purely an optimization **hint**. It does not change the result of the instruction and it does not
gate trapping. A non-atomic access to a misaligned effective address is fully defined and produces
the correct value; it may simply be slower on hardware that does not support unaligned access
natively. The only traps for plain load/store are the ordinary out-of-bounds traps (effective
address + access size beyond the memory's bounds) — misalignment alone never traps.

The WebAssembly portability contract requires the host to "support unaligned memory accesses or
reliable trapping that allows software emulation thereof," i.e. unaligned plain accesses must work.
Emscripten confirms this at the toolchain level: "unaligned loads and stores will work; each may be
annotated with its expected alignment. However, if the actual alignment does not match, it may be
very slow on some systems."

### Atomic ops: natural alignment REQUIRED — misaligned address TRAPS at runtime

The threads/atomics proposal makes atomics the sharp exception. Two distinct rules:

- **Validation (static):** "It is a validation error if the alignment field of the memory access
  immediate has any other value than the natural alignment for that access size." So an atomic
  instruction cannot even encode a non-natural alignment hint — the module fails to validate.
- **Execution (dynamic):** "Unlike normal memory accesses, misaligned atomic accesses trap." The
  effective address must be a multiple of the access size (2 bytes for 16-bit, 4 for 32-bit, 8 for
  64-bit); if not, the atomic op traps at runtime. `wait` operators require alignment of their
  access size; `notify` requires 32-bit alignment.

WebAssembly guarantees lock-free atomics only "when naturally aligned" for 8-, 16- and 32-bit
accesses (and 64-bit under wasm64) — which is exactly why non-natural alignment is disallowed
rather than emulated.

### Trap / no-trap table

| Instruction class                          | Misaligned address behavior                          |
|--------------------------------------------|------------------------------------------------------|
| `i32`/`i64`/`f32`/`f64` `.load` / `.store` | No trap. Alignment immediate is a hint only; correct result, possibly slower. |
| Narrow variants (`load8_u`, `store16`, …)  | No trap on misalignment (hint only). |
| SIMD `v128.load` / `v128.store`            | No trap on misalignment (hint only). |
| `*.atomic.load` / `*.atomic.store`         | **Traps** if effective address is not naturally aligned. |
| `*.atomic.rmw.*` (add/sub/and/or/xor/xchg/cmpxchg) | **Traps** if not naturally aligned. |
| `memory.atomic.wait32` / `wait64`          | **Traps** if not aligned to access size; also traps on unshared memory. |
| `memory.atomic.notify`                     | **Traps** if not 32-bit aligned. |
| Out-of-bounds (any access, atomic or not)  | Traps (separate from alignment). |

### V8 error "operation does not support unaligned accesses"

This runtime error corresponds to the **atomic instruction class**, not plain load/store. It is V8's
message for the trap taken when an atomic memory access (`atomic.load`/`store`/`rmw`/`wait`/`notify`)
is performed on an effective address that is not naturally aligned. Plain loads/stores never raise it,
because for them alignment is only a hint. Seeing this error means generated code executed a WASM
atomic against a non-naturally-aligned address.

### Atomics and shared memory

Atomic accesses do **not** require shared memory: "All atomic memory accesses can be performed on
both shared and unshared linear memories." The exception is the wait operators, which "additionally
trap if used on an unshared linear memory." (`notify` works on unshared memory but simply finds zero
waiters.) So sharedness is a separate axis from alignment: an atomic RMW on unshared memory is legal,
but if its address is misaligned it still traps.

### Emscripten specifics

- Emscripten emits normal (hint-annotated) loads/stores that tolerate misalignment; when the source
  language forces an unaligned access, unaligned pointer/types cause LLVM to emit the appropriately
  hinted (align=1) loads/stores, which still do not trap.
- `SAFE_HEAP=1` adds a Binaryen instrumentation pass that reports alignment problems (and null
  dereferences) — useful to surface where unaligned or misaligned atomic accesses occur.
- Emscripten's pthreads support is built on shared memory + WASM atomics for synchronization, and it
  relies on those atomics being naturally aligned (aligned C11 atomics / lock structures).

## How this applies to us

Our QEMU-to-WASM JIT emits guest memory operations, and guest addresses are frequently **not**
naturally aligned (guest code is free to do unaligned accesses, and some guest ISAs allow unaligned
atomics). The rules above give a clean split:

- **Plain guest loads/stores are safe to lower to plain WASM `load`/`store`** even when the guest
  address may be unaligned. WASM plain accesses never trap on misalignment (alignment is a hint), so
  a possibly-unaligned guest read/write lowers correctly with, at worst, a performance cost. Emit
  `align=1` (byte alignment) hints for addresses we cannot prove aligned so the engine does not
  assume alignment it does not have.

- **Guest atomics are the trap hazard.** If we lower a guest atomic to a WASM `*.atomic.*`
  instruction and the guest address is not naturally aligned, the WASM atomic **traps at runtime** —
  this is exactly the V8 "operation does not support unaligned accesses" failure. Non-natural
  alignment is not even encodable (validation error), so we cannot "hint" our way out of it.

- **Correct fix: do not emit trapping atomics on possibly-misaligned addresses; fall back.** When the
  guest atomic's address is not provably naturally aligned, do not emit a raw WASM atomic. Instead
  fall back to a non-trapping path — e.g. an alignment check that dispatches aligned addresses to the
  fast WASM atomic and misaligned ones to a software-emulated atomic (a locked/critical-section
  helper implementing the read-modify-write over plain loads/stores), or route the whole operation
  through a runtime helper. Only emit a direct WASM atomic when we can prove natural alignment
  (statically known aligned address, or after a runtime alignment test on the fast branch).

- Remember atomics do not require shared memory, so the trap we hit is an **alignment** trap, not a
  sharedness one; adding shared memory does not fix a misaligned-atomic trap. The alignment fallback
  is the actual fix.

## Misapplication warning (added 2026-07-05, from a real debugging mistake)

The findings above are correct but were MISAPPLIED once; do not repeat it.

What happened: seeing V8's "operation does not support unaligned accesses"
during live generated execution, we concluded "our generated (JIT-emitted)
WASM must be emitting a trapping atomic for a guest atomic" and spent two
failed fixes guarding generated-body atomic emission - which DOES NOT EXIST
(the wasm64 generated-body validator rejects atomic memops outright, and the
emitter produces only plain loads/stores).

The actual lesson: this trap can originate in ANY WebAssembly code in the
page, including the STATIC main module compiled by emscripten - C-level
`qatomic_*` / `_Atomic` / `__atomic_*` builtins are lowered to WASM atomics,
so ordinary C code trips this trap when its pointer is unaligned.

Before attributing this error, check in order:
1. The FUNCTION INDEX in the stack trace. A stable index across runs (e.g.
   `wasm-function[1403]` of qemu-system-riscv64.wasm every time) is a STATIC
   function of that module - i.e. compiled C - NOT a dynamically created
   `WebAssembly.Module`. Generated/JIT modules are separate instances and
   cannot appear as a stable index of the main binary.
2. Whether the suspected emitter CAN produce the op at all: inventory the
   emission/validation code first (grep the validator + emitter); do not fix
   an emission path you have not proven exists.
3. Symbolize (names/profiling-funcs build) to get the C symbol before
   patching anything.

Rule of thumb: "only atomics trap on misalignment" identifies WHAT trapped,
never WHOSE code trapped. Attribution requires the index/symbol evidence.
