# AGENTS

The page heading contract: the layout outputs the front matter `title` as the
single `<h1>` in the content area. The site header (`.busdk-site-header`)
shows the site title and links to home; it is not repeated as the page h1. Each
page should use a meaningful first `##` in the body (e.g. Overview, In this
section) so that both h1 (page title) and h2 (first section) add meaning;
avoid using the first `##` to repeat the page title.

This repository has two documentation page layouts that must stay consistent.
The front page is the home layout without the left navigation sidebar. Inner
pages use the documentation layout with the left sidebar navigation.

The visual contract is that section backgrounds span the full visible content
area, while text content stays readable in a constrained column. Keep max-width
constraints on `.busdk-content-inner` and related inner wrappers, and apply
backgrounds on the outer section wrappers (for example chapter sections and home
sections) so backgrounds do not collapse to text width.

Section headings in body content must keep the accent heading style. When
updating chapter wrappers or styles, ensure heading selectors cover both chapter
structures used by the site: headings under `.busdk-chapter-inner` and headings
under `.busdk-chapter-section-inner`.

When making style changes, edit source files under `docs/docs/_sass` and
`docs/docs/_layouts`, not generated files under `_site`. Use `git diff` to
confirm layout and styling changes are intentional before finishing.
