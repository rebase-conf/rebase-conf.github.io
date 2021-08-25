GEM_CACHE_DIR := .gem-cache
CONTAINER_NAME := rebaseconf

.PHONY: jekyll run

jekyll:
	[ -d $(GEM_CACHE_DIR) ] || mkdir -p $(GEM_CACHE_DIR)
	[ -d _site ] || mkdir _site
	docker_status=$$(docker inspect -f '{{.State.Running}}' $(CONTAINER_NAME) 2>/dev/null); \
  echo "$$docker_status"; \
  if [[ -z "$$docker_status" ]]; then \
    docker run \
      -d \
      --name $(CONTAINER_NAME) \
      -v "$(CURDIR)/$(GEM_CACHE_DIR):/usr/local/bundle" \
      -v "$(CURDIR):/srv/jekyll" \
      -p 4000:4000 \
      jekyll/jekyll \
      jekyll $(TASK); \
  elif [[ "$$docker_status" == "false" ]]; then \
    docker start $(CONTAINER_NAME); \
  fi
	docker logs -f $(CONTAINER_NAME)

run:
	$(MAKE) jekyll TASK=serve

stop:
	docker stop $(CONTAINER_NAME)

data:
	./_tools/2021-SPLASH/generate-data.R
