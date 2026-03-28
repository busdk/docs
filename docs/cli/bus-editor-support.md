---
title: Editor support for `.bus` files
description: Install BusDK .bus editor support for VS Code compatible editors, Tree-sitter-based editors, and stdio language-server clients.
---

## Overview

BusDK ships three `.bus` editor-support layers.

The first is the VS Code compatible language package. It adds file association,
syntax highlighting, and semantic tokens for shebang lines, comments, include
lines, sticky directive lines, command targets, flags, `key=value`
assignments, quoted strings, trailing line continuations, and common date-like
values that appear in Bus command files.

This is the primary install path for VS Code, Cursor, VSCodium, Windsurf, and
other editors that can consume VS Code extensions or `.vsix` packages.

The second is a Tree-sitter grammar under `bus/editors/tree-sitter-bus/` for
parser-backed highlighting in editors such as Neovim and Emacs.

The third is a lightweight stdio language server at
`bus/editors/vscode-bus-language/language-server.js`. Editors that can launch a
custom language server can use it directly for `.bus` semantic tokens even when
they do not consume VS Code extensions.

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

The supported release surfaces are intentionally simple. The `.vsix` artifact
is the first-class downloadable package for VS Code, Cursor, and Windsurf, and
the same extension metadata is also validated for the Open VSX-compatible
identifier `busdk.language-bus` / `busdk/language-bus` so VSCodium-style
distribution remains aligned with the shipped package metadata.

From the `bus` repository root, maintainers can validate that release metadata
still matches those supported distribution paths:

```sh
make check-vscode-extension-release
```

## What the package contains

The VS Code-compatible source lives under `bus/editors/vscode-bus-language/`.
BusDK keeps one canonical TextMate grammar there, packages it into the
installable `.vsix` artifact with an offline packager script, and ships a local
semantic-token provider plus the same stdio language-server script that other
editors can run directly.

The parser-backed Tree-sitter source lives under `bus/editors/tree-sitter-bus/`
with `grammar.js` and `queries/highlights.scm`. That is the intended integration
path for editors that use Tree-sitter natively.

The repository verifies these artifacts with deterministic offline checks, so
shipping the extension or the parser-backed assets does not depend on users
writing local editor settings by hand or on maintainers checking grammar changes
manually.

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
