.PHONY: clean

# Generated artifacts and local caches for the SDD Jekyll site.
CLEAN_PATHS := \
	_site \
	.jekyll-cache \
	.jekyll-metadata \
	.sass-cache \
	.bundle \
	vendor/bundle \
	tmp

clean:
	rm -rf $(CLEAN_PATHS)
