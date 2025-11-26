local Logger = require("99.logger.logger")
local Request = require("99.request")
local system_rules = require("99.request.system-rules")
local marks = require("99.ops.marks")

--- @param _99 _99.State
--- @return _99.Request
local function fill_in_function(_99)
	local request = Request.new({
		model = _99.model,
		md_files = _99.md_files,
	})

	if !request:has_scopes() then
		Logger:warn("fill_in_function: unable to find any containing function")
		error("you cannot call fill_in_function not in a function")
	end

    local range = request:get_inner_scope()

    request:set_system_prompt(system_rules(request))
    request.mark = marks(request.buffer, range)

    return request
end

return fill_in_function
