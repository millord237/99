R("99")
local _99 = require("99")
_99.setup({
  completion = {
    custom_rules = {
      "~/.behaviors/",
    },
    source = "cmp",
  },
})
local Ext = require("99.extensions")
local Agents = require("99.extensions.agents")
local Helpers = require("99.extensions.agents.helpers")

print(vim.inspect(Agents.rules(_99.__get_state())))
print(vim.inspect(Helpers.ls("/home/theprimeagen/.behaviors")))

function fizz_buzz(count)
  for i = 1, count do
    if i % 15 == 0 then
      print("FizzBuzz")
    elseif i % 3 == 0 then
      print("Fizz")
    elseif i % 5 == 0 then
      print("Buzz")
    else
      print(i)
    end
  end
end
