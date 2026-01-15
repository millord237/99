local M = {}

--- @param dir string
--- @return _99.Agents.Rule[]
function M.ls(dir)
  local cursor_rules_dir = vim.uv.cwd() .. dir
  local files = vim.fn.glob(cursor_rules_dir .. "/*.{mdc,md}", false, true)
  local rules = {}

  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t:r")
    table.insert(rules, {
      name = filename,
      path = file,
    })
  end

  return rules
end

--- @class _99.Agents.FuzzyState.Selected
--- @field name string
--- @field index number

--- @class _99.Agents.FuzzyState
--- @field selected _99.Agents.FuzzyState.Selected[]
--- @field input string
--- @field possible string[]
--- @field case_sensitive boolean

--- @param input string
---@param state _99.Agents.FuzzyState
---@return _99.Agents.FuzzyState
local function play_input(input, state)
  local current_input = ""
  state = M.create_state(state.possible, state.case_sensitive)
  for i = 1, #input do
    current_input = current_input .. input:sub(i, i)
    state = M.fuzzy_match(current_input, state)
  end
  return state
end

local function clone(state)
  return {
    input = state.input,
    selected = state.selected,
    possible = state.possible,
    case_sensitive = state.case_sensitive,
  }
end

--- @param possible string[]
--- @param case_sensitive boolean | nil
--- @return _99.Agents.FuzzyState
function M.create_state(possible, case_sensitive)
  --- @type _99.Agents.FuzzyState
  local state = {
    input = "",
    selected = {},
    possible = possible,
    case_sensitive = case_sensitive or false,
  }
  for _, p in ipairs(state.possible) do
    table.insert(state.selected, {
      name = p,
      index = 1,
    })
  end
  return state
end

--- @param input string
---@param state _99.Agents.FuzzyState
function M.fuzzy_match(input, state)
  if state.input == input then
    return state
  end

  state = clone(state)
  if
    input:sub(1, #state.input) ~= state.input
    or #state.input + 2 <= #input
  then
    return play_input(input, state)
  end

  -- search through each selected item
  local last_char = input:sub(#input, #input)
  if not state.case_sensitive then
    last_char = last_char:lower()
  end

  local new_selected = {}
  for _, selected in ipairs(state.selected) do
    local name = selected.name
    if not state.case_sensitive then
      name = name:lower()
    end

    -- check if the character at the current index matches the last input character
    -- find the next occurrence of last_char starting from selected.index
    local next_index = name:find(last_char, selected.index, true)
    if next_index then
      table.insert(new_selected, {
        name = selected.name,
        index = next_index + 1,
      })
    end
  end

  state.selected = new_selected
  state.input = input

  return state
end

return M
