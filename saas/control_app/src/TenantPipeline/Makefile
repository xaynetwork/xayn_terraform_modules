.PHONY: build-TenantPipeline

build-TenantPipeline:
	npm install
	npm run clean
	npm run build
	cp -r dist "$(ARTIFACTS_DIR)/"
	cp package.json package-lock.json "$(ARTIFACTS_DIR)/"
	npm install --production --prefix "$(ARTIFACTS_DIR)/"
	rm "$(ARTIFACTS_DIR)/package.json" # to avoid rebuilding when changes don't relate to dependencies
