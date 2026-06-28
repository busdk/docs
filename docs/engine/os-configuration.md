---
title: "Bus Engine OS configuration files"
description: How Bus Engine OS package recipes, source manifests, image profiles, package archives, and root filesystem assembly fit together.
---

# Bus Engine OS configuration files

The FSL-licensed Bus Engine OS preview binary can use configuration files you
provide to inspect package recipes, validate source manifests, build package
archives, assemble root filesystems, and build image profiles. The complete
tested Bus Engine OS Linux distribution source set is separate from the binary
tool: paid users receive the accepted package catalog, profile source, build
scripts, and release materials under the applicable source-access terms.

## The configuration model

Bus Engine OS builds a Linux system through four layers:

| Layer | Files | Purpose |
| --- | --- | --- |
| Source manifest | `manifests/.../sources.yml` | Declares upstream or generated source archives and their verification metadata. |
| Package recipe | `packages/<name>/package.yml` plus `build.sh` | Defines how one source package becomes a validated `.buspkg.tar.gz` archive. |
| Image profile | `config/profiles/<profile>.json` | Selects package groups, kernel config, services, boot expectations, and acceptance policy for one target system. |
| Build workspace | `build/workspaces/<workspace>/...` | Holds package outputs, assembled root filesystems, images, logs, checksums, provenance, and boot evidence. |

People sometimes call the package catalog `packages.yml`. In the current Bus
Engine OS layout, the catalog is directory-based: each package has its own
`package.yml`, and profile commands resolve those files into one package set.

## Package recipes

A package recipe names the package identity, source identity, architecture,
license, dependency edges, and runtime-image membership. A minimal runtime
package recipe looks like this:

```yaml
name: hello
version: 1.0.0
release: 1
architecture: x86_64
license: MIT
license_status: reviewed
runtime: true
builder_only: false
source_name: hello
source_version: 1.0.0
source_filename: hello-1.0.0.tar.gz
runtime_dependencies: zlib
```

The package directory normally also contains `build.sh`. During a package
build, Bus Engine OS resolves the recipe, verifies the declared source archive
from the source cache, prepares dependency sysroots, runs the build into a
staging root, records metadata, and writes a `.buspkg.tar.gz` archive.

The main fields are:

| Field | Meaning |
| --- | --- |
| `name`, `version`, `release` | Package identity used in archive ids, package databases, and dependency graphs. |
| `architecture` | Target package architecture such as `x86_64`, `aarch64`, or `noarch`. |
| `license`, `license_status` | License expression and review state required before an archive can be accepted. |
| `runtime` | Marks a package as a runtime package rather than only a build tool. |
| `builder_only` | Marks packages used only to build other packages. Builder-only packages must stay out of runtime rootfs closure. |
| `source_name`, `source_version`, `source_filename` | Link the recipe to a source entry in the source manifest. |
| `source_type` | Use `generated` when the package source is produced by Bus Engine OS rather than downloaded from upstream. |
| `source_dependencies` | Source archives that must be present before the build can run. |
| `build_dependencies` | Package archives installed into the build sysroot for compilation or configuration. |
| `test_dependencies` | Package archives needed only for package tests. |
| `runtime_dependencies` | Package archives required in the final runtime dependency graph. |
| `image_member` | Defaults to true for profile-selected runtime packages. Set it to false for accepted builder packages that must stay out of assembled images. |
| `patches` | Declared patch files and checksums applied before the build. |

Runtime dependency constraints can select version variants when a recipe
provides them. For example, `runtime_dependencies: openssl=4.0.1` selects a
matching OpenSSL variant instead of the default `openssl` recipe.

## Recipe variants

Version and architecture variants can override the top-level recipe. A version
variant such as `packages/iproute2/versions/7.0.0/package.yml` can inherit the
default recipe while changing version-specific fields. An architecture variant
such as `packages/example/architectures/x86_64/package.yml` can override the
target architecture or architecture-specific dependency details.

Variant manifests use `extends`:

```yaml
extends: ../../package.yml
architecture: x86_64
```

Run the layout and graph checks before relying on a package tree:

```sh
bus engine os package layout-check --recipes packages
bus engine os package graph --kind runtime --recipes packages --package openssh
bus engine os package final-system-plan --recipes packages
```

## Source manifests

Source manifests describe the upstream or generated source inputs that package
recipes refer to. A custom package tree can keep its own source manifest as
long as package recipes and source entries agree on `source_name`,
`source_version`, and `source_filename`.

Validate, fetch, and verify source inputs before building packages:

```sh
bus engine os source validate --manifest manifests/sources.yml
bus engine os source fetch --manifest manifests/sources.yml --cache build/sources
bus engine os source verify --manifest manifests/sources.yml --cache build/sources
```

Detached signature verification is available when source metadata requires it:

```sh
bus engine os source verify-openpgp \
  --manifest manifests/sources.yml \
  --cache build/sources \
  --keyring keys/upstream.gpg
```

## Image profiles

Image profiles live under `config/profiles/`. A profile selects the target
architecture, build profile, kernel package and config, rootfs package groups,
runtime configuration packages, service expectations, boot expectations, and
acceptance policy.

The accepted `virtual-server` profile is the starting point for server systems.
The `gui-wayfire` profile is additive GUI work under development and must not
change the accepted server package set.

Useful profile commands:

```sh
bus engine os profile list
bus engine os profile validate --manifest config/profiles/virtual-server.json
bus engine os profile resolve --profile virtual-server
bus engine os profile resolve --profile gui-wayfire --format json
bus engine os profile diff --left virtual-server --right gui-wayfire
bus engine os profile lock --profile virtual-server --check config/profiles/virtual-server.lock.json
```

A profile package entry has a status. `existing` means the recipe is expected
to build or resolve now. `planned` means the package is part of the design but
is not accepted for that profile yet.

Create a new profile when the target system needs a different kernel
configuration, package group, service expectation, or acceptance policy. Keep
feature work in additive profiles so experimental packages cannot silently
alter the accepted server image.

## Building a custom root filesystem

For a custom package tree, start with one package and one source entry. Fetch
and verify sources, build the package, inspect the archive, then install it
into a scratch root:

```sh
bus engine os source validate --manifest manifests/sources.yml
bus engine os source fetch --manifest manifests/sources.yml --cache build/sources
bus engine os source verify --manifest manifests/sources.yml --cache build/sources
bus engine os package build \
  --recipe packages/hello \
  --sources-cache build/sources \
  --work build/work/hello \
  --out-dir build/packages
bus engine os package validate build/packages/hello-1.0.0-1.x86_64.buspkg.tar.gz
bus engine os rootfs assemble \
  --root build/rootfs \
  build/packages/hello-1.0.0-1.x86_64.buspkg.tar.gz
bus engine os rootfs audit --root build/rootfs
bus engine os rootfs archive --root build/rootfs --out build/rootfs.tar.gz
```

For a full Bus Engine OS image, use an image profile:

```sh
bus engine os build image --profile virtual-server
```

The full-system command expects the relevant package recipes, source manifests,
build scripts, and profile files to be available to the build workspace. The
preview binary supplies the command implementation. Paid source access supplies
the complete tested Bus Engine OS distribution source set for supported
profiles.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./status">Status and roadmap</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bus Engine</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./licensing">Software and source licensing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
