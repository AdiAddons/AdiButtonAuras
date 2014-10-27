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
local CreateFrame = _G.CreateFrame
local ipairs = _G.ipairs
local next = _G.next
local pairs = _G.pairs
local rawget = _G.rawget
local setmetatable = _G.setmetatable
local UnitAura = _G.UnitAura
local wipe = _G.wipe
local math = _G.math
local GetTime = _G.GetTime
local type = _G.type
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID

local Debug = function(...) addon.Debug('AuraTools', ...) end

------------------------------------------------------------------------------
-- Table recycling
------------------------------------------------------------------------------

local new, del
do
	local heap = setmetatable({}, { __mode = 'k' })

	function new()
		local t = next(heap)
		if not t then return {} end
		heap[t] = nil
		return t
	end

	function del(t)
		if t then
			heap[t] = true
		end
	end
end

------------------------------------------------------------------------------
-- Prototypes
------------------------------------------------------------------------------

local function UpdateAuras(self)
	self.__guid = UnitGUID(self.__unit)
	if not self.__guid then
		for k, v in pairs(self) do
			if type(k) == "number" then
				self[k] = del(v)
			end
		end
		return
	end
	return self:_Update(self.__unit, self.__filter)
end

local function CheckGUID(self)
	if self.__guid ~= UnitGUID(self.__unit) then
		self:Update()
	end
	return self
end

local playerAurasMetatable = {
	__index = {
		Update = UpdateAuras,
		CheckGUID = CheckGUID,
		_Update = function(self, unit, filter)
			local serial = GetTime()
			for index = 1, math.huge do
				local name, _, _, count, _, _, expiration, _, _, _, id = UnitAura(unit, index, filter)
				if not name then
					break
				end
				local aura = rawget(self, id)
				if not aura then
					aura = new()
					self[id] = aura
				end
				aura.count = count
				aura.expiration = expiration
				aura.id = id
				aura.serial = serial
			end
			for id, aura in pairs(self) do
				if type(id) == "number" and aura.serial ~= serial then
					self[id] = del(aura)
				end
			end
			return self
		end,
		GetById = function(self, id)
			return rawget(self, id)
		end,
	}
}

local allAurasMetatable = {
	__index = {
		Update = UpdateAuras,
		CheckGUID = CheckGUID,
		_Update = function(self, unit, filter)
			for index = 1, math.huge do
				local name, _, _, count, _, _, expiration, _, _, _, id = UnitAura(unit, index, filter)
				if not name then
					for i = index, #self do
						self[i] = del(rawget(self, i))
					end
					return
				end
				local aura = rawget(self, index)
				if not aura then
					aura = new()
					self[index] = aura
				end
				aura.count = count
				aura.expiration = expiration
				aura.id = id
			end
			return self
		end,
		GetById = function(self, id)
			for i, aura in ipairs(self) do
				if aura.id == id then
					return aura
				end
			end
		end,
	}
}

local function UpdateUnit(self)
	for _, auras in pairs(self) do
		if type(auras) == "table" then
			auras:Update()
		end
	end
end

local mts = {
	PlayerBuff = {
		filter = 'HELPFUL PLAYER',
		metatable = playerAurasMetatable
	},
	PlayerDebuff = {
		filter = 'HARMFUL PLAYER',
		metatable = playerAurasMetatable
	},
	Buff = {
		filter = 'HELPFUL',
		metatable = allAurasMetatable
	},
	Debuff = {
		filter = 'HARMFUL',
		metatable = allAurasMetatable
	},
}

local unitMetatable = {
	__index = function(self, key)
		if key == 'Update' then
			return UpdateUnit
		elseif key and mts[key] then
			Debug('Spawning', key, 'cache for', self.__unit)
			local auras = setmetatable(
				{
					__unit = self.__unit,
					__filter = mts[key].filter,
				},
				mts[key].metatable
			)
			auras:Update()
			self[key] = auras
			return auras
		end
	end
}

------------------------------------------------------------------------------
-- The cache and its updater
------------------------------------------------------------------------------

local cache = setmetatable({}, {
	__index = function(self, unit)
		Debug('Spawning cache for', unit)
		local unitAuras = setmetatable({__unit = unit}, unitMetatable)
		self[unit] = unitAuras
		return unitAuras
	end
})

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript('OnEvent', function(self, event, unit)
	if event == 'UNIT_AURA' then
		if rawget(cache, unit) then
			cache[unit]:Update()
		end
	elseif event == 'PLAYER_REGEN_ENABLED' then
		wipe(cache)
	end
end)
eventFrame:RegisterEvent('UNIT_AURA')
eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')

------------------------------------------------------------------------------
-- Accessors
------------------------------------------------------------------------------

local function auraIterator(auras, index)
	local nextIndex, aura = index
	repeat
		nextIndex, aura = next(auras, nextIndex)
		if type(nextIndex) == "number" then
			return nextIndex, aura.id, aura.count, aura.expiration
		end
	until not nextIndex
end
local function NOP() end

local getters = {}
local iterators = {}

for key in pairs(mts) do
	local key = key
	getters[key] = function(unit, id)
		if unit and UnitExists(unit) then
			local aura = cache[unit][key]:CheckGUID():GetById(id)
			if aura then
				return id, aura.count, aura.expiration
			end
		end
	end
	iterators[key] = function(unit)
		if not unit or not UnitExists(unit) then return NOP end
		return auraIterator, cache[unit][key]:CheckGUID()
	end
end

------------------------------------------------------------------------------
-- Filter parser, memoized
------------------------------------------------------------------------------

local parsedFilter = addon.Memoize(function(filter)
	return (filter:match('PLAYER') and 'Player' or '') ..
		(filter:match('HARMFUL') and 'Debuff' or 'Buff')
end)

------------------------------------------------------------------------------
-- Functions for the rule environment
------------------------------------------------------------------------------

addon.AuraTools = {
	GetAura = function(unit, id, filter)
		return getters[parsedFilter[filter]](unit, id)
	end,
	IterateAuras = function(unit, filter)
		return iterators[parsedFilter[filter]](unit)
	end
}
for suffix, getter in pairs(getters) do
	addon.AuraTools["Get"..suffix] = getter
end
for suffix, iterator in pairs(iterators) do
	addon.AuraTools["Iterate"..suffix.."s"] = iterator
end

------------------------------------------------------------------------------
-- Helpers to build rules
------------------------------------------------------------------------------

function addon.GetAuraGetter(filter)
	return getters[parsedFilter[filter]]
end

function addon.GetAuraIterator(filter)
	return iterators[parsedFilter[filter]]
end
