local Context = require("99.ops.context")
local Logger = require("99.logger.logger")
local Request = require("99.request")
local editor = require("99.editor")
local Location = require("99.editor.location")
local geo = require("99.geo")
local Range = geo.Range
local Point = geo.Point
local Mark = require("99.ops.marks")
local RequestStatus = require("99.ops.request_status")

local function update_code(request, ok, res)
    if not ok then
        error("unable to implement function.  check logger for more details")
    end
    Logger:fatal("not implemented yet")
end

--- @param _99 _99.State
local function implement_fn(_99)
    local ts = editor.treesitter
    local cursor = Point:from_cursor()
    local buffer = vim.api.nvim_get_current_buf()
    local fn_call = ts.fn_call(buffer, cursor)

    if not fn_call then
        Logger:fatal(
            "cannot implement function, cursor was not on an identifier that is a function call"
        )
        return
    end

    local range = Range:from_ts_node(fn_call, buffer)
    local context = Context.new(_99)
    local location = Location.from_ts_node(fn_call, range)
    local request = Request.new({
        on_complete = update_code,
        model = _99.model,
        context = context,
    })

    location.marks.end_of_fn_call = Mark.mark_end_of_range(buffer, range)
    local func = ts.containing_function(buffer, cursor)
    if func then
        location.marks.code_placement = Mark.mark_above_func(buffer, func)
    else
        location.marks.code_placement = Mark.mark_above_range(buffer, range)
    end

    local code_placement = RequestStatus.new(
        250,
        _99.ai_stdout_rows,
        "Loading",
        location.marks.code_placement
    )
    local at_call_site = RequestStatus.new(
        250,
        1,
        "Implementing Function",
        location.marks.end_of_fn_call
    )

    code_placement:start()
    at_call_site:start()

    request:add_prompt_content(_99.prompts.prompts.implement_function)
    request:start({
        on_stdout = function(line)
            request_status:push(line)
        end,
        on_complete = function(ok, response)
            request_status:stop()
            if not ok then
                Logger:fatal(
                    "unable to fill in function, enable and check logger for more details"
                )
            end
            update_file_with_changes(response, location)
        end,
        on_stderr = function(line) end,
    })

    return request
end

return implement_fn
