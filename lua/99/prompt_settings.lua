--- @class _99.Prompts.SpecificOperations
local prompts = {
	fill_in_function = "fill in the function.  dont change the function signature. do not edit anything outside of this function.  prioritize using internal functions for work that has already been done.  any NOTE's left in the function should be removed but instructions followed",
	implement_function = "implement the function that the cursor is on.  make sure you inspect the current file carefully and any imports that look related.  being thorough is better than being fast.  being correct is better than being speedy.",
}

--- @class _99.Prompts
local prompt_settings = {
	prompts = prompts,

	--- @param output_file string
	--- @param tmp_file string
	--- @return string
	tmp_file_location = function(output_file, tmp_file)
		return string.format("<MustObey>\n%s\n%s\n</MustObey><TEMP_FILE>%s</TEMP_FILE>", output_file, tmp_file)
	end,

	---@param location _99.Location
	---@return string
	get_file_location = function(location)
		return string.format(
			"<Location><File>%s</File><Function>%s</Function></Location>",
			location.full_path,
			location.range:to_string()
		)
	end,

	--- @param range Range
	get_range_text = function(range)
		return string.format("<FunctionText>%s</FunctionText>", range:to_text())
	end,
}

return prompt_settings
