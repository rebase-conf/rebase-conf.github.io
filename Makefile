GEM_CACHE_DIR := .gem-cache
CONTAINER_NAME := rebaseconf

.PHONY: jekyll run

jekyll:
	[ -d $(GEM_CACHE_DIR) ] || mkdir -p $(GEM_CACHE_DIR)
	[ -d _site ] || mkdir _site
	if [ "$$(docker inspect -f '{{.State.Running}}' $(CONTAINER_NAME))" = "true" ]; then \
    docker logs -f $(CONTAINER_NAME); \
  else \
   docker run \
      --name $(CONTAINER_NAME) \
      --rm \
      -v "$$PWD/$(GEM_CACHE_DIR):/usr/local/bundle" \
      -v "$$PWD:/srv/jekyll" \
      -p 4000:4000 \
      jekyll/jekyll \
      jekyll $(TASK); \
  fi

run:
	$(MAKE) jekyll TASK=serve
