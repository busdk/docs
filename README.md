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

The script enables rbenv (so the correct Ruby is used), runs `bundle install` if needed, then starts `bundle exec jekyll serve -s docs`. You can pass extra arguments to Jekyll (e.g. `./start.sh --livereload`). Alternatively, run `bundle install` and `bundle exec jekyll serve -s docs` yourself.

## GitHub Pages

Custom Jekyll plugins in `docs/_plugins` (for example the chapter-wrapping filter) do not run when GitHub Pages builds the site from the branch (safe mode). To use them, switch the site to **Deploy from GitHub Actions**: in the repo **Settings → Pages**, set **Build and deployment → Source** to **GitHub Actions**. The workflow in `.github/workflows/jekyll.yml` runs `bundle exec jekyll build -s docs` so plugins are loaded, then deploys the built site.

This site includes a smart not-found page in `docs/404.md`. It is built to `/404.html` via `permalink: /404.html`, suggests the appropriate section index by matching the requested URL path, and uses `{{ "/" | relative_url }}` plus `site.baseurl` so it remains correct with both a custom domain and a `baseurl`. The page still works without JavaScript, falling back to the documentation index and a short list of section links.
