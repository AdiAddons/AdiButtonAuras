--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.

This file is part of AdiButtonAuras.

AdiButtonAuras is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

AdiButtonAuras is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AdiButtonAuras.  If not, see <http://www.gnu.org/licenses/>.
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
