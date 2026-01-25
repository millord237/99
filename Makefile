lua_fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lua_fmt_check:
	echo "===> Checking format"
	stylua lua/ --config-path=.stylua.toml --check

lua_lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

lua_lsp_check:
	echo "===> LSP Diagnostics"
	nvim --headless --noplugin -u scripts/tests/minimal.vim \
		-c "lua dofile('scripts/ci/lua_ls_check.lua')"

lua_test:
	echo "===> Testing"
	nvim --headless --noplugin -u scripts/tests/minimal.vim \
        -c "PlenaryBustedDirectory lua/99 {minimal_init = 'scripts/tests/minimal.vim'}"

lua_clean:
	echo "===> Cleaning"
	rm /tmp/lua_*

pr_ready: lua_lint lua_test lua_fmt_check lua_lsp_check
