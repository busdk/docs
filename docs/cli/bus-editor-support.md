---
title: Editor support for `.bus` files
description: Install syntax highlighting for BusDK .bus files in VS Code compatible editors and build a .vsix package from source.
---

## Overview

BusDK ships a VS Code compatible language package for `.bus` files. The package
adds file association and syntax highlighting for shebang lines, comments,
include lines, sticky directive lines, command targets, flags, `key=value`
assignments, quoted strings, trailing line continuations, and common date-like
values that appear in Bus command files.

This is the primary install path for VS Code, Cursor, VSCodium, Windsurf, and
other editors that can consume VS Code extensions or `.vsix` packages.

## Install a shipped package

If BusDK publishes the extension in a marketplace, install it there in the same
way as other editor extensions. If you receive a release artifact instead,
install the `.vsix` file from the editor command palette. In VS Code and Cursor
this is typically the `Extensions: Install from VSIX...` command.

The same `.vsix` artifact is the fallback distribution path for users who do
not use the Microsoft Marketplace. A BusDK release can attach the file
directly, and editors that accept local `.vsix` packages can install it without
extra user-side configuration.

## Build the `.vsix` package from source

Inside the public [`bus`](https://github.com/busdk/bus) repository, run:

```sh
make package-vscode-extension
```

That command writes a `.vsix` artifact into `bus/bin/`. Maintainers can ship
that same file to users through release assets or another downloadable channel.

## What the package contains

The source lives under `bus/editors/vscode-bus-language/`. BusDK keeps one
canonical grammar there and packages it into the installable `.vsix` artifact
with an offline packager script. The same repository also verifies
representative `.bus` grammar fixtures in both source form and packaged `.vsix`
form, so shipping the extension does not depend on users writing local editor
settings by hand or on maintainers checking regex changes manually.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-script-files">`.bus` script files (writing and execution guide)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./validation-and-safety-checks">Validation and safety checks</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus module reference](../modules/bus)
- [`.bus` script files (writing and execution guide)](./bus-script-files)
- [BusDK CLI tooling and workflow](./index)
