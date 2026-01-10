local function fail(message)
  vim.api.nvim_err_writeln(message)
  vim.cmd("cq")
end

local install_dir = vim.fn.stdpath("data") .. "/site"

local ok_setup, setup_err = pcall(function()
  require("nvim-treesitter").setup({ install_dir = install_dir })
end)

if not ok_setup then
  fail(tostring(setup_err))
end

local ok_install, install_err = pcall(function()
  require("nvim-treesitter").install({ "lua", "typescript" }):wait(300000)
end)

if not ok_install then
  fail(tostring(install_err))
end

local required_parsers = {
  lua = "lua.so",
  typescript = "typescript.so",
}

for lang, filename in pairs(required_parsers) do
  local parser_path = install_dir .. "/parser/" .. filename
  if not vim.uv.fs_stat(parser_path) then
    fail(lang .. " parser missing after install: " .. parser_path)
  end
end
