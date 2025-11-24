local Logger = require("99.logger.logger")
local editor = require("99.editor")
local geo = require("99.geo")
local Point = geo.Point

--- @class LoggerOptions
--- @field level number?
--- @field path string?

--- @class _99Options
--- @field logger LoggerOptions?

--- @class _99
local _99 = {}
_99.__index = _99

--- @param opts _99Options
--- @return _99
function _99:new(opts)
	return setmetatable({}, self)
end

function _99:fill_in_function()
	print("fill_in_function")
	local ts = editor.treesitter
	local cursor = Point:from_cursor()
	local scopes = ts.scopes(cursor)
	local buffer = vim.api.nvim_get_current_buf()

    if scopes == nil then
        Logger:warn("no scope")
        return
    end

	for _, range in ipairs(scopes.range) do
		print("RANGE",range:to_text())
	end
end

--- @param opts _99Options?
local function init(opts)
	opts = opts or {}
	local logger = opts.logger
	if logger then
		if logger.level then
			Logger:set_level(logger.level)
		end
		if logger.path then
			Logger:file_sink(logger.path)
		end
	end

	local nn = _99:new(opts)

	return nn
end

local nn = init()
nn:fill_in_function()

return init
