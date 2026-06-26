# bus-engine

`bus engine` controls the managed local Linux Engine. The local profile starts a
QEMU-backed Bus Engine OS guest through Bus API, Bus Events, the generic
artifact integration, the VM integration, and the QEMU provider.

The default Engine profile references two Bus Engine OS artifact ids:
`bus-engine-os-rootfs-aarch64` for the raw root disk and
`bus-engine-os-kernel-aarch64` for the direct QEMU kernel image. Build those
artifacts in `bus-engine-os`, then register the resulting files in the artifact
catalog before starting the Engine.

```sh
ENGINE_OS_ARTIFACTS=/path/to/bus-engine-os/build/lanes/bootstrap/images
ROOTFS="$ENGINE_OS_ARTIFACTS/rootfs.raw"
KERNEL="$ENGINE_OS_ARTIFACTS/Image"
ROOTFS_DIGEST="sha256:$(openssl dgst -sha256 -r "$ROOTFS" | awk '{print $1}')"
KERNEL_DIGEST="sha256:$(openssl dgst -sha256 -r "$KERNEL" | awk '{print $1}')"

bus artifacts catalog set bus-engine-os-rootfs-aarch64 \
  --handle "$ROOTFS" \
  --digest "$ROOTFS_DIGEST"

bus artifacts catalog set bus-engine-os-kernel-aarch64 \
  --handle "$KERNEL" \
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
