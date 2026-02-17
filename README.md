Documentation from this repository is available at https://docs.busdk.com/.

## Design and SDD

The canonical BusDK design spec and Software Design Documents (SDDs) are published from this repo:

- [BusDK design spec](https://docs.busdk.com/) — entrypoint for the multi-page design (overview, CLI, data, layout, workflow, compliance, implementation).
- [BusDK Software Design Document (SDD)](https://docs.busdk.com/sdd) — single-page consolidated view of goals, requirements, architecture, and key decisions.
- [Module SDDs](https://docs.busdk.com/sdd/modules) — per-module SDDs (e.g. [bus-init](https://docs.busdk.com/sdd/bus-init), [bus-data](https://docs.busdk.com/sdd/bus-data), [bus-dev](https://docs.busdk.com/sdd/bus-dev), [bus-validate](https://docs.busdk.com/sdd/bus-validate)).

## Styling and branding

This site uses the upstream `jekyll-theme-primer` theme as the base and layers BusDK branding on top using standard GitHub Pages theme overrides. The primary entry point is `docs/assets/css/style.scss`, which imports the theme stylesheet and then imports a small set of local partials under `docs/_sass/busdk/`.

Light and dark appearance is automatic and follows the reader’s system preference via `prefers-color-scheme`. The BusDK brand token layer lives in `docs/_sass/busdk/_tokens.scss` as CSS custom properties, and the rest of the overrides map Primer-visible surfaces to those tokens. When adjusting colors, change token values in one place rather than introducing new literal color values across selectors.

This project uses **Ruby 3.3** and **Jekyll 4.4**. A `.ruby-version` file is included for rbenv or asdf; install Ruby 3.3 if needed (e.g. `rbenv install` or `asdf install`). For local preview, run from the repo root:

```bash
./start.sh
```

The script enables rbenv (so the correct Ruby is used), runs `bundle install` if needed, then starts `bundle exec jekyll serve -s docs`. It sets `JEKYLL_ENV=development` so Sass emits source maps and the Chrome DevTools automatic-workspace file is generated; production builds do not include source maps or that file. You can pass extra arguments to Jekyll (e.g. `./start.sh --livereload`). Alternatively, run `bundle install` and `bundle exec jekyll serve -s docs` yourself (set `JEKYLL_ENV=development` for local source maps).

**Chrome DevTools automatic workspaces.** When the site is served locally with `./start.sh`, a Jekyll plugin writes `/.well-known/appspecific/com.chrome.devtools.json` so Chrome DevTools can discover the workspace when you open the site from localhost. Chrome only requests this endpoint in local development; the file is never committed (it is generated in the build output only) and is removed in production builds. To use it: open the site in Chrome (e.g. `http://localhost:4000`), open DevTools (F12), go to **Sources → Workspace**. DevTools will show a **Connect** button for the discovered folder; click it and when prompted grant **Edit files** so Chrome can access your local project directory. Once connected, you can edit CSS, HTML, and JavaScript in the Sources panel and save (e.g. Cmd/Ctrl+S) back to disk. Note: changes you make in the **Elements** panel (DOM) are not saved to source files; only edits in the **Sources** panel to actual files in the workspace are persisted. The workspace root is the Jekyll source directory (the `docs` subdirectory); you can override it with `CHROME_DEVTOOLS_WORKSPACE_ROOT`. To verify the endpoint locally, with the dev server running run `./scripts/verify-devtools-workspace.sh dev` (optionally pass a different base URL, e.g. `./scripts/verify-devtools-workspace.sh dev http://localhost:4000`). The production build is verified in CI: the workflow asserts that the built site does not contain this file.

**Acceptance criteria (for PRs).** Manual: (1) Run `./start.sh`, open `http://localhost:4000` in Chrome, open DevTools → Sources → Workspace; a folder should appear with a Connect button; click Connect and grant "Edit files"; confirm the workspace is listed. (2) In Sources, open a file from the workspace (e.g. under `docs/_sass`), edit it, save (Cmd/Ctrl+S); confirm the change is written to disk. (3) Confirm that edits in the Elements panel do not persist to source files. Automated: (1) With dev server running, `./scripts/verify-devtools-workspace.sh dev` exits 0 and prints OK. (2) After a production build (`JEKYLL_ENV=production bundle exec jekyll build -s docs -d _site`) and the workflow’s removal step, `./scripts/verify-devtools-workspace.sh prod _site` exits 0; CI runs this assertion.

**Source maps.** When running locally with `./start.sh`, the built CSS is generated with source maps so DevTools can map rules back to the original `.scss` files. To verify CSS source maps, open the site in Chrome, open DevTools (F12 or Inspect), then in the Elements panel select an element and look at the Styles pane: the file name next to a rule should be a `.scss` path (e.g. `_sass/busdk/_tokens.scss`); clicking it should open the original source in the Sources panel. This site does not bundle or minify custom JavaScript; theme-provided JS is served as-is. If you add a JS build step later, enable source maps in that tool for development only (emit `.map` files and a `//# sourceMappingURL=` comment in the built JS), ensure Jekyll serves the `.map` files in dev, and configure production builds to omit or remove `.map` files; then in DevTools → Sources you can confirm you can navigate to the original JS source files.

## Content index JSON

This repository generates a machine-readable index at `docs/assets/data/content-index.json` with one record per tracked content file under `docs/` (excluding Jekyll internal paths under `docs/_*`). The JSON is flat: a metadata key `@generated_at` is included, and every other top-level key is a site path starting with `/` (the `docs/` prefix is removed, `.md` and `.html` suffixes are stripped, and trailing `/index` is removed) whose value is the ISO 8601 timestamp from the most recent Git commit that edited that file.

Generate it locally from the repository root with:

```bash
python3 scripts/generate-content-index.py
```

The GitHub Pages workflow also regenerates this file on every build. The workflow uses full repository history so timestamps come from Git commit history instead of filesystem modification times.

## GitHub Pages

Custom Jekyll plugins in `docs/_plugins` (for example the chapter-wrapping filter) do not run when GitHub Pages builds the site from the branch (safe mode). To use them, switch the site to **Deploy from GitHub Actions**: in the repo **Settings → Pages**, set **Build and deployment → Source** to **GitHub Actions**. The workflow in `.github/workflows/jekyll.yml` runs `bundle exec jekyll build -s docs` so plugins are loaded, then deploys the built site.

This site includes a smart not-found page in `docs/404.md`. It is built to `/404.html` via `permalink: /404.html`, suggests the appropriate section index by matching the requested URL path, and uses `{{ "/" | relative_url }}` plus `site.baseurl` so it remains correct with both a custom domain and a `baseurl`. The page still works without JavaScript, falling back to the documentation index and a short list of section links.
