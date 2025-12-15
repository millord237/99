local editor = require("99.editor")

local M = {}

--- Gets the containing function at the given cursor position
--- @param cursor _99.Point
--- @return _99.treesitter.Function?
function M.get_containing_function(cursor)
    local buffer = vim.api.nvim_get_current_buf()
    return editor.treesitter.containing_function(buffer, cursor)
end

return M
