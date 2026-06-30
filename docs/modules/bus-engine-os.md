# bus-engine-os

`bus-engine-os` builds Bus Engine OS: the source-built Linux distribution used
by Bus Engine runtime environments.

The FSL-licensed preview binary release is available for technical evaluation.
It can inspect package recipes, validate source manifests, build package
archives, assemble root filesystems, build the accepted `virtual-server` image
path, and promote accepted artifacts into a local Bus Engine runtime. The
complete tested Bus Engine OS Linux distribution source tree, including the
accepted package catalog and profile source used for supported builds, is
available to paid users under the applicable source-access terms.

The accepted `virtual-server` image is built from verified source inputs,
assembled from validated `.buspkg.tar.gz` package archives, and boot-tested in
QEMU.

## Quick Start

Build an image:

```sh
bus engine os build image
```

The command detects the host architecture and CPU count, creates an isolated
build workspace, builds or restores required packages, assembles a root
filesystem, creates QEMU image artifacts, and runs the image acceptance path.

Use focused package builds only when you are working on one package or a small
package set:

```sh
bus engine os build packages openssl openssh
```

List packages that are currently available to compile from source for the
current host architecture:

```sh
bus engine os packages
bus engine os packages --format json
bus engine os packages --profile virtual-server
bus engine os packages --arch x86_64
bus engine os packages --missing-arch x86_64
bus engine os packages --license GPL-3.0
```

List the complete recipe catalog, including all architectures and planned
package entries:

```sh
bus engine os packages --all
```

Inspect packages already installed in an assembled root filesystem:

```sh
bus engine os rootfs packages --root <rootfs>
```

After an accepted image build, promote it to the local Bus Engine catalog and
start the runtime:

```sh
bus engine os artifact promote-engine
bus services up
bus engine start
bus engine status
bus engine ssh
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
bus engine os build packages --profile virtual-desktop wayland-protocols libxkbcommon
```

The lower-level package command can build one recipe directory directly. This
is useful when you are creating or debugging your own package tree with the
preview binary:

```sh
bus engine os package build \
  --recipe packages/hello \
  --sources-cache build/sources \
  --work build/work/hello \
  --out-dir build/packages
```

Use `package validate`, `package inspect`, `package cleanup-audit`, and
`package repro` to check archives before installing them into a root filesystem:

```sh
bus engine os package validate build/packages/hello-1.0.0-1.x86_64.buspkg.tar.gz
bus engine os package inspect build/packages/hello-1.0.0-1.x86_64.buspkg.tar.gz
bus engine os package cleanup-audit build/packages/hello-1.0.0-1.x86_64.buspkg.tar.gz
```

The package recipe, source manifest, and profile formats are documented in
[Bus Engine OS configuration files](../engine/os-configuration). That page
explains `package.yml`, source manifests, profile JSON, variant recipes,
dependency fields, and how a preview binary user can build a custom package
tree without access to the complete tested Bus Engine OS distribution source.

## Profiles

Image profiles live under `config/profiles/`. A profile selects the target
architecture, build profile, kernel package and config, rootfs package groups,
runtime configuration packages, service expectations, boot expectations, and
acceptance policy.

Useful profile commands:

```sh
bus engine os profile list
bus engine os profile resolve --profile virtual-server
bus engine os profile diff --left virtual-server --right virtual-desktop
bus engine os profile lock --profile virtual-server --check config/profiles/virtual-server.lock.json
```

`virtual-server` is the accepted minimal server profile. `virtual-desktop` is
an additive desktop profile under development; it must not change the accepted
`virtual-server` package set.

The accepted `virtual-server` profile is the right starting point for server
systems. Create a new profile only when the target system needs a different
kernel configuration, package group, service expectation, or acceptance policy.
Keep desktop work in an additive profile such as `virtual-desktop` so it
cannot alter the accepted server package set accidentally.

For a step-by-step custom root filesystem example, see
[Building a custom root filesystem](../engine/os-configuration#building-a-custom-root-filesystem).

## Promoting Artifacts

An accepted image workspace contains a raw root disk and an architecture-specific
kernel image. Promote them into the local Bus Engine artifact catalog with:

```sh
bus engine os artifact promote-engine
```

The command copies stable local handles under `.bus/artifacts/`, calculates
`sha256:` digests, and updates the local Bus artifact catalog records used by
the Engine runtime. It selects the host architecture by default and can find
the current accepted image workspace without an explicit workspace argument.
Pass `--workspace <workspace>` only when promoting a specific build workspace.
Pass `--target-arch` only when promoting artifacts for another architecture.

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

Use the source-build availability command for the current package, version, and
license list that is available to compile for the current host architecture:

```sh
bus engine os packages
bus engine os packages --format json
```

Filter by image profile when you want the package set for one target without
other feature sets. For example, this lists the selected `virtual-server`
source packages without `virtual-desktop` additions:

```sh
bus engine os packages --profile virtual-server
bus engine os packages --profile virtual-server --format json
```

The complete recipe catalog includes planned package entries that are not
buildable yet and every declared architecture variant. It prints availability
status so automation can distinguish accepted source-build recipes from planned
entries:

```sh
bus engine os packages --all
bus engine os packages --all --format json
```

Architecture variants are printed as separate rows, and filters include
`noarch` package entries automatically. License filters match SPDX-style
license ids inside compound expressions; for example, `--license GPL-3.0`
matches a package declared as
`MIT AND GPL-3.0-or-later`.

Use `--missing-arch x86_64` to find package names that have a recipe for
another architecture but no x86_64 or `noarch` recipe. This is useful when
checking what remains to port before a profile can build on another target.

Use `--arch all` or `--status all` when you only want to broaden one part of
the default view. `--all` is the shortcut for both defaults; an explicit
`--arch` or `--status` narrows that dimension again.

Packages already installed into a built root filesystem are a separate view:

```sh
bus engine os rootfs packages --root <rootfs>
```

## Source And License Handling

Bus Engine OS builds from declared source manifests and package recipes.
Downloaded sources are verified by reviewed SHA-256 checksums before use.
Detached signature artifacts and OpenPGP checks are supported where package
metadata requires them.

Package manifests must declare license metadata before package archives can be
accepted. The authoritative license text for third-party components remains the
upstream package license text distributed with the corresponding source.

Before publishing a static Bus Engine OS or Browser Lab directory, generate the
release license files and required source-material payloads into that same
directory:

```sh
bus engine os artifact license-bundle \
  --out ./public/engine/browser-lab \
  --sources-cache build/sources \
  --qemu-source-dir ../../qemu
```

The command writes `LICENSES.txt`, `THIRD-PARTY-NOTICES.txt`,
`SOURCE-MATERIALS.txt`, `licenses.json`, and `source-materials/`.
`source-materials/sources/` contains only source archives and patch files for
shipped package recipes whose effective recorded license expression requires
source delivery. Dual-license expressions with a non-copyleft option do not
copy source archives unless another required license term still creates a
source-delivery obligation. QEMU source materials are included when
`--qemu-source-dir` is used for a QEMU/WASM release. Permissive shipped
packages remain listed in the license and notice indexes, but their source
archives are not copied.

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
