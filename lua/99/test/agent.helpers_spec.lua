-- luacheck: globals describe it assert
local helpers = require("99.agents.helpers")
local eq = assert.are.same

--- @param selected _99.Agents.FuzzyState.Selected[]
--- @return string[]
local function n(selected)
  return vim.tbl_map(function(item) return item.name end, selected)
end

local possible = {
  "react-hooks",
  "react-state",
  "redux",
  "recoil",
  "rust-analyzer",
}

describe("99.agents.helpers", function()
  it("fuzzy matching", function()
    local state = helpers.create_state(possible, false)
    eq(5, #state.selected)

    state = helpers.fuzzy_match("rea", state)
    eq({ "react-hooks", "react-state", }, n(state.selected))

    state = helpers.fuzzy_match("rh", state)
    eq({ "react-hooks" }, n(state.selected))

    state = helpers.fuzzy_match("rst", state)
    eq({ "react-state", "rust-analyzer" }, n(state.selected))

    state = helpers.fuzzy_match("xyz", state)
    eq({}, state.selected)
  end)

  it("fuzzy matching iterative", function()
    local state = helpers.create_state(possible, false)

    state = helpers.fuzzy_match("r", state)
    eq(possible, n(state.selected))

    state = helpers.fuzzy_match("re", state)
    eq(possible, n(state.selected))

    state = helpers.fuzzy_match("rea", state)
    eq({ "react-hooks", "react-state", }, n(state.selected))

    state = helpers.fuzzy_match("re", state)
    eq(possible, n(state.selected))
  end)
end)
