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

if select(2, UnitClass("player")) ~= "SHAMAN" then return end

local addonName, addon = ...

-- Globals: AddRuleFor Configure SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding shaman rules')

	local format = _G.format
	local GetSpellInfo = _G.GetSpellInfo
	local select = _G.select
	local UnitAura = _G.UnitAura
	local UnitClass = _G.UnitClass

	local L = addon.L
	local lightningShield = GetSpellInfo(324)

	return {
		ImportPlayerSpells { "SHAMAN" },
		Configure {
			lightningShield,
			format(L['Show %s stacks.'], lightningShield),
			8042, -- Earth Shock
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, _, _, count = UnitAura("player", lightningShield, nil, "HELPFUL PLAYER")
				if found then
					model.count = count
				end
			end,
			88766, -- Provided by: Fulmination
		},
		Configure {
			"FireTotems",
			format(L["Show %s duration."], L["fire totems"]),
			{3599, 8190, 2894}, -- Searing, Magma, Fire Elemental Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(units, model)
				local haveTotem, name, startTime, duration, icon = GetTotemInfo(FIRE_TOTEM_SLOT)
				if haveTotem then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
			{3599, 8190, 2894},
		},
		Configure {
			"EarthTotems",
			format(L["Show %s duration."], L["earth totems"]),
			{2484, 8143, 51485, 108270, 2062}, -- Earthbind, Tremor, Earthgrab, Stone Bulwark, Earth Elemental Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(units, model)
				local haveTotem, name, startTime, duration, icon = GetTotemInfo(EARTH_TOTEM_SLOT)
				if haveTotem then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
			{2484, 8143, 51485, 108270, 2062},
		},
		Configure {
			"WaterTotems",
			format(L["Show %s duration."], L["water totems"]),
			{16190, 108280, 5394}, -- Mana Tide, Healing Tide, Healing Stream Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(units, model)
				local haveTotem, name, startTime, duration, icon = GetTotemInfo(WATER_TOTEM_SLOT)
				if haveTotem then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
			{16190, 108280, 5394},
		},
		Configure {
			"AirTotems",
			format(L["Show %s duration."], L["air totems"]),
			{98008, 120668, 108269, 8177, 108273}, -- Spirit Link, Stormlash, Capacitator, Grounding, Windwalk Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(units, model)
				local haveTotem, name, startTime, duration, icon = GetTotemInfo(AIR_TOTEM_SLOT)
				if haveTotem then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
			{98008, 120668, 108269, 8177, 108273},
		},
	}
end)
