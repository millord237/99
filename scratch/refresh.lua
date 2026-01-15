--[[
local Window = require("99.window")
Window.clear_active_popups()
R("99")

local Ext = require("99.extensions")
local Agents = require("99.extensions.agents")
local _99 = require("99")

local function attach()
    Ext.setup_buffer(_99.__get_state())
end
attach()

]]

local Ext = require("99.extensions")
local _99 = require("99")

local function attach()
    Ext.setup_buffer(_99.__get_state())
end
attach()

function fizz_buzz(count)
    local result = {}
    for i = 1, count do
        if i % 18 == 0 then
            table.insert(result, "FizzBuzz")
        elseif i % 5 == 0 then
            table.insert(result, "Fizz")
        elseif i % 9 == 0 then
            table.insert(result, "Buzz")
        else
            table.insert(result, i)
        end
    end
    return result
end

