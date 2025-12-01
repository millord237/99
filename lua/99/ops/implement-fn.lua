local Logger = require("99.logger.logger")
local Request = require("99.request")
local editor = require("99.editor")
local Range = require("99.geo").Range

local function update_code(request, ok, res)
	if not ok then
		error("unable to implement function.  check logger for more details")
	end
    Logger:fatal("not implemented yet")
end

--- @param _99 _99.State
--- @return _99.Request?
local function implement_fn(_99)
	local request = Request.new({
		model = _99.model,
		md_files = _99.md_files,
		on_complete = update_code,
	})
	local ts = editor.treesitter
	local ident = ts.identifier(request.buffer, request.cursor)

    print_ident(ident)

    if not ident then
        Logger:error("implement_fn was called but cursor was not on a function call", "cursor", request.cursor)
        return nil
    end

	Range:from_ts_node(ident, request.buffer)

	return request
end

return implement_fn
