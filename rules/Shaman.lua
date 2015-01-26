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

local _, addon = ...

if not addon.isClass("SHAMAN") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding shaman rules')

	local lightningShield = GetSpellInfo(324)

	local function BuildTotemHandler(totemSlot)
		return function(units, model)
			local haveTotem, name, startTime, duration, icon = GetTotemInfo(totemSlot)
			if haveTotem and name == GetSpellInfo(model.actionId) then
				model.highlight = "good"
				model.expiration = startTime + duration
			end
		end
	end

	return {
		ImportPlayerSpells { "SHAMAN" },
		ShowStacks {
			8042,     -- Earth Shock
			324,      -- Lightning Shield
			20,       -- Max 20 stacks
			"player",
			nil,
			nil,
			88766,    -- Provided by: Fulmination
		},
		Configure {
			"FireTotems",
			format(L["Show %s duration."], L["fire totems"]),
			{3599, 8190, 2894}, -- Searing, Magma, Fire Elemental Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			-- GLOBALS: FIRE_TOTEM_SLOT
			BuildTotemHandler(FIRE_TOTEM_SLOT),
			{3599, 8190, 2894},
		},
		Configure {
			"EarthTotems",
			format(L["Show %s duration."], L["earth totems"]),
			{2484, 8143, 51485, 108270, 2062}, -- Earthbind, Tremor, Earthgrab, Stone Bulwark, Earth Elemental Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			-- GLOBALS: EARTH_TOTEM_SLOT
			BuildTotemHandler(EARTH_TOTEM_SLOT),
			{2484, 8143, 51485, 108270, 2062},
		},
		Configure {
			"WaterTotems",
			format(L["Show %s duration."], L["water totems"]),
			{108280, 5394}, -- Healing Tide, Healing Stream Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			-- GLOBALS: WATER_TOTEM_SLOT
			BuildTotemHandler(WATER_TOTEM_SLOT),
			{108280, 5394},
		},
		Configure {
			"AirTotems",
			format(L["Show %s duration."], L["air totems"]),
			{98008, 108269, 8177, 108273}, -- Spirit Link, Capacitator, Grounding, Windwalk Totem
			"player",
			"PLAYER_TOTEM_UPDATE",
			-- GLOBALS: AIR_TOTEM_SLOT
			BuildTotemHandler(AIR_TOTEM_SLOT),
			{98008, 108269, 8177, 108273},
		},
		PassiveModifier {
			77762, -- Lava Surge
			51505, -- Lava Burst
			77762, -- Lava Surge
			"player",
			"flash"
		}
	}
end)

-- GLOBALS: AddRuleFor BuffAliases BuildAuraHandler_FirstOf BuildAuraHandler_Longest
-- GLOBALS: BuildAuraHandler_Single BuildDesc BuildKey Configure DebuffAliases Debug
-- GLOBALS: DescribeAllSpells DescribeAllTokens DescribeFilter DescribeHighlight
-- GLOBALS: DescribeLPSSource GetComboPoints GetEclipseDirection GetNumGroupMembers
-- GLOBALS: GetShapeshiftFormID GetSpellBonusHealing GetSpellInfo GetTime
-- GLOBALS: GetTotemInfo HasPetSpells ImportPlayerSpells L LongestDebuffOf
-- GLOBALS: PLAYER_CLASS PassiveModifier PetBuffs SelfBuffAliases SelfBuffs
-- GLOBALS: SharedSimpleBuffs SharedSimpleDebuffs ShowPower SimpleBuffs
-- GLOBALS: SimpleDebuffs UnitCanAttack UnitCastingInfo UnitChannelInfo UnitClass
-- GLOBALS: UnitHealth UnitHealthMax UnitIsDeadOrGhost UnitIsPlayer UnitPower
-- GLOBALS: UnitPowerMax UnitStagger bit ceil floor format ipairs math min pairs
-- GLOBALS: print select string table tinsert GetPlayerBuff ShowStacks
