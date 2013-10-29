--[[
LuaAuras - Enhance action buttons using Lua handlers.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...

function addon.Memoize(func)
	return setmetatable({}, {__index = function(self, key)
		local value = func(key)
		self[key] = value
		return value
	end})
end
