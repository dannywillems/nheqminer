.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; \
		{printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install documentation dependencies
	npm install

.PHONY: start
start: ## Run the docs dev server
	npx docusaurus start

.PHONY: build
build: ## Build the docs for production
	npx docusaurus build

.PHONY: serve
serve: ## Serve the built docs locally
	npx docusaurus serve

.PHONY: clear
clear: ## Clear the Docusaurus cache
	npx docusaurus clear
