TEST_DIR=test
WASM_OUTDIR=${TEST_DIR}/_wasm_out

.PHONY: type_check
type_check:
	for i in src/*.mo ; do \
		echo "==== Run type check $$i ===="; \
		$(shell dfx cache show)/moc $(shell vessel sources) --check $$i || exit; \
	done
	echo "SUCCEED: All motoko type check passed"

.PHONY: module_test
module_test:
	rm -rf $(WASM_OUTDIR)
	mkdir $(WASM_OUTDIR)

	for i in $(TEST_DIR)/*Test.mo; do \
		$(shell dfx cache show)/moc $(shell vessel sources) -wasi-system-api -o $(WASM_OUTDIR)/$(shell basename $$i .mo).wasm $$i; \
		wasmtime $(WASM_OUTDIR)/$(shell basename $$i .mo).wasm; \
	done
	rm -rf $(WASM_OUTDIR)
	echo "SUCCEED: All module tests passed"