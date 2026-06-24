# bus-engine

`bus engine` controls the managed local Linux Engine. The local profile starts a
QEMU-backed Debian 12 guest through Bus API, Bus Events, the generic artifact
integration, the VM integration, and the QEMU provider.

The Debian 12 Bookworm generic cloud image is part of the default Engine
profile. Bus Engine also ships a default Debian record in
`bus-engine/artifacts/catalog.json` for file-based catalog seeding. On first
start, Engine asks the artifact integration to download the image from Debian
and verify it against the Debian `SHA256SUMS` manifest. Bus Engine creates the
default artifact catalog when the default profile starts and requests its
configured image artifacts.

Register a Bus kernel package when the selected Engine profile should use a
custom kernel package that is not already in the artifact catalog. Prefer the
built `linux-image-*_amd64.deb` package. The QEMU provider extracts
`boot/vmlinuz-*` from that package into its runtime directory before starting
the VM. The current default profile uses the `bus-engine-kernel-amd64` artifact
id, so updating that catalog record changes the kernel package resolved for that
profile.

```sh
KERNEL_DEB=/path/to/linux-image-7.1.0_6_amd64.deb
KERNEL_DIGEST="sha256:$(openssl dgst -sha256 -r "$KERNEL_DEB" | awk '{print $1}')"

bus artifacts catalog set bus-engine-kernel-amd64 \
  --handle "$KERNEL_DEB" \
  --digest "$KERNEL_DIGEST"
```

After local Bus services are running, for example with `bus services up`, the
local service token is read from `.bus/tokens/local-events.jwt`. Custom or
hosted endpoints can use `--token-file`, `BUS_AI_TOKEN`, or `BUS_API_TOKEN`.
Verify the selected endpoint and token with:

```sh
bus engine status
```

Then start and stop the Engine with:

```sh
bus engine status
bus engine start
bus engine status
bus engine ssh
bus engine stop
```

Repeat `bus engine status` until the Engine reports `running` before using SSH.
