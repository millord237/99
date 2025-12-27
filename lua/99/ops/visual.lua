local Logger = require("99.logger.logger")
local Request = require("99.request")
local RequestStatus = require("99.ops.request_status")
local Mark = require("99.ops.marks")
local Range = require("99.geo").Range

--- @param context _99.RequestContext
--- @param range _99.Range
local function visual(context, range)
    local request = Request.new(context)
    local top_mark, bottom_mark = Mark.mark_range(range)
    context.marks.top_mark = top_mark
    context.marks.bottom_mark = bottom_mark

    local display_ai_status = context._99.ai_stdout_rows > 1
    local top_status = RequestStatus.new(250, context._99.ai_stdout_rows or 1, "Implementing...")
    local bottom_status = RequestStatus.new(250, 1, "Implementing...")

    local clean_up_id = -1
    local function clean_up()
        top_status:stop()
        bottom_status:stop()
        context:clear_marks()
        context._99:remove_active_request(clean_up_id)
    end
    clean_up_id = context._99:add_active_request(function()
        clean_up()
        request:cancel()
    end)

    request:add_prompt_content(context._99.prompts.prompts.visual_selection)

    top_status:start()
    bottom_status:start()
    request:start({
        on_complete = function(status, response)
            if status == "cancelled" then
                Logger:debug("request cancelled for visual selection, removing marks")
            elseif status == "failed" then
                Logger:error("request failed for visual_selection", "error response", response or "no response provided")
            elseif status == "success" then
                local valid = top_mark:is_valid() and bottom_mark:is_valid()
                if not valid then
                    Logger:fatal("the original visual_selection has been destroyed.  You cannot delete the original visual selection during a request")
                end
                local new_range = Range.from_marks(top_mark, bottom_mark)
                local lines = vim.split(response, "\n")
                new_range:replace_text(lines)
            end
            clean_up()
        end,
        on_stdout = function(line)
            if display_ai_status then
                top_status:push(line)
            end
        end,
        on_stderr = function(line)
            Logger:debug("visual_selection#on_stderr received", "line", line)
        end
    })
end

return visual
