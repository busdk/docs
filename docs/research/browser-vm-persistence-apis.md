# Browser VM Persistence APIs

2026-07-05

## Question

From local Bus Engine OS and local QEMU source-tree evidence only, what is
already known about the browser-hosted VM storage/lifecycle design, and which
browser API claims must wait for supervisor-authored spec research notes?

## Local Sources

- `bus-engine-os/README.md`
- `bus-engine-os/BACKLOG.md`
- `bus-engine-os/config/kernel/virtual-riscv64.config`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/wasm-support-plan.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/configs/meson/emscripten.txt`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/system/wasm-power.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/scripts/ci/wasm-browser-persistent-disk-proof.mjs`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/scripts/ci/wasm-native-persistent-disk-proof.mjs`

## Findings

The Bus Engine OS README already defines the current browser-hosted persistent
disk contract. `--persistent-disk` keeps `guest/rootfs.raw` immutable and adds
a separate browser-local raw disk at `/persistent.raw`. The generated manifest
records the root image as non-mutable, records persistent disk size, OPFS name,
and virtio device mode, and exposes the disk as a second virtio-blk device.

The README says OPFS is the default and currently only supported persistent
backend. Reset means deleting the named OPFS disk and recreating an empty image
on next boot. Export reads the OPFS file as a raw disk image; import replaces
it with another raw image. Browser quota and persistence status are reported by
the QEMU/WASM harness and must be checked by release smoke tests before stored
guest state is treated as durable.

The README deliberately separates storage layers: Emscripten filesystem state,
immutable fetched `guest/rootfs.raw`, QEMU block devices, guest filesystems
inside those block devices, and the persistent disk snapshot in OPFS.
IndexedDB is only a compatibility metadata or later fallback path. Corruption,
quota denial, failed import, or unavailable OPFS must be surfaced and must not
silently fall back to mutating the release image.

The BACKLOG records browser artifact and harness requirements around required
headers when pthreads, SharedArrayBuffer, or `PROXY_TO_PTHREAD` are used. It
also requires browser-hosted boot tests to fail clearly when WebAssembly, Web
Workers, SharedArrayBuffer, Emscripten filesystem, or browser storage support
is unavailable.

The local QEMU wasm Emscripten Meson config links with `-pthread` and
`-sPROXY_TO_PTHREAD=1`, plus `ASYNCIFY`, offscreen canvas support,
`FORCE_FILESYSTEM`, `TOTAL_MEMORY=2GB`, `WASM_BIGINT`, and ES module export.
This is local evidence that the current artifact expects browser thread/shared
memory support, but the browser API compatibility matrix itself must come from
supervisor-authored web/spec notes.

The local QEMU wasm support plan says the MVP does not require durable browser
storage. The persistent disk work in Bus Engine OS is therefore product-layer
storage around the QEMU/WASM artifact, and pre-booted migration snapshots plus
continuous checkpointing are additional future design work.

The BACKLOG already has an item for browser-backed `virtio-rng` using Web
Crypto, and an item for browser-hosted storage policy covering OPFS, IndexedDB,
and File System Access API. Those items are not completed acceptance evidence.

## Pending Supervisor Research

This note intentionally does not cite MDN, WHATWG, W3C, Chrome, WebKit, or
Mozilla pages. The following external API claims are pending supervisor-authored
research notes before they should be treated as durable citations:

- OPFS SyncAccessHandle availability and worker restrictions.
- `navigator.storage.persist()` behavior, quota, and eviction semantics.
- `visibilitychange`, `pagehide`, freeze/discard/terminate lifecycle budgets.
- SharedWorker lifetime and browser matrix.
- SharedArrayBuffer cross-origin-isolation, COOP, COEP, CORP requirements.
- Web Locks leader-election behavior and browser matrix.

## How this applies to us

Local evidence supports the product direction that `guest/rootfs.raw` remains
immutable and all mutable browser VM data lives in OPFS-owned artifacts with
explicit status, reset/export/import, and corruption/quota handling.

The local QEMU build configuration makes thread/shared-memory support a hard
deployment concern for the current wasm artifact. The design can require
feature probes and clear diagnostics locally, but the exact browser support
claims must cite supervisor web/spec notes once they arrive.

For the suspend/resume design, the local storage contract implies an atomic
generation model: RAM/device checkpoint, disk overlay, hashes, QEMU artifact
metadata, package/rootfs/kernel digests, and manifest pointer must advance
together. If a generation is absent, corrupt, evicted, or incompatible, the
browser should fall back to the shipped factory snapshot rather than mutate the
immutable rootfs.

The shared-instance browser architecture recommendation remains design-level
until the supervisor API notes land. Locally, the requirement should be carried
as: one VM instance, many view clients, no per-tab independent VM ownership,
and a fallback that preserves OPFS generation consistency.
