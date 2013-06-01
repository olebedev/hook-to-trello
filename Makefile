LSC   = $(patsubst src/%.ls, build/%.js, $(shell find src -name "*.ls" -type f | sort))
TMPLS = $(patsubst src/%.eco, build/%.js, $(shell find src -name "*.eco" -type f  | sort))
COPY  = $(patsubst src/%, build/%, $(shell find src \! -name "*.ls" \! -name "*.less" \! -name "*.eco" -type f | sort))
LESS  = build/static/css/style.css

clean:
	@rm -rf build/bg build/server build/static build/templates build/app.js build/conf.js
	@echo "\033[1;33mClean done!\033[m"

build: $(LSC) $(TMPLS) $(COPY)
	@echo "\033[1;33mYep!\033[m"

build/%.js: src/%.ls
	@mkdir -p $(@D)
	@./node_modules/.bin/lsc -pcb $< > $@

build/%.css: src/%.less
	@mkdir -p $(@D)
	@./node_modules/.bin/lessc $< > $@

build/%.js: src/%.eco
	@mkdir -p $(@D)
	@./node_modules/.bin/cake -f $< eco > $@

build/%: src/%
	@mkdir -p $(@D)
	@cp $< $@

watch: clean build
	@clear
	@echo "Start watching \033[1;33m$(shell pwd)\033[m"
	@fswatch ./src 'make build'

APP   = "./build/app"

serve_fn = fswatch ./src 'kill `pidof fswatch` &&	\
				kill `pidof node` && 											\
				make build &&															\
				node $(KEYS) $(1)'

serve: build
	@clear
	@echo "Start watching \033[1;33m$(shell pwd)\033[m"
	@node $(KEYS) $(APP) &
	@while true; do $(call serve_fn, $(APP)); done

test: build
	@echo "Tests runner is not set"

.PHONY: clean build watch serve test install