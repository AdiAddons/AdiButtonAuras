--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2016 Adirelle (adirelle@gmail.com)
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

if not addon.isClass("DEATHKNIGHT") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding deathknight rules')

	return {
		ImportPlayerSpells { "DEATHKNIGHT" },
		-- show the stacks of Razorice on Frost Strike if Shattering Strikes is known
		ShowStacks {
			49143, -- Frost Strike
			51714, -- Razorice
			5, -- max
			"enemy",
			nil,
			nil,
			207057, -- Shattering Strikes
		},

		Configure {
			"BurstFesteringWound",
			format(L["%s when %s has %d or more stacks"], DescribeHighlight("hint"), GetSpellInfo(194310), 7), -- Festering Wound
			{
				 55090, -- Scourge Strike
				207311, -- Clawing Shadows
			},
			"enemy",
			"UNIT_AURA",
			function(units, model)
				local found, count = GetPlayerDebuff(units.enemy, 194310) -- Festering Wound
				if found and count >= 7 then
					model.hint = true
				end
			end,
		},

		Configure {
			"SummonGargoyle",
			format("%s when you summoned either your Gargoyle or Dark Arbiter.", DescribeHighlight("good")),
			{
				 49206, -- Summon Gargoyle
				207349, -- Dark Arbiter
			},
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(_, model)
				local found, _, startTime, duration = GetTotemInfo(3) -- both are always the third totem
				if found then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
		},

		Configure {
			"RaiseDead",
			format(L["%s when you don't have a summoned ghoul."], DescribeHighlight("hint")),
			46584,
			"player",
			"UNIT_PET",
			function(_, model)
				if HasPetSpells() then
					model.highlight = "good"
				else
					model.hint = true
				end
			end,
		},
	}
end)

-- ABA
-- GLOBALS: AddRuleFor BuffAliases BuildAuraHandler_FirstOf BuildAuraHandler_Longest
-- GLOBALS: BuildAuraHandler_Single BuildDesc BuildKey Configure DebuffAliases Debug
-- GLOBALS: DescribeAllSpells DescribeAllTokens DescribeFilter DescribeHighlight
-- GLOBALS: DescribeLPSSource GetBuff GetDebuff GetLib GetPlayerBuff GetPlayerDebuff
-- GLOBALS: ImportPlayerSpells IterateBuffs IterateDebuffs IteratePlayerBuffs
-- GLOBALS: IteratePlayerDebuffs L LongestDebuffOf PassiveModifier PetBuffs PLAYER_CLASS
-- GLOBALS: SelfBuffAliases SelfBuffs SharedSimpleBuffs SharedSimpleDebuffs ShowPower
-- GLOBALS: ShowStacks SimpleBuffs SimpleDebuffs

-- WoW API
-- GLOBALS: GetNumGroupMembers GetRuneCooldown GetShapeshiftFormID GetSpellCharges
-- GLOBALS: GetSpellBonusHealing GetSpellInfo GetTime GetTotemInfo HasPetSpells
-- GLOBALS: IsPlayerSpell UnitCanAttack UnitCastingInfo UnitChannelInfo UnitClass
-- GLOBALS: UnitHealth UnitHealthMax UnitIsDeadOrGhost UnitIsPlayer UnitName UnitPower
-- GLOBALS: UnitPowerMax UnitStagger

-- Lua API
-- GLOBALS: bit ceil floor format ipairs math min pairs print select string table
-- GLOBALS: tinsert type
