GEM_CACHE_DIR := .gem-cache

.PHONY: jekyll run

jekyll:
	[ -d $(GEM_CACHE_DIR) ] || mkdir -p $(GEM_CACHE_DIR)
	[ -d _site ] || mkdir _site
	docker run \
      --name rebaseconf \
      --rm \
      -v "$$PWD/$(GEM_CACHE_DIR):/usr/local/bundle" \
      -v "$$PWD:/srv/jekyll" \
      -p 4000:4000 \
      jekyll/jekyll \
      jekyll $(TASK)

run:
	$(MAKE) jekyll TASK=serve
