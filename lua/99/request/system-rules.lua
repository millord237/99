local _99_settings = {
	output_file = "you must NEVER alter the file given.  You must provide the desired change to TEMP_FILE. Do NOT inspec the TEMP_FILE.  It is for you to write into, never read.  TEMP_FILE previous contents do not matter.",
	fill_in_function = "fill in the function.  dont change the function signature. do not edit anything outside of this function.  prioritize using internal functions for work that has already been done.  any NOTE's left in the function should be removed but instructions followed",
}

--- @param tmp_file string
--- @return string
local function system_rules(tmp_file)
	return string.format(
		"<MustObey>\n%s\n%s\n</MustObey><TEMP_FILE>%s</TEMP_FILE>",
		_99_settings.output_file,
		_99_settings.fill_in_function,
		tmp_file
	)
end

--- @param buffer number
---@param range Range
---@return string
local function get_file_location(buffer, range)
	local full_path = vim.fn.expand("%:p")
	return string.format("<Location><File>%s</File><Function>%s</Function></Location>", full_path, range:to_string())
end

--- @param range Range
local function get_range_text(range)
	return string.format("<FunctionText>%s</FunctionText>", range:to_text())
end

--- @param request _99.Request
--- @return string
return function(request)
    local range = request:get_inner_scope()
    local buffer = request.buffer
    return table.concat({
        system_rules(request.tmp_name),
        get_file_location(buffer, range),
        get_range_text(range),
    })
end
