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

if not addon.isClass("ROGUE") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding rogue rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			"ROGUE",
			-- except
			192425, -- Surge of Toxins (Assassination artifact) (not game changing)
			192432, -- From the Shadows (Assassination artifact) (to emphasize Vendetta's debuff)
			192925, -- Blood of the Assassinated (Assassination artifact) (completely within Rupture's own debuff)
			193538, -- Alacity (not game changing)
			206760, -- Night Terrors (to emphasize Nightblade's DoT)
		},

		ShowPower {
			{
				   408, -- Kidney Shot
				  1943, -- Rupture
				  2098, -- Run Through
				  5171, -- Slice and Dice
				 32645, -- Envenom
				152150, -- Death from Above
				193316, -- Roll the Bones
				195452, -- Nightblade
				196819, -- Eviscerate
				199804, -- Between the Eyes
				206237, -- Enveloping Shadows
			},
			"COMBO_POINTS",
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
