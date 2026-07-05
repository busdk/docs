# QEMU Migration Stream Compatibility

2026-07-05

## Question

From local QEMU source-tree evidence only, can Bus Engine OS use QEMU migration
streams as browser factory snapshots and OPFS checkpoints, and what local
compatibility constraints must be proven before accepting native-to-wasm stream
production?

## Local Sources

- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/migration/main.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/migration/compatibility.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/migration/features.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/migration/mapped-ram.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/migration/xbzrle.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/migration/virtio.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/migration/CPR.rst`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/qapi/migration.json`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/migration/file.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/migration/savevm.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/migration/ram.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/migration/vmstate.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/migration/block-dirty-bitmap.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/docs/devel/wasm-support-plan.rst`

## Findings

The local QEMU migration framework documentation says saving guest state saves
the state for each device, while restore loads each device's state. It also
says QEMU must be launched with the same arguments for save and restore because
the restored guest needs the same devices as the saved guest. That is the core
constraint for any Bus Engine OS factory snapshot.

The local migration docs define the stream as a byte stream carried over
transports including tcp, unix, exec, fd, and file. The file transport can use a
path or pre-opened descriptors, but the local docs explicitly say QEMU does not
flush cached file data or metadata at the end of migration. A browser wrapper
therefore has to own OPFS flush, integrity metadata, and generation commit.

Most device state is non-iterative and saved at the end of precopy while CPUs
are paused. RAM is the large iterative state. The local docs describe live
migration as keeping the guest running while most state transfers, stopping it
only for the final part; they give low hundreds of milliseconds as a typical
unresponsive interval, with the caveat that it depends on many things. This
cannot be assumed for TCG-in-browser plus OPFS until measured.

VMState is the local migration schema mechanism for most devices. The local
docs describe `version_id`, `minimum_version_id`, subsections, and massaging
functions. They also warn that migration streams are still raw at the wire
level and that internal device behavior can accidentally become migration
version dependent. The destination must treat incoming streams as hostile and
fail corrupted streams.

The local compatibility document distinguishes QEMU version from machine type
version. It says migration is only supposed to work with the same machine type
and the same hardware configuration on source and destination. It also says
most backend configuration can differ except when backend features affect the
frontend device feature exposure. The virtio-blk multi-queue example shows why
frontend-visible feature/queue differences break migration.

The local QAPI schema exposes the primitives needed for this design:
`query-migrate`, `migrate`, `migrate-incoming`, `calc-dirty-rate`, migration
capabilities such as `dirty-bitmaps`, `background-snapshot`, and `mapped-ram`,
and migration modes such as CPR. `dirty-limit` is documented in QAPI as KVM
dirty-ring dependent, so it is not a browser TCG primitive.

The local block dirty bitmap migration code documents a separate block bitmap
migration stream for named, QMP-addressable bitmaps. This is relevant to disk
overlay consistency, but it is not a complete RAM+disk checkpoint protocol by
itself. RAM/device migration and disk overlay generations must still be tied
by higher-level commit metadata.

The local wasm support plan says the current MVP does not require durable
browser storage. Therefore pre-booted factory snapshots and OPFS checkpointing
are a new design layer above the current wasm MVP, not a feature already
accepted by the local plan.

## How this applies to us

QEMU migration is the right local primitive for CPU/RAM/device state, but the
browser product must add a compatibility manifest. That manifest should pin the
QEMU fork commit, artifact hashes, target architecture, machine type and
properties, CPU model/ISA flags, memory size, SMP topology, device list and
ordering, block node names, virtio frontend feature exposure, rootfs/kernel and
package-set digests, and selected migration capabilities.

Native-to-wasm factory snapshot production is only acceptable after an exact
native-to-wasm restore proof. Local QEMU docs make the optimistic same-version
same-machine case plausible, but backend/frontend feature differences can still
break migration. If the proof fails, the factory snapshot must be produced by
the wasm build itself.

User OPFS checkpoints should be browser-produced because they include the
browser-backed disk overlay, browser device glue, and local storage generation
state. They should not be produced natively.

For suspend/resume, use continuous background checkpointing and an atomic
manifest generation. A full 512 MiB RAM/device stream should not be left until
page close. The final close/hide path should commit only a small final delta
or leave the previous generation valid.
