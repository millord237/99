local Window = require("99.window")
Window.clear_active_popups()
R("99")

local function test()
  Window = require("99.window")
  Window.capture_input(function(input)
    print(input)
  end, {})
end
test()
