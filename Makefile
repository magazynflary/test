.PHONY: help test test-phase1 test-server test-cms test-links test-production validate-ready hugo hugo-cms cms build hugo-build purge-css clean backstop-ref backstop-test backstop-approve

help:
	@echo "Dostępne komendy:"
	@echo "  make hugo             - Uruchom serwer lokalny Hugo"
	@echo "  make hugo-cms         - Uruchom Hugo + CMS server"
	@echo "  make cms              - Uruchom tylko CMS server (decap-server)"
	@echo "  make build            - Zbuduj stronę produkcyjną"
	@echo "  make test             - Uruchom wszystkie testy"
	@echo "  make test-phase1      - Uruchom testy Fazy 1"
	@echo "  make test-server      - Uruchom testy lokalnego serwera"
	@echo "  make test-cms         - Uruchom testy Decap CMS"
	@echo "  make test-links       - Uruchom testy integralności odnośników"
	@echo "  make test-production  - Test buildu produkcyjnego"
	@echo "  make validate-ready   - Sprawdź czy projekt gotowy do GitHub Pages"
	@echo "  make backstop-ref     - Zrzuty referencyjne (przed zmianami)"
	@echo "  make backstop-test    - Porównaj z referencją (po zmianach)"
	@echo "  make backstop-approve - Zatwierdź nowe zrzuty jako referencję"
	@echo "  make clean            - Wyczyść wygenerowane pliki"

hugo:
	hugo server --buildDrafts --buildFuture

hugo-cms:
	@./scripts/start-cms-local.sh

cms:
	@echo "Uruchamianie Decap CMS server..."
	npx decap-server

build: hugo-build purge-css

hugo-build:
	hugo --minify --buildFuture

purge-css:
	npx purgecss --config purgecss.config.js

test: test-phase1 test-server test-cms test-links

test-phase1:
	@./tests/test-phase1.sh

test-server:
	@./tests/test-local-server.sh

test-cms:
	@./tests/test-decap-cms.sh

test-links:
	hugo --buildDrafts --buildFuture --quiet
	cd tests/reference-integrity && go test -count=1 -v .

test-production:
	@./scripts/test-production-build.sh

validate-ready:
	@./scripts/validate-github-ready.sh

backstop-ref:
	npx backstop reference

backstop-test:
	npx backstop test

backstop-approve:
	npx backstop approve

clean:
	rm -rf public/ resources/ .hugo_build.lock
	go clean -testcache
