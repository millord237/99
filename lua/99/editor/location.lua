local Range = require("99.geo").Range

--- @class _99.Location
--- @field full_path string
--- @field range Range
--- @field node TSNode
--- @field buffer number
--- @field file_type string
--- @field marks table<string, string>
--- @field ns_id string
local Location = {}
Location.__index = Location

--- @param node TSNode
--- @param range Range
function Location.from_ts_node(node, range)
    local full_path = vim.api.nvim_buf_get_name(range.buffer)
    local file_type = vim.bo[range.buffer].ft
    local ns_string = tostring(range.buffer) .. range:to_string()
    local ns_id = vim.api.nvim_create_namespace(ns_string)

    return setmetatable({
        buffer = range.buffer,
        full_path = full_path,
        range = range,
        node = node,
        file_type = file_type,
        marks = {},
        ns_id = ns_id,
    }, Location)
end

return Location
