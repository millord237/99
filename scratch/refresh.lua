R("99")
local _99 = require("99")
local Window = require("99.window")
_99.setup({
  completion = {
    custom_rules = {
      "~/.behaviors/",
      "~/personal/skills/skills",
    },
    source = "cmp",
  },
})

Window.capture_input({
  cb = function(success, result)
    print("results")
  end,
  rules = _99.__get_state().rules,
})
