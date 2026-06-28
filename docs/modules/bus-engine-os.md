# bus-engine-os

`bus-engine-os` builds Bus Engine OS images from source. It is the module that
turns verified source manifests, package recipes, kernel configuration, image
profiles, and validation rules into bootable Linux runtime artifacts for Bus
Engine.

The normal user path is intentionally short:

```sh
bus engine os build image
bus engine os artifact promote-engine --workspace <workspace>
bus services up
bus engine start
bus engine ssh
```

The image command builds missing packages as part of the full image flow. Use
the package command only when you are working on one package or a small package
set:

```sh
bus engine os build packages openssl openssh
```

## Image Builds

`bus engine os build image` creates an isolated workspace, selects the host
architecture by default, detects the host CPU count, and runs the image
acceptance path. On Linux it uses the local build host when the preflight passes.
If Docker is available and the local host is missing build requirements, it
falls back to Docker. On macOS the command uses Docker because the full Linux
build cannot be produced directly on the native macOS host.

The default profile is `virtual-server`. It builds the minimal serial-console
server image used by the accepted Bus Engine OS proof. Pass `--profile` when you
are intentionally building another profile:

```sh
bus engine os build image --profile virtual-server
```

The command prints progress with log levels and writes detailed output under the
selected workspace. Failed builds print the full log path. The common image log
is:

```text
build/workspaces/<workspace>/logs/image-build.log
```

Use a generated workspace for normal builds. Reuse `--workspace` when you want
to resume or inspect a named workspace.

## Package Builds

Package builds produce deterministic `.buspkg.tar.gz` archives. A package
archive contains metadata, checksums, dependency information, patch information,
build provenance, and the staged package root.

Focused package work uses:

```sh
bus engine os build packages <package>...
```

The command validates package names, maps them to cache-keyed archive targets,
reuses validated package archives when their inputs have not changed, and writes
full logs under the selected workspace.

Examples:

```sh
bus engine os build packages openssl
bus engine os build packages openssl openssh
bus engine os build packages --profile gui-wayfire wayland-protocols libxkbcommon
```

## Profiles

Image profiles live under `config/profiles/`. A profile selects the target
architecture, build profile, kernel package and config, rootfs package groups,
runtime configuration packages, service expectations, boot expectations, and
acceptance policy.

Useful profile commands:

```sh
bus engine os profile list
bus engine os profile resolve --profile virtual-server
bus engine os profile diff --left virtual-server --right gui-wayfire
bus engine os profile lock --profile virtual-server --check config/profiles/virtual-server.lock.json
```

`virtual-server` is the accepted minimal server profile. `gui-wayfire` is an
additive GUI profile under development; it must not change the accepted
`virtual-server` package set.

## Promoting Artifacts

An accepted image workspace contains a raw root disk and an architecture-specific
kernel image. Promote them into the local Bus Engine artifact catalog with:

```sh
bus engine os artifact promote-engine --workspace <workspace>
```

The command copies stable local handles under `.bus/artifacts/`, calculates
`sha256:` digests, and updates the local Bus artifact catalog records used by
the Engine runtime. It selects the host architecture by default. Pass
`--target-arch` only when promoting artifacts for another architecture.

The architecture-specific artifacts are:

| Architecture | Rootfs record | Kernel record | Kernel file |
| --- | --- | --- | --- |
| `x86_64` | `bus-engine-os-rootfs-x86_64` | `bus-engine-os-kernel-x86_64` | `bzImage` |
| `aarch64` | `bus-engine-os-rootfs-aarch64` | `bus-engine-os-kernel-aarch64` | `Image` |

## Running Through Bus Engine

After promotion, start Bus services and the Engine runtime:

```sh
bus services up
bus engine start
bus engine status
bus engine ssh
```

The local Engine profile boots Bus Engine OS through QEMU direct kernel boot.
Operator SSH uses a host-generated key. The public key is passed to the guest at
boot, and the private key stays on the host.

## Current Accepted Runtime

The latest accepted virtual-server proof is documented in the module repository
at `docs/image-acceptance-2026-06-27.md`. It boots the package-built rootfs to
Systemd multi-user readiness, starts OpenSSH, and proves Engine SSH access.

Important runtime versions from that proof:

| Component | Version |
| --- | --- |
| Linux kernel | 6.18.36 |
| Systemd | 261.1 |
| OpenSSL | 3.5.7 |
| OpenSSH | 10.3p1 |
| Iproute2 | 7.1.0 |
| Util-linux | 2.42.2 |
| Expat | 2.8.2 |
| SQLite | 3.53.3 |
| Bash | 5.3 with patch stream through `bash53-015` |
| Readline | 8.3 with patch stream through `readline83-003` |

Use the package recipe inventory command for the full current package/version
list:

```sh
bus engine os package recipes
bus engine os package recipes --format json
```

## Source And License Handling

Bus Engine OS builds from declared source manifests and package recipes.
Downloaded sources are verified by reviewed SHA-256 checksums before use.
Detached signature artifacts and OpenPGP checks are supported where package
metadata requires them.

Package manifests must declare license metadata before package archives can be
accepted. The authoritative license text for third-party components remains the
upstream package license text distributed with the corresponding source.

## Generated Outputs

Build outputs are generated under `build/` and are not committed. Important
outputs from an accepted image workspace include:

```text
build/workspaces/<workspace>/images/rootfs.raw
build/workspaces/<workspace>/images/rootfs.tar.gz
build/workspaces/<workspace>/images/Image
build/workspaces/<workspace>/images/bzImage
build/workspaces/<workspace>/images/qemu-artifacts.json
build/workspaces/<workspace>/images/build-provenance.json
build/workspaces/<workspace>/images/image-acceptance.json
build/workspaces/<workspace>/logs/qemu-serial.log
```

Only one of `Image` or `bzImage` is expected for a single architecture-specific
workspace.
