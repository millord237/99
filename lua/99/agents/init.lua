local helpers = require("99.agents.helpers")
local M = {}

--- @class _99.Agents.Rule
--- @field name string
--- @field path string

--- @class _99.Agents.Rules
--- @field cursor _99.Agents.Rule[]
--- @field custom _99.Agents.Rule[]

--- @class _99.Agents.Agent
--- @field rules _99.Agents.Rules

---@param _99 _99.State
---@return _99.Agents.Rules
function M.rules(_99)
  local cursor = helpers.ls(".cursor/rules")
  local custom = {}
  for _, path in ipairs(_99.custom_rules) do
    local c = helpers.ls(path)
    table.insert(custom, c)
  end
  return {
    cursor = cursor,
    custom = custom,
  }
end

return M
