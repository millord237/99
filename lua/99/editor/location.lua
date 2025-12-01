local Point = require("99.geo")

--- @class _99.Location
--- @field full_path string
--- @field range Range
--- @field buffer number
--- @field marks table<string, string>
--- @field cursor Point
local Location = {}
Location.__index = Location

function Location.from_range(range)
    local full_path = vim.api.nvim_buf_get_name(range.buffer)
	local cursor = Point:from_cursor()

    return setmetatable({
        cursor = cursor,
        buffer = range.buffer,
        full_path = full_path,
        range = range,
        marks = {}
    }, Location)
end

return Location
