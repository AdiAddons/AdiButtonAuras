--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2023 Adirelle (adirelle@gmail.com)
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
along with AdiButtonAuras. If not, see <http://www.gnu.org/licenses/>.
--]]

local addonName, addon = ...

local _G = _G
local GetAuraDataByAuraInstanceID = _G.C_UnitAuras.GetAuraDataByAuraInstanceID
local GetAuraDataBySlot = _G.C_UnitAuras.GetAuraDataBySlot
local IsAuraFilteredOutByInstanceID = _G.C_UnitAuras.IsAuraFilteredOutByInstanceID
local next = _G.next
local rawget = _G.rawget
local setmetatable = _G.setmetatable
local wipe = _G.wipe
local type = _G.type
local UnitAuraSlots = _G.UnitAuraSlots
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

local function ProcessAura(data, aura)
	aura.count = data.applications
	aura.dispel = data.dispelName == '' and 'Enrage' or data.dispelName
	aura.expiration = data.expirationTime
	aura.id = data.spellId

	return aura
end

local empty = {}
local aurasMetatable = {
	__index = {
		CheckGUID = function (self)
			if self.__guid ~= UnitGUID(self.__unit) then
				self:Update()
			end

			return self
		end,
		Update = function (self, info)
			self.__guid = UnitGUID(self.__unit)

			if not self.__guid then
				for k, v in next, self do
					if type(k) == 'number' then
						self[k] = del(v)
					end
				end

				return
			end

			if not info or info.isFullUpdate then
				self:FullUpdate(self.__unit, self.__filter)
			else
				if type(info) ~= 'table' then print('Unexpected info', info) end
				self:IncrementalUpdate(self.__unit, self.__filter, info)
			end
		end,
		FullUpdate = function (self, unit, filter)
			for k, v in next, self do
				if type(k) == 'number' then
					self[k] = del(v)
				end
			end

			local slots = { UnitAuraSlots(unit, filter) }
			for i = 2, #slots do
				local data = GetAuraDataBySlot(unit, slots[i])

				self[data.auraInstanceID] = ProcessAura(data, new())
			end
		end,
		IncrementalUpdate = function (self, unit, filter, info)
			for _, data in next, info.addedAuras or empty do
				if not IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, filter) then
					self[data.auraInstanceID] = ProcessAura(data, new())
				end
			end

			for _, auraInstanceID in next, info.updatedAuraInstanceIDs or empty do
				if not IsAuraFilteredOutByInstanceID(unit, auraInstanceID, filter) then
					self[auraInstanceID] = ProcessAura(
						GetAuraDataByAuraInstanceID(unit, auraInstanceID),
						rawget(self, auraInstanceID) or new()
					)
				end
			end

			for _, auraInstaceID in next, info.removedAuraInstanceIDs or empty do
				local aura = rawget(self, auraInstaceID)

				if aura then
					self[auraInstaceID] = del(aura)
				end
			end
		end,
		GetById = function (self, id)
			for k, v in next, self do
				if type(k) == 'number' and v.id == id then
					return v
				end
			end
		end,
	}
}

local function UpdateUnit(self, info)
	for _, auras in next, self do
		if type(auras) == 'table' then
			auras:Update(info)
		end
	end
end

local mts = {
	PlayerBuff = {
		filter = 'HELPFUL PLAYER',
		metatable = aurasMetatable
	},
	PlayerDebuff = {
		filter = 'HARMFUL PLAYER',
		metatable = aurasMetatable
	},
	Buff = {
		filter = 'HELPFUL',
		metatable = aurasMetatable
	},
	Debuff = {
		filter = 'HARMFUL',
		metatable = aurasMetatable
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

local eventFrame = _G.CreateFrame('Frame')
eventFrame:SetScript('OnEvent', function(self, event, unit, info)
	if event == 'UNIT_AURA' then
		if rawget(cache, unit) then
			cache[unit]:Update(info)
		end
	elseif event == 'PLAYER_REGEN_ENABLED' then
		wipe(cache) -- TODO: why?
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
			return nextIndex, aura.id, aura.count, aura.expiration, aura.dispel
		end
	until not nextIndex
end
local function NOP() end

local getters = {}
local iterators = {}

for key in next, mts do
	getters[key] = function(unit, id)
		if unit and UnitExists(unit) then
			local aura = cache[unit][key]:CheckGUID():GetById(id)
			if aura then
				return id, aura.count, aura.expiration, aura.dispel
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
for suffix, getter in next, getters do
	addon.AuraTools["Get"..suffix] = getter
end
for suffix, iterator in next, iterators do
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
