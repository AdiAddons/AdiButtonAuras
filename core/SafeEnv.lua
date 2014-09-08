--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2014 Adirelle (adirelle@gmail.com)
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
local error = _G.error
local format = _G.format
local getmetatable = _G.getmetatable
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local type = _G.type

-- Check if a value does not contain a function
local isSafe
do
	local visited = setmetatable({}, { __mode = 'k' })
	function isSafe(value)
		if visited[value] ~= nil then
			return visited[value]
		end
		if type(value) == "function" then
			visited[value] = false
			return false
		end
		if type(value) == "table" then
			visited[value] = true
			if not isSafe(getmetatable(value)) then
				visited[value] = false
				return false
			end
			for k, v in pairs(value) do
				if not isSafe(k) or not isSafe(v) then
					visited[value] = false
					return false
				end
			end
		end
		return true
	end
end

-- Build a read-only environnement, allowing accessing to a restricted sets of libraries and globals
function addon.BuildSafeEnv(baseEnv, allowedLibraries, allowedGlobals)

	allowedLibraries = addon.AsSet(allowedLibraries, "string", 0)

	baseEnv.GetLib = function(major)
		if not allowedLibraries[major] then
			error(format("Library '%s' is not allowed", major), 2)
		end
		return addon.GetLib(major)
	end

	baseEnv.SafeGetGlobal = function(name)
		local value = _G[name]
		return isSafe(value) and value or nil
	end

	for i, name in pairs(allowedGlobals) do
		baseEnv[name] = _G[name]
	end

	-- Automatically import constants, send custom error messages otherwise
	setmetatable(baseEnv, {
		__index = function(t, name)
			local value = _G[name]
			if value == nil then
				error(format("Unknown symbol '%s'.", name), 2)
			elseif not isSafe(value, {}) then
				error(format("Using '%s' is forbidden.", name), 2)
			end
			t[name] = value
			return value
		end
	})

	return setmetatable({}, {
		__metatable = false,
		__index = baseEnv,
		__newindex = function(_, name)
			error(format("Setting '%s' is forbidden; use local variables.", name), 2)
		end,
	})
end
