local install_dir = vim.fn.stdpath("data") .. "/site"
local ok_setup, setup_err = pcall(function()
    require("nvim-treesitter").setup({
        install_dir = install_dir,
    })
end)

if not ok_setup then
    vim.api.nvim_echo(
        { { "Error: " .. tostring(setup_err), "ErrorMsg" } },
        true,
        {}
    )
    vim.cmd("cq")
end

local ok_install, install_err = pcall(function()
    require("nvim-treesitter").install({ "lua", "typescript" }):wait(300000)
end)

if not ok_install then
    vim.api.nvim_echo({
        { "Error: " .. tostring(install_err), "ErrorMsg" },
    }, true, {})
    vim.cmd("cq")
end

local required_parsers = {
    lua = "lua.so",
    typescript = "typescript.so",
}

for lang, filename in pairs(required_parsers) do
    local parser_path = install_dir .. "/parser/" .. filename
    if not vim.uv.fs_stat(parser_path) then
        vim.api.nvim_echo({
            {
                "Error: "
                    .. lang
                    .. " parser missing after install: "
                    .. parser_path,
                "ErrorMsg",
            },
        }, true, {})
        vim.cmd("cq")
    end
end
