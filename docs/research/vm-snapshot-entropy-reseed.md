# VM Snapshot Entropy Reseed

2026-07-05

## Question

From local kernel, QEMU, systemd, and Bus Engine OS evidence only, what is
required to avoid cloned entropy and cloned per-instance identity when browser
VMs restore from a pre-booted snapshot or OPFS checkpoint?

## Local Sources

- `bus-engine-os/config/kernel/virtual-riscv64.config`
- `bus-engine-os/BACKLOG.md`
- `/private/tmp/beo-riscv64-olddef-20260705a/src/linux-6.18.36/Documentation/admin-guide/hw_random.rst`
- `/private/tmp/beo-riscv64-olddef-20260705a/src/linux-6.18.36/Documentation/admin-guide/sysctl/kernel.rst`
- `/private/tmp/beo-riscv64-olddef-20260705a/src/linux-6.18.36/drivers/char/hw_random/virtio-rng.c`
- `/private/tmp/beo-riscv64-olddef-20260705a/src/linux-6.18.36/drivers/char/hw_random/core.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/hw/virtio/virtio-rng.c`
- `/private/tmp/beo-qemu-src-check.XzDwrV/qemu-source/include/hw/virtio/virtio-rng.h`
- `/private/tmp/systemd-hwdb-src/docs/RANDOM_SEEDS.md`
- `/private/tmp/systemd-hwdb-src/man/systemd-machine-id-setup.xml`
- `/private/tmp/systemd-hwdb-src/man/systemd-random-seed.service.xml`
- `/private/tmp/systemd-hwdb-src/units/systemd-random-seed.service.in`
- `/private/tmp/systemd-hwdb-src/units/systemd-machine-id-commit.service`

## Findings

The Bus Engine OS riscv64 kernel config enables the needed guest-side hwrng
path with `CONFIG_HW_RANDOM=y` and `CONFIG_HW_RANDOM_VIRTIO=y`.

The local Linux `hw_random` documentation says the hwrng framework provides
`/dev/hwrng` and sysfs support, with hardware-specific drivers plugged into
the core. It says rng-tools can use `/dev/hwrng` to fill the kernel entropy
pool, which is used internally and exported by `/dev/urandom` and
`/dev/random`. It also warns raw `/dev/hwrng` data is not fitness-tested before
exposure.

The local Linux sysctl documentation says `/proc/sys/kernel/random/boot_id` is
a UUID generated the first time it is retrieved and then remains unvarying.
`uuid` generates a UUID every time it is read, and `entropy_avail` reports the
pool's entropy count in bits. The obsolete `urandom_min_reseed_secs` and
`write_wakeup_threshold` knobs do not affect RNG behavior.

The local Linux virtio-rng driver requests entropy by adding an input buffer to
the virtqueue and kicking it. Completed buffers make data available through the
hwrng interface. The local hwrng core has a background path that calls
`add_hwgenerator_randomness()` with data read from the current hwrng source,
which is the kernel-side path that can mix hardware generator bytes into the
kernel random subsystem.

The local QEMU virtio-rng device defaults to a QEMU-created rng backend when
no backend is provided. It has a VM state change handler that calls
`virtio_rng_process()` when the VM is running and the guest is ready. Its
VMState migrates the virtio device state, while runtime quota state is not part
of the migrated VMState in the local header/source comments.

The local systemd random-seed documentation says `virtio-rng` is used in
virtualized environments and retrieves random data from the VM host. It also
says systemd will try to load the relevant modules early when it detects a VM
with virtio-rng. The same document warns that `/var/lib/systemd/random-seed`
is often not reset when golden master images are created, and therefore is
replicated into every installation; by default systemd does not credit entropy
for that seed.

The local systemd machine-id documentation says `systemd-machine-id-setup`
initializes `/etc/machine-id` from several sources and otherwise generates a
new random ID. It warns that if a KVM VM UUID is used, the caller must ensure
it is sufficiently unique and different for every booted VM instance.

## How this applies to us

A QEMU migration snapshot or browser checkpoint preserves guest RAM. Therefore
it can preserve the in-RAM Linux RNG state, generated `boot_id` if already
read, systemd random-seed state, machine-id state, and any services that have
already consumed randomness. Fresh host entropy after restore is necessary,
but the guest must actually receive and mix it before creating or releasing
per-instance secrets.

The factory snapshot milestone should happen before reading or committing
per-instance material: no committed `/etc/machine-id`, no SSH host keys, no
saved `/var/lib/systemd/random-seed`, no DHCP leases, and no Bus workload
credentials. If `boot_id` was read before the snapshot, clones can inherit it;
therefore the factory path should avoid using `boot_id` as a uniqueness proof
unless the resume gate separately generates and records a fresh post-resume
nonce.

Every resume, including OPFS user-checkpoint resume, needs an entropy gate.
The gate should wait for virtio-rng/hwrng availability, wait for fresh entropy
delivery from the browser host backend, and only then allow systemd machine-id
commit, SSH host-key generation, network identity, and Bus instance credential
creation. This is stronger than a first-boot-only personalization unit.

The browser QEMU invocation should include virtio-rng and the browser backend
must use an acceptable host entropy source. The BACKLOG's browser-backed
virtio-rng item names Web Crypto `crypto.getRandomValues()` as the intended
host path, but the Web Crypto API citation itself is pending supervisor-authored
browser research.

Proof should restore two instances from the same factory snapshot and show
post-resume divergence in machine-id, SSH host key fingerprints, and a
guest-generated nonce/UUID after the entropy gate. It should also show that an
OPFS checkpoint resume runs the every-resume entropy gate before secret-bearing
services continue.
