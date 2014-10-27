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
local ipairs = _G.ipairs
local max = _G.max
local min = _G.min
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local setmetatable = _G.setmetatable
local strjoin = _G.strjoin
local tinsert = _G.tinsert
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack
local math = _G.math

------------------------------------------------------------------------------
-- Create a memoization table
------------------------------------------------------------------------------

local function Memoize(func)
	return setmetatable({}, {__index = function(self, key)
		if key == nil then return nil end
		local value = func(key)
		self[key] = value
		return value
	end})
end
addon.Memoize = Memoize

------------------------------------------------------------------------------
-- simple table functions
------------------------------------------------------------------------------

local function getkeys(t, prevKey)
	local key = next(t, prevKey)
	if key then
		return tostring(key), getkeys(t, key)
	end
end
addon.getkeys = getkeys

------------------------------------------------------------------------------
-- String functions
------------------------------------------------------------------------------

local function ucfirst(s)
	return s:sub(0,1):upper()..s:sub(2)
end
addon.ucfirst = ucfirst

local BuildKey
do
	local function BuildKey0(value, ...)
		if type(value) == "table" then
			return BuildKey(unpack(value)), BuildKey0(...)
		elseif value then
			return tostring(value), BuildKey0(...)
		end
	end

	function BuildKey(...)
		return strjoin(':', BuildKey0(...))
	end
end
addon.BuildKey = BuildKey

------------------------------------------------------------------------------
-- Color manipulation functions
------------------------------------------------------------------------------

-- Code to calculate HCY color gradients
local function GetY(r, g, b)
	return 0.3 * r + 0.59 * g + 0.11 * b
end

local function RGBToHCY(r, g, b)
	local min, max = min(r, g, b), max(r, g, b)
	local chroma = max - min
	local hue
	if chroma > 0 then
		if r == max then
			hue = ((g - b) / chroma) % 6
		elseif g == max then
			hue = (b - r) / chroma + 2
		elseif b == max then
			hue = (r - g) / chroma + 4
		end
		hue = hue / 6
	end
	return hue, chroma, GetY(r, g, b)
end

local abs = math.abs
local function HCYtoRGB(hue, chroma, luma)
	local r, g, b = 0, 0, 0
	if hue then
		local h2 = hue * 6
		local x = chroma * (1 - abs(h2 % 2 - 1))
		if h2 < 1 then
			r, g, b = chroma, x, 0
		elseif h2 < 2 then
			r, g, b = x, chroma, 0
		elseif h2 < 3 then
			r, g, b = 0, chroma, x
		elseif h2 < 4 then
			r, g, b = 0, x, chroma
		elseif h2 < 5 then
			r, g, b = x, 0, chroma
		else
			r, g, b = chroma, 0, x
		end
	end
	local m = luma - GetY(r, g, b)
	return r + m, g + m, b + m
end

local function ColorsAndPercent(a, b, ...)
	if a <= 0 or b == 0 then
		return nil, ...
	elseif a >= b then
		return nil, select(select('#', ...) - 2, ...)
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf((a/b)*(num-1))
	return relperc, select((segment*3)+1, ...)
end

function addon.ColorGradient(...)
	local relperc, r1, g1, b1, r2, g2, b2 = ColorsAndPercent(...)
	if not relperc then return r1, g1, b1 end
	local h1, c1, y1 = RGBToHCY(r1, g1, b1)
	local h2, c2, y2 = RGBToHCY(r2, g2, b2)
	local c = c1 + (c2-c1) * relperc
	local y = y1 + (y2-y1) * relperc
	if h1 and h2 then
		local dh = h2 - h1
		if dh < -0.5  then
			dh = dh + 1
		elseif dh > 0.5 then
			dh = dh - 1
		end
		return HCYtoRGB((h1 + dh * relperc) % 1, c, y)
	else
		return HCYtoRGB(h1 or h2, c, y)
	end
end

------------------------------------------------------------------------------
-- List & set helpers
------------------------------------------------------------------------------

local function ConcatLists(a, b)
	for i, v in ipairs(b) do
		tinsert(a, v)
	end
	return a
end
addon.ConcatLists = ConcatLists

local FlattenList
do
	local function Flatten0(a, b)
		for i, v in ipairs(b) do
			if type(v) == "table" then
				Flatten0(a, v)
			else
				tinsert(a, v)
			end
		end
		return a
	end

	function FlattenList(l) return Flatten0({}, l) end
end
addon.FlattenList = FlattenList

local function AsList(value, checkType, callLevel)
	if type(value) == "table" then
		value = FlattenList(value)
		if checkType then
			for i, v in ipairs(value) do
				if type(v) ~= checkType then
					error(format("Invalid value type, expected %s, got %s", checkType, type(v)), callLevel+1)
				end
			end
		end
		return value
	elseif checkType == nil or type(value) == checkType then
		return { value }
	else
		error(format("Invalid value type, expected %s, got %s", checkType, type(value)), callLevel+1)
	end
end
addon.AsList = AsList

local function AsSet(value, checkType, callLevel)
	local set = {}
	local size = 0
	for i, value in ipairs(AsList(value, checkType, callLevel+1)) do
		if not set[value] then
			set[value] = true
			size = size + 1
		end
	end
	return set, size
end
addon.AsSet = AsSet

local function MergeSets(a, b)
	for k in pairs(b) do
		a[k] = true
	end
	return a
end
addon.MergeSets = MergeSets
