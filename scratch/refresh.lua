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
