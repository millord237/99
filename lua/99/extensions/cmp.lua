--- @class CmpSource
--- @field _99 _99.State
--- @field items string[]
local CmpSource = {}
CmpSource.__index = CmpSource

local SOURCE = "99"

--- @param _99 _99.State
function CmpSource.new(_99)
  return setmetatable({}, CmpSource)
end

function CmpSource:is_available()
  return true
end

function CmpSource:get_debug_name()
  return SOURCE
end

function CmpSource:get_keyword_pattern()
  return [[@\k\+]]
end

function CmpSource:get_trigger_characters()
  return { "@" }
end

--- @class CompletionItem
--- @field label string
--- @field kind number kind is optional but gives icons / categories
--- @field documentation string can be a string or markdown table
--- @field detail string detail shows a right-side hint

--- @class Completion
--- @field items CompletionItem[]
--- @field isIncomplete boolean -
-- true: I might return more if user types more
-- false: this result set is complete
function CmpSource:complete(params, callback)
  local cmp = require("cmp")
  local before = params.context.cursor_before_line or ""
  local prefix = before:match("(%w+)$") or ""

  local items = {} --[[ @as CompletionItem[] ]]

  print("complete: context", vim.inspect(params.context))

  callback({
    items = items,
    isIncomplete = true,
  })
end

-- resolve(completion_item, callback) (optional)
-- Some sources return lightweight items first, then fill in heavy fields
-- only when the user selects an item.
--
-- For example:
--  - fetch docs lazily
--  - compute expensive detail text
--
-- If you don’t need it, omit it.
function CmpSource:resolve(completion_item, callback)
  -- You can modify completion_item here.
  callback(completion_item)
end

-- execute(completion_item, callback) (optional)
-- Called when the item is confirmed, if the item contains an "command" field
-- or if your source wants to perform side-effects.
--
-- Examples:
--  - insert import statements (usually via additionalTextEdits instead)
--  - open a snippet, run something, etc.
function CmpSource:execute(completion_item, callback)
  callback(completion_item)
end

--- @type CmpSource | nil
local source = nil

--- @param _99 _99.State
local function init_for_buffer(_99)
  local cmp = require("cmp")
  cmp.setup.buffer({
    sources = {
      { name = "my_source" },
    },
  })
end

--- @param _99 _99.State
local function init(_99)
  assert(source == nil, "the source must be nil when calling init on an completer")

  local cmp = require("cmp")
  source = CmpSource.new(_99)
  cmp.register_source(SOURCE, source)
end

local function refresh_state(_99) end

return {
  init_for_buffer = init_for_buffer,
  init = init,
  refresh_state = refresh_state,
}
