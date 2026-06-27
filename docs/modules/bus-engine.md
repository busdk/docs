# bus-engine

`bus engine` controls the managed local Linux Engine. The local profile starts a
QEMU-backed Bus Engine OS guest through Bus API, Bus Events, the generic
artifact integration, the VM integration, and the QEMU provider.

The default Engine profile references two Bus Engine OS artifact ids:
`bus-engine-os-rootfs-aarch64` for the raw root disk and
`bus-engine-os-kernel-aarch64` for the direct QEMU kernel image. Build and
promote those artifacts through the delegated Bus Engine OS command before
starting the Engine.

```sh
bus engine os build mvp --target-arch aarch64 --lane bootstrap
bus engine os artifact promote-engine --target-arch aarch64 --lane bootstrap
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
