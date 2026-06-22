# bus-engine

`bus engine` controls the managed local Linux Engine. The local profile starts a
QEMU-backed Debian 12 guest through Bus API, Bus Events, the generic artifact
integration, the VM integration, and the QEMU provider.

The Debian 12 Bookworm generic cloud image is part of the default Engine
profile. Bus Engine also ships a default Debian record in
`bus-engine/artifacts/catalog.json` for file-based catalog seeding. On first
start, Engine asks the artifact integration to download the image from Debian
and verify it against the Debian `SHA256SUMS` manifest. End users do not need
to create artifact directories, download the Debian image, or write catalog
JSON for the Debian base image.

The Bus kernel should be registered as a package artifact, usually the built
`linux-image-*_amd64.deb` package. The QEMU provider extracts `boot/vmlinuz-*`
from that package into its runtime directory before starting the VM.

```sh
KERNEL_DEB=/path/to/linux-image-7.1.0_6_amd64.deb
KERNEL_DIGEST="sha256:$(openssl dgst -sha256 -r "$KERNEL_DEB" | awk '{print $1}')"

bus artifacts catalog set bus-engine-kernel-amd64 \
  --handle "$KERNEL_DEB" \
  --digest "$KERNEL_DIGEST"
```

After the local services are running and a valid API token is available:

```sh
bus engine status
bus engine start
bus engine status
bus engine ssh
bus engine stop
```

Repeat `bus engine status` until the Engine reports `running` before using SSH.
