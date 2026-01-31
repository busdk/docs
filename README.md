Documentation from this repository is available at https://docs.busdk.com/.

## Styling and branding

This site uses the upstream `jekyll-theme-primer` theme as the base and layers BusDK branding on top using standard GitHub Pages theme overrides. The primary entry point is `docs/assets/css/style.scss`, which imports the theme stylesheet and then imports a small set of local partials under `docs/_sass/busdk/`.

Light and dark appearance is automatic and follows the reader’s system preference via `prefers-color-scheme`. The BusDK brand token layer lives in `docs/_sass/busdk/_tokens.scss` as CSS custom properties, and the rest of the overrides map Primer-visible surfaces to those tokens. When adjusting colors, change token values in one place rather than introducing new literal color values across selectors.

For local preview, use Bundler with the GitHub Pages gem set. On macOS you typically need Xcode Command Line Tools available so native extensions can compile:

```bash
bundle install
bundle exec jekyll serve -s docs
```

## GitHub Pages

This site includes a smart not-found page in `docs/404.md`. It is built to `/404.html` via `permalink: /404.html`, suggests the appropriate section index by matching the requested URL path, and uses `{{ "/" | relative_url }}` plus `site.baseurl` so it remains correct with both a custom domain and a `baseurl`. The page still works without JavaScript, falling back to the documentation index and a short list of section links.
