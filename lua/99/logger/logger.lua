local levels = require("99.logger.level")

--- @class _99.Logger.Options
--- @field level number?
--- @field path string?
--- @field print_on_error? boolean
--- @field max_logs_cached? number
--- @field max_errors_cached? number
--- @field error_cache_level? number

--- @class _99.Logger.LoggerConfig
--- @field type? "file" | "print"
--- @field path? string
--- @field level? number
--- @field max_logs_cached? number
--- @field max_errors_cached? number
--- @field error_cache_level? number i dont know how to do enum values :)

local function to_args(...)
    local count = select("#", ...)
    local out = {}
    assert(
        count % 2 == 0,
        "you cannot call logging with an odd number of args. e.g: msg, [k, v]..."
    )
    for i = 1, count, 2 do
        local key = select(i, ...)
        local value = select(i + 1, ...)
        assert(type(key) == "string", "keys in logging must be strings")
        assert(out[key] == nil, "key collision in logs: " .. key)
        out[key] = value
    end
    return out
end

--- @param log_statement table<string, any>
--- @param args table<string, any>
local function put_args(log_statement, args)
    for k, v in pairs(args) do
        assert(log_statement[k] == nil, "key collision in logs: " .. k)
        log_statement[k] = v
    end
end

--- @class LoggerSink
--- @field write_line fun(LoggerSink, string): nil

--- @class VoidLogger : LoggerSink
local VoidSink = {}
VoidSink.__index = VoidSink

function VoidSink.new()
    return setmetatable({}, VoidSink)
end

--- @param _ string
function VoidSink:write_line(_) end

--- @class FileSink : LoggerSink
--- @field fd number
local FileSink = {}
FileSink.__index = FileSink

--- @param path string
--- @return LoggerSink
function FileSink:new(path)
    local fd, err = vim.uv.fs_open(path, "w", 493)
    if not fd then
        error("unable to file sink", err)
    end

    return setmetatable({
        fd = fd,
    }, self)
end

--- @param str string
function FileSink:write_line(str)
    local success, err = vim.uv.fs_write(self.fd, str .. "\n")
    if not success then
        error("unable to write to file sink", err)
    end
    vim.uv.fs_fsync(self.fd)
end

--- @class PrintSink : LoggerSink
local PrintSink = {}
PrintSink.__index = PrintSink

--- @return LoggerSink
function PrintSink:new()
    return setmetatable({}, self)
end

--- @param str string
function PrintSink:write_line(str)
    local _ = self
    print(str)
end

--- @class _99.Logger
--- @field level number
--- @field sink LoggerSink
--- @field print_on_error boolean
--- @field log_cache string[]
--- @field max_logs_cached number
--- @field max_errors_cached number
--- @field error_cache string[]
--- @field error_cache_level number
--- @field extra_params table<string, any>
local Logger = {}
Logger.__index = Logger

--- @param level number?
function Logger:new(level)
    level = level or levels.FATAL
    return setmetatable({
        sink = VoidSink:new(),
        level = level,
        print_on_error = false,
        extra_params = {},
        log_cache = {},
        error_cache = {},
        error_cache_level = levels.FATAL,
        max_errors_cached = 5,
        max_logs_cached = 100,
    }, self)
end

function Logger:clone()
    local params = {}
    for k, v in pairs(self.extra_params) do
        params[k] = v
    end
    return setmetatable({
        sink = self.sink,
        level = self.level,
        print_on_error = self.print_on_error,
        extra_params = params,
        log_cache = {},
        error_cache = {},
        error_cache_level = self.error_cache_level,
        max_errors_cached = self.max_errors_cached,
        max_logs_cached = self.max_logs_cached,
    }, Logger)
end

--- @param path string
--- @return _99.Logger
function Logger:file_sink(path)
    self.sink = FileSink:new(path)
    return self
end

--- @return _99.Logger
function Logger:void_sink()
    self.sink = VoidSink:new()
    return self
end


--- @return _99.Logger
function Logger:print_sink()
    self.sink = PrintSink:new()
    return self
end

--- @param area string
--- @return _99.Logger
function Logger:set_area(area)
    local new_logger = self:clone()
    new_logger.extra_params["Area"] = area
    return new_logger
end

--- @param xid number
--- @return _99.Logger
function Logger:set_id(xid)
    local new_logger = self:clone()
    new_logger.extra_params["id"] = xid
    return new_logger
end

--- @param level number
--- @return _99.Logger
function Logger:set_level(level)
    self.level = level
    return self
end

--- @return _99.Logger
function Logger:on_error_print_message()
    self.print_on_error = true
    return self
end

--- @param opts _99.Logger.Options?
function Logger:configure(opts)
    if not opts then
        return
    end

    if opts.level then
        self:set_level(opts.level)
    end

    if opts.path == "print" then
        self:print_sink()
    elseif opts.path then
        self:file_sink(opts.path)
    else
        self:void_sink()
    end

    if opts.print_on_error then
        self:on_error_print_message()
    end

    self.max_logs_cached = opts.max_logs_cached or 100
    self.max_errors_cached = opts.max_errors_cached or 5
    self.error_cache_level = opts.error_cache_level or levels.FATAL
end

--- @param level number
--- @param line string
function Logger:_cache_log(level, line)
    if not self.log_cache then
        self.log_cache = {}
    end

    table.insert(self.log_cache, line)
    if level >= self.error_cache_level then
        table.insert(self.error_cache, line)
    end

    if #self.log_cache > self.max_logs_cached then
        table.remove(self.log_cache, 1)
    end
    if #self.error_cache > self.max_errors_cached then
        table.remove(self.error_cache, 1)
    end
end

function Logger:_log(level, msg, ...)
    if self.level > level then
        return
    end

    local log_statement = {
        level = levels.levelToString(level),
        msg = msg,
    }

    put_args(log_statement, to_args(...))
    put_args(log_statement, self.extra_params)
    local json_string = vim.json.encode(log_statement)
    if self.print_on_error and level == levels.ERROR then
        print(json_string)
    end

    self:_cache_log(level, json_string)
    self.sink:write_line(json_string)
end

--- @param msg string
--- @param ... any
function Logger:info(msg, ...)
    self:_log(levels.INFO, msg, ...)
end

--- @param msg string
--- @param ... any
function Logger:warn(msg, ...)
    self:_log(levels.WARN, msg, ...)
end

--- @param msg string
--- @param ... any
function Logger:debug(msg, ...)
    self:_log(levels.DEBUG, msg, ...)
end

--- @param msg string
--- @param ... any
function Logger:error(msg, ...)
    self:_log(levels.ERROR, msg, ...)
end

--- @param msg string
--- @param ... any
function Logger:fatal(msg, ...)
    self:_log(levels.FATAL, msg, ...)
    assert(false, "fatal msg recieved: " .. msg)
end

local module_logger = Logger:new(levels.DEBUG)

return module_logger
