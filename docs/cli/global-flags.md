## Standard global flags

Most BusDK module CLIs accept a common set of global flags before the subcommand. These flags behave the same across modules that support them: help and version exit immediately, working directory and output redirection are applied before any module logic, and color and verbosity affect only human-facing diagnostics. In module synopsis lines this set is referred to as **[global flags]**; the list below is the canonical definition.

Global flags are accepted in any order before the subcommand name. A lone `--` ends flag parsing; everything after it is passed to the subcommand as positional arguments and is not interpreted as a flag, even if it starts with `-`. Short flags such as `-v` and `-V` are distinct; combining them (e.g. `-vV`) is only valid if a module explicitly documents that behavior. Repeated `-v` or `--verbose` accumulates: `-vv` is verbosity level 2, `-vvv` is 3, and so on. Quiet and verbose are mutually exclusive; providing both is invalid usage and exits with status 2.

- **`-h`**, **`--help`** — Print help to standard output and exit 0. When a subcommand is present, help is for that subcommand; otherwise it is global help. When help is requested, all other flags and arguments are ignored.
- **`-V`**, **`--version`** — Print the tool name and version to standard output as a single line (e.g. `bus-accounts <version>`) and exit 0. All other flags and arguments are ignored when version is requested.
- **`-v`**, **`--verbose`** — Enable verbose informational output. Verbose output is written to standard error so that standard output stays reserved for command results. Verbosity can be repeated (`-vv`, `--verbose --verbose`) and accumulates. Verbose output must not alter structured output written to stdout or to the file given by `--output`, and must never be required for correctness.
- **`-q`**, **`--quiet`** — Suppress all normal non-error output. When quiet is set, the tool must not print command result output to stdout and must not print informational or verbose messages; only error messages may go to standard error. Exit codes are unchanged. If both `--quiet` and `--verbose` are provided, the tool prints a short error to stderr and exits with status 2.
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory for the command. All module paths (e.g. dataset and schema paths) are resolved relative to this directory. If the directory does not exist or is not accessible, the tool prints a clear error to stderr and exits with status 1.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of standard output. Errors and diagnostics still go to stderr. The file is created if it does not exist and truncated if it exists. If the file cannot be created or written, the tool prints a clear error to stderr and exits with status 1. If `--output` is used together with `--quiet`, quiet wins: no output is written to the file or to stdout; the command still runs and exits with the correct status.
- **`-f <format>`**, **`--format <format>`** — Select the output format for commands that produce structured results. The default is stable and documented per command (e.g. `tsv` or `text`). Supported formats are listed in the command’s help. An unknown format is invalid usage: the tool prints a short error to stderr and exits with status 2. Format selection affects only command result output, not validation or other behavior. Commands that do not produce a result set (e.g. `validate`) either ignore `--format` safely or treat it as invalid usage, as documented per module.
- **`--color <mode>`** — Control colored output for human-facing messages. `<mode>` must be one of `auto`, `always`, or `never`. `auto` enables color only when stderr is a terminal and the environment supports it; `always` forces color; `never` disables it. Color applies only to text on standard error (help, diagnostics). Structured output on stdout or in `--output` must not contain color control sequences unless the selected format explicitly requires it. An invalid mode is invalid usage and exits with status 2.
- **`--no-color`** — Alias for `--color=never`. If both `--color` and `--no-color` are present, color is disabled.
- **`--`** — Terminate global flag parsing. All following tokens are positional arguments for the subcommand and are passed through unchanged.

Some modules add their own global flags (e.g. `bus dev --agent`). Those are documented on the module’s CLI reference page. To see the full set of flags for a module, run `bus <module> --help`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./command-structure">Command structure and discoverability</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next">&rarr; <a href="./command-naming">CLI command naming</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference](../modules/index) (synopsis convention for [global flags])
- [Command structure and discoverability](./command-structure)
