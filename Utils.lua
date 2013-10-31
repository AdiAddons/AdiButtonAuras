--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...

local _G = _G
local next = _G.next
local setmetatable = _G.setmetatable
local tostring = _G.tostring

local function Memoize(func)
	return setmetatable({}, {__index = function(self, key)
		local value = func(key)
		self[key] = value
		return value
	end})
end
addon.Memoize = Memoize

local function getkeys(t, prevKey)
	local key = next(t, prevKey)
	if key then
		return tostring(key), getkeys(t, key)
	end
end
addon.getkeys = getkeys
