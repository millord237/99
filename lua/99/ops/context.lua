--- TODO: some people change their current working directory as they open new
--- directories.  if this is still the case in neovim land, then we will need
--- to make the _99_state have the project directory.
--- @return string
local function random_file()
	return string.format("%s/tmp/99-%d", vim.uv.cwd(), math.floor(math.random() * 10000))
end

--- @class _99.Context
--- @field md_file_names string[]
--- @field ai_context string[]
--- @field tmp_file string
local Context = {}
Context.__index = Context

function Context.new()
	return setmetatable({
		md_file_names = {},
		ai_context = {},
		tmp_file = random_file(),
	}, Context)
end

--- @param md_file_name string
--- @return self
function Context:add_md_file_name(md_file_name)
	table.insert(self.md_file_names, md_file_name)
	return self
end

--- @param location _99.Location
function Context:finalize(location)
	--- @ai use location's buffer's full path and walk back until we are at cwd
	--- @ai and read each of the md_file_names.  if it exists then add it to
	--- @ai ai_context.
end

--- @param request _99.Request
function Context:add_to_request(request)
	for _, context in ipairs(self.ai_context) do
		request:add_prompt_content(context)
	end
end

return Context
