.PHONY: build-TenantPipeline

build-TenantPipeline:
	npm install -g clean-modules
	npm install
	npm run clean
	npm run build
	cp -r dist "$(ARTIFACTS_DIR)/"
	cp package.json package-lock.json "$(ARTIFACTS_DIR)/"
	npm install --production --prefix "$(ARTIFACTS_DIR)/"
	pushd "$(ARTIFACTS_DIR)/" && clean-modules -y && popd
	rm "$(ARTIFACTS_DIR)/package.json" # to avoid rebuilding when changes don't relate to dependencies
