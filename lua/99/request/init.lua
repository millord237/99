local Logger = require("99.logger.logger")

--- no, i am not going to use a uuid, in case of collision, call the police
--- @return string
local function get_id()
	return tostring(math.floor(math.random() * 100000000))
end

--- @param opts _99.Request.Opts
local function validate_opts(opts)
    assert(opts.model, "you must provide a model for hange requests to work")
    assert(type(opts.on_complete) == "function", "on_complete must be provided")
    assert(opts.context, "you must provide context")
end

--- @alias _99.Request.State "ready" | "calling-model" | "parsing-result" | "updating-file"

--- @class _99.Request.Opts
--- @field model string
--- @field on_complete fun(req: _99.Request, success: boolean, res: string): nil
--- @field context _99.Context

--- @class _99.Request
--- @field config _99.Request.Opts
--- @field id string
--- @field state _99.Request.State
--- @field _content string[]
local Request = {}
Request.__index = Request

--- @param opts _99.Request.Opts
function Request.new(opts)
    validate_opts(opts)
    return setmetatable({
        config = opts,
        id = get_id(),
        state = "ready",
        _content = {},
    }, Request)
end

function Request:_retrieve_response()
    local tmp = self.config.context.tmp_file
	local success, result = pcall(function()
		return vim.fn.readfile(tmp)
	end)

	if not success then
		Logger:error("retrieve_results: failed to read file", "tmp_name", tmp, "error", result)
		return false, ""
	end

	return true, table.concat(result, "\n")
end

--- @param content string
--- @return self
function Request:add_prompt_content(content)
    table.insert(self._content, content)
    return self
end

function Request:start()
    local query = table.concat(self._content, "\n")
	Logger:debug("99#make_query", "id", self.id, "query", query)
	vim.system({ "opencode", "run", "-m", "anthropic/claude-sonnet-4-5", query }, {
		text = true,
		stdout = vim.schedule_wrap(function(err, data)
			Logger:debug("STDOUT#data", "id", self.id, "data", data)
            if err and err ~= "" then
                Logger:debug("STDOUT#error", "id", self.id, "err", err)
            end
		end),
		stderr = vim.schedule_wrap(function(err, data)
			Logger:debug("STDERR#data", "id", self.id, "data", data)
            if err and err ~= "" then
                Logger:debug("STDERR#error", "id", self.id, "err", err)
            end
		end),
	}, function(obj)
		if obj.code ~= 0 then
			Logger:fatal("opencode make_query failed", "request", self, "obj from results", obj)
			return
		end
		vim.schedule(function()
			local ok, res = self:_retrieve_response()
            self.config.on_complete(self, ok, res)
		end)
	end)
end

return Request
