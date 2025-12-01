local Point = require("99.geo").Point
local Logger = require("99.logger.logger")
local Request = require("99.request")
local system_rules = require("99.request.system-rules")
local marks = require("99.ops.marks")
local editor = require("99.editor")
local ops = require("99.ops")

--- @param request _99.Request
--- @param ok boolean
--- @param res string
local function update_file_with_changes(request, ok, res)
    if not ok then
        error("unable to fill in function, enable and check logger for more details")
    end
	local mark_pos = vim.api.nvim_buf_get_mark(request.buffer, request.mark)
	local mark_point = Point:new(mark_pos[1], mark_pos[2] + 1)

	local ts = editor.treesitter
	local scopes = ts.function_scopes(mark_point, request.buffer)
    print("update_file_with_changes buffer", request.buffer)

	if not scopes or not scopes:has_scope() then
		Logger:error("update_file_with_changes: unable to find function at mark location")
        error("update_file_with_changes: funable to find function at mark location")
		return
	end

	local range = scopes.range[#scopes.range]

	local function_start_row, _ = range.start:to_vim()
	local function_end_row, _ = range.end_:to_vim()

	local lines = vim.split(res, "\n")
	vim.api.nvim_buf_set_lines(request.buffer, function_start_row, function_end_row + 1, false, lines)
end


--- @param _99 _99.State
--- @return _99.Request
local function fill_in_function(_99)
	local ts = editor.treesitter
	local cursor = Point:from_cursor()
	local scopes = ts.function_scopes(cursor)
	local buffer = vim.api.nvim_get_current_buf()

    local location = editor.Location.from_range(range)
	local request = Request.new({
		model = _99.model,
        on_complete = update_file_with_changes,
	})

	if not request:has_scopes() then
		Logger:warn("fill_in_function: unable to find any containing function")
		error("you cannot call fill_in_function not in a function")
	end

    local range = request:get_inner_scope()

    request:set_system_prompt(system_rules(request))
    request.mark = marks(request.buffer, range)

    return request
end

return fill_in_function
